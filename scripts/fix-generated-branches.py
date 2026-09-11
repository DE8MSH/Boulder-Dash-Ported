#!/usr/bin/env python3
"""Rewrite long cave-scan back branches in generated shared source.

The shared scan dispatch grows as more C64 objects are ported. 6502-family
relative branches only reach +/-127 bytes, so the loop-closing branches are
written as an inverse short branch plus an absolute JMP. This is semantics-
preserving and works for both 65C816 and HuC6280 builds.
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

path.write_text(text)
