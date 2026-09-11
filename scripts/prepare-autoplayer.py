#!/usr/bin/env python3
"""Prepare the shared rule-based autoplay source for 65C816/HuC6280."""

from pathlib import Path
import re
import sys

src = Path(sys.argv[1]).read_text()

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
