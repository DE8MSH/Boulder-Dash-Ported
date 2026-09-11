#!/usr/bin/env python3
"""Wire the rule-based autoplay player into the generated shared game loop."""

from pathlib import Path
import sys

path = Path(sys.argv[1])
text = path.read_text()

old = ".import game_progress_init\n"
new = ".import game_progress_init\n.import game_progress_tick\n.import game_autoplay_step\n"
if old not in text:
    raise SystemExit("autoplay import marker not found")
text = text.replace(old, new, 1)

old = "    jsr platform_read_pad\n    sta game_pad_current\n"
new = "    jsr game_autoplay_step\n    sta game_pad_current\n"
if old not in text:
    raise SystemExit("autoplay input marker not found")
text = text.replace(old, new, 1)

# Progress/lives/time/exit completion are frame based. Keep that independent of
# the slower cave physics scan, just like the C64 IRQ-side timing.
old = "@render_ready:\n    jsr platform_wait_frame\n"
new = "@render_ready:\n    jsr game_progress_tick\n    jsr platform_wait_frame\n"
if old not in text:
    raise SystemExit("progress frame marker not found")
text = text.replace(old, new, 1)

path.write_text(text)
