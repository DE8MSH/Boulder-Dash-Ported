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

- HuCard mapping is handled in 8 KiB pages through the HuC6280 MPR registers.
- The fixed boot/vector bank is mapped at CPU `$E000-$FFFF` (MPR7).
- Vectors stay at `$FFF6-$FFFF` in that fixed final bank.
- Future banked game/data pages should use a dedicated 8 KiB window (normally
  MPR6 at `$C000-$DFFF`) and switch it explicitly with `TAM`/`TMA` helpers.
- Interrupt/startup code and any routine required while changing MPRs stays in
  the fixed bank.
- Shared RAM state stays at `$2200+` and must never depend on the currently
  mapped HuCard bank.

## Build rules

- SNES images grow in whole 32 KiB banks.
- PCE images grow in whole 8 KiB banks.
- `scripts/check-roms.py` accepts those native bank multiples and still checks
  the fixed reset-vector locations.
- Do not enlarge a ROM merely to hide a linker overflow. Add a banked segment
  deliberately and keep the fixed bank small enough for startup, vectors and
  bank-switching support.
