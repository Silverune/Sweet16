# Sweet16

A Commodore 64 implementation of Steve Wozniak's *Sweet16* 16-bit metaprocessor processor using *Kick Assembler*

# Overview
In 1977, Steve Wozniak wrote an article for BYTE magazine about a 16-bit "metaprocessor" that he had invented to deal with manipulating 16-bit values on an 8-bit CPU (6502) for the *AppleBASIC* he was writing at the time.  What he came up with was "*Sweet16*"  which he referred to "*as a 6502 enhancement package, not a stand alone processor*".  It defined sixteen 16-bit registers (```R0``` to ```R15```) which under the bonnet were implemented as 32 contiguous memory locations located in zero page. Some of the registers were dual purpose (e.g., ```R0``` doubled as the *Sweet16* accumulator).  

The *Sweet16* instructions fell into register and nonregister categories with the register operations specifying one of the 16 registers to be used as either a data element or a pointer to data in memory depending on the specific instruction.  Except for the ```SET``` instruction, register operations only required one byte. The nonregister operations were primarily 6502 style branches with the second byte specifying a +/-127 byte displacement relative to the address of the following instruction. If a prior register operation result met a specified branch condition, the displacement was added to *Sweet16*'s program counter, effecting a branch.

# Kick Assembler
This project provides an implementation of Steve Wozniak's "*Sweet16*" ported to the Commodore 64 using *Kick Assembler* which provides powerful scripting language features via ```.pseudocommand``` and ```.macro``` allowing *Sweet16* programs to be more natively coded that better reflect the metaprocessor's original description.  An assumption is made the reader underestands *Sweet16* and 6502 assembler.

One of the downsides of using the original *Sweet16* implementation without convenience helpers is the fact that it is built on top of the existing 6502 mnemonics and has no native assembler support so using it requires the user to hand-roll conversion from *Sweet16* to a byte sequence for use by the *Sweet16* routines. 

An example of some 6502 generic code showing the equivalent *Sweet16* operations in the comments:

```
eg:
   jsr SWEET16
  .byte $11,$00,$12 // SET R1,$1200
  .byte $12,$34,$00 // SET R2,$0034
!:                  // 
  .byte $41         // LD @R1
  .byte $52         // ST @R2
  .byte $F3         // DCR R3
  .byte $07,$FB     // BNZ !-
  .byte $00         // RTN
```

Looking at the equivalent *Sweet16* mnemonics (in comments) to have them execute correctly each needs to be converted into a byte sequence of their opcodes and operands by hand.  So without the comments the code becomes at first glace straight machine code:

```
eg:
  jsr SWEET16
  .byte $11,$00,$12,$12,$34,$00,$41,$52,$F3,$07,$FB,$00
```

Code like this is not easy to maintain / modify and coding in this manner is error prone.   However, using *Kick Assembler's* ```pseudocommands``` the following mnemonics can produce the same *Sweet16* opcodes / operands:

