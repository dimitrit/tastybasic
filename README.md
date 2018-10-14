# Tasty Basic

## Introduction
Tasty Basic is a basic interpreter for the SBC v2, based on the Z80 port of Palo Alto Tiny Basic
([Gabbard, 2017; Rauskolb, 1976; Wang, 1976](##References)).

## Tasty Basic Language
The Tasty Basic language is based on Palo Alto Tiny Basic, as described in the December 1976
issue of Interface Age ([Rauskolb, 1976](##References)). As such, Tasty Basic shares many of the
same limitations as Palo Alto Basic. All numbers are integers and must be less than or
equal to 32767, and support for only 26 variables denoted by letters A through Z. In addition
to Tiny Basic's `ABS(n)`, `RND(n)` and `SIZE` functions, however, Tasty Basic provides functions
to read and write memory locations, and allows interaction with I/O ports.

### Functions
Tasty Basic provides the following functions to read from and write to memory locations and I/O ports:

  `PEEK(m)` Returns the byte value of address location _m_

  `POKE m,n` Writes the value _n_ to address location _m_

  `INP(m)` Returns the byte read from I/O port _m_

  `OUT m,n` Sends the value n to I/O port _m_

  `USR(i)`  Accepts a numeric expression _i_ , calls a user-defined machine language routine, and returns the resulting value.

#### Example
The following example shows _TODO_

```
10 DATA 1,2,3,4,5
20 FOR I=1 TO 5
30 READ A
40 POKE 100+I,A
50 NEXT I
60 INPUT P
70 Q=USR(P)
80 PRINT "The something of", P, "is", Q
```

## Building the ROM image

Building the ROM image requires TASM (Telemark Assembler).

## Running in Z80 Emulator
Tasty Basic can be run in the Z80 Emulator ([Moore, 2015](##References)) when it is built with
the `-Dzemu` flag:

```tasm.exe -t80 -g3 -fFF -Dzemu tastybasic.asm tastybasic.bin tastybasic.lst```

Then load the resulting `tastybasic.bin` image in the emulator at address 0, bank 0.

Before running, ensure that the `TTY0` device is configured as following in the Z80 Emulator:

**I/O Devices**

| Device | CRT | TTY | COM | NET | Printer | Spooler |
|-------:|:---:|:---:|:---:|:---:|:-------:|:-------:|
| TTY 0  |     |  x  |     |     |         |         |

**I/O Properties for device 0**

|              | Bit | State | Status |
|--------------|:---:|:-----:|:------:|
| RxFull       | 1   | 1     | 00     |
| TxEmpty      | 0   | 1     |        
| RxFull IntE  | N/A |        
| TxEmpty IntE | N/A |         

## License
In line with Wang's (1976) original Tiny Basic source listing and later derived works
by Rauskolb (1976) and Gabbard (2017), Tasty Basic is licensed under GPL v3.
For license details refer to the enclosed [LICENSE](../LICENSE) file.

## References
b1ackmai1er (2018). _SBC V2_. Retrieved  October 6, 2018, from [https://www.retrobrewcomputers.org/doku.php?id=boards:sbc:sbc_v2:start](https://www.retrobrewcomputers.org/doku.php?id=boards:sbc:sbc_v2:start)  
Gabbard, D. (2017, October 10). _TinyBASIC for the z80 – TinyBASIC 2.0g._ Retrieved September 29, 2108, from [http://retrodepot.net/?p=274](http://retrodepot.net/?p=274)  
Moore, W. J. (2015). _Z80 Emulator_ [Computer software]. Retrieved October 6, 2018, from [https://amaus.org/static/S100/cromemco/emulator/latest.zemuemulator.rar](https://amaus.org/static/S100/cromemco/emulator/latest.zemuemulator.rar)  
Rauskolb, P. (1976, December). _DR. WANG'S PALO ALTO TINY BASIC._ Interface Age, (2)1, 92-108. Retrieved from [https://archive.org/stream/InterfaceAge197612/Interface%20Age%201976-12#page/n93/mode/1up](https://archive.org/stream/InterfaceAge197612/Interface%20Age%201976-12#page/n93/mode/1up)  
Wang, L-C. (1976). Palo Alto Tiny BASIC. In J. C. Warren Jr. (Ed.), _Dr. Dobb's Journal of COMPUTER Calisthenics & Orthodontia_ (pp. 129-142). Menlo Park, CA: People's Computer Company
