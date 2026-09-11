#!/usr/bin/env python3
"""Apply shared generated-source fixes used by both 65xx targets.

The shared scan dispatch grows as more C64 objects are ported. 6502-family
relative branches only reach +/-127 bytes, so loop-closing branches are
written as inverse short branches plus absolute JMPs. The post-pass also
places the platform animation hook on the unconditional video-frame path so
charset animation does not depend on cave movement/dirty state.
"""

from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

replacements = (
    (
        "    cmp #39\n    bne @col\n",
        "    cmp #39\n    beq :+\n    jmp @col\n:\n",
    ),
    (
        "    cmp #22\n    bne @row\n",
        "    cmp #22\n    beq :+\n    jmp @row\n:\n",
    ),
)

for old, new in replacements:
    if old in text:
        text = text.replace(old, new, 1)

# C64 character animation is IRQ/frame driven. It must continue while
# Rockford stands still, independently of game_video_dirty.
old = "    jsr platform_wait_frame\n\n    lda game_video_dirty\n"
new = "    jsr platform_wait_frame\n    jsr platform_video_tick\n\n    lda game_video_dirty\n"
if old not in text:
    raise SystemExit("game per-frame video hook marker not found")
text = text.replace(old, new, 1)

path.write_text(text)
