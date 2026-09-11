#!/usr/bin/env python3
"""Apply shared generated-source fixes used by both 65xx targets.

The shared game source keeps growing as more original C64 object handlers are
ported. 6502-family conditional branches and BRA only reach +/-127 bytes.
Instead of fixing individual overflows after every new object, make every
branch to a named local @label range-safe:

    bne @target        ->  beq :+ / jmp @target / :
    bra @target        ->  jmp @target

Anonymous :+ / :- branches are intentionally left alone because they are used
only for nearby skip labels. The rewrite is semantics-preserving on both the
65C816 and HuC6280 builds.

The post-pass also places the platform animation hook on the unconditional
video-frame path so charset animation does not depend on cave movement/dirty
state.
"""

from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
text = path.read_text()

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

# Rewrite every conditional branch to a named local label. Comments following
# the original branch are kept on the JMP line so generated listings remain
# readable. The anonymous skip label is always within a few bytes.
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

# BRA is also relative. A named local target can always use absolute JMP.
text = re.sub(
    r"^(?P<indent>[ \t]*)bra[ \t]+(?P<target>@[A-Za-z_][A-Za-z0-9_]*)"
    r"(?P<comment>[ \t]*(?:;.*)?)$",
    lambda m: f"{m.group('indent')}jmp {m.group('target')}{m.group('comment')}",
    text,
    flags=re.MULTILINE | re.IGNORECASE,
)

# C64 character animation is IRQ/frame driven. It must continue while
# Rockford stands still, independently of game_video_dirty.
old = "    jsr platform_wait_frame\n\n    lda game_video_dirty\n"
new = "    jsr platform_wait_frame\n    jsr platform_video_tick\n\n    lda game_video_dirty\n"
if old not in text:
    raise SystemExit("game per-frame video hook marker not found")
text = text.replace(old, new, 1)

path.write_text(text)
