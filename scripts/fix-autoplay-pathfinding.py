#!/usr/bin/env python3
"""Optimize generated autoplay BFS addressing and harden gateway scanning."""

from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: fix-autoplay-pathfinding.py FILE")

path = Path(sys.argv[1])
text = path.read_text()

# Replace the repeated y*40 route-pointer loop with constant-time row tables.
route_block = r'''ai_cave_row_ptrs:
    .word game_cave_state +   0, game_cave_state +  40
    .word game_cave_state +  80, game_cave_state + 120
    .word game_cave_state + 160, game_cave_state + 200
    .word game_cave_state + 240, game_cave_state + 280
    .word game_cave_state + 320, game_cave_state + 360
    .word game_cave_state + 400, game_cave_state + 440
    .word game_cave_state + 480, game_cave_state + 520
    .word game_cave_state + 560, game_cave_state + 600
    .word game_cave_state + 640, game_cave_state + 680
    .word game_cave_state + 720, game_cave_state + 760
    .word game_cave_state + 800, game_cave_state + 840
    .word game_cave_state + 880

ai_route_row_ptrs:
    .word ai_route +   0, ai_route +  40
    .word ai_route +  80, ai_route + 120
    .word ai_route + 160, ai_route + 200
    .word ai_route + 240, ai_route + 280
    .word ai_route + 320, ai_route + 360
    .word ai_route + 400, ai_route + 440
    .word ai_route + 480, ai_route + 520
    .word ai_route + 560, ai_route + 600
    .word ai_route + 640, ai_route + 680
    .word ai_route + 720, ai_route + 760
    .word ai_route + 800, ai_route + 840
    .word ai_route + 880

.proc ai_route_probe_ptr
    lda ai_probe_y
    asl a
    tax
    lda ai_route_row_ptrs,x
    sta ai_route_ptr
    lda ai_route_row_ptrs+1,x
    sta ai_route_ptr+1
    ldy ai_probe_x
    rts
.endproc

.proc ai_get_probe_fast
    lda ai_probe_y
    asl a
    tax
    lda ai_cave_row_ptrs,x
    sta ai_ptr
    lda ai_cave_row_ptrs+1,x
    sta ai_ptr+1
    ldy ai_probe_x
    lda (ai_ptr),y
    rts
.endproc'''

pattern = re.compile(
    r"\.proc ai_route_probe_ptr\n.*?\.endproc",
    re.DOTALL,
)
text, count = pattern.subn(route_block, text, count=1)
if count != 1:
    raise SystemExit("optimized route-probe marker not found")

# BFS probes are the hot path; use constant-time cave row lookup there.
bfs_marker = ".proc ai_bfs_try_probe\n"
if bfs_marker not in text:
    raise SystemExit("BFS probe routine marker not found")
pre, rest = text.split(bfs_marker, 1)
end = rest.find(".endproc")
if end < 0:
    raise SystemExit("BFS probe routine end not found")
body = rest[:end]
if "    jsr ai_get_probe\n" not in body:
    raise SystemExit("BFS cave probe call not found")
body = body.replace("    jsr ai_get_probe\n", "    jsr ai_get_probe_fast\n", 1)
text = pre + bfs_marker + body + rest[end:]

# The first gateway implementation scanned with ai_ptr while helper probes also
# used ai_ptr. Replace it with coordinate scanning so probe calls cannot corrupt
# the outer scan state.
gateway = r'''.proc ai_find_push_gateway
    lda #1
    sta ai_scan_y
@row:
    lda #1
    sta ai_scan_x
@col:
    lda ai_scan_x
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_probe_fast
    cmp #T_BOULDER_FIXED
    beq @boulder
    cmp #T_BOULDER_FIXED_
    bne @next

@boulder:
    ; Push right: approach x-1 must already be reachable and x+1 empty.
    lda ai_scan_x
    cmp #1
    beq @try_left
    cmp #38
    beq @try_left
    dec a
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_route_probe
    beq @try_left

    lda ai_scan_x
    inc a
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_probe_fast
    cmp #T_EMPTY
    bne @try_left

    lda ai_scan_x
    dec a
    sta ai_target_x
    lda ai_scan_y
    sta ai_target_y
    lda #PAD_RIGHT
    sta ai_gateway_dir
    lda #AI_GOAL_PUSH
    sta ai_goal_kind
    sec
    rts

@try_left:
    ; Push left: approach x+1 must already be reachable and x-1 empty.
    lda ai_scan_x
    cmp #1
    beq @next
    cmp #38
    beq @next
    inc a
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_route_probe
    beq @next

    lda ai_scan_x
    dec a
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_probe_fast
    cmp #T_EMPTY
    bne @next

    lda ai_scan_x
    inc a
    sta ai_target_x
    lda ai_scan_y
    sta ai_target_y
    lda #PAD_LEFT
    sta ai_gateway_dir
    lda #AI_GOAL_PUSH
    sta ai_goal_kind
    sec
    rts

@next:
    inc ai_scan_x
    lda ai_scan_x
    cmp #39
    bne @col
    inc ai_scan_y
    lda ai_scan_y
    cmp #22
    bne @row
@no:
    clc
    rts
.endproc'''

pattern = re.compile(
    r"\.proc ai_find_push_gateway\n.*?\.endproc",
    re.DOTALL,
)
text, count = pattern.subn(gateway, text, count=1)
if count != 1:
    raise SystemExit("gateway routine marker not found")

# Newly inserted named local branches need the same range-safe lowering used by
# the other generated sources.
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
branch_re = re.compile(
    r"^(?P<indent>[ \t]*)(?P<op>beq|bne|bcc|bcs|bmi|bpl|bvc|bvs)"
    r"[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    re.MULTILINE | re.IGNORECASE,
)


def lower(match: re.Match[str]) -> str:
    indent = match.group("indent")
    op = match.group("op").lower()
    target = match.group("target")
    comment = match.group("comment")
    return (
        f"{indent}{inverse[op]} :+\n"
        f"{indent}jmp {target}{comment}\n"
        f"{indent}:"
    )


text = branch_re.sub(lower, text)
text = re.sub(
    r"^(?P<indent>[ \t]*)bra[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    lambda m: f"{m.group('indent')}jmp {m.group('target')}{m.group('comment')}",
    text,
    flags=re.MULTILINE | re.IGNORECASE,
)

path.write_text(text)
