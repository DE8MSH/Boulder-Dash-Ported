# Boulder Dash I port map

This file is the working map from the C64 reconstruction to the SNES and PC Engine implementations.

## Rule

Do **not** port C64 device register files (`cia*.asm`, `sid.asm`, `vic.asm`, KERNAL definitions) instruction-for-instruction. Port the behaviour used by Boulder Dash behind `src/common/platform.inc`.

| C64 dependency | Boulder Dash use | SNES replacement | PC Engine replacement | Status |
|---|---|---|---|---|
| CIA1 joystick | player/menu input | auto joypad registers `$4218/$4219` | HuC6280 joypad `$1000`, SEL/CLR scan | started |
| CIA timers / raster timing | game/frame timing | VBlank polling now, NMI later | VDC VBlank IRQ/polling | SNES started; PCE pending |
| VIC-II screen/charset | cave rendering, UI | BG tilemap + VRAM + CGRAM | VDC BAT + VRAM + VCE palette | pending |
| VIC-II raster features | display timing/effects | PPU/NMI/DMA | VDC IRQ/DMA | pending |
| C64 Color RAM | tile colours | CGRAM + tile attributes | VCE palette + BAT attributes | pending |
| SID | music and SFX | SPC700/DSP backend | HuC6280 PSG backend | **deferred, required** |
| KERNAL | startup/input/I/O helpers | native ROM startup/helpers | native ROM startup/helpers | pending audit |
| C64 zero page | hot game state/pointers | 65C816 Direct Page | HuC6280 zero page | planned |
| C64 memory map | fixed RAM/ROM/device locations | SNES WRAM/LoROM map | HuCard/RAM/MPR map | pending |

## Port order

1. Controller input and frame boundary.
2. Native ROM startup, vectors and deterministic RAM layout.
3. Character/tile conversion and one visible cave screen.
4. Extract cave data decoding/generation.
5. Extract one deterministic cave simulation tick.
6. Port player movement, falling objects, enemies, amoeba/magic wall and scoring.
7. Menus/title/demo integration.
8. Audio: preserve event hooks first, then implement SNES SPC700 and PCE PSG playback.

## Shared gameplay contract

`src/common/game.s` owns the hardware-neutral frame order. Platform code may read controllers, wait for a frame, submit video work and later service audio, but it must not contain Boulder Dash physics.

The portable core will preserve the original's observable behaviour where practical:

- 8-bit arithmetic wrap behaviour;
- object scan/update order;
- cave RNG sequence;
- frame/tick assumptions;
- cave and demo data byte layout.

## Current input mapping

Common bit | Boulder Dash meaning | SNES | PC Engine
---|---|---|---
`PAD_LEFT` | left | D-pad Left | D-pad Left
`PAD_RIGHT` | right | D-pad Right | D-pad Right
`PAD_UP` | up | D-pad Up | D-pad Up
`PAD_DOWN` | down | D-pad Down | D-pad Down
`PAD_FIRE` | action/fire modifier | B | I
`PAD_START` | start/pause/menu | Start | Run
`PAD_SELECT` | selection/helper | Select | Select

## Audio parking lot (not current priority)

Audio work is intentionally delayed until gameplay/video are stable. The `platform_audio_tick` ABI entry remains in the frame loop so the feature is not lost during the refactor.

Planned direction:

- identify gameplay sound events instead of preserving raw SID register writes;
- SNES: event -> SPC700/DSP music/SFX driver;
- PC Engine: event -> HuC6280 PSG driver;
- preserve original pitch/rhythm/envelopes where useful, but do not emulate the SID merely to run Boulder Dash.
