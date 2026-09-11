#!/usr/bin/env python3
"""Add cave-aware route finding and Boulder gateway opening to autoplay.

The original rule player chooses sensible local moves, but Manhattan target
selection can still lock onto a diamond that is close geometrically and cut
off by walls/boulders. This pass adds a live flood/BFS route map over the C64
40x23 control field. Goals must be genuinely reachable before they are chosen.

When fixed diamonds exist but none is currently reachable, the player searches
the reachable boundary for a horizontally pushable boulder with empty space
behind it. It walks to the correct side and uses the normal Boulder Dash push
rule to open connectivity, then rebuilds the route map on the next cave pass.
"""

from pathlib import Path
import re
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: add-autoplay-pathfinding.py FILE")

path = Path(sys.argv[1])
text = path.read_text()


def replace_once(old: str, new: str, what: str) -> None:
    global text
    if old not in text:
        raise SystemExit(f"autoplay pathfinding marker not found: {what}")
    text = text.replace(old, new, 1)


# A second ZP pointer addresses the 920-byte route map without disturbing the
# cave-data pointer used by the source strategy.
replace_once(
    "ai_ptr: .res 2\n",
    "ai_ptr:       .res 2\nai_route_ptr: .res 2\n",
    "route zeropage pointer",
)

# Rockford forms are walkable route-map cells. AI_GOAL_PUSH is a temporary
# approach-and-push objective used only when all remaining diamonds are cut off.
replace_once(
    "T_BUTTERFLY3_    = $37\n",
    "T_BUTTERFLY3_    = $37\nT_ROCKFORD       = $38\nT_ROCKFORD_      = $39\n",
    "Rockford constants",
)
replace_once(
    "AI_GOAL_WAIT     = $05\n",
    "AI_GOAL_WAIT     = $05\nAI_GOAL_PUSH     = $06\n",
    "push goal constant",
)

# One byte per cave cell stores the first controller direction on a real route
# from Rockford. $00=unreachable, $80=start cell, otherwise a PAD_* direction.
# A 256-entry x/y ring queue is comfortably larger than the maximum practical
# breadth of the 40x23 cave while keeping indexing native 8-bit on both CPUs.
replace_once(
    "ai_black2_time:  .res 1\n",
    """ai_black2_time:  .res 1
ai_reach_filter: .res 1
ai_gateway_dir:  .res 1
ai_queue_head:   .res 1
ai_queue_tail:   .res 1
ai_bfs_x:        .res 1
ai_bfs_y:        .res 1
ai_bfs_route:    .res 1
ai_route:        .res 920
ai_queue_x:      .res 256
ai_queue_y:      .res 256
""",
    "route-map BSS",
)

