# Sweet16
A C64 / Kick Assembler port of Steven Wozniak's ("Woz") 16-bit metaprocessor processor
- [Original BYTE Article](https://archive.org/stream/byte-magazine-1977-11-rescan/1977_11_BYTE_02-11_Memory_Mapped_IO#page/n151)
- [Text Only BYTE Article](http://amigan.1emu.net/kolsen/programming/sweet16.html)
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
One aspect of using SWEET16 which at first might appear to be problematic is debugging.  While working in assembler a lot of time is spent inspecting memory location and registers and SWEET16 is not forgiving in this regard.  The registers you are inspecting are arbitrary memory locations outside of the normal 6502 ones and breakpoints don't work as well as would initially be expecting due to this (you don't simply put a ```BRK``` in the SWEET16 code and load up the debugger).  When SWEET16 encounteres a  ```BK``` it executes the the ISR for break.   This is usually not setup unless debugging so I have added two ways to set this up to assist in debugging SWEET16 programs "natively".  They both make the assumption the developer has access to VICE and is not developing on native hardware for this part of the development as it installs an ISR that produces a breakpoint in a VICE format.  So when run in debug mode once the SWEET16 call ```BR``` is encountered the monitor will appear and the developer can inspect the state of the metaprocessor.   There are two ways to achieve this.

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
- [VICE JS](https://vice.janicek.co/c64/#%7B%22controlPort2%22%3A%22joystick%22%2C%22primaryControlPort%22%3A2%2C%22keys%22%3A%7B%22SPACE%22%3A%22%22%2C%22RETURN%22%3A%22%22%2C%22F1%22%3A%22%22%2C%22F3%22%3A%22%22%2C%22F5%22%3A%22%22%2C%22F7%22%3A%22%22%7D%2C%22files%22%3A%7B%22sweet16.prg%22%3A%22data%3A%3Bbase64%2CAQgLCB4AnjIwNjEAAACgHbq9SRmd%2FADK0PdM%2BRgzYQSFBRUGnXYH6NDq8QfWkHWF07YEUHJK7R9MUtII63%2BorpEiStsIjwyoR%2BmCnqsUVvaNrRb5IvZvJC0l10sm69on9eYpeoArvYstXpoxya8yXTTX8zXrdjj1mzldwTrlrzv4PNchPutVP%2FWJQHq5Qb3poiREu0JFXnFGoa9H2UrXE0zrQE31bU5ailBas1EgOUn6rp1V0LXeCGPIGQNaZhXIdagCOQegglCGgSqTzCD3rCHkKIWEIIdnIeRGZZArBlrOKqtOyWR0XWRYhWRUwCgcs5cOpf5jJv6EUIaBKhMDYZAJoOwAyFvJCrD59phIXzBoqK2rIjjpCv%2BI0Po%2FYEw3CgkwvgTc0n9rws71X0JUXK0%2FCg0%2FFlOth%2F9MzVRFOujDL6IgDddgKYAGAJhzTnajANUDTBHkL9VNR9gWXEm4aA5lrfJMHCA74qkhSLzs0SkP2Wu%2FUTXwC%2FWGwQxKqLljesdgo%2FK9ZiBIpfk0SmBH7PCI0v78mDjdgi2QiLkA9wOLE4z8K50coDWnP67%2F57dJwHPLXAz%2F69ZegSQQUw3%2F1fQDcAAA6kxRIPzpQcSF3clJfniPiiLevU2AlZGSnZTglcmE9lxgYVdkR4LtIN0sR1dWCR1KVdQSJZASbcSBskyoBCI7zuxFGNavUiM4L1NFF6oqy%2FVGmRhLmGkAV1W71JQyjax1oqTwkelRNQmlkOwfIRiwDvuJEAGId1QEmLhlo65JsOwbMBDoL8ow4RqB8Nh4ghW50M9WAPDEYOEKqrUXNV9J%2F9C59WCiGE82nBo1YM5n8A%2B2A6hT%2B7pmpEwJ0iL1IaHdhRfRGKDTAIQ0v2izraqj8AMgJn5sNQCN%2FWWOL4x7CFnyIdhg9hQYraZZrqdarIoiumCorqrR6bEUaKW0aoUkIDcVhY04AQ3MqOY5ojdgeoQDRTgBIyCURCIbIAHGpzehS5mlbgORIrKir4QAsUJI6TXQAub0NmBMKCBf0VNXGGIxujZ7%2Fx9VVE5FUujvEjRWeJr7vAABAgMEBQb%2FBwgJCgsMDQ7%2FDwFY%2FwjAAEL8WRqIMgeiHCPbqH%2BAwxH0d0uhaTgjy1Mjgpmdx%2F4FbUo6myNK5%2B9ARpsLxZ2YmyNK5u%2BwSsBUlfIjSjl%2FAMb8I0x4JEo0%2FweVIVHlPiSCzKxnfyWE%2BrtnkLRUUeVtJIvMEaH4P4co6bUkzD8OpWmKxlMxt0pMyCTnH%2B2Hq9okxGUMJebfAIgxFv4nuyX5504hyzvIclnS9%2FgQNBLHJTYPL4McbHBkOYslg%2B8f5bRlye%2BloKTTJXN2OcOkmeTnMtVFTOYl6dnlC7D4JcZlKibO7kOANTRKTEUmz65sh5tZcXN%2FJuWmhXYzRfTuqIULKpWerpwm7OkKjSHFqArzmiYb4%2BMm8Hk1FCRtAVQ5Gidr2ydHz9s0QEliJ2coUodKi%2F9QZIx1uUo5%2Fhxqh6y5J0oz%2FwCMw1FM1CdWOnv7uIboJ%2BKhDyjwmR5cnO%2BBJkVWWPM8hZMpjZhCKO8zHQHvIS11KOHGPmLckJyNdYDY2LGGayqeqrecKCBTUkNTn8TFxhrRVAX%2FKM2Nce8ouLwaJtINRpUmKXPTU1TvmxbGydtAoKRuKbPJXiFNcX8qcMaB3Bx5N6bck4x1xSkm796A6yjPSkzgKSevB0nQ9ClFmP3pGmqhQUaqT1Vp9U%2Fmdf9Cd2XJ8F5K%2BNg3yHJQRkFdQ1WoLRLyI2xwc5oqZoyKKsPl1btwSsFHysAqixm82oAqTwgr88n4KlVhFhkVCmMbblWON0CsLbFfK85VPHggY2mUTHorVc4eoX6Oxs%2B0K2T5HrtzvTKfEBa1UWV2Zvu%2B4XBdzkUVxucrZnxjxWZ4GpcsSmkEmzWzsQ4lG9tWsLFDUeVcfFO67%2FYHdm6kLM6NcZQIyUqQv7BK7qFyyywgRIDebiOkJODHgL695SzBRhMt1zNzA0hTJJyKFTEmd3YdS9Y4WGot59kNg8gYdCWvLYjX9qwQ0pmokszALdfMFjGxxiUENFBfqgUqZsoQBgBV%2B8M1Di%2BgezC72IUNMSofKfnISlUPTPst6QPMYaqx6j8uA8wDWDJJRkxaLunXtoGHiW6NJYXn0jFNTOlMTJxBzsouSvl8LoeJbey4jtmiSmr9Liv5S0zqTEwHQc41mVglhy%2Bhu1ehp0Sx5FsvINx%2B7Ovz4rlygpOgL87U5ZCwxWAsspKKo1FMtC%2F6OnPZuErkQ1tFL5%2F6PBHgYgKUTBMw%2Bs6CuRY5siaMLE0nTbq8I74gMnm5pTELbhsbW1NzzsYzyMYGxMYaSJy7MHNjHFYwG9vdcEq1HyniMOenleMFsbEG%2FDAXKs3GOhoxtnxvWDU2OaZRnJLVwt0EvEe6a0HOmTHZchyJloleuxhoqAx0zjENponmLZ1ebaPqCBTFSxXHr4KElV1e%2FbhK6jFxaQMylFYfApSheiLdw5Rs9TYyZeEjh5JRMs5CDkFpRrVQU4xkuTnhiYY1dtaoMlk4wSBjspTOfjIK7x7qLqHXqBL4mjKhYInCi6ENM%2BHsoIf3KMLRFcaULTMgWPOy9LYRvHBKpK1A0nUzStnuQLuGnop3MYg3B94NrTeaY8ydM8E75eAa1opM59IzwesOoWP7M%2BOrFAl1QUSh4BVbwUu4gjcuQc5cNBm8HEw0Bu9%2BhoBrRkCP59aGZVJBQ3rkNQReegh2ESdCsd%2FrgrBu77%2BFq6xElMM0IDDzxROst92DNIULZvE6%2BzTsXhxRMVAeuTn3bkNYMGNinTXdO3sgY2yUTH017l4PpJeKkahyqjUgRi8NxaFNNLo3xEFG1f01dC%2FihzXNeRTDRgFjoyfzN99PUE6t2aRC29%2F1x4WH%2BFTDDSaUEFMidU83lk8NOAbFwc8XYo42T6ZnnDaWf6xyY%2FQQ%2BIFBSa8259Byn0grwJ6KsVFMwjbEOnPnuErUNiy%2BN8STBx9kEIxMIdI3vtN7SOjYNahyTDdfvovpqmLDHSPqHWMQcZY3zo5xmBzjuHBK2UPlvDc%2FfC%2FrqpBcKK7sHjW22DfgoAbZWPaHN67HbyjY2BWYci0%2BULLd2yAwJ6YY4B55VkeQc3U4lhxlh2XKC5cDhI2BpE6uASJNUEFP3znJto4vFNfksHXqJdav%2BQYv2VxBxpHl4Th8G1Xp9I5YCI7kBvs4St85Ss97h0p1H4orMTw3SnfnUE5jgJ05Su8BGIqjTJs5SvT7h8yvmDnROeKDL%2F6zw1A15b7DC%2FxKV305HAGaRiuK7%2FnFUUhQwgQbJUmdOoUcOS6hWqgYS3Ncc8INgWturKA6s3C5QMaqKEy7Ol3o4uESz4oqofE6mXzrQwt4TUU7Ft4tEGGwVfTqB%2Fzf7yHCGg5RJTvOMKqGTB%2BkIOB%2BhmIAhpITP5R0bTuOH12HRjS5UG%2BMgLm5%2BG2luBmS68Q7HL8B3UoXD0zfO%2Bnx8wZwZfM7vGIV%2Fn1ZebNNT0Qifo%2FgOoWaJ0aRQDwgUvNUTv7XAfDkI1KCkoA8zkcOcGlGLBSCY5Nu7ri44WalVJXXPPk4IFpH4VFM8jz60RnDQQbjoCzTa8ch8UG9WVOXPOJeXbBKRpRhPbIzP3tQ0kk9tXKZuKy6omKrlEy8PW7l4XCVzj24AD7M1gEZGQpj5Rs%2BbfVC0NEv6OhXBJx1Tk9s3QBZGZGsfhHllT43fD%2BvUGU13T5bOc1cVu5xWd9FTPA%2B6VYOFWug6jQ%2FbB1NkDE%2BSkxPP7d6duhoY3R0iz%2B2Tpv4QVJZUwDHtYL%2FpQMCHqoxTsVwlbKIcsk%2Fo55D3KM4b%2BM%2FsNQRQCzlAXBJIkXFE5gkm5NuSVg2Y2idQKUDgTJyRkyDQOlSD6oHl42DvUDO0gkrpZpjLrBVo56XwF7uuF7bRNWL9ECZ20xSoz0fCqkA3cl%2F8PRMJvVBpR8TSjpBUCkxh0sqsp33RlRuTrp5YWaNdZiupAOxMoZKTLNButTawyUVx1VS7RPTRVNWRaOYJbVckQwl1hKIcilCJh9DKOlxQkxyYbhIglExc%2BaE5sgNqTeWY8idQskB4Rcp0kpM40InPQokNPdCJhtNFTmhHLAGRxlPrDwR5VNDHH1toKSbQ0pzvMNKig%2FFnZibQ0rGO6wSwFVl8kNKjgdg%2FIxDTEdESuMfEiGNiUZEzqhMMGF0CnylXyjKfmBrjSiCROfoA5wlyp1Eoxy6rqjbuKLMokzdRPQoAoc170QuIXOKDjrIGCshPEXvqGOHiVDGRHVF5%2BgEaYSUlAiUMq24SppEObFFSx%2FLqJL5mkWlHOlFlgqKivtFTAzxOekxhjUe1pFGSgdpZFqMTGvSRqUekioafxWlnbyy1Umj1iEtMbJeAo%2BwqbUJB28M3P71BbQkASHy3cJVyiLK4UaZfPtGYNIpR0xyGbhIOlExK%2BY85sgNYWtOrIBHMzmZIGOKlEybR%2Blue8K4SK%2BR0M1HGTLvSILKzVvj7AtS9I1HUQtIzM%2F8JUBJU%2Bc0PA5DaYpkUzFV5mbmqBuL1nhYqkhn6sOAjLRRTMVIOtXsw0UV2VVU8Egz9QqBnDhJM5UoScPq3VrwM0cGdmlK0HR1VM1LRUFL7t6CNYoWiqkijRcD%2BiB07f5ZSbH8ECMBCg1Kav9RkJZUh4yYuWA53r1wM6qqytxJYMwD9S6G5ihM90no3fYekLELEeUidDG6jGmJ2zxBzmrJWFqHjInMVYzI2HmIcpBKIDI6niM6RSYBOjmqQc7YSjl0HMhK%2B7Y3%2BlyM50rEjA1M31RCUnNDSN69K4aNFdBrFIUW3RpgJkvAViTVBPr71QtHVRs0MUdL7mqin%2BDgEHsLvcl13dnp8PPVe0vv%2BW2hpJtL88mL4TqsRcWdmJtLnhzTSi4eqjLyS58DCzL8S8bBTJ4eNBYaIQtJnTYV41RVPU5FRlJPTT2mlGLq%2FQwEAB5ZTBB4Vgv9RAt6AxtnVYBMzuZVQptIF6QY4Hg%2BkVYkJpoo6chMTOS4cBHZxUUUysulTF8iAIc17aLKH01MHDiQMSkeOk3evbVhh55O0XN0Zk3xQlP5%2FqHS11W%2BTVCbA0IQZU4%2FvfWgwsCGpHJWTX%2FrchU0rxLkNcBB1dXuTXzl3nBdRWpd8E3FTAHnrhsmbhNGww5qXQdeHBl1TO9Oeh2CEH3ITT9ns46FhXvGQqCnbUlYVEVXTkXfSlNS6mcsFpBPmtQ0qRLfDBXdIUNc89SFSoseK9tOqOdBTd%2FHc%2FVOYKojTxm2HBPSFDSnYiXMNs1i8VuGNUjWek9imQeTZISMTJXST2J5kBa8LlKpZDnEmH9WQUyb%2F20mUptDkdEE3k9HDM3NOvxPvJmZ%2Fk6pq%2B2FRyNFcRY6PjYnrkGcUTY1MDL3jjvg7U8lwP6HXFuCnIlQM%2BQ4ecxkjheraphGzb1Q%2BXgwRElvwENUuygPFjXmXEXTUVU08VAXLcws7JbFBQ0lO51RixwrrqJYKT3GTtxccXPDGmDrklFcHKuQMZxKTFVRi%2B5jhDkPMdTnwsGImORRMzRTnTBPUlnmsiODDCAOOyEA7u2rMw5n5g1cbfpRnDEYUm87Z1Qgd0VNOgD0piGkl%2BzDRibMxOzQqCHurCIvyQU8OQA7NIySYlLOLEZiOQIlFgHRFHOnYmTMdfVErgbgFd3QXa1PSKkB7BHIhprch4xoqo2GAky5X2pQUi9T6EFO9EuwRVlLKSBDT%2BlUSdJOVUUHLtbMn6Qg5NL%2FVfgtvYta8Acg0v%2Fov8NUTNRSDfqiAI7orSJgBxIJZGUFNEBQM9qrcCNzBjU0taxAYwMxQyG58BmZ%2FgeI0PcYqpgpD5loA%2FAMinlnA5loA6WeeZsDmZwDqQGFnql4IAABSqrwCQgGnjhqytD5KGqZNAMwBaWehp4kisjANNDBoNqg2opMlgEwAFJpgAoQDwb90AhIIBoBKoX9aCow8XABYDiFn60mAdADzicBziYBrfkYYJjQAsb%2FiCAaAZH%2Bygb90AYgGgEqhf3okPPw5eARsFe9MwMgAAF9ZwOFp6WffZsDhZ6mp6nx4AOwA72hAbggBQEYqqkAhZ%2B9NAMgAAF9aAOFrqWffZwDZf%2BFr6anmNAExv%2FGr4ixrpH%2BytDxpZ6Gn%2FCaxp5MhQFMEAjM8gEACwgKfJ4yMDY0rn0%2BlCBIyQLXWG6OIcXQqSC%2F%22%7D%2C%22vice%22%3A%7B%22-autostart%22%3A%22sweet16.prg%22%7D%7D)

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
