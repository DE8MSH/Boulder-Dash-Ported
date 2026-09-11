#!/usr/bin/env python3
"""Prepare the shared rule-based autoplay source for 65C816/HuC6280.

Besides placing the sizeable PCE strategy code in HuCard bank $01, this pass
adds navigation memory around the source-level strategy: progress/oscillation
detection, two temporary tabu goals, and a deterministic unstick move. This
keeps the C64-demo-inspired local movement style while preventing the player
from chasing the same unreachable Manhattan-nearest target forever.
"""

from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text()

# Autoplay needs the cave number only to reset navigation memory on transitions.
old = ".import game_game_over\n"
new = ".import game_game_over\n.import game_current_cave\n"
if old not in src:
    raise SystemExit("autoplayer import marker not found")
src = src.replace(old, new, 1)

# Navigation memory. Two tabu slots are enough to break the common A<->B goal
# oscillation without permanently excluding a diamond; timers make both goals
# eligible again later after the cave has changed around them.
old = "ai_wall_flip:    .res 1\n"
new = """ai_wall_flip:    .res 1
ai_seen_cave:    .res 1
ai_seen_valid:   .res 1
ai_obs_x:        .res 1
ai_obs_y:        .res 1
ai_prev_x:       .res 1
ai_prev_y:       .res 1
ai_obs_valid:    .res 1
ai_stuck_count:  .res 1
ai_black1_x:     .res 1
ai_black1_y:     .res 1
ai_black1_time:  .res 1
ai_black2_x:     .res 1
ai_black2_y:     .res 1
ai_black2_time:  .res 1
"""
if old not in src:
    raise SystemExit("autoplayer BSS marker not found")
src = src.replace(old, new, 1)

# Do not select a temporarily blacklisted target in the Manhattan goal scan.
old = """    cmp ai_match_lo
    bcc @next
    cmp ai_match_end
    bcs @next

    lda ai_scan_x
"""
new = """    cmp ai_match_lo
    bcc @next
    cmp ai_match_end
    bcs @next

    lda ai_black1_time
    beq @black2
    lda ai_scan_x
    cmp ai_black1_x
    bne @black2
    lda ai_scan_y
    cmp ai_black1_y
    beq @next
@black2:
    lda ai_black2_time
    beq @distance
    lda ai_scan_x
    cmp ai_black2_x
    bne @distance
    lda ai_scan_y
    cmp ai_black2_y
    beq @next
@distance:
    lda ai_scan_x
"""
if old not in src:
    raise SystemExit("autoplayer goal scan marker not found")
src = src.replace(old, new, 1)

# A changed goal is a fresh navigation attempt; do not carry a stuck score or
# stale observed position from the previous target into it.
old = """    lda #1
    sta ai_goal_valid
    stz ai_detour_dir
    rts
@endproc_placeholder
"""
# Use a direct, less fragile replacement around the real routine tail.
real_old = """    lda #1
    sta ai_goal_valid
    stz ai_detour_dir
    rts
.endproc

.proc ai_prepare_dirs
"""
real_new = """    lda #1
    sta ai_goal_valid
    stz ai_detour_dir
    stz ai_stuck_count
    stz ai_obs_valid
    rts
.endproc

.proc ai_prepare_dirs
"""
if real_old not in src:
    raise SystemExit("autoplayer goal-memory tail marker not found")
src = src.replace(real_old, real_new, 1)

# Insert navigation-memory helpers before the direction chooser. The progress
# detector treats both repeated positions and A-B-A-B oscillation as failure.
# Six failed samples blacklist the current goal for 64 cave passes. Deliberate
# demo-style waits reset this detector in game_autoplay_step below.
anchor = ".proc ai_prepare_dirs\n"
helpers = r'''
.proc ai_reset_navigation
    lda game_current_cave
    sta ai_seen_cave
    lda #1
    sta ai_seen_valid
    stz ai_obs_valid
    stz ai_stuck_count
    stz ai_goal_valid
    stz ai_detour_dir
    stz ai_last_dir
    stz ai_wall_flip
    stz ai_black1_time
    stz ai_black2_time
    rts
.endproc

.proc ai_sync_cave
    lda ai_seen_valid
    beq @reset
    lda game_current_cave
    cmp ai_seen_cave
    beq @done
@reset:
    jsr ai_reset_navigation
@done:
    rts
.endproc

.proc ai_tick_blacklists
    lda ai_black1_time
    beq :+
    dec ai_black1_time
:
    lda ai_black2_time
    beq :+
    dec ai_black2_time
:
    rts
.endproc

.proc ai_blacklist_goal
    ; Keep the previous tabu target as slot 2 so two unreachable diamonds do
    ; not immediately bounce the player back and forth between each other.
    lda ai_black1_x
    sta ai_black2_x
    lda ai_black1_y
    sta ai_black2_y
    lda ai_black1_time
    sta ai_black2_time

    lda ai_target_x
    sta ai_black1_x
    lda ai_target_y
    sta ai_black1_y
    lda #64
    sta ai_black1_time

    stz ai_goal_valid
    stz ai_detour_dir
    inc ai_wall_flip
    rts
.endproc

.proc ai_track_progress
    lda ai_obs_valid
    bne @have
    lda game_player_x
    sta ai_obs_x
    sta ai_prev_x
    lda game_player_y
    sta ai_obs_y
    sta ai_prev_y
    lda #1
    sta ai_obs_valid
    stz ai_stuck_count
    clc
    rts

@have:
    lda game_player_x
    cmp ai_obs_x
    bne @moved
    lda game_player_y
    cmp ai_obs_y
    bne @moved

    ; A requested route that leaves Rockford on the same cell repeatedly is
    ; normally a blocked/push loop. Give probabilistic pushes several chances.
    inc ai_stuck_count
    jmp @check

@moved:
    ; Detect A-B-A-B oscillation. It is more informative than a stationary
    ; miss, so count it twice toward the stuck threshold.
    lda game_player_x
    cmp ai_prev_x
    bne @new_progress
    lda game_player_y
    cmp ai_prev_y
    bne @new_progress
    inc ai_stuck_count
    inc ai_stuck_count
    jmp @shift

@new_progress:
    stz ai_stuck_count

@shift:
    lda ai_obs_x
    sta ai_prev_x
    lda ai_obs_y
    sta ai_prev_y
    lda game_player_x
    sta ai_obs_x
    lda game_player_y
    sta ai_obs_y

@check:
    lda ai_stuck_count
    cmp #6
    bcc @ok
    stz ai_stuck_count
    jsr ai_blacklist_goal
    sec
    rts
@ok:
    clc
    rts
.endproc

.proc ai_choose_unstick
    ; Change the escape handedness on every stuck event. ai_try_dir still
    ; applies all Boulder Dash collision, falling-object and enemy safety rules.
    lda ai_wall_flip
    and #1
    bne @right_first

    lda #PAD_LEFT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_UP
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_RIGHT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_DOWN
    jsr ai_try_dir
    bcc @none
    rts

@right_first:
    lda #PAD_RIGHT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_DOWN
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_LEFT
    jsr ai_try_dir
    bcc :+
    rts
:
    lda #PAD_UP
    jsr ai_try_dir
    bcc @none
    rts

@none:
    lda #0
    rts
.endproc

'''
if anchor not in src:
    raise SystemExit("autoplayer helper insertion marker not found")
