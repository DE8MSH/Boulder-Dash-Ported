CA65 ?= ca65

.PHONY: all check snes-obj pce-obj clean

all: snes-obj pce-obj

check:
	@command -v $(CA65) >/dev/null || (echo "error: ca65 not found; install cc65" && exit 1)
	@echo "ca65: $$($(CA65) --version 2>&1 | head -n 1)"

snes-obj: check
	@mkdir -p build/snes
	cd src/common && $(CA65) --cpu 65816 game.s -o ../../build/snes/game.o
	cd src/snes && $(CA65) platform.s -o ../../build/snes/platform.o
	@echo "built SNES portable core + platform objects (65C816)"

pce-obj: check
	@mkdir -p build/pce
	cd src/common && $(CA65) --cpu huc6280 game.s -o ../../build/pce/game.o
	cd src/pce && $(CA65) platform.s -o ../../build/pce/platform.o
	@echo "built PCE portable core + platform objects (HuC6280)"

clean:
	rm -rf build
