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

SWEET16 instructions fell into register and nonregister categories with the register operations specifying one of the 16 registers to be used as either a data element or a pointer to data in memory depending on the specific instruction.  Except for the ```SET``` instruction, register operations only require one byte. The nonregister operations were primarily 6502 style branches with the second byte specifying a +/-127 byte displacement relative to the address of the following instruction. If a prior register operation result meets a specified branch condition, the displacement was added to SWEET16's program counter, effecting a branch.

Any implementation of SWEET16 required a few key things to achieve this.   The first is that the implementation of all the instructions are located on the same 256 byte memory page.  In this implementation this was achieved by using Kick's ```!align $100``` command and then inserting a ```nop``` at the first address (see later).    This way a jumptable can be used which only needs to specify a single byte as they will all share a common high byte.  Another requirement is that the registers themselves are located in zero page due to the addressing modes required.  (More information can be found in Carsten Strotmann [article](http://www.6502.org/source/interpreters/sweet16.htm)) detailing porting SWEET16.

# Extensions
In addition to the standard SWEET16 mnemonics there was room for an additional 3 instructions which I have created in this implementation.  This is in addition to creating another ```pseudocommand``` that appears to be a SWEET16 call but is actually simply a macro calling two successive SWEET16 calls to provide the ability to perform an absolute jump.  These SWEET16 extensions are:

- ```XJSR``` - Provides a means to calling 6502 code while still executing code as if within the SWEET16 metaprocessor.  All state is kept intact within the SWEET16 virtual environment and after a ```RTS``` is executed in the regular 6502 code SWEET16 continues execution.   This was found to be invaluable in the test suite for outputting intermediate results.
- ```SETM``` - SWEET16 uses up half its mnemonics on setter routines which are only able to use direct absolute values.   The ```SETM``` extension allows an indirect memory address to be used which will have their values loaded directly into the register instead
- ```SETI``` - Very similar to ```SETM``` except that the byte ordering is High to Low which is how SWEET16 treats 16-bit values passed as constants to registers.

To elaborate:

```
SHOW_DIFFERECE:
	.const VAL_1 = $1234            // arbitrary number
	.const REGISTER = 5             // arbitrary register (location $0021)
	jmp !eg+
VAL_1_MEMORY:
	!byte $12, $34                  // same as VAL_1
!eg:
	SWEET16
	SET REGISTER : VAL_1            // assigns VAL_1 to register 5 - in memory:  34 12 ...
	SETM REGISTER : VAL_1_MEMORY    // assigns VAL_1_MEMORY memory to register 5: 12 34 ...
	SETI REGISTER : VAL_1_MEMORY    // assigns VAL_1_MEMORY high / low to register 5: 34 21 ...
	RTN
	rts
```

- ```AJMP``` - This is simply a convenience call which sets the SWEET16 PC to the values specified which causes a jump to the desired address.  To store this value in the PC it overwrites the value in the ACC register

# Convenience
There are a number of convenience routine created to make using and verifying SWEET16 more readily accessable:
- ```ibk``` - (see below) Installs an ISR handler for working with VICE and calling ```BK```
- ```ldyx``` - Loads the values from the passed in register to the ```X``` and ```Y``` registers.  This is handy for debugging when you want to quickly inspect what is happening in SWEET16

# Test Suite
Each of the SWEET16 has some unit style tests around them.  These are usually quite trivial and not exhaustive but they have proven to be suitable for catching game-changing breakages when my experiments have gone too far.   Some do rely on my extension ```XJSR``` due to the nature of needing to call a lot of 6502 code to output the intermediate results to the screen memory.   The other point looking at the branch tests is the need to place the jumps close within the calls themselves as the branches can only every be +/- 127 which causes issues when calling convenience routine to output to the display which can be quite a lot of code.

# SWEET16 code changes for C64
There were a few things I needed to do to bring it into the C64 world.  First was to find a place in Zero Page which wouldn't cause too much damage.  I start at $0017 and take the next 34 bytes for registers and a convience zero page location I use as part of the ```SETI``` / ```SETM``` implementations.  This clobbers some BASIC important values but that doesn't impact this work.

Its important to have the opcode lookup table all within the one page so that only a single address byte is required in the opcode itself.  It doesn't matter where else the subroutine calls after that as long as all 32 branches are on the same page.   As such some calls have had to be moved outside of this page to allow for the 3 new mnemonics.   All ```POP```, ```SET``` and ```RTN``` mnemonics have the bulk of their implementation moved out of page.   This costs a single jump but it is a difference from other SWEET16 implementations and if the extensions are not required these out of page jumps can be moved into page.

