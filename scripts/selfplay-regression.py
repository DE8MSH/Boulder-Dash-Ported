#!/usr/bin/env python3
"""Headless Boulder Dash gameplay regression.

Uses the C64 demo packet format (high nibble = MoveTiles duration, low nibble =
joystick direction), then drives a reference model of the shared Cave 1 core to
completion. After the first clean completion it repeats the run with
deterministic pseudo-random forced deaths to exercise life loss and respawn.

This is intentionally host-side: no emulator GUI or GitHub Actions required.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
import argparse
import importlib.util
from pathlib import Path
import random
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

T_EMPTY = 0x00
T_SOIL = 0x01
T_BRICK = 0x02
T_EXIT_CLOSED = 0x04
T_EXIT_OPEN = 0x05
T_STEEL = 0x07
T_BOULDER_FIXED = 0x10
T_BOULDER_FIXED_MARK = 0x11
T_BOULDER_FALL = 0x12
T_BOULDER_FALL_MARK = 0x13
T_DIAMOND_FIXED = 0x14
T_DIAMOND_FIXED_MARK = 0x15
T_DIAMOND_FALL = 0x16
T_DIAMOND_FALL_MARK = 0x17
T_XPL_EMPTY0 = 0x1B
T_XPL_EMPTY1 = 0x1C
T_XPL_EMPTY2 = 0x1D
T_XPL_EMPTY3 = 0x1E
T_XPL_EMPTY4 = 0x1F
T_ROCKFORD = 0x38
T_ROCKFORD_MARK = 0x39

JOY_RIGHT = 0x07
JOY_LEFT = 0x0B
JOY_DOWN = 0x0D
JOY_UP = 0x0E
JOY_IDLE = 0x0F
VALID_JOY = {JOY_RIGHT, JOY_LEFT, JOY_DOWN, JOY_UP, JOY_IDLE}

COLS = 40
ROWS = 22
PLAYER_X = 3
PLAYER_Y = 4
DIAMONDS_NEEDED = 12
INITIAL_LIVES = 3
MAX_STEPS = 2000


def load_cave_builder():
    path = ROOT / "scripts" / "generate-cave1.py"
    spec = importlib.util.spec_from_file_location("generate_cave1", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module.build_full_cave


BUILD_FULL_CAVE = load_cave_builder()


def parse_c64_demo(path: Path) -> list[int]:
    text = path.read_text(encoding="utf-8", errors="replace")
    values = []
    in_table = False
    for line in text.splitlines():
        if "TabDemoMoves" in line:
            in_table = True
        if not in_table:
            continue
        m = re.search(r"\.(?:byte|BYTE)\s+\$([0-9a-fA-F]{2})", line)
        if m:
            value = int(m.group(1), 16)
            if value == 0:
                break
            values.append(value)
    if not values:
        raise AssertionError("C64 demo stream not found")
    for value in values:
        duration = value >> 4
        joy = value & 0x0F
        if duration == 0:
            raise AssertionError(f"invalid zero-duration demo packet ${value:02x}")
        if joy not in VALID_JOY:
            raise AssertionError(f"unknown C64 demo joystick nibble ${joy:x}")
    return values


def expand_packets(packets: list[int]) -> list[int]:
    moves = []
    for value in packets:
        moves.extend([value & 0x0F] * (value >> 4))
    return moves


def compress_moves(moves: list[int]) -> list[int]:
    if not moves:
        return []
    packets: list[int] = []
    current = moves[0]
    count = 0
    for move in moves:
        if move == current and count < 15:
            count += 1
            continue
        packets.append((count << 4) | current)
        current = move
        count = 1
    packets.append((count << 4) | current)
    return packets


@dataclass
class RunResult:
    complete: bool
    steps: int
    diamonds: int
    lives: int
    deaths: int
    moves: list[int]


class CoreModel:
    """Reference mirror of the currently shared Cave 1 gameplay rules."""

    def __init__(self, lives: int = INITIAL_LIVES):
        self.lives = lives
        self.deaths = 0
        self.score = 0
        self.random_value = 0x5A
        self.phys_counter = 0
        self.reset_attempt()

    def reset_attempt(self) -> None:
        self.cave = [row[:] for row in BUILD_FULL_CAVE()]
        self.cave[PLAYER_Y][PLAYER_X] = T_ROCKFORD
        self.player_x = PLAYER_X
        self.player_y = PLAYER_Y
        self.alive = True
        self.exit_open = False
        self.diamonds = 0

    def get(self, x: int, y: int) -> int:
        return self.cave[y][x]

    def set(self, x: int, y: int, tile: int) -> None:
        self.cave[y][x] = tile

    def next_random(self) -> int:
        value = self.random_value
        carry = 1 if value & 0x80 else 0
        value = (value << 1) & 0xFF
        if carry:
            value ^= 0x1D
        value ^= self.phys_counter
        value = (value + 0x17 + carry) & 0xFF
        self.random_value = value
        return value

    @staticmethod
    def rounded(tile: int) -> bool:
        return tile in (T_BOULDER_FIXED, T_DIAMOND_FIXED, T_BRICK)

    def mark_normalize(self) -> None:
        replace = {
            T_BOULDER_FIXED_MARK: T_BOULDER_FIXED,
            T_BOULDER_FALL_MARK: T_BOULDER_FALL,
            T_DIAMOND_FIXED_MARK: T_DIAMOND_FIXED,
            T_DIAMOND_FALL_MARK: T_DIAMOND_FALL,
            T_ROCKFORD_MARK: T_ROCKFORD,
            T_XPL_EMPTY0: T_XPL_EMPTY1,
            T_XPL_EMPTY1: T_XPL_EMPTY2,
            T_XPL_EMPTY2: T_XPL_EMPTY3,
            T_XPL_EMPTY3: T_XPL_EMPTY4,
            T_XPL_EMPTY4: T_EMPTY,
        }
        for y in range(ROWS):
            for x in range(COLS):
                tile = self.cave[y][x]
                if tile in replace:
                    self.cave[y][x] = replace[tile]

    def open_exit(self) -> None:
        self.exit_open = True
        for y in range(ROWS):
            for x in range(COLS):
                if self.cave[y][x] == T_EXIT_CLOSED:
                    self.cave[y][x] = T_EXIT_OPEN

    def move_object(self, x: int, y: int, tx: int, ty: int, tile: int) -> None:
        self.set(x, y, T_EMPTY)
        self.set(tx, ty, tile)

    def try_roll(self, x: int, y: int, fall_tile: int) -> bool:
        if x != 1 and self.get(x - 1, y) == T_EMPTY and self.get(x - 1, y + 1) == T_EMPTY:
            self.move_object(x, y, x - 1, y + 1, fall_tile)
            return True
        if x != 38 and self.get(x + 1, y) == T_EMPTY and self.get(x + 1, y + 1) == T_EMPTY:
            self.move_object(x, y, x + 1, y + 1, fall_tile)
            return True
        return False

    def player_move(self, joy: int) -> None:
        direction = {
            JOY_LEFT: (-1, 0),
            JOY_RIGHT: (1, 0),
            JOY_UP: (0, -1),
            JOY_DOWN: (0, 1),
        }.get(joy)
        if direction is None:
            return
        dx, dy = direction
        tx = self.player_x + dx
        ty = self.player_y + dy
        target = self.get(tx, ty)

        if target == T_BOULDER_FIXED and dy == 0:
            bx = tx + dx
            if self.get(bx, ty) != T_EMPTY or (self.next_random() & 3) != 0:
                return
            self.set(bx, ty, T_BOULDER_FIXED_MARK)
        elif target not in (T_EMPTY, T_SOIL, T_DIAMOND_FIXED, T_EXIT_OPEN):
            return

        if target == T_DIAMOND_FIXED:
            self.diamonds += 1
            self.score += 10 if self.diamonds <= DIAMONDS_NEEDED else 15
            if self.diamonds == DIAMONDS_NEEDED:
                self.open_exit()

        self.set(self.player_x, self.player_y, T_EMPTY)
        self.set(tx, ty, T_ROCKFORD_MARK)
        self.player_x = tx
        self.player_y = ty

    def cave_pass(self, joy: int) -> None:
        if not self.alive:
            return
        self.phys_counter = (self.phys_counter + 1) % 3
        self.mark_normalize()

        for y in range(1, 21):
            for x in range(1, 39):
                tile = self.get(x, y)
                if tile == T_BOULDER_FIXED:
                    below = self.get(x, y + 1)
                    if below == T_EMPTY:
                        self.move_object(x, y, x, y + 1, T_BOULDER_FALL_MARK)
                    elif self.rounded(below):
                        self.try_roll(x, y, T_BOULDER_FALL_MARK)

                elif tile == T_BOULDER_FALL:
                    below = self.get(x, y + 1)
                    if below == T_ROCKFORD:
                        self.alive = False
                        return
                    if below == T_EMPTY:
                        self.move_object(x, y, x, y + 1, T_BOULDER_FALL_MARK)
                    elif self.rounded(below) and self.try_roll(x, y, T_BOULDER_FALL_MARK):
                        pass
                    else:
                        self.set(x, y, T_BOULDER_FIXED_MARK)

                elif tile == T_DIAMOND_FIXED:
                    below = self.get(x, y + 1)
                    if below == T_EMPTY:
                        self.move_object(x, y, x, y + 1, T_DIAMOND_FALL_MARK)
                    elif self.rounded(below):
                        self.try_roll(x, y, T_DIAMOND_FALL_MARK)

                elif tile == T_DIAMOND_FALL:
                    below = self.get(x, y + 1)
                    if below == T_ROCKFORD:
                        self.alive = False
                        return
                    if below == T_EMPTY:
                        self.move_object(x, y, x, y + 1, T_DIAMOND_FALL_MARK)
                    elif self.rounded(below) and self.try_roll(x, y, T_DIAMOND_FALL_MARK):
                        pass
                    else:
                        self.set(x, y, T_DIAMOND_FIXED_MARK)

                elif tile == T_ROCKFORD:
                    self.player_move(joy)

    def completed(self) -> bool:
        return self.exit_open and (self.player_x, self.player_y) == (38, 18)

    def force_death_and_respawn(self) -> None:
        if not self.alive:
            return
        self.alive = False
        self.deaths += 1
        self.lives -= 1
        if self.lives > 0:
            for _ in range(5):
                self.mark_normalize()
            self.reset_attempt()


def choose_move(model: CoreModel) -> int:
    """Greedy safe route to the nearest required diamond, then the exit."""
    start = (model.player_x, model.player_y)
    if model.exit_open:
        targets = {
            (x, y)
            for y in range(ROWS)
            for x in range(COLS)
            if model.get(x, y) == T_EXIT_OPEN
        }
    else:
        targets = {
            (x, y)
            for y in range(ROWS)
            for x in range(COLS)
            if model.get(x, y) == T_DIAMOND_FIXED
        }

    queue = deque([start])
    previous = {start: None}
    first_move: dict[tuple[int, int], int] = {}
    directions = (
        (-1, 0, JOY_LEFT),
        (1, 0, JOY_RIGHT),
        (0, -1, JOY_UP),
        (0, 1, JOY_DOWN),
    )

    while queue:
        pos = queue.popleft()
        if pos in targets:
            cur = pos
            while previous[cur] is not None and previous[cur] != start:
                cur = previous[cur]
            if previous[cur] is None:
                return JOY_IDLE
            return first_move[cur]

        for dx, dy, joy in directions:
            nx = pos[0] + dx
            ny = pos[1] + dy
            nxt = (nx, ny)
            if not (1 <= nx <= 38 and 1 <= ny <= 20):
                continue
            if nxt in previous:
                continue
            tile = model.get(nx, ny)
            if tile not in (T_EMPTY, T_SOIL, T_DIAMOND_FIXED, T_EXIT_OPEN):
                continue
            previous[nxt] = pos
            first_move[nxt] = joy
            queue.append(nxt)

    return JOY_IDLE


def clean_run() -> RunResult:
    model = CoreModel()
    moves: list[int] = []
    for step in range(1, MAX_STEPS + 1):
        joy = choose_move(model)
        moves.append(joy)
        model.cave_pass(joy)
        if not model.alive:
            raise AssertionError(
                f"autoplayer died in clean run at step {step}, "
                f"pos=({model.player_x},{model.player_y}), diamonds={model.diamonds}"
            )
        if model.completed():
            return RunResult(True, step, model.diamonds, model.lives, model.deaths, moves)
    raise AssertionError("autoplayer did not complete Cave 1 within step limit")


def replay_packets(packets: list[int]) -> RunResult:
    model = CoreModel()
    moves: list[int] = []
    step = 0
    for packet in packets:
        duration = packet >> 4
        joy = packet & 0x0F
        for _ in range(duration):
            step += 1
            moves.append(joy)
            model.cave_pass(joy)
            if not model.alive:
                raise AssertionError(f"compressed autoplay replay died at step {step}")
            if model.completed():
                return RunResult(True, step, model.diamonds, model.lives, model.deaths, moves)
    raise AssertionError("compressed autoplay replay ended before cave completion")


def random_death_run(seed: int, death_count: int) -> RunResult:
    rng = random.Random(seed)
    model = CoreModel()
    moves: list[int] = []
    steps_since_spawn = 0
    next_death = rng.randint(18, 55)
    forced = 0

    for step in range(1, MAX_STEPS + 1):
        joy = choose_move(model)
        moves.append(joy)
        model.cave_pass(joy)
        steps_since_spawn += 1

        if not model.alive:
            model.deaths += 1
            model.lives -= 1
            if model.lives <= 0:
                raise AssertionError(f"game over before recovery, seed={seed}")
            model.reset_attempt()
            steps_since_spawn = 0
            next_death = rng.randint(18, 55)
            continue

        if forced < death_count and steps_since_spawn >= next_death:
            model.force_death_and_respawn()
            forced += 1
            if model.lives <= 0:
                raise AssertionError(f"forced deaths exhausted lives, seed={seed}")
            steps_since_spawn = 0
            next_death = rng.randint(18, 55)
            continue

        if model.completed():
            if forced != death_count:
                raise AssertionError(
                    f"completed before all forced deaths, seed={seed}, "
                    f"forced={forced}/{death_count}"
                )
            return RunResult(True, step, model.diamonds, model.lives, model.deaths, moves)

    raise AssertionError(f"death-injection run did not recover, seed={seed}")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--death-seed", type=lambda x: int(x, 0), default=0xB0D1)
    parser.add_argument("--death-runs", type=int, default=4)
    args = parser.parse_args()

    demo_packets = parse_c64_demo(ROOT / "B1_Demo.asm")
    demo_moves = expand_packets(demo_packets)
    if len(demo_moves) != 259:
        raise AssertionError(
            f"original C64 demo duration changed: expected 259 MoveTiles passes, got {len(demo_moves)}"
        )

    clean = clean_run()
    generated_packets = compress_moves(clean.moves)
    replay = replay_packets(generated_packets)
    if replay.steps != clean.steps:
        raise AssertionError(
            f"packet replay length mismatch: clean={clean.steps}, replay={replay.steps}"
        )

    print(
        f"autoplay clean: PASS ({clean.steps} cave passes, "
        f"{clean.diamonds} diamonds, {len(generated_packets)} demo-format packets)"
    )
    print(
        f"C64 demo decoder: PASS ({len(demo_packets)} packets, "
        f"{len(demo_moves)} MoveTiles passes)"
    )

    for index in range(args.death_runs):
        seed = args.death_seed + index
        deaths = 1 + (index & 1)
        result = random_death_run(seed, deaths)
        print(
            f"autoplay deaths[{index}]: PASS "
            f"(seed=${seed:04x}, forced={deaths}, total_deaths={result.deaths}, "
            f"lives={result.lives}, steps={result.steps})"
        )

    print("autoplay regression: PASS")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except AssertionError as exc:
        print(f"autoplay regression: FAIL: {exc}", file=sys.stderr)
        raise SystemExit(1)