```
eg:
  SWEET16
  SET 1 : $1200
  SET 2 : $0034
!:
  LDI 1
  STI 2
  DCR 3
  BNZ !-
  RTN
```
## Details
Any implementation of *Sweet16* requires a few key things.   
 * The implementation of all the instructions are located on the same 256 byte memory page.  The code itself can contain subroutines outside of this however the initial jump table subroutine must sit within this page.  In this implementation this was achieved by using *Kick Assembler's* ```!align $100``` command to ensure the code was page aligned and then inserting a ```nop``` as the first address (see later).    This way a jumptable can be used which only needs to specify a single byte as they all share a common high byte.
  * The registers themselves are located in zero page due to the addressing modes required.  (More information can be found in Carsten Strotmann [article](http://www.6502.org/source/interpreters/sweet16.htm)) detailing porting *Sweet16*.

# Extensions
As Wozniak stated in the original article "...*I leave it to readers to explore further possibilities for SWEET16*.".  For this implementation I have added two different types of extensions:
 1. *Macro Extensions* - implemented as convenience ```.macro``` calls which simply chain *Sweet16* calls to achieve a single outcome
 2. *New Instructions* - first class extensions utilizing the 3 additional instruction slots remaining in the original specification.

# Macro extensions
- ```AJMP``` - This is simply a convenience call which sets the *Sweet16* PC to the values specified which causes a jump to the desired address.  To store this value in the PC it overwrites the value in the ACC register
- ```IBK``` - (see below) Installs an ISR handler for working with VICE and calling ```BK```
- ```LDXY``` - Loads the values from the passed in register to the ```X``` and ```Y``` registers.  This is handy for debugging when you want to quickly inspect what is happening in *Sweet16*

# New Instructions
- ```XJSR``` - Provides a means to calling 6502 code while still executing code as if within the *Sweet16* metaprocessor.  All state is kept intact within the *Sweet16* virtual environment and after a ```RTS``` is executed in the regular 6502 code *Sweet16* continues execution.   This was found to be invaluable in the test suite for outputting intermediate results.
- ```SETM``` - *Sweet16* uses up half its mnemonics on setter routines which are only able to use direct absolute values.   The ```SETM``` extension allows an indirect memory address to be used which will have their values loaded directly into the register instead
- ```SETI``` - Very similar to ```SETM``` except that the byte ordering is High to Low which is how *Sweet16* treats 16-bit values passed as constants to registers.

To elaborate:

```
eg:
	.const REGISTER = 5             // arbitrary register
	jmp !+
!:
	SWEET16
	SET REGISTER : $1234            // assigns value to register - in memory:  34 12 ...
	SETM REGISTER : !data+          // assigns data memory to register: 12 34 ...
	SETI REGISTER : !data+          // assigns data high / low to register: 34 12 ...
	RTN
	rts
!data:
	.byte $12, $34                  
```
# Test Suite
Each of the *Sweet16* instructions have unit style tests to validate them.  These are quite trivial and not exhaustive but they have proven to be suitable for catching game-changing breakages when my experiments have gone too far.   Some do rely on the extension ```XJSR``` due to the nature of needing to call a lot of 6502 code to output the intermediate results to the screen memory.

# *Sweet16* code changes for Commodore 64
There were a few things done to bring *Sweet16* into the Commodore world.  First was to find a place in Zero Page which wouldn't cause too much damage.  Assuming the user is not attempting to use ```BASIC``` it should be safe to store it in 32-bytes starting from ```$0002``` all the way up ```008f```.  If using *Sweet16's* subroutine functionality (optionally installed) then the stack pointer storage needs to be specified which is also within this block.

Its important to have the opcode lookup table all within the one page so that only a single address byte is required in the opcode itself.  It doesn't matter where else the subroutine calls after that as long as all 32 branches are on the same page.   As such some calls have had to be moved outside of this page to allow for the 3 new mnemonics.   All ```POP```, ```SET``` and ```RTN``` mnemonics have the bulk of their implementation moved out of page.   This costs a single jump but it is a difference from other *Sweet16* implementations and if the extensions are not required these out of page jumps can be moved into page.

Another difference is the introduction of a ```nop``` at the start of the page containing all the mnemonics.  The reasons for this is that the *Kick Assembler* allows code to be page aligned which is done via the ```.align $100``` command.  This means it is now on a 256 byte page alignment.  However, *Sweet16* uses ```JSR```'s as ```JMP``` by putting the address minus one onto the stack and then executing an ```RTS```.   In every case except being page aligned this works but the first call (```SET```) being page aligned at ```$00``` in its low byte becomes ```$ff``` after the minus one.  So to ensure this will always work a ```nop``` has been placed at the start of the table.   This is not a deficiency in *Sweet16*, rather an implementation detail that affected this particular port.

The original (and other ports) tends to use specific memory locations to store the calling state which I've opted instead to use the stack as an alternate place to (optionally) store the current state before calling *Sweet16* rather than have to specifiy an alternate memory location.  This has minimal impact but simplifies moving *Sweet16* to other locations.

Lastly, the original implementation required " _...the user must initialize and otherwise not disturb R12 if the *Sweet16* subroutine capability is used since it is utilized as the automatic subroutine return stack pointer..._".  This is can now be taken care of as part of the initialization to ensure that usage of this functionality does not crash the program using uninitialized memory if the user had not already known to set this up.  This can be enabled by passing a non-zero value as the first argument to the pseudocommand.  e.g., ```sweet16 : 1```

# Debugging
One aspect of using *Sweet16* which at first might appear to be problematic is debugging.  While working in assembler a lot of time is spent inspecting memory location and registers and *Sweet16* is not forgiving in this regard.  The registers being inspected are arbitrary memory locations outside of the normal 6502 ones and breakpoints don't work as well as would initially be expecting due to this (you don't simply put a ```BRK``` in the *Sweet16* code and load up the debugger).  When *Sweet16* encounteres a  ```BK``` it executes the the ISR for break.   This is usually not setup unless debugging so have added two ways to set this up to assist in debugging *Sweet16* programs "natively".  They both make the assumption the developer has access to VICE and is not developing on native hardware for this part of the development as it installs an ISR that produces a breakpoint in a VICE format.  When run in debug mode once the *Sweet16* call ```BR``` is encountered the monitor will appear and the developer can inspect the state of the metaprocessor.   There are two ways to achieve this.

- Start *Sweet16* with the optional flag to install the interrupt routine: ```sweet16 : 0: 1```
- While within *Sweet16* execute the extension ```IBK``` which will ensure the ISR is installed (only needs to be done once - use ```BK``` from then onwards).

In either case, once the command is encountered (and assuming using VICE) the monitor will show up at that point.   From this point it is important to realise that the user is in 6502 world (not *Sweet16*) so it is fine to inspect the mapped zero-page registers etc. which are all mapped in the debug output file ```breakpoints.txt``` However, once you continued execution the call will jump to ```Sweet16_Exexcute``` which continues where the break left off in the *Sweet16* metaprocessor.

A more powerful alternative to this is using the extension of ```XJSR``` which will allow any 6502 routine to be called within *Sweet16* execution to continue once it encounters an ```RTS```.

# Test Suite
Added is a rudimentary test suite based on Wozniak's original descriptions for each mnemonic.  Very few look 1:1 with the description but they are similar in vibe.  Often (to keep a single source of truth) used is a *Kick Assembler* ```.const``` instead of the original value so that it can pass the same value to an assert routine.   The end code is the same but code maintainability and the flexibility is more-so today than it was in 1977.  In total there are over 50 "unit" tests validating the original code, the extensions and my understanding of the metaprocessor.  I'm sure there is room for many more but there are enough to give a vague guide to anyone putting their toes into *Sweet16* for the first time some confidence about how it is meant to work.

# External Use
There are only a handful of main files required to use this implementation of *Sweet16* which are part of the *Core* library:
- ```sweet16_const.asm```: configuration
- ```sweet16.asm```: the core implememtation with some extensions
- ```sweet16_pseudocommands.asm```: Kick Assembler pseudo commands to map mnemonics to *Sweet16*
- ```sweet16_macros.asm```: macro's used by the pseudo commands and core extensions
- ```sweet16_functions.asm```: functions used by the pseudo commands

# Screenshots
| Screen One | Screen Two |
| ------------- |:----------:|
| ![alt text](https://github.com/Silverune/Sweet16/blob/master/screenshots/first_test_screen.png "First Test Screen") | ![alt text](https://github.com/Silverune/Sweet16/blob/master/screenshots/second_test_screen.png "Second Test Screen") |

# Binaries
- .PRG format [sweet16.prg](https://github.com/Silverune/Sweet16/blob/master/bin/sweet16.prg)
- .D64 format (1541 disk image) [sweet16.d64](https://github.com/Silverune/Sweet16/blob/master/bin/sweet16.d64)
- .B64 format (Base64 zip encoded) [sweet16.b64](https://github.com/Silverune/Sweet16/blob/master/bin/sweet16.b64)

# Online Emulator
- [VICE JS](https://vice.janicek.co/c64/#%7B%22controlPort2%22%3A%22joystick%22%2C%22primaryControlPort%22%3A2%2C%22keys%22%3A%7B%22SPACE%22%3A%22%22%2C%22RETURN%22%3A%22%22%2C%22F1%22%3A%22%22%2C%22F3%22%3A%22%22%2C%22F5%22%3A%22%22%2C%22F7%22%3A%22%22%7D%2C%22files%22%3A%7B%22sweet16.prg%22%3A%22data%3A%3Bbase64%2CAQgLCB4AnjIwNjEAAACgHbq9SRmd%2FADK0PdM%2BRgzYQSFBRUGnXYH6NDq8QfWkHWF07YEUHJK7R9MUtII63%2BorpEiStsIjwyoR%2BmCnqsUVvaNrRb5IvZvJC0l10sm69on9eYpeoArvYstXpoxya8yXTTX8zXrdjj1mzldwTrlrzv4PNchPutVP%2FWJQHq5Qb3poiREu0JFXnFGoa9H2UrXE0zrQE31bU5ailBas1EgOUn6rp1V0LXeCGPIGQNaZhXIdagCOQegglCGgSqTzCD3rCHkKIWEIIdnIeRGZZArBlrOKqtOyWR0XWRYhWRUwCgcs5cOpf5jJv6EUIaBKhMDYZAJoOwAyFvJCrD59phIXzBoqK2rIjjpCv%2BI0Po%2FYEw3CgkwvgTc0n9rws71X0JUXK0%2FCg0%2FFlOth%2F9MzVRFOujDL6IgDddgKYAGAJhzTnajANUDTBHkL9VNR9gWXEm4aA5lrfJMHCA74qkhSLzs0SkP2Wu%2FUTXwC%2FWGwQxKqLljesdgo%2FK9ZiBIpfk0SmBH7PCI0v78mDjdgi2QiLkA9wOLE4z8K50coDWnP67%2F57dJwHPLXAz%2F69ZegSQQUw3%2F1fQDcAAA6kxRIPzpQcSF3clJfniPiiLevU2AlZGSnZTglcmE9lxgYVdkR4LtIN0sR1dWCR1KVdQSJZASbcSBskyoBCI7zuxFGNavUiM4L1NFF6oqy%2FVGmRhLmGkAV1W71JQyjax1oqTwkelRNQmlkOwfIRiwDvuJEAGId1QEmLhlo65JsOwbMBDoL8ow4RqB8Nh4ghW50M9WAPDEYOEKqrUXNV9J%2F9C59WCiGE82nBo1YM5n8A%2B2A6hT%2B7pmpEwJ0iL1IaHdhRfRGKDTAIQ0v2izraqj8AMgJn5sNQCN%2FWWOL4x7CFnyIdhg9hQYraZZrqdarIoiumCorqrR6bEUaKW0aoUkIDcVhY04AQ3MqOY5ojdgeoQDRTgBIyCURCIbIAHGpzehS5mlbgORIrKir4QAsUJI6TXQAub0NmBMKCBf0VNXGGIxujZ7%2Fx9VVE5FUujvEjRWeJr7vAABAgMEBQb%2FBwgJCgsMDQ7%2FDwFY%2FwjAAEL8WRqIMgeiHCPbqH%2BAwxH0d0uhaTgjy1Mjgpmdx%2F4FbUo6myNK5%2B9ARpsLxZ2YmyNK5u%2BwSsBUlfIjSjl%2FAMb8I0x4JEo0%2FweVIVHlPiSCzKxnfyWE%2BrtnkLRUUeVtJIvMEaH4P4co6bUkzD8OpWmKxlMxt0pMyCTnH%2B2Hq9okxGUMJebfAIgxFv4nuyX5504hyzvIclnS9%2FgQNBLHJTYPL4McbHBkOYslg%2B8f5bRlye%2BloKTTJXN2OcOkmeTnMtVFTOYl6dnlC7D4JcZlKibO7kOANTRKTEUmz65sh5tZcXN%2FJuWmhXYzRfTuqIULKpWerpwm7OkKjSHFqArzmiYb4%2BMm8Hk1FCRtAVQ5Gidr2ydHz9s0QEliJ2coUodKi%2F9QZIx1uUo5%2Fhxqh6y5J0oz%2FwCMw1FM1CdWOnv7uIboJ%2BKhDyjwmR5cnO%2BBJkVWWPM8hZMpjZhCKO8zHQHvIS11KOHGPmLckJyNdYDY2LGGayqeqrecKCBTUkNTn8TFxhrRVAX%2FKM2Nce8ouLwaJtINRpUmKXPTU1TvmxbGydtAoKRuKbPJXiFNcX8qcMaB3Bx5N6bck4x1xSkm796A6yjPSkzgKSevB0nQ9ClFmP3pGmqhQUaqT1Vp9U%2Fmdf9Cd2XJ8F5K%2BNg3yHJQRkFdQ1WoLRLyI2xwc5oqZoyKKsPl1btwSsFHysAqixm82oAqTwgr88n4KlVhFhkVCmMbblWON0CsLbFfK85VPHggY2mUTHorVc4eoX6Oxs%2B0K2T5HrtzvTKfEBa1UWV2Zvu%2B4XBdzkUVxucrZnxjxWZ4GpcsSmkEmzWzsQ4lG9tWsLFDUeVcfFO67%2FYHdm6kLM6NcZQIyUqQv7BK7qFyyywgRIDebiOkJODHgL695SzBRhMt1zNzA0hTJJyKFTEmd3YdS9Y4WGot59kNg8gYdCWvLYjX9qwQ0pmokszALdfMFjGxxiUENFBfqgUqZsoQBgBV%2B8M1Di%2BgezC72IUNMSofKfnISlUPTPst6QPMYaqx6j8uA8wDWDJJRkxaLunXtoGHiW6NJYXn0jFNTOlMTJxBzsouSvl8LoeJbey4jtmiSmr9Liv5S0zqTEwHQc41mVglhy%2Bhu1ehp0Sx5FsvINx%2B7Ovz4rlygpOgL87U5ZCwxWAsspKKo1FMtC%2F6OnPZuErkQ1tFL5%2F6PBHgYgKUTBMw%2Bs6CuRY5siaMLE0nTbq8I74gMnm5pTELbhsbW1NzzsYzyMYGxMYaSJy7MHNjHFYwG9vdcEq1HyniMOenleMFsbEG%2FDAXKs3GOhoxtnxvWDU2OaZRnJLVwt0EvEe6a0HOmTHZchyJloleuxhoqAx0zjENponmLZ1ebaPqCBTFSxXHr4KElV1e%2FbhK6jFxaQMylFYfApSheiLdw5Rs9TYyZeEjh5JRMs5CDkFpRrVQU4xkuTnhiYY1dtaoMlk4wSBjspTOfjIK7x7qLqHXqBL4mjKhYInCi6ENM%2BHsoIf3KMLRFcaULTMgWPOy9LYRvHBKpK1A0nUzStnuQLuGnop3MYg3B94NrTeaY8ydM8E75eAa1opM59IzwesOoWP7M%2BOrFAl1QUSh4BVbwUu4gjcuQc5cNBm8HEw0Bu9%2BhoBrRkCP59aGZVJBQ3rkNQReegh2ESdCsd%2FrgrBu77%2BFq6xElMM0IDDzxROst92DNIULZvE6%2BzTsXhxRMVAeuTn3bkNYMGNinTXdO3sgY2yUTH017l4PpJeKkahyqjUgRi8NxaFNNLo3xEFG1f01dC%2FihzXNeRTDRgFjoyfzN99PUE6t2aRC29%2F1x4WH%2BFTDDSaUEFMidU83lk8NOAbFwc8XYo42T6ZnnDaWf6xyY%2FQQ%2BIFBSa8259Byn0grwJ6KsVFMwjbEOnPnuErUNiy%2BN8STBx9kEIxMIdI3vtN7SOjYNahyTDdfvovpqmLDHSPqHWMQcZY3zo5xmBzjuHBK2UPlvDc%2FfC%2FrqpBcKK7sHjW22DfgoAbZWPaHN67HbyjY2BWYci0%2BULLd2yAwJ6YY4B55VkeQc3U4lhxlh2XKC5cDhI2BpE6uASJNUEFP3znJto4vFNfksHXqJdav%2BQYv2VxBxpHl4Th8G1Xp9I5YCI7kBvs4St85Ss97h0p1H4orMTw3SnfnUE5jgJ05Su8BGIqjTJs5SvT7h8yvmDnROeKDL%2F6zw1A15b7DC%2FxKV305HAGaRiuK7%2FnFUUhQwgQbJUmdOoUcOS6hWqgYS3Ncc8INgWturKA6s3C5QMaqKEy7Ol3o4uESz4oqofE6mXzrQwt4TUU7Ft4tEGGwVfTqB%2Fzf7yHCGg5RJTvOMKqGTB%2BkIOB%2BhmIAhpITP5R0bTuOH12HRjS5UG%2BMgLm5%2BG2luBmS68Q7HL8B3UoXD0zfO%2Bnx8wZwZfM7vGIV%2Fn1ZebNNT0Qifo%2FgOoWaJ0aRQDwgUvNUTv7XAfDkI1KCkoA8zkcOcGlGLBSCY5Nu7ri44WalVJXXPPk4IFpH4VFM8jz60RnDQQbjoCzTa8ch8UG9WVOXPOJeXbBKRpRhPbIzP3tQ0kk9tXKZuKy6omKrlEy8PW7l4XCVzj24AD7M1gEZGQpj5Rs%2BbfVC0NEv6OhXBJx1Tk9s3QBZGZGsfhHllT43fD%2BvUGU13T5bOc1cVu5xWd9FTPA%2B6VYOFWug6jQ%2FbB1NkDE%2BSkxPP7d6duhoY3R0iz%2B2Tpv4QVJZUwDHtYL%2FpQMCHqoxTsVwlbKIcsk%2Fo55D3KM4b%2BM%2FsNQRQCzlAXBJIkXFE5gkm5NuSVg2Y2idQKUDgTJyRkyDQOlSD6oHl42DvUDO0gkrpZpjLrBVo56XwF7uuF7bRNWL9ECZ20xSoz0fCqkA3cl%2F8PRMJvVBpR8TSjpBUCkxh0sqsp33RlRuTrp5YWaNdZiupAOxMoZKTLNButTawyUVx1VS7RPTRVNWRaOYJbVckQwl1hKIcilCJh9DKOlxQkxyYbhIglExc%2BaE5sgNqTeWY8idQskB4Rcp0kpM40InPQokNPdCJhtNFTmhHLAGRxlPrDwR5VNDHH1toKSbQ0pzvMNKig%2FFnZibQ0rGO6wSwFVl8kNKjgdg%2FIxDTEdESuMfEiGNiUZEzqhMMGF0CnylXyjKfmBrjSiCROfoA5wlyp1Eoxy6rqjbuKLMokzdRPQoAoc170QuIXOKDjrIGCshPEXvqGOHiVDGRHVF5%2BgEaYSUlAiUMq24SppEObFFSx%2FLqJL5mkWlHOlFlgqKivtFTAzxOekxhjUe1pFGSgdpZFqMTGvSRqUekioafxWlnbyy1Umj1iEtMbJeAo%2BwqbUJB28M3P71BbQkASHy3cJVyiLK4UaZfPtGYNIpR0xyGbhIOlExK%2BY85sgNYWtOrIBHMzmZIGOKlEybR%2Blue8K4SK%2BR0M1HGTLvSILKzVvj7AtS9I1HUQtIzM%2F8JUBJU%2Bc0PA5DaYpkUzFV5mbmqBuL1nhYqkhn6sOAjLRRTMVIOtXsw0UV2VVU8Egz9QqBnDhJM5UoScPq3VrwM0cGdmlK0HR1VM1LRUFL7t6CNYoWiqkijRcD%2BiB07f5ZSbH8ECMBCg1Kav9RkJZUh4yYuWA53r1wM6qqytxJYMwD9S6G5ihM90no3fYekLELEeUidDG6jGmJ2zxBzmrJWFqHjInMVYzI2HmIcpBKIDI6niM6RSYBOjmqQc7YSjl0HMhK%2B7Y3%2BlyM50rEjA1M31RCUnNDSN69K4aNFdBrFIUW3RpgJkvAViTVBPr71QtHVRs0MUdL7mqin%2BDgEHsLvcl13dnp8PPVe0vv%2BW2hpJtL88mL4TqsRcWdmJtLnhzTSi4eqjLyS58DCzL8S8bBTJ4eNBYaIQtJnTYV41RVPU5FRlJPTT2mlGLq%2FQwEAB5ZTBB4Vgv9RAt6AxtnVYBMzuZVQptIF6QY4Hg%2BkVYkJpoo6chMTOS4cBHZxUUUysulTF8iAIc17aLKH01MHDiQMSkeOk3evbVhh55O0XN0Zk3xQlP5%2FqHS11W%2BTVCbA0IQZU4%2FvfWgwsCGpHJWTX%2FrchU0rxLkNcBB1dXuTXzl3nBdRWpd8E3FTAHnrhsmbhNGww5qXQdeHBl1TO9Oeh2CEH3ITT9ns46FhXvGQqCnbUlYVEVXTkXfSlNS6mcsFpBPmtQ0qRLfDBXdIUNc89SFSoseK9tOqOdBTd%2FHc%2FVOYKojTxm2HBPSFDSnYiXMNs1i8VuGNUjWek9imQeTZISMTJXST2J5kBa8LlKpZDnEmH9WQUyb%2F20mUptDkdEE3k9HDM3NOvxPvJmZ%2Fk6pq%2B2FRyNFcRY6PjYnrkGcUTY1MDL3jjvg7U8lwP6HXFuCnIlQM%2BQ4ecxkjheraphGzb1Q%2BXgwRElvwENUuygPFjXmXEXTUVU08VAXLcws7JbFBQ0lO51RixwrrqJYKT3GTtxccXPDGmDrklFcHKuQMZxKTFVRi%2B5jhDkPMdTnwsGImORRMzRTnTBPUlnmsiODDCAOOyEA7u2rMw5n5g1cbfpRnDEYUm87Z1Qgd0VNOgD0piGkl%2BzDRibMxOzQqCHurCIvyQU8OQA7NIySYlLOLEZiOQIlFgHRFHOnYmTMdfVErgbgFd3QXa1PSKkB7BHIhprch4xoqo2GAky5X2pQUi9T6EFO9EuwRVlLKSBDT%2BlUSdJOVUUHLtbMn6Qg5NL%2FVfgtvYta8Acg0v%2Fov8NUTNRSDfqiAI7orSJgBxIJZGUFNEBQM9qrcCNzBjU0taxAYwMxQyG58BmZ%2FgeI0PcYqpgpD5loA%2FAMinlnA5loA6WeeZsDmZwDqQGFnql4IAABSqrwCQgGnjhqytD5KGqZNAMwBaWehp4kisjANNDBoNqg2opMlgEwAFJpgAoQDwb90AhIIBoBKoX9aCow8XABYDiFn60mAdADzicBziYBrfkYYJjQAsb%2FiCAaAZH%2Bygb90AYgGgEqhf3okPPw5eARsFe9MwMgAAF9ZwOFp6WffZsDhZ6mp6nx4AOwA72hAbggBQEYqqkAhZ%2B9NAMgAAF9aAOFrqWffZwDZf%2BFr6anmNAExv%2FGr4ixrpH%2BytDxpZ6Gn%2FCaxp5MhQFMEAjM8gEACwgKfJ4yMDY0rn0%2BlCBIyQLXWG6OIcXQqSC%2F%22%7D%2C%22vice%22%3A%7B%22-autostart%22%3A%22sweet16.prg%22%7D%7D)
# Opcode Reference

<table width="100%" border="">
<tbody><tr><td align="center" colspan="6"><b>*Sweet16* OP CODE SUMMARY</b></td></tr>
<tr><td width="5%">00</td><td width="12%">RTN</td><td width="33%">Return to 6502 mode</td><td width="5%">&nbsp;</td><td width="12%">&nbsp;</td><td width="33%">&nbsp;</td></tr>
<tr><td>01</td><td>BR ea</td><td>Branch always</td><td>1n</td><td>SET n : val</td><td>Constant set value</td></tr>
<tr><td>02</td><td>BNC ea</td><td>Branch if No Carry</td><td>2n</td><td>LD n</td><td>Load</td></tr>
<tr><td>03</td><td>BC ea</td><td>Branch if Carry</td><td>3n</td><td>ST n</td><td>Store</td></tr>
<tr><td>04</td><td>BP ea</td><td>Branch if Plus</td><td>4n</td><td>LDI n</td><td>Load indirect</td></tr>
<tr><td>05</td><td>BM ea</td><td>Branch if Minus</td><td>5n</td><td>STI n</td><td>Store indirect</td></tr>
<tr><td>06</td><td>BZ ea</td><td>Branch if Zero</td><td>6n</td><td>LDDI n</td><td>Load double indirect</td></tr>
<tr><td>07</td><td>BNZ ea</td><td>Branch if Non Zero</td><td>7n</td><td>STDI n</td><td>Store double indirect</td></tr>
<tr><td>08</td><td>BM1 ea</td><td>Branch if Minus 1</td><td>8n</td><td>POPI n</td><td>Pop indirect</td></tr>
<tr><td>09</td><td>BNM1 ea</td><td>Branch if Not Minus 1</td><td>9n</td><td>STPI n</td><td>Store Pop indirect</td></tr>
<tr><td>0A</td><td>BK</td><td>Break</td><td>An</td><td>ADD n</td><td>Add</td></tr>
<tr><td>0B</td><td>RS</td><td>Return from Subroutine</td><td>Bn</td><td>SUB n</td><td>Subtract</td></tr>
<tr><td>0C</td><td>BS ea</td><td>Branch to Subroutine</td><td>Cn</td><td>POPDI n</td><td>Pop double indirect</td></tr>
<tr><td>0D</td><td><i>XJSR ea</i></td><td><i>Extension - Jump to External 6502 Subroutine</i></td><td>Dn</td><td>CPR n</td><td>Compare</td></tr>
<tr><td>0E</td><td><i>SETM ea</i></td><td><i>Extension - Sets register with value from memory</i></td><td>En</td><td>INR n</td><td>Increment</td></tr>
<tr><td>0F</td><td><i>SETI ea</i></td><td>Extension - Set reguster with value from address (High / Low) as if the value at the address was a const to SET</td><td>Fn</td><td>DCR n</td><td>Decrement</td></tr>
<tr><td colspan="6"><b>*Sweet16* Operation Code Summary:</b> Table 1 summarizes the list of *Sweet16* operation codes.  They are executed after a call to the entry point *Sweet16*.  Return to the calling program and normal noninterpretive operation is accomplished with the RTN mnemonic of *Sweet16*.  These codes differ from Woz's original only in the removal of the redundant <b>R</b> for register numbers and the replacement of <b>I</b> instead of <b>@</b> to refer to indirect address mnemonics</td></tr>
</tbody></table>

## Essential Links
- [Original BYTE Article](https://archive.org/stream/byte-magazine-1977-11-rescan/1977_11_BYTE_02-11_Memory_Mapped_IO#page/n151) [TXT](http://amigan.1emu.net/kolsen/programming/sweet16.html)
- [Kick Assembler](http://theweb.dk/KickAssembler/Main.html)

## Other Implementations
- [Porting](http://www.6502.org/source/interpreters/sweet16.htm)
- [Atari Source Port](https://github.com/jefftranter/6502/blob/master/asm/sweet16/sweet16.s)
