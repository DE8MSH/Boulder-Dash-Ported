# ROM architecture

The ports keep platform startup/vectors in a fixed boot bank and move coherent
asset groups into later banks as the C64 feature set grows.

## SNES

- Native mapper: LoROM.
- Bank granularity: 32 KiB at CPU `$8000-$FFFF`.
- Bank 0 keeps startup, shared gameplay, platform code, header and vectors.
- Header remains at file `$7FC0`; vectors remain at file `$7FE0-$7FFF`.
- Bank 1 contains the deduplicated static title-screen tiles generated from
  `B1_Title_therza.asm` and the original `B1_ChrS.asm`.
- Bank 2 contains all eight 32x32 title-screen maps used by the original C64
  moving-background animation.
- Bank 3 is reserved expansion space and is deliberately materialized so the
  image remains a standard power-of-two 128 KiB LoROM. The header ROM-size
  byte is `$07`.
- The intro BG1 map lives at VRAM word `$7C00`; the title graphics start at
  word `$0400`, so the animated title tiles and map never overlap.
- Same-bank routines use `JSR/RTS`. Cross-bank executable code must use an
  explicit trampoline or `JSL/RTL`; the current extra banks contain data only.
- WRAM game state remains separate from ROM banking.

## PC Engine

- HuCard ROM is split into physical 8 KiB pages selected by HuC6280 MPRs.
- On reset `MPR7=$00`, so physical bank `$00` contains startup, fixed code and
  vectors and appears at logical `$E000-$FFFF`.
- Reset/IRQ vectors remain at physical ROM offsets `$1FF6-$1FFF`.
- Bank `$01` is mapped through `MPR6` at `$C000-$DFFF` during gameplay and
  contains the converted cave charset and generated diamond animation data.
- Intro graphics occupy physical banks `$02` through `$05` in native 32-byte
  HuC6270 4bpp tile format.
- Intro BAT animation maps 0-3 occupy bank `$06`; maps 4-7 occupy bank `$07`.
  During the title screen only the BAT is replaced. Bank `$01` is restored
  before gameplay begins.
- The current image is 64 KiB (eight 8 KiB HuCard banks).
- Shared RAM state stays at `$2200+` and never depends on the mapped ROM bank.

## Intro asset pipeline

- `scripts/generate-intro.py` reads the 1000-cell 40x25 title matrix. The
  Therza variant replaces only its first two rows and inherits the remaining
  920 cells byte-for-byte from the untouched original `B1_Title.asm`.
- The glyphs come directly from the original `B1_ChrS.asm`.
- The original C64 animation is reproduced from the title IRQ logic:
  character `$0B` seeds character `$00`; `$00` rotates upward; `$09/$0A` are
  rebuilt as `$06/$07 OR $00`. Eight phases are generated.
- Each phase is reconstructed at the original 320x200 C64 geometry and then
  horizontally sampled to the consoles' stable 256-pixel mode. Tiles are
  deduplicated across all phases, remain resident in VRAM, and animation
  switches only the map/BAT.
- The C64 updates that title animation every fourth PAL IRQ (12.5 Hz). SNES
  uses four PAL frames directly; PCE uses a 5/24 accumulator on its roughly
  60 Hz timer loop to preserve the same average rate.
- Start-screen colors keep the original C64 roles: black background, blue
  multicolor 1, light-blue multicolor 2 and white character foreground.

## Build rules

- SNES images grow in whole 32 KiB banks.
- PCE images grow in whole 8 KiB banks.
- `scripts/check-roms.py` currently verifies the expected 128 KiB SNES and
  64 KiB PCE layouts, including fixed reset-vector locations and populated
  intro banks.
- Do not enlarge a ROM merely to hide a linker overflow. Add a banked segment
  deliberately and place a coherent asset/code group there.
