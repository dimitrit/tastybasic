UNAME := $(shell uname)
VER := $(shell git describe --tags --abbrev=0)
APPDIR := .
BINDIR := ../../../Tools/$(UNAME)

ROMIMAGE := tastybasic.bin
ROMDEPS := tastybasic.asm romwbwio.asm
CPMCMD := tastybasic.com
CPMDEPS := tastybasic.asm cpmio.asm
CPMAPP := $(APPDIR)/tbasic.com
CPMIMAGE := tastybasic.img
NABUIMAGE := B.DSK

export PATH := $(BINDIR):${PATH}

all: $(ROMIMAGE) $(CPMCMD) | $(APPDIR)

$(ROMIMAGE): $(ROMDEPS)
	@uz80as -dROMWBW -d"VERSION \"$(VER)\"" $< $@ $(basename $<).lst
	
$(NABUIMAGE): $(CPMCMD)
	@dd if=/dev/zero of=$@ bs=512 count=16384 
	@mkfs.cpm -f naburn8mb $@
	@cpmcp -f naburn8mb $@ $(CPMCMD) 0:tbasic.com

$(CPMIMAGE): $(CPMCMD)
	@dd if=/dev/zero of=$@ bs=512 count=1440
	@mkfs.cpm -f wbw_fd144 $@
	@cpmcp -f wbw_fd144 $@ $(CPMCMD) 0:tbasic.com

$(CPMCMD): $(CPMDEPS)
	@uz80as -dCPM -d"VERSION \"$(VER)\"" $< $@ $(basename $<).lst

$(APPDIR): $(CPMCMD)
	@cat $(CPMCMD) > $(CPMAPP)

.PHONY: clean clobber $(APPDIR)

clean clobber:
	@rm -f *.lst *.img *.com *.bin *.DSK $(CPMAPP)
