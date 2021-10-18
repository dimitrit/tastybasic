UNAME := $(shell uname)
APPDIR := $(wildcard ../../../Binary/Apps)
BINDIR := ../../../Tools/$(UNAME)

ROMIMAGE := tastybasic.bin
ROMDEPS := tastybasic.asm romwbwio.asm
CPMIMAGE := tastybasic.com
CPMDEPS := tastybasic.asm cpmio.asm
CPMAPP := $(APPDIR)/tbasic.com

export PATH := $(BINDIR):${PATH}

all: $(ROMIMAGE) $(CPMIMAGE) | $(APPDIR)

clean:
	@rm -f *.lst *.img *.com *.bin $(CPMAPP)

$(ROMIMAGE): $(ROMDEPS)
	@uz80as -dROMWBW tastybasic.asm tastybasic.bin tastybasic.bin.lst

$(CPMIMAGE): $(CPMDEPS)
	@uz80as -dCPM tastybasic.asm tastybasic.com tastybasic.com.lst

$(APPDIR): $(CPMIMAGE)
	@cat $(CPMIMAGE) > $(CPMAPP)

.PHONY: clean $(APPDIR)