Another difference is the introduction of a ```nop``` at the start of the page containing all the mnemonics.  The reasons for this is that the Kick Assembler allows code to be page aligned which is done via the ```.align $100``` command.  This means it is now on a 256 byte page alignment.  However, SWEET16 uses ```JSR```'s as ```JMP``` by putting the address minus one onto the stack and then executing an ```RTS```.   In every case except being page aligned this works but the first call (```SET```) being page aligned at ```00``` in its low byte becomes ```ff``` after the minus one.  So to ensure this will always work a ```nop``` has been placed at the start of the table.   This is not a deficiency in SWEET16, rather an implementation detail that affected this particular port.

# Debugging
One aspect of using SWEET16 which at first might appear to be problematic is debugging.  While working in assembler a lot of time is spent inspecting memory location and registers and SWEET16 is not forgiving in this regard.  The registers you are inspecting are arbitrary memory locations outside of the normal 6502 ones and breakpoints don't work as well as would initially be expecting due to this (you don't simply put a ```BRK``` in the SWEET16 code and load up the debugger).   The implementations I've looked at for both Apple and Atari appear to be using a trick to inject the opcode for ```BRK``` (```00```) by making the jump table go to a location just after the ```LD``` implementation and execute a ```00```.  I instead made it a proper call and issue a ```BK``` which executes the the ISR for break.   This is usually not setup unless debugging so I have added two ways to set this up to assist in debugging SWEET16 programs "natively".  They both make the assumption the developer has access to VICE and is not developing on native hardware for this part of the development as it installs an ISR that produces a breakpoint in a VICE format.  So when run in debug mode once the SWEET16 call ```BR``` is encountered the monitor will appear and the developer can inspect the state of the metaprocessor.   There are two ways to achieve this.

- Start SWEET16 with the optional flag to install the interrupt routine: ```sweet16 : 1```
- While within SWEET16 execute the extension ```IBK``` which will ensure the ISR is installed (only needs to be done once - use ```BK``` from then onwards).

In either case once the command is encountered (and assuming using VICE) the monitor will show up at that point.   From this point it is important to realise that the user is in 6502 world (not SWEET16) so it is fine to inspect the mapped zero-page registers etc. which are all mapped in the debug output file ```breakpoints.txt``` However, once you continue execution the call will jump to ```SW16D``` which effectively continues where you left off back in the SWEET16 metaprocessor.

A more powerful alternative to this is using the extension of ```XJSR``` which will allow any 6502 routine to be called within SWEET16 execution to continue once it encounters a ```RTS```.

# Test Suite
I've added a rudimentary test suite based on Woz's original descriptions for each mnemonic.  Very few look 1:1 with the description but they are similar in vibe.  Often (to keep a single source of truth) I'll use a Kick ```.const``` instead of the original value so that I can pass the same value to an assert routine.   The end code is the same but code maintainability and the flexibility is more-so in 2018 than it was in 1977.  In total there are over 50 "unit" tests validating the original code, the extensions and my understanding of the metaprocessor.  I'm sure there is room for many more but I do think there are enough to give a vague guide to anyone putting their toes into SWEET16 for the first time some confidence about how it is meant to work.

# External Use
There are only four main files required to use this implementation of SWEET16:
- ```sweet16.asm```: the core implememtation with some extensions
- ```sweet16_pseudocommands.asm```: Kick Assembler pseudo commands to map mnemonics to SWEET16
- ```sweet16_macros.asm```: macro's used by the pseudo commands and core extensions
- ```sweet16_functions.asm```: functions used by the pseudo commands

# Screenshots
| Screen One | Screen Two |
| ------------- |:----------:|
| ![alt text](https://github.com/Silverune/Sweet16/blob/master/screenshots/first_test_screen.png "First Test Screen") | ![alt text](https://github.com/Silverune/Sweet16/blob/master/screenshots/second_test_screen.png "Second Test Screen") |

# Binaries
- .PRG format [sweet16.prg](https://github.com/Silverune/Sweet16/blob/master/build/sweet16.prg)
- .D64 format (1541 disk image) [sweet16.d64](https://github.com/Silverune/Sweet16/blob/master/build/sweet16.d64)

# Online Emulator
- VICE JS [Sweet16](https://vice.janicek.co/c64/#{%22controlPort2%22:%22joystick%22,%22primaryControlPort%22:2,%22keys%22:{%22SPACE%22:%22%22,%22RETURN%22:%22%22,%22F1%22:%22%22,%22F3%22:%22%22,%22F5%22:%22%22,%22F7%22:%22%22},%22files%22:{%22sweet16.zip%22:%22data:application/x-zip-compressed;base64,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%22},%22vice%22:{%22-autostart%22:%22sweet16.d64%22}})

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
