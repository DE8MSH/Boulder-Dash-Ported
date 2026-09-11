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
- `python3` — reserved for deterministic asset conversion scripts (C64 charset/cave data -> console-native data)

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

This checks that both `ca65` and `ld65` are installed and prints their versions.

## Build philosophy

All required build steps must run locally on Linux Mint 22. Do not require GitHub Actions, cloud build services, Docker, Wine, or a Windows-only assembler.

Later asset conversion tools should be implemented as portable Python 3 scripts so the same `make` invocation continues to build both ports on Linux Mint 22.

## Audio

Music and sound effects are currently deferred, but not removed from the architecture. The shared `platform_audio_tick` entry point remains reserved for the later SNES SPC700/DSP and PC Engine PSG implementations.
