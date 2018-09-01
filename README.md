# Sweet16
A C64 / Kick Assembler port of Stephen Wozniak's ("Woz") 16-bit metaprocessor processor
- [Original Source Article](http://amigan.1emu.net/kolsen/programming/sweet16.html)
- [Porting](http://www.6502.org/source/interpreters/sweet16.htm)
- [Original Source Code](http://www.6502.org/source/interpreters/sweet16.htm#The_Story_of_Sweet_Sixteen)
- [S-C Macro Assembler](http://www.6502.org/source/interpreters/sweet16.htm#Sweet_16_S_C_Macro_Assembler_Tex)
- [Original Register Instructions](http://www.6502.org/source/interpreters/sweet16.htm#Register_Instructions_)
- [Original Detailed Description](http://www.6502.org/source/interpreters/sweet16.htm#SWEET_16_A_Pseudo_16_Bit_Micropr)
- [SWEET16 Introduction](http://www.6502.org/source/interpreters/sweet16.htm#SWEET_16_INTRODUCTION)
- [Atari Source Port](https://github.com/jefftranter/6502/blob/master/asm/sweet16/sweet16.s)

This project provides an implementation of Steve Wozniak's "SWEET16" ported to the C64 6502 / 6510 using the Kick Assembler.   Using Kick's scripting language features SWEET16 can more natively be coded using ```pseudocommands``` that better reflect Woz's original description.  Using an example from Jeff Tranter's Atari port of SWEET16:

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

Looking at the comments you can see the SWEET16 mnemonics but to actually have them execute correctly each needs to be converted into the a byte sequence of their opcodes and operands by hand.  So without the comments the code becomes at first glace straight assembler:

```
TEST:
  JSR SWEET16
  .BYTE $11,$00,$70,$12,$02,$70,$13,$01,$00
;LOOP:
  .BYTE $41,$52,$F3,$07,$FB,$00
```

Clearly this is not easy to maintain and coding in this manner is error prone.   However, using Kick's ```pseudocommands``` the following mnemonics produces the same SWEET16 opcodes / operands:

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

# Overview
In 1977, Stephen Wozniak wrote an article for BYTE magazine about a 16-bit "metaprocessor" that he had invented to deal with manipulating 16-bit values on an 8-bit CPU (6502) for the AppleBASIC he was writing at the time.  What he came up with was "SWEET16"  which he referred to "as a 6502 enhancement package, not a stand alone processor".  It defined sixteen 16-bit registers (R0 to R15) which under the bonnet were implemented as 32 memory locations located in zero page. Some of the registers were dual purpose (e.g., R0 doubled as the SWEET16 accumulator).  

SWEET16 instructions fell into register and nonregister categories with the register operations specifying one of the 16 registers to be used as either a data element or a pointer to data in memory depending on the specific instruction.  Except for the ``SET``` instruction, register operations only require one byte. The nonregister operations were primarily 6502 style branches with the second byte specifying a +/-127 byte displacement relative to the address of the following instruction. If a prior register operation result meets a specified branch condition, the displacement was added to SWEET16's program counter, effecting a branch.

The implementation of SWEET16 required a few key things to achieve this.   The first is that the implementation of all the instructions are located on the same 256 byte memory page.  This way a jumptable can be used which only needs to specify a single byte as they will all share a common high byte.  Another requirement is that the registers themselves are located in zero page.  (More information can be found in Carsten Strotmann [article](http://www.6502.org/source/interpreters/sweet16.htm)) detailing porting SWEET16.


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
<tr><td width="5%">&nbsp;</td><td width="12%">&nbsp;</td><td width="33%">&nbsp;</td><td width="5%">00</td><td width="12%">RTN</td><td width="33%">Return to 6502 mode</td></tr>
<tr><td>1n</td><td>SET n : val</td><td>Constant set value</td><td>01</td><td>BR ea</td><td>Branch always</td></tr>
<tr><td>2n</td><td>LD n</td><td>Load</td><td>02</td><td>BNC ea</td><td>Branch if No Carry</td></tr>
<tr><td>3n</td><td>ST n</td><td>Store</td><td>03</td><td>BC ea</td><td>Branch if Carry</td></tr>
<tr><td>4n</td><td>LDI n</td><td>Load indirect</td><td>04</td><td>BP ea</td><td>Branch if Plus</td></tr>
<tr><td>5n</td><td>STI n</td><td>Store indirect</td><td>05</td><td>BM ea</td><td>Branch if Minus</td></tr>
<tr><td>6n</td><td>LDDI n</td><td>Load double indirect</td><td>06</td><td>BZ ea</td><td>Branch if Zero</td></tr>
<tr><td>7n</td><td>STDI n</td><td>Store double indirect</td><td>07</td><td>BNZ ea</td><td>Branch if NonZero</td></tr>
<tr><td>8n</td><td>POPI n</td><td>Pop indirect</td><td>08</td><td>BM1 ea</td><td>Branch if Minus 1</td></tr>
<tr><td>9n</td><td>STPI n</td><td>Store Pop indirect</td><td>09</td><td>BNM1 ea</td><td>Branch if Not Minus 1</td></tr>
<tr><td>An</td><td>ADD n</td><td>Add</td><td>0A</td><td>BK</td><td>Break</td></tr>
<tr><td>Bn</td><td>SUB n</td><td>Subtract</td><td>0B</td><td>RS</td><td>Return from Subroutine</td></tr>
<tr><td>Cn</td><td>POPDI n</td><td>Pop double indirect</td><td>0C</td><td>BS ea</td><td>Branch to Subroutine</td></tr>
<tr><td>Dn</td><td>CPR n</td><td>Compare</td><td>0D</td><td><i>XJSR addr</i></td><td><i>Extension - Jump to External 6502 Subroutine</i></td></tr>
<tr><td>En</td><td>INR n</td><td>Increment</td><td>0E</td><td><i>SETM</i></td><td><i>Extension - Sets register with value from memory</i></td></tr>
<tr><td>Fn</td><td>DCR n</td><td>Decrement</td><td>0F</td><td><i>SETI</i></td><td>Extension - Set reguster with value from address (High / Low) as if the value at the address was a const to SET</td></tr>
<tr><td colspan="6"><b>SWEET16 Operation Code Summary:</b> Table 1 summarizes the list of SWEET16 operation codes.  They are executed after a call to the entry point SWEET16.  Return to the calling program and normal noninterpretive operation is accomplished with the RTN mnemonic of SWEET16.  These codes differ from Woz's original only in the removal of the redundant <b>R</b> for register numbers and the replacement of <b>I</b> instead of <b>@</b> to refer to indirect address mnemonics</td></tr>
</tbody></table>
