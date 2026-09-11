#!/usr/bin/env python3
"""Generate build-only timing/autoplay variants for the shared game/PCE source."""

from pathlib import Path
import argparse


def prepare_game(src: str, step: int, threshold: int) -> str:
    text = src.replace("PHYSICS_DIV = 3", f"LOGIC_THRESHOLD = {threshold}")
    old = """    inc game_phys_counter\n    lda game_phys_counter\n    cmp #PHYSICS_DIV\n    bcc @render_ready\n    stz game_phys_counter\n"""
    new = f"""    ; Fractional host-frame accumulator. The cave pass itself remains the\n    ; original shared top-to-bottom C64-style scan.\n    clc\n    lda game_phys_counter\n    adc #{step}\n    sta game_phys_counter\n    cmp #LOGIC_THRESHOLD\n    bcc @render_ready\n    sec\n    sbc #LOGIC_THRESHOLD\n    sta game_phys_counter\n"""
    if old not in text:
        raise SystemExit("game timing block not found")
    text = text.replace(old, new, 1)

    # Visible benchmark build: keep the real shared game core, but feed each
    # logical cave pass from the generated C64-format autoplay stream instead
    # of the physical controller. Explicitly reset the stream because console
    # WRAM power-on contents are not guaranteed to be zero.
    text = text.replace(
        ".import game_cave_initial",
        ".import game_cave_initial\n.import game_autoplay_read\n.import game_autoplay_reset",
        1,
    )
    if "jsr platform_read_pad" not in text:
        raise SystemExit("pad read call not found")
    text = text.replace("jsr platform_read_pad", "jsr game_autoplay_read", 1)

    init_anchor = "    jsr game_copy_initial_cave\n"
    if init_anchor not in text:
        raise SystemExit("game init cave-copy call not found")
    text = text.replace(
        init_anchor,
        init_anchor + "    jsr game_autoplay_reset\n",
        1,
    )
    return text


def prepare_pce(src: str, reload_value: int) -> str:
    text = src.replace("PCE_TIMER_RELOAD = $74", f"PCE_TIMER_RELOAD = ${reload_value:02X}", 1)
    old = """.proc platform_wait_frame\n@wait_timer:\n    lda IRQ_STATUS\n    and #PCE_TIMER_IRQ\n    beq @wait_timer\n    stz IRQ_STATUS\n    rts\n.endproc\n"""
    new = """.proc platform_wait_frame\n    ; Restart the pacing timer for every host frame. A timer request that\n    ; arrived while rendering must not make the next frame return instantly.\n    stz TIMER_CTRL\n    stz IRQ_STATUS\n    lda #PCE_TIMER_RELOAD\n    sta TIMER_RELOAD\n    lda #$01\n    sta TIMER_CTRL\n@wait_timer:\n    lda IRQ_STATUS\n    and #PCE_TIMER_IRQ\n    beq @wait_timer\n    stz TIMER_CTRL\n    stz IRQ_STATUS\n    rts\n.endproc\n"""
    if old not in text:
        raise SystemExit("PCE timer wait block not found")
    return text.replace(old, new, 1)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("mode", choices=("game", "pce"))
    ap.add_argument("input", type=Path)
    ap.add_argument("output", type=Path)
    ap.add_argument("--step", type=int, default=4)
    ap.add_argument("--threshold", type=int, default=12)
    ap.add_argument("--reload", type=lambda x: int(x, 0), default=0x7F)
    args = ap.parse_args()

    src = args.input.read_text()
    if args.mode == "game":
        out = prepare_game(src, args.step, args.threshold)
    else:
        out = prepare_pce(src, args.reload)
    args.output.write_text(out)


if __name__ == "__main__":
    main()