src = src.replace(anchor, helpers + anchor, 1)

# Replace the public decision routine. Deliberate wait phases must never count
# as being stuck. On a genuine stuck condition the current goal is tabu'd and
# one safe unstick move is issued immediately; next pass selects another goal.
step_marker = ".proc game_autoplay_step\n"
if step_marker not in src:
    raise SystemExit("autoplayer step marker not found")
prefix, _old_step = src.split(step_marker, 1)
new_step = r'''.proc game_autoplay_step
    lda game_game_over
    beq :+
    lda #PAD_START
    rts
:
    lda game_player_alive
    bne :+
    stz ai_obs_valid
    stz ai_stuck_count
    stz ai_goal_valid
    lda #0
    rts
:
    jsr ai_sync_cave
    jsr ai_tick_blacklists

    jsr ai_current_danger
    bcc @goal
    ; Survival remains absolute priority. Danger escape is not judged against
    ; a diamond goal because the cave state may force temporary retreat.
    stz ai_obs_valid
    stz ai_stuck_count
    jsr ai_choose_escape
    rts

@goal:
    jsr ai_find_goal
    lda ai_goal_kind
    cmp #AI_GOAL_WAIT
    bne :+
    stz ai_obs_valid
    stz ai_stuck_count
    lda #0
    rts
:
    cmp #AI_GOAL_NONE
    bne :+
    stz ai_obs_valid
    stz ai_stuck_count
    lda #0
    rts
:
    jsr ai_update_goal_memory
    jsr ai_track_progress
    bcc @toward
    jsr ai_choose_unstick
    rts

@toward:
    jsr ai_choose_toward
    rts
.endproc
'''
src = prefix + new_step

# The PCE keeps physical HuCard bank $01 permanently mapped through MPR6 at
# $C000-$DFFF during gameplay. Put the sizeable strategy code there instead of
# consuming the fixed boot/vector bank. SNES keeps the routine in normal CODE.
old_segment = '.segment "CODE"\n'
new_segment = (
    '.ifdef PCE_AUTOPLAY_BANK\n'
    '.segment "BANK1_CODE"\n'
    '.else\n'
    '.segment "CODE"\n'
    '.endif\n'
)
if old_segment not in src:
    raise SystemExit("autoplayer CODE segment marker not found")
src = src.replace(old_segment, new_segment, 1)

# ca65 conditional branches and BRA are relative. The strategy is intentionally
# large, so make all named local branches range-safe for both CPU targets.
inverse = {
    "beq": "bne",
    "bne": "beq",
    "bcc": "bcs",
    "bcs": "bcc",
    "bmi": "bpl",
    "bpl": "bmi",
    "bvc": "bvs",
    "bvs": "bvc",
}

pattern = re.compile(
    r"^(?P<indent>[ \t]*)(?P<op>beq|bne|bcc|bcs|bmi|bpl|bvc|bvs)"
    r"[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    re.MULTILINE | re.IGNORECASE,
)


def make_long(match: re.Match[str]) -> str:
    indent = match.group("indent")
    op = match.group("op").lower()
    target = match.group("target")
    comment = match.group("comment")
    return (
        f"{indent}{inverse[op]} :+\n"
        f"{indent}jmp {target}{comment}\n"
        f"{indent}:"
    )


src = pattern.sub(make_long, src)
src = re.sub(
    r"^(?P<indent>[ \t]*)bra[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    lambda m: f"{m.group('indent')}jmp {m.group('target')}{m.group('comment')}",
    src,
    flags=re.MULTILINE | re.IGNORECASE,
)

Path(sys.argv[2]).write_text(src)
