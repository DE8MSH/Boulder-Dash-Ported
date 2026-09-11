# ROM architecture

The ports keep platform startup/vectors in a fixed boot bank and leave game
content free to move into additional banks as the C64 feature set grows.

## SNES

- Native mapper: LoROM.
- Bank granularity: 32 KiB at CPU `$8000-$FFFF`.
- Bank 0 keeps startup, header and vectors.
- Header remains at file `$7FC0`; vectors remain at file `$7FE0-$7FFF`.
- Additional code/data should be placed in later 32 KiB LoROM banks instead of
  forcing everything into bank 0.
- Same-bank routines continue to use `JSR/RTS`. Cross-bank calls must use a
  platform trampoline or `JSL/RTL`; shared 6502-like game code should not gain
  hidden bank assumptions.
- WRAM game state remains separate from ROM banking.

## PC Engine

- HuCard ROM is split into physical 8 KiB pages selected by the HuC6280 MPRs.
- On reset the CPU forces `MPR7=$00`. Therefore physical HuCard bank `$00`
  must contain startup and vectors and appears at logical `$E000-$FFFF`.
- Reset/IRQ vectors remain at physical ROM offsets `$1FF6-$1FFF`, not at the
  end of an expanded multi-bank image.
- The current 16 KiB layout maps physical bank `$01` permanently through
  `MPR6` at logical `$C000-$DFFF`.
- The converted C64 charset lives in bank `$01`; startup, shared game code,
  platform code and vectors remain in bank `$00` for now.
- Future banks can be switched through another dedicated MPR window with
  `TAM`/`TMA`; bank-switching helpers and interrupt/startup code must remain in
  fixed bank `$00`.
- Shared RAM state stays at `$2200+` and never depends on the mapped ROM bank.

## Build rules

- SNES images grow in whole 32 KiB banks.
- PCE images grow in whole 8 KiB banks.
- `scripts/check-roms.py` validates the SNES bank-0 vectors and the PCE
  physical bank-0 reset vector even when later banks are present.
- Do not enlarge a ROM merely to hide a linker overflow. Add a banked segment
  deliberately and place a coherent asset/code group there.
