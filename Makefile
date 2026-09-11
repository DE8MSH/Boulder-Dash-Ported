CA65 ?= ca65
LD65 ?= ld65

.PHONY: all check snes-obj pce-obj snes-rom pce-rom clean

all: snes-rom pce-rom

check:
	@command -v $(CA65) >/dev/null || (echo "error: ca65 not found; install cc65" && exit 1)
	@command -v $(LD65) >/dev/null || (echo "error: ld65 not found; install cc65" && exit 1)
	@echo "ca65: $$($(CA65) --version 2>&1 | head -n 1)"
	@echo "ld65: $$($(LD65) --version 2>&1 | head -n 1)"

snes-obj: check
	@mkdir -p build/snes
	cd src/common && $(CA65) --cpu 65816 game.s -o ../../build/snes/game.o
	cd src/snes && $(CA65) platform.s -o ../../build/snes/platform.o
	cd src/snes && $(CA65) startup.s -o ../../build/snes/startup.o
	@echo "built SNES objects (65C816)"

pce-obj: check
	@mkdir -p build/pce
	cd src/common && $(CA65) --cpu huc6280 game.s -o ../../build/pce/game.o
	cd src/pce && $(CA65) platform.s -o ../../build/pce/platform.o
	cd src/pce && $(CA65) startup.s -o ../../build/pce/startup.o
	@echo "built PCE objects (HuC6280)"

snes-rom: snes-obj
	$(LD65) -C cfg/snes-lorom.cfg -m build/snes/boulder-dash.map \
		-o build/snes/boulder-dash.sfc \
		build/snes/startup.o build/snes/game.o build/snes/platform.o
	@echo "built build/snes/boulder-dash.sfc"

pce-rom: pce-obj
	$(LD65) -C cfg/pce-hucard.cfg -m build/pce/boulder-dash.map \
		-o build/pce/boulder-dash.pce \
		build/pce/startup.o build/pce/game.o build/pce/platform.o
	@echo "built build/pce/boulder-dash.pce"

clean:
	rm -rf build
