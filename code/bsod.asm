// http://sleepingelephant.com/ipw-web/bulletin/bb/viewtopic.php?t=4509#

// DEC2HEX
// Convert 8-bit binary in $fb to two hex characters in $fc and $fd
   // Conversion table
CHARS:
	.text "0123456789ABCDEF"

.const P0FREE = $fc

dec2hex:
    lax P0FREE            // Get the original byte into .A and .X (UNDOCUMENTED OPCODE)
    and #$0f              // Mask-off upper nybble
    tay                   // Stash index in .Y
    lda CHARS,y           // Get character
    sta P0FREE+2          // Save it in the hex string
    txa                   // Get the original byte again
    lsr                   // Shift right one bit
    lsr                   // Shift right one bit
    lsr                   // Shift right one bit
    lsr                   // Shift right one bit
    tay                   // Stash index in .Y
    lda CHARS,y           // Get character
    sta P0FREE+1          // Save it in the hex string
    rts

.macro DCPRINT(msg) {
	.const kernal_chrout = $ffd2    // kernel CHROUT subroutine
	ldx #$00
!loop:
	lda msg,x
	beq !done+
	jsr kernal_chrout
	inx
	jmp !loop-
!done:	
}

/*	
// DCPRINT address
// Created by Valarian
// Call the VIC-20 ROM 'PRINT' routine.
	// Parameters are:
//      address      - start address of zero-terminated string to print
	.macro DCPRINT(address) {

    lda #<(address)                                    // .A contains MSB of message start address
    ldy #>(address)                                    // .Y contains LSB of message start address
    jsr STROUT                                 // Call ROM routine
}
	*/
	
// BSODLITE
// Displays a mini-Blue Screen of Death with register information when BRK encountered.
// Note: set BRK vector at $0316-0317 to point to this routine
bsod:
    sei                              // Disable interrupts
    pla                              // Pull .Y from stack
    sta P0FREE      	            // Save to zero-page
    jsr dec2hex 	                 // Convert to hex
    lda P0FREE+1        	       // Copy to contents line
    sta bsodm6y
    lda P0FREE+2
    sta bsodm6y+1

    pla                              // Pull .X from stack
    sta P0FREE                  // Save to zero-page
    jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6x
    lda P0FREE+2
    sta bsodm6x+1

    pla                              // Pull .A from stack
    sta P0FREE                  // Save to zero-page
    jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6a
    lda P0FREE+2
    sta bsodm6a+1

    pla                              // Pull .SR from stack (BRK)
    sta P0FREE                  // Save to zero-page

    // Cycle the .SR bits out for the flags line
    lda #"1"                     // Bit-set indicator
    ldx #7                        // Flag character index in .X
cycle:
	ror   P0FREE                  // Sets/clears Carry to bit value
    bcc nextbit               // Carry clear, so skip to next bit
    sta bsodm8n,x            // Set bit indicator
nextbit:
	dex                              // Decrement flag character index
    bpl cycle                  // Loop for next bit if not all done
    ror   P0FREE                  // Final rotate to return to start value

    jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6sr
    lda P0FREE+2
    sta bsodm6sr+1

    pla                              // Pull .PCL from stack (BRK)
    sec                              // Set Carry
    sbc #2                        // Compensate PCL for BRK
    sta P0FREE                  // Save to zero-page
    bvc pchok                  // Overflow is clear when result >=0

    // If PCL underflowed when we subtracted 2, adjust PCH down as well
    pla                              // Pull .PCH from stack (BRK)
    sec                              // Set Carry
    sbc #1                        // Subtraction because PCL underflowed
    pha                              // Push it back to stack

pchok:
	jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6pc+2
    lda P0FREE+2
    sta bsodm6pc+3

    pla                              // Pull .PCH from stack (BRK)
    sta P0FREE                  // Save to zero-page
    jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6pc
    lda P0FREE+2
    sta bsodm6pc+1

    tsx                              // Move .SP to .X
    stx P0FREE                  // Save to zero-page
    jsr dec2hex                  // Convert to hex
    lda P0FREE+1               // Copy to contents line
    sta bsodm6sp
    lda P0FREE+2
    sta bsodm6sp+1

    jsr CINT1                     // Reset VIC
    lda #110                     // Blue screen
    sta SCRNCOL
    lda #1                        // White text
    sta   CURRCOL
    jsr CLRSCRN                  // Clear the screen

    dcprint bsodm3            // Register headings
    dcprint bsodm6            // Register contents

    jsr GONXTLN                  // Skip a line
    dcprint bsodm7            // Flags title
    dcprint bsodm8            // Flag bits

    //DC.B $02                     // HLT - stop CPU (UNDOCUMENTED OPCODE - not in DASM lexicon)
    jmp *                           // Endless loop - use if you don't want HLT

// Information message strings
bsodm3:
	.byte " PC  AC XR YR SP SR"
    .byte 13,10,0

bsodm6:	
bsodm6pc:
	.byte 4,"0000"
    .byte " "
bsodm6a:
	.byte 2,"00"
    .byte " "
bsodm6x:
	.byte 2,"00"
    .byte " "
bsodm6y:
	.byte 2,"00"
    .byte " "
bsodm6sp:
	.byte 2,"00"
    .byte " "
bsodm6sr:
	.byte 2,"00"
    .byte 13,10,0
bsodm7:
	.byte " SR: NV-BDIZC"
    .byte 13,10,0
bsodm8:
	.byte "     "
bsodm8n:
	.byte 1,"0"
bsodm8v:
	.byte 1,"0"
bsodm8u:
	.byte 1,"0"
bsodm8b:
	.byte 1,"0"
bsodm8d:
	.byte 1,"0"
bsodm8i:
	.byte 1,"0"
bsodm8z:
	.byte 1,"0"
bsodm8c:
	.byte 1,"0"
    .byte 0

