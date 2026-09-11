# Building on Linux Mint 22

The SNES and PC Engine ports are intended to build locally on Linux Mint 22.x (Ubuntu 24.04/Noble package base).

No GitHub Actions or other hosted CI is required.

## Install the toolchain

Use the helper script:

```sh
chmod +x scripts/setup-linux-mint22.sh
./scripts/setup-linux-mint22.sh
```

Or install the packages manually:

```sh
sudo apt update
sudo apt install build-essential make cc65 git python3
```

The important tools are:

- `ca65` — assembler, used with the 65816 target for SNES and HuC6280 target for PC Engine
- `ld65` — linker used to create the cartridge ROM images
- `make` — local build driver
- `python3` — deterministic ROM checks now, asset conversion later

## Build both ports

From the repository root:

```sh
make clean
make
```

Expected outputs:

```text
build/snes/boulder-dash.sfc
build/snes/boulder-dash.map
build/pce/boulder-dash.pce
build/pce/boulder-dash.map
```

The current bootstrap initializes video hardware and should show a deterministic dark-blue backdrop on both targets. That is intentional: it proves the reset, memory map, video initialization and frame loop before C64 character data is converted.

## Build and verify both ROMs

```sh
make clean
make verify
```

`make verify` runs `scripts/check-roms.py` locally. It checks:

- SNES ROM size is exactly 32 KiB
- SNES LoROM header/title bytes are present
- SNES reset vector points into linked ROM code
- PC Engine ROM size is exactly 8 KiB
- PC Engine reset vector points into linked ROM code

No emulator, network access, cloud service or CI runner is required for these checks.

## Build one target

SNES only:

```sh
make snes-rom
```

PC Engine only:

```sh
make pce-rom
```

Assembler-only checks remain available:

```sh
make snes-obj
make pce-obj
```

## Verify the local toolchain

```sh
make check
```

This checks that `ca65`, `ld65` and `python3` are installed and prints assembler/linker versions.

## Emulator smoke test

After `make verify`, load the generated ROMs in your preferred SNES and PC Engine emulators. At this milestone the expected result is a stable dark-blue screen; there is deliberately no Boulder Dash artwork yet.

If a target stays black, resets repeatedly or fails to boot, keep the generated `.map` file and emulator/debugger log. Those two files are the most useful inputs for fixing the startup path.

## Build philosophy

All required build steps must run locally on Linux Mint 22. Do not require GitHub Actions, cloud build services, Docker, Wine, or a Windows-only assembler.

Asset conversion tools are implemented as portable Python 3 scripts so the same `make` invocation can continue to build both ports on Linux Mint 22.

## Audio

Music and sound effects are currently deferred, but not removed from the architecture. The shared `platform_audio_tick` entry point remains reserved for the later SNES SPC700/DSP and PC Engine PSG implementations.
