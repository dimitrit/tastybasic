SRCDIR=./src

tastybasic: tastybasic.img tastybasic.bin 

tastybasic.img: tastybasic.com 
	@rm -f tastybasic.img
	@mkfs.cpm -f wbw_fd144 tastybasic.img
	@cpmcp -f wbw_fd144 tastybasic.img $(SRCDIR)/tastybasic.com 0:tbasic.com

tastybasic.com: $(SRCDIR)/tastybasic.asm $(SRCDIR)/cpmio.asm
	@uz80as -tz80 -dCPM $(SRCDIR)/tastybasic.asm $(SRCDIR)/tastybasic.com $(SRCDIR)/tastybasic.com.lst

tastybasic.bin: $(SRCDIR)/tastybasic.asm $(SRCDIR)/zemuio.asm
	@uz80as -tz80 -dZEMU $(SRCDIR)/tastybasic.asm $(SRCDIR)/tastybasic.bin $(SRCDIR)/tastybasic.bin.lst

clean:
	@rm -f **/*.lst **/*.img **/*.com **/*.bin
