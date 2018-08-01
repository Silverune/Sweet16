# Sweet16
C64 Port of Stephen Wozniak's ("Woz") virtual 16-bit processor
- [Original Source Article](http://amigan.1emu.net/kolsen/programming/sweet16.html)
- [Porting and original source](http://www.6502.org/source/interpreters/sweet16.htm)
- [Atari Source Port](https://github.com/jefftranter/6502/blob/master/asm/sweet16/sweet16.s)

This project provides an implementation of Steve Wozniak's "SWEET-16" ported to the C64 6502 / 6510 using the Kick Assembler.   Using Kick's powerful language features SWEET-16 can more natively be coded using ```pseudocommands``` that better reflect Woz's original description.  Using an example from Jeff Tranter's Atari port of SWEET-16:

```
TEST:
   JSR SWEET16
  .BYTE $11,$00,$70 ; SET R1,$7000
  .BYTE $12,$02,$70 ; SET R2,$7002
  .BYTE $13,$01,$00 ; SET R3,1
;LOOP:
  .BYTE $41         ; LD @R1
  .BYTE $52         ; ST @R2
  .BYTE $F3         ; DCR R3
  .BYTE $07,$FB     ; BNZ LOOP
  .BYTE $00         ; RTN
```

Looking at the comments you can see the SWEET-16 opcodes but to actually have them execute correctly each needs to be converted into the byte sequence.  So without the comments the code becomes at first glace unreadable assembler:

```
TEST:
  JSR SWEET16
  .BYTE $11,$00,$70,$12,$02,$70,$13,$01,$00
;LOOP:
  .BYTE $41,$52,$F3,$07,$FB,$00
```

Clearly this is not easy to maintain and coding in this manner error prone.   However, using Kick's ```pseudocommands``` the following produces the same SWEET-16 code:

```
TEST:
  SWEET16
  SET 1 : $7000
  SET 2 : $7002
  SET 3 : $0001
LOOP:
  LDI 1
  STI 2
  DCR 3
  BNZ LOOP
  RTN
```

# Development
- Cross-Assembler [Kick Assembler v4.19](http://www.theweb.dk/KickAssembler/Main.html#frontpage)
- Emulator [VICE v3.1](http://vice-emu.sourceforge.net/)
- Editor [Emacs v25](https://www.gnu.org/software/emacs/)
- Tested platforms: OSX, Ubuntu

# Links
Collection of links related to the project development:
 - [Kick Assembler Reference](http://www.theweb.dk/KickAssembler/webhelp/content/cpt_Introduction.html)
 - [C64 Memory Map](http://sta.c64.org/cbm64mem.html)
 - [6502 Assembly Reference](http://www.obelisk.me.uk/6502/reference.html)
 - [6502 Addressing Modes](http://www.obelisk.me.uk/6502/addressing.html)
 - [Zero Page](https://www.c64-wiki.com/wiki/Zeropage)
 - [Markdown Reference](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
 - [VICE Options](https://github.com/rjanicek/vice.js/blob/master/vice-options.md)
 - [VICE Monitor](http://codebase64.org/doku.php?id=base:using_the_vice_monitor)
 - [VICE Monitor Commands](http://vice-emu.sourceforge.net/vice_12.html#SEC290)
 
# Opcode Reference

<table width="100%" border="">
<tbody><tr><td align="center" colspan="6"><b>SWEET16 OP CODE SUMMARY</b></td></tr>
<tr><td align="center" width="50%" colspan="3">Register Ops</td><td align="center" width="50%" colspan="3">Nonregister Ops</td></tr>
<tr><td width="5%">&nbsp;</td><td width="12%">&nbsp;</td><td width="33%">&nbsp;</td><td width="5%">00</td><td width="12%">RTN</td><td width="33%">(Return to 6502 mode)</td></tr>
<tr><td>1n</td><td>SET n</td><td>Constant (set)</td><td>01</td><td>BR ea</td><td>(Branch always)</td></tr>
<tr><td>2n</td><td>LD n</td><td>(Load)</td><td>02</td><td>BNC ea</td><td>(Branch if No Carry)</td></tr>
<tr><td>3n</td><td>ST n</td><td>(Store)</td><td>03</td><td>BC ea</td><td>(Branch if Carry)</td></tr>
<tr><td>4n</td><td>LDI n</td><td>(Load indirect)</td><td>04</td><td>BP ea</td><td>(Branch if Plus)</td></tr>
<tr><td>5n</td><td>STI n</td><td>(Store indirect)</td><td>05</td><td>BM ea</td><td>(Branch if Minus)</td></tr>
<tr><td>6n</td><td>LDDI n</td><td>(Load double indirect)</td><td>06</td><td>BZ ea</td><td>(Branch if Zero)</td></tr>
<tr><td>7n</td><td>STDI n</td><td>(Store double indirect)</td><td>07</td><td>BNZ ea</td><td>(Branch if NonZero)</td></tr>
<tr><td>8n</td><td>POPI n</td><td>(Pop indirect)</td><td>08</td><td>BM1 ea</td><td>(Branch if Minus 1)</td></tr>
<tr><td>9n</td><td>STPI n</td><td>(Store Pop indirect)</td><td>09</td><td>BNM1 ea</td><td>(Branch if Not Minus 1)</td></tr>
<tr><td>An</td><td>ADD n</td><td>(Add)</td><td>0A</td><td>BK ea</td><td>(Break)</td></tr>
<tr><td>Bn</td><td>SUB n</td><td>(Subtract)</td><td>0B</td><td>RS</td><td>(Return from Subroutine)</td></tr>
<tr><td>Cn</td><td>POPDI n</td><td>(Pop double indirect)</td><td>0C</td><td>BS ea</td><td>(Branch to Subroutine)</td></tr>
<tr><td>Dn</td><td>CPR n</td><td>(Compare)</td><td>0D</td><td>&nbsp;</td><td>(Unassigned)</td></tr>
<tr><td>En</td><td>INR n</td><td>(Increment)</td><td>0E</td><td>&nbsp;</td><td>(Unassigned)</td></tr>
<tr><td>Fn</td><td>DCR n</td><td>(Decrement)</td><td>0F</td><td>&nbsp;</td><td>(Unassigned)</td></tr>
<tr><td colspan="6"><b>SWEET16 Operation Code Summary:</b> Table 1 summarizes the list of SWEET16 operation codes.  They are executed after a call to the entry point SWEET16.  Return to the calling program and normal noninterpretive operation is accomplished with the RTN mnemonic of SWEET16.  These codes differ from Woz's original only in the removal of the redundant <b>R</b> for register numbers and the replacement of <b>I</b> instead of <b>@</b> to refer to indirect address mnemonics</td></tr>
</tbody></table>
