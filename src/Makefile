APPS := ../../../Binary/Apps

ROMIMAGE := tastybasic.bin
ROMDEPS := tastybasic.asm romwbwio.asm
CPMIMAGE := tastybasic.com
CPMDEPS := tastybasic.asm cpmio.asm
CPMAPP := $(APPS)/tbasic.com

all: $(ROMIMAGE) $(CPMAPP)

clean:
	@rm -f *.lst *.img *.com *.bin $(CPMAPP)

$(ROMIMAGE): $(ROMDEPS)
	@uz80as -dROMWBW tastybasic.asm tastybasic.bin tastybasic.bin.lst

$(CPMIMAGE): $(CPMDEPS)
	@uz80as -dCPM tastybasic.asm tastybasic.com tastybasic.com.lst

$(CPMAPP): $(CPMIMAGE)
	@cat $(CPMIMAGE) > $(CPMAPP)

.PHONY: clean
