CA65 ?= ca65
LD65 ?= ld65
PYTHON ?= python3
MEDNAFEN ?= mednafen

.PHONY: all check check-emulator assets snes-obj pce-obj snes-rom pce-rom verify run-snes run-pce run-both clean

all: snes-rom pce-rom

check:
	@command -v $(CA65) >/dev/null || (echo "error: ca65 not found; install cc65" && exit 1)
	@command -v $(LD65) >/dev/null || (echo "error: ld65 not found; install cc65" && exit 1)
	@command -v $(PYTHON) >/dev/null || (echo "error: python3 not found" && exit 1)
	@echo "ca65: $$($(CA65) --version 2>&1 | sed -n '1p')"
	@echo "ld65: $$($(LD65) --version 2>&1 | sed -n '1p')"

check-emulator:
	@command -v $(MEDNAFEN) >/dev/null || (echo "error: mednafen not found; install with: sudo apt install mednafen" && exit 1)
	@echo "mednafen: $$($(MEDNAFEN) -help 2>&1 | sed -n '1p' || true)"

assets: check
	@mkdir -p build/generated/snes build/generated/pce
	$(PYTHON) scripts/convert-charset.py B1_ChrS.asm --limit 64 \
		--snes-out build/generated/snes/charset.inc \
		--pce-out build/generated/pce/charset.inc

snes-obj: assets
	@mkdir -p build/snes
	cd src/common && $(CA65) --cpu 65816 game.s -o ../../build/snes/game.o
	cd src/common && $(CA65) --cpu 65816 cave_preview.s -o ../../build/snes/cave_preview.o
	cd src/snes && $(CA65) platform.s -o ../../build/snes/platform.o
	cd src/snes && $(CA65) startup.s -o ../../build/snes/startup.o
	@echo "built SNES objects (65C816)"

pce-obj: assets
	@mkdir -p build/pce
	cd src/common && $(CA65) --cpu huc6280 game.s -o ../../build/pce/game.o
	cd src/common && $(CA65) --cpu huc6280 cave_preview.s -o ../../build/pce/cave_preview.o
	cd src/pce && $(CA65) platform.s -o ../../build/pce/platform.o
	cd src/pce && $(CA65) startup.s -o ../../build/pce/startup.o
	@echo "built PCE objects (HuC6280)"

snes-rom: snes-obj
	$(LD65) -C cfg/snes-lorom.cfg -m build/snes/boulder-dash.map \
		-o build/snes/boulder-dash.sfc \
		build/snes/startup.o build/snes/game.o build/snes/cave_preview.o build/snes/platform.o
	@echo "built build/snes/boulder-dash.sfc"

pce-rom: pce-obj
	$(LD65) -C cfg/pce-hucard.cfg -m build/pce/boulder-dash.map \
		-o build/pce/boulder-dash.pce \
		build/pce/startup.o build/pce/game.o build/pce/cave_preview.o build/pce/platform.o
	@echo "built build/pce/boulder-dash.pce"

verify: all
	$(PYTHON) scripts/check-roms.py

run-snes: snes-rom check-emulator
	$(MEDNAFEN) build/snes/boulder-dash.sfc

run-pce: pce-rom check-emulator
	$(MEDNAFEN) build/pce/boulder-dash.pce

run-both: all check-emulator
	@echo "Starting SNES and PC Engine simultaneously in separate Mednafen processes..."
	@nohup $(MEDNAFEN) build/snes/boulder-dash.sfc >/tmp/boulder-dash-snes-mednafen.log 2>&1 & \
	 echo "SNES Mednafen PID: $$!"; \
	 nohup $(MEDNAFEN) build/pce/boulder-dash.pce >/tmp/boulder-dash-pce-mednafen.log 2>&1 & \
	 echo "PCE  Mednafen PID: $$!"; \
	 echo "Logs: /tmp/boulder-dash-{snes,pce}-mednafen.log"

clean:
	rm -rf build
