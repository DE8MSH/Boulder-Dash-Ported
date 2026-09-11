# Boulder-Dash-Ported

Porting project for the Boulder Dash I C64/6502 source in this repository.

Targets:

- Super Nintendo / Super Famicom (65C816)
- PC Engine / TurboGrafx-16 (HuC6280)

The original root-level assembly sources remain the behaviour reference. New platform-independent and console-specific code lives under `src/`.

See [`PORTING.md`](PORTING.md) for the architecture, milestones and build notes.

## Bootstrap build

A recent cc65 installation is required. The first project stage only assembles the target backends as a CPU/toolchain smoke test; bootable ROM linker layouts and hardware initialization are the next milestone.

```sh
make check
make snes-obj
make pce-obj
```
