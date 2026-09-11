CA65 ?= ca65
LD65 ?= ld65
PYTHON ?= python3
MEDNAFEN ?= mednafen

.PHONY: all check check-emulator assets snes-obj pce-obj snes-rom pce-rom selfplay verify run-snes run-pce run-both clean

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
	@mkdir -p build/generated/snes build/generated/pce build/generated/common
	$(PYTHON) scripts/convert-charset.py B1_GfxS.asm --source-format gfx --limit 124 \
		--snes-out build/generated/snes/charset.inc \
		--pce-out build/generated/pce/charset.inc
	$(PYTHON) scripts/inject-benchmark-font.py \
		build/generated/snes/charset.inc \
		build/generated/pce/charset.inc
	$(PYTHON) scripts/generate-cave1.py \
		build/generated/common/cave1.inc \
		build/generated/pce/cave1_bat.inc
	$(PYTHON) scripts/generate-rom-autoplay.py build/generated/common/autoplay.inc

snes-obj: assets
	@mkdir -p build/snes
	$(PYTHON) scripts/prepare-timed-source.py game src/common/game.s src/common/.game-snes-build.s --step 4 --threshold 11
	cd src/common && $(CA65) --cpu 65816 .game-snes-build.s -o ../../build/snes/game.o
	@rm -f src/common/.game-snes-build.s
	cd src/common && $(CA65) --cpu 65816 game_autoplay.s -o ../../build/snes/game_autoplay.o
	cd src/common && $(CA65) --cpu 65816 game_flow.s -o ../../build/snes/game_flow.o
	cd src/common && $(CA65) --cpu 65816 game_progress.s -o ../../build/snes/game_progress.o
	cd src/common && $(CA65) --cpu 65816 cave_preview.s -o ../../build/snes/cave_preview.o
	cd src/snes && $(CA65) benchmark.s -o ../../build/snes/benchmark.o
	cd src/snes && $(CA65) platform.s -o ../../build/snes/platform.o
	cd src/snes && $(CA65) startup.s -o ../../build/snes/startup.o
	@echo "built SNES objects (65C816)"

pce-obj: assets
	@mkdir -p build/pce
	$(PYTHON) scripts/prepare-timed-source.py game src/common/game.s src/common/.game-pce-build.s --step 4 --threshold 12
	cd src/common && $(CA65) --cpu huc6280 .game-pce-build.s -o ../../build/pce/game.o
	@rm -f src/common/.game-pce-build.s
	cd src/common && $(CA65) --cpu huc6280 game_autoplay.s -o ../../build/pce/game_autoplay.o
	cd src/common && $(CA65) --cpu huc6280 game_flow.s -o ../../build/pce/game_flow.o
	cd src/common && $(CA65) --cpu huc6280 game_progress.s -o ../../build/pce/game_progress.o
	cd src/common && $(CA65) --cpu huc6280 cave_preview.s -o ../../build/pce/cave_preview.o
	cd src/pce && $(CA65) benchmark.s -o ../../build/pce/benchmark.o
	$(PYTHON) scripts/prepare-timed-source.py pce src/pce/platform.s src/pce/.platform-build.s --reload 0x7f
	cd src/pce && $(CA65) .platform-build.s -o ../../build/pce/platform.o
	@rm -f src/pce/.platform-build.s
	cd src/pce && $(CA65) startup.s -o ../../build/pce/startup.o
	@echo "built PCE objects (HuC6280)"

snes-rom: snes-obj
	$(LD65) -C cfg/snes-lorom.cfg -m build/snes/boulder-dash.map \
		-o build/snes/boulder-dash.sfc \
		build/snes/startup.o build/snes/game.o build/snes/game_autoplay.o build/snes/game_flow.o build/snes/game_progress.o build/snes/cave_preview.o build/snes/benchmark.o build/snes/platform.o
	@echo "built build/snes/boulder-dash.sfc"

pce-rom: pce-obj
	$(LD65) -C cfg/pce-hucard.cfg -m build/pce/boulder-dash.map \
		-o build/pce/boulder-dash.pce \
		build/pce/startup.o build/pce/game.o build/pce/game_autoplay.o build/pce/game_flow.o build/pce/game_progress.o build/pce/cave_preview.o build/pce/benchmark.o build/pce/platform.o
	@echo "built build/pce/boulder-dash.pce"

selfplay: check
	$(PYTHON) scripts/selfplay-regression.py

verify: all
	$(PYTHON) scripts/check-roms.py
	$(PYTHON) scripts/selfplay-regression.py

run-snes: snes-rom check-emulator
	$(MEDNAFEN) build/snes/boulder-dash.sfc

run-pce: pce-rom check-emulator
	$(MEDNAFEN) build/pce/boulder-dash.pce

run-both: all check-emulator
	@echo "Starting SNES and PC Engine simultaneously in separate Mednafen processes..."
	@nohup $(MEDNAFEN) build/snes/boulder-dash.sfc >/tmp/boulder-dash-snes-mednafen.log 2>&1 & \
	 echo "SNES Mednafen PID: $$!"; \
	 nohup $(MEDNAFEN) build/pce/boulder-dash.pce >/tmp/boulder-dash-pce-mednafen.log 2>&1 & \
	 echo "PCE Mednafen PID: $$!"; \
	 echo "Logs: /tmp/boulder-dash-{snes,pce}-mednafen.log"

clean:
	rm -rf build
	rm -f src/common/.game-snes-build.s src/common/.game-pce-build.s src/pce/.platform-build.s