helpers = r'''
; ---------------------------------------------------------------------------
; Live route map. Walls, steel and boulders are not treated as ordinary floor.
; Boulder pushes are handled explicitly by ai_find_push_gateway so the map
; never pretends Rockford can simply walk through a stone.
.proc ai_route_add40
    clc
    lda ai_route_ptr
    adc #40
    sta ai_route_ptr
    lda ai_route_ptr+1
    adc #0
    sta ai_route_ptr+1
    rts
.endproc

.proc ai_route_probe_ptr
    lda #<ai_route
    sta ai_route_ptr
    lda #>ai_route
    sta ai_route_ptr+1
    ldx ai_probe_y
    beq @rows_done
@rows:
    jsr ai_route_add40
    dex
    bne @rows
@rows_done:
    ldy ai_probe_x
    rts
.endproc

.proc ai_get_route_probe
    jsr ai_route_probe_ptr
    lda (ai_route_ptr),y
    rts
.endproc

; A = route value to store at ai_probe_x/y.
.proc ai_set_route_probe
    pha
    jsr ai_route_probe_ptr
    pla
    sta (ai_route_ptr),y
    rts
.endproc

.proc ai_clear_routes
    lda #<ai_route
    sta ai_route_ptr
    lda #>ai_route
    sta ai_route_ptr+1
    lda #0
    ldx #3
@page:
    ldy #0
@page_byte:
    sta (ai_route_ptr),y
    iny
    bne @page_byte
    inc ai_route_ptr+1
    dex
    bne @page

    ldy #0
@tail:
    sta (ai_route_ptr),y
    iny
    cpy #152
    bne @tail
    rts
.endproc

.proc ai_tile_pathable
    cmp #T_EMPTY
    beq @yes
    cmp #T_SOIL
    beq @yes
    cmp #T_EXIT_OPEN
    beq @yes
    cmp #T_DIAMOND_FIXED
    beq @yes
    cmp #T_DIAMOND_FIXED_
    beq @yes
    cmp #T_ROCKFORD
    beq @yes
    cmp #T_ROCKFORD_
    beq @yes
    clc
    rts
@yes:
    sec
    rts
.endproc

.proc ai_bfs_enqueue_probe
    ldy ai_queue_tail
    lda ai_probe_x
    sta ai_queue_x,y
    lda ai_probe_y
    sta ai_queue_y,y
    inc ai_queue_tail
    rts
.endproc

; Try to add ai_probe_x/y to the route map. ai_test_dir is the edge direction
; from the currently dequeued cell. The first edge is propagated through the
; whole BFS tree so every reachable goal directly tells us the next pad move.
.proc ai_bfs_try_probe
    jsr ai_get_route_probe
    bne @no

    jsr ai_get_probe
    jsr ai_tile_pathable
    bcc @no

    lda ai_bfs_route
    cmp #$80
    bne @inherit
    lda ai_test_dir
    jmp @store
@inherit:
    lda ai_bfs_route
@store:
    jsr ai_set_route_probe
    jsr ai_bfs_enqueue_probe
    sec
    rts
@no:
    clc
    rts
.endproc

.proc ai_build_routes
    jsr ai_clear_routes
    stz ai_queue_head
    stz ai_queue_tail

    lda game_player_x
    sta ai_probe_x
    lda game_player_y
    sta ai_probe_y
    lda #$80
    jsr ai_set_route_probe
    jsr ai_bfs_enqueue_probe

@queue:
    lda ai_queue_head
    cmp ai_queue_tail
    beq @done

    ldy ai_queue_head
    lda ai_queue_x,y
    sta ai_bfs_x
    sta ai_probe_x
    lda ai_queue_y,y
    sta ai_bfs_y
    sta ai_probe_y
    inc ai_queue_head
    jsr ai_get_route_probe
    sta ai_bfs_route

    lda ai_bfs_x
    cmp #1
    beq @right
    dec a
    sta ai_probe_x
    lda ai_bfs_y
    sta ai_probe_y
    lda #PAD_LEFT
    sta ai_test_dir
    jsr ai_bfs_try_probe

@right:
    lda ai_bfs_x
    cmp #38
    beq @up
    inc a
    sta ai_probe_x
    lda ai_bfs_y
    sta ai_probe_y
    lda #PAD_RIGHT
    sta ai_test_dir
    jsr ai_bfs_try_probe

@up:
    lda ai_bfs_y
    cmp #1
    beq @down
    dec a
    sta ai_probe_y
    lda ai_bfs_x
    sta ai_probe_x
    lda #PAD_UP
    sta ai_test_dir
    jsr ai_bfs_try_probe

@down:
    lda ai_bfs_y
    cmp #22
    beq @queue
    inc a
    sta ai_probe_y
    lda ai_bfs_x
    sta ai_probe_x
    lda #PAD_DOWN
    sta ai_test_dir
    jsr ai_bfs_try_probe
    jmp @queue

@done:
    rts
.endproc

; Find a reachable side of a horizontally pushable boulder. This is used only
; when fixed diamonds still exist globally but the route map reaches none of
; them. Pushing stays subject to the real game's 1-in-4 push chance.
.proc ai_find_push_gateway
    lda #<(game_cave_state + 40)
    sta ai_ptr
    lda #>(game_cave_state + 40)
    sta ai_ptr+1
    lda #1
    sta ai_scan_y
@row:
    lda #1
    sta ai_scan_x
@col:
    ldy ai_scan_x
    lda (ai_ptr),y
    cmp #T_BOULDER_FIXED
    beq @boulder
    cmp #T_BOULDER_FIXED_
    bne @next

@boulder:
    ; Push right: Rockford can reach x-1 and x+1 is empty.
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
    jsr ai_get_probe
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
    ; Push left: Rockford can reach x+1 and x-1 is empty.
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
    jsr ai_get_probe
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
    beq @no
    jsr ai_add40
    jmp @row
@no:
    clc
    rts
.endproc

; Follow the actual BFS first edge instead of steering by Manhattan direction.
; Push goals first walk to the reachable side of a boulder, then issue the
; stored horizontal push direction when Rockford is standing there.
.proc ai_follow_route
    lda ai_goal_kind
    cmp #AI_GOAL_PUSH
    bne @normal
    lda game_player_x
    cmp ai_target_x
    bne @normal
    lda game_player_y
    cmp ai_target_y
    bne @normal
    lda ai_gateway_dir
    jsr ai_try_dir
    bcc @fallback
    rts

@normal:
    lda ai_target_x
    sta ai_probe_x
    lda ai_target_y
    sta ai_probe_y
    jsr ai_get_route_probe
    beq @fallback
    cmp #$80
    beq @fallback
    jsr ai_try_dir
    bcc @fallback
    rts

@fallback:
    jsr ai_choose_toward
    rts
.endproc

'''
replace_once(
    ".proc ai_find_range\n",
    helpers + ".proc ai_find_range\n",
    "route helper insertion",
)

