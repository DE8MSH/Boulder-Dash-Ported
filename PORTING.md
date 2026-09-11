# Boulder Dash I — SNES / PC Engine port

This repository contains a C64/6502 reconstruction of Boulder Dash I. The port keeps the original sources as the reference implementation and introduces a small platform boundary for console-specific hardware.

## Port strategy

The original code directly references C64 VIC-II, SID, CIA, KERNAL and C64 memory-map symbols. Those accesses must not leak into the portable game logic.

The port is split into three layers:

- the existing root-level C64 sources remain untouched as the behavioural reference;
- `src/common/` contains shared constants, ABI definitions and hardware-independent game logic/data extracted incrementally from the original 6502 code;
- `src/snes/` and `src/pce/` contain the platform implementations.

Both target CPUs are close relatives of the 6502: SNES uses the 65C816 and PC Engine uses the HuC6280. The project starts with `ca65`, which supports both instruction sets.

See `PORT_MAP.md` for the live C64 -> SNES/PCE replacement table.

## Current implementation

### Common

- shared logical controller bit layout;
- portable `game_init` / `game_tick` bootstrap;
- current/previous/newly-pressed input state;
- video begin/end hooks;
- audio tick retained as a deferred no-op hook.

### SNES

- switches the 65C816 into native mode while keeping A/X/Y 8-bit for a 6502-like porting environment;
- Direct Page initialized to `$0000`;
- controller auto-read enabled;
- frame boundary currently polled through `HVBJOY` rather than NMI;
- SNES pad directions/B/Start/Select mapped to the common ABI;
- display remains force-blanked until valid tile/map data exists.

### PC Engine

- HuC6280 high-speed mode selected;
- standard 2-button controller scan implemented through `$1000` SEL/CLR I/O;
- directions/I/Run/Select mapped to the common ABI;
- VDC VBlank synchronization still pending because ROM/VDC initialization and vectors are not linked yet.

## Milestones

1. **Characterize the C64 source** — in progress
   - document zero-page and game-state memory
   - isolate cave simulation from VIC/SID/CIA access
   - identify frame/tick rate assumptions
   - verify cave/demo data formats

2. **Native startup + deterministic RAM map** — next
   - SNES ROM header/reset/vector/linker map
   - PC Engine HuCard reset/vector/linker map
   - clear/init platform RAM
   - implement PC Engine VDC frame synchronization

3. **Video**
   - SNES: BG tile map + VRAM upload + palette conversion
   - PC Engine: VDC BAT + pattern upload + palette conversion
   - translate the C64 character/tile representation into console-native tiles

4. **Portable simulation core**
   - migrate cave state transitions behind the common game loop
   - keep 8-bit overflow and update order compatible where gameplay depends on it
   - add deterministic input/replay hooks

5. **Full gameplay integration**
   - player movement
   - boulders/diamonds
   - enemies/explosions
   - amoeba/magic wall
   - score/time, title/menu/demo

6. **Audio — deliberately deferred, not dropped**
   - replace SID playback rather than trying to emulate raw SID register writes
   - SNES: SPC700/DSP driver / converted effects and music
   - PC Engine: PSG driver / converted effects and music

7. **Hardware validation**
   - validate in emulators and on real hardware/flash carts

## Shared platform ABI

`src/common/platform.inc` defines the entry points the portable core may call:

- `platform_init`
- `platform_wait_frame`
- `platform_read_pad`
- `platform_video_begin`
- `platform_video_end`
- `platform_audio_tick`

## Build prerequisites

Install a recent cc65 toolchain so `ca65` is available on `PATH`.

```sh
make check
make snes-obj
make pce-obj
```

Each target now assembles both `src/common/game.s` and its platform backend. ROM headers, linker maps and native startup code come next.

## Important source constraints

The original C64 source uses its own assembler dialect (`equ`, `dc.b`, `dc.w`, bracketed expressions and C64 include layout). It should not be mass-converted mechanically. Port behaviour first, then migrate individual modules/data with tests or replay comparisons.
