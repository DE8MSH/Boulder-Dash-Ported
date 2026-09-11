# Boulder Dash I — SNES / PC Engine port

This repository contains a C64/6502 reconstruction of Boulder Dash I. The port keeps the original sources as the reference implementation and introduces a small platform boundary for console-specific hardware.

## Port strategy

The original code directly references C64 VIC-II, SID, CIA, KERNAL and C64 memory-map symbols. Those accesses must not leak into the portable game logic.

The port is split into three layers:

- `original/` conceptually means the existing root-level C64 sources. They remain untouched while behaviour is characterized.
- `src/common/` contains shared constants, ABI definitions and, incrementally, hardware-independent game logic/data extracted from the original 6502 code.
- `src/snes/` and `src/pce/` contain the platform implementations.

Both target CPUs are close relatives of the 6502: SNES uses the 65C816 and PC Engine uses the HuC6280. The project therefore starts with `ca65`, which supports both instruction sets. A later SNES-specific switch to PVSnesLib/WLA-DX remains possible if its video/audio helpers become useful.

## Milestones

1. **Characterize the C64 source**
   - document zero-page and game-state memory
   - isolate cave simulation from VIC/SID/CIA access
   - identify frame/tick rate assumptions
   - verify cave/demo data formats

2. **Portable simulation core**
   - move cave state transitions behind a shared API
   - keep 8-bit overflow and update order bit-compatible where gameplay depends on it
   - add deterministic input/replay hooks

3. **Video**
   - SNES: BG tile map + VRAM upload + palette conversion
   - PC Engine: VDC BAT + pattern upload + palette conversion
   - translate the C64 character/tile representation into console-native tiles

4. **Input/timing**
   - map SNES joypad and PC Engine pad onto a common button byte
   - drive one game tick from a platform frame/timer callback

5. **Audio**
   - replace SID playback rather than trying to emulate SID register writes
   - SNES: SPC700-side driver / converted effects and music
   - PC Engine: PSG-side driver / converted effects and music

6. **ROM packaging and hardware validation**
   - add linker configurations and headers
   - validate in emulators and on real hardware/flash carts

## Shared platform ABI

`src/common/platform.inc` defines the entry points the portable core may call:

- `platform_init`
- `platform_wait_frame`
- `platform_read_pad`
- `platform_video_begin`
- `platform_video_end`
- `platform_audio_tick`

The first scaffold only guarantees that target-specific assembly can be assembled. It deliberately does not claim to produce bootable ROM images yet; linker maps, vectors, cartridge headers and asset conversion come next.

## Build prerequisites

Install a recent cc65 toolchain so `ca65` is available on `PATH`.

```sh
make check
make snes-obj
make pce-obj
```

The two object targets are intentionally small smoke tests for the selected CPUs and platform ABI.

## Important source constraints

The original C64 source uses its own assembler dialect (`equ`, `dc.b`, `dc.w`, bracketed expressions and C64 include layout). It should not be mass-converted mechanically. Port behaviour first, then migrate individual modules/data with tests or replay comparisons.