# Prepared autoplay already has the two goal-tabu checks and their @distance
# label. From that point on, require a real route for normal target searches.
replace_once(
    "@distance:\n    lda ai_scan_x\n",
    """@distance:
    lda ai_reach_filter
    beq @distance_calc
    lda ai_scan_x
    sta ai_probe_x
    lda ai_scan_y
    sta ai_probe_y
    jsr ai_get_route_probe
    bne @distance_calc
    jmp @next
@distance_calc:
    lda ai_scan_x
""",
    "reachable-goal filter",
)

# Butterfly discovery itself must remain global because a butterfly cell is not
# walkable. The approach/support target is later followed through the route map
# where possible.
replace_once(
    ".proc ai_find_butterfly_support\n    lda #T_BUTTERFLY0\n",
    ".proc ai_find_butterfly_support\n    stz ai_reach_filter\n    lda #T_BUTTERFLY0\n",
    "butterfly global search",
)

# Goal policy: nearest *reachable* fixed diamond first. If diamonds exist but
# none is reachable, try to open the reachable boundary by pushing a boulder.
replace_once(
    ".proc ai_find_goal\n    stz ai_goal_kind\n",
    ".proc ai_find_goal\n    stz ai_goal_kind\n    lda #1\n    sta ai_reach_filter\n",
    "goal reachability enable",
)

# Inject a global-diamond fallback immediately after the reachable fixed-diamond
# search. This exact sequence survives prepare-autoplayer's branch expansion.
needle = """    lda #AI_GOAL_DIAMOND
    sta ai_goal_kind
    rts
:
    ; Demo-inspired wait: do not run to the exit while a diamond is still
"""
replacement = """    lda #AI_GOAL_DIAMOND
    sta ai_goal_kind
    rts
:
    ; No reachable fixed diamond. Check whether fixed diamonds still exist
    ; elsewhere; if so, try a legal horizontal boulder push that can change
    ; connectivity before falling/explosion wait handling.
    stz ai_reach_filter
    lda #T_DIAMOND_FIXED
    sta ai_match_lo
    lda #(T_DIAMOND_FIXED_ + 1)
    sta ai_match_end
    jsr ai_find_range
    lda ai_goal_found
    beq @no_cutoff_diamond
    jsr ai_find_push_gateway
    bcc @no_push_gateway
    rts
@no_push_gateway:
    stz ai_reach_filter
    jmp @wait_falling
@no_cutoff_diamond:
@wait_falling:
    ; Demo-inspired wait: do not run to the exit while a diamond is still
"""
replace_once(needle, replacement, "cut-off diamond gateway policy")

# Falling/explosion searches are global wait conditions. Exit and soil targets
# must again be genuinely reachable.
replace_once(
    "    lda game_exit_open\n",
    "    lda #1\n    sta ai_reach_filter\n    lda game_exit_open\n",
    "exit reachability restore",
)
replace_once(
    "@explore:\n    lda #T_SOIL\n",
    "@explore:\n    lda #1\n    sta ai_reach_filter\n    lda #T_SOIL\n",
    "explore reachability restore",
)

# Rebuild routes from the live cave immediately before selecting the goal, then
# use the stored first BFS edge rather than the old Manhattan-only steering.
replace_once(
    "@goal:\n    jsr ai_find_goal\n",
    "@goal:\n    jsr ai_build_routes\n    jsr ai_find_goal\n",
    "per-pass BFS build",
)
replace_once(
    "@toward:\n    jsr ai_choose_toward\n",
    "@toward:\n    jsr ai_follow_route\n",
    "BFS route following",
)

# This file is applied after prepare-autoplayer.py, whose own range pass has
# already run. Make newly inserted named local branches range-safe as well.
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


text = pattern.sub(make_long, text)
text = re.sub(
    r"^(?P<indent>[ \t]*)bra[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    lambda m: f"{m.group('indent')}jmp {m.group('target')}{m.group('comment')}",
    text,
    flags=re.MULTILINE | re.IGNORECASE,
)

path.write_text(text)
