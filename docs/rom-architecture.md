# ROM architecture

The ports keep platform startup/vectors in a fixed boot bank and move coherent
asset groups into later banks as the C64 feature set grows.

## SNES

- Native mapper: LoROM.
- Bank granularity: 32 KiB at CPU `$8000-$FFFF`.
- Bank 0 keeps startup, shared gameplay, platform code, header and vectors.
- Header remains at file `$7FC0`; vectors remain at file `$7FE0-$7FFF`.
- Bank 1 contains the generated title-screen graphics/map derived directly
  from `B1_Title.asm` and `B1_ChrS.asm`.
- The current image is 64 KiB (two LoROM banks); the header ROM-size byte is
  `$06`.
- Same-bank routines use `JSR/RTS`. Cross-bank executable code must use an
  explicit trampoline or `JSL/RTL`; the current intro bank contains data only.
- WRAM game state remains separate from ROM banking.

## PC Engine

- HuCard ROM is split into physical 8 KiB pages selected by HuC6280 MPRs.
- On reset `MPR7=$00`, so physical bank `$00` contains startup, fixed code and
  vectors and appears at logical `$E000-$FFFF`.
- Reset/IRQ vectors remain at physical ROM offsets `$1FF6-$1FFF`.
- Bank `$01` is permanently mapped through `MPR6` at `$C000-$DFFF` during
  gameplay and contains the converted cave charset.
- Intro graphics use physical banks `$02` and `$03`. `platform_init` maps them
  temporarily through `MPR6`, expands the packed 2bpp C64-derived title tiles
  into 4bpp VRAM, uploads the BAT, then restores bank `$01` before gameplay.
- The current image is 32 KiB (four 8 KiB HuCard banks).
- Shared RAM state stays at `$2200+` and never depends on the mapped ROM bank.

## Intro asset pipeline

- `scripts/generate-intro.py` reads the first 1000 screen bytes from the
  original `B1_Title.asm` (40x25 C64 screen) and the matching glyphs from
  `B1_ChrS.asm`.
- It reconstructs the original 320x200 multicolor picture using the VIC-II
  2-bit color roles and samples it horizontally to the consoles' stable
  256-pixel mode. The artwork and text therefore come from the original ASM;
  only the unavoidable 320-to-256 hardware-width conversion is performed.
- Start-screen colors use the original C64 roles: black background, blue
  multicolor 1, light-blue multicolor 2 and white character foreground.

## Build rules

- SNES images grow in whole 32 KiB banks.
- PCE images grow in whole 8 KiB banks.
- `scripts/check-roms.py` currently verifies the expected 64 KiB SNES and
  32 KiB PCE layouts, including the fixed reset-vector locations and non-empty
  intro banks.
- Do not enlarge a ROM merely to hide a linker overflow. Add a banked segment
  deliberately and place a coherent asset/code group there.
