.importonce
.segment Util

.const kernal_chrout = $ffd2    // kernel CHROUT subroutine
.const border_color = $d020     // Border color
.const background_color = $d021 // Background color
.const foreground_color = $0286 // Cursor color
.const spacebar = $20           // Code for the SPACEBAR
.const cursor_col = $00D3
.const cursor_row = $00D6
.const NULL = $00
.const RETURN = $0D

.macro LoadAddress(address, lowByte) {
	LoadAddressFull(address, lowByte, lowByte + 1)
}

.macro LoadAddressFull(address, lowByte, highByte) {
	lda #<address
    sta lowByte
    lda #>address 
    sta highByte
}

.macro WordAddr(addr) {
    //*=addr virtual
    .label lo = *       // naming consistency with .lohifill
    .label hi = *+1     // naming consistency with .lohifill
	.word $0000
}

.macro LoHi(value) {
    .label lo = *       // naming consistency with .lohifill
    .label hi = *+1     // naming consistency with .lohifill
    .byte <value, >value
}

/*

// ZpVariables.One		$fb/$fc - L/H source address
// ZpVariables.Two 		$fd/$fe - L/H destination address
// ZpVariables.Three 	$4e/$4f - L/H source end address
.macro CopyMemoryZeroPage() {
 	ldy #$00
!comp:
   tya
   clc
   adc ZpVariables.One.lo
   bcs !overflow+

   cmp ZpVariables.Three.lo
   bne !loop+
   ldx ZpVariables.One.hi
   cpx ZpVariables.Three.hi
   beq !done+
   jmp !loop+

 !overflow:
   cmp ZpVariables.Three.lo  // overflow with end address
   bne !loop+
   ldx ZpVariables.One.hi  
   inx
   cpx ZpVariables.Three.hi
   beq !done+

!loop:
	lda (ZpVariables.One.lo),y 
	sta (ZpVariables.Two.lo),y
	iny
 	bne !comp-				// next block
    inc ZpVariables.One.hi 	// inc MSB source 
    inc ZpVariables.Two.hi 	// inc MSB dest 
    jmp !comp-
!done:
}
*/
// ZpVariables.One		$fb/$fc - L/H source address
// ZpVariables.Two		$fd/$fe - L/H destination address
// ZpVariables.Three	$4e/$4f - L/H size
// ZpVariables.Four		$50/$51 - used by routine
.macro CopyMemoryZeroPageSize() {
	ldy #$00
   	sty ZpVariables.Four.lo     // LSB size
   	sty ZpVariables.Four.hi     // MSH size
!loop:
   	lda ZpVariables.Three.hi
   	cmp ZpVariables.Four.hi
   	beq !msb_match+
!copy:   
   	lda (ZpVariables.One.lo),y 
	sta (ZpVariables.Two.lo),y
	inc ZpVariables.Four.lo
   	beq inc_msb
!cont:
   	iny
   	bne !loop-
!next:
   	inc ZpVariables.One.hi 	// inc MSB source 
   	inc ZpVariables.Two.hi 	// inc MSB dest 
 	jmp !loop-

inc_msb:
   	inc ZpVariables.Four.hi
   	jmp !cont-

!msb_match:
   	lda ZpVariables.Three.lo
   	cmp ZpVariables.Four.lo
   	beq !done+
   	jmp !copy-

!done:
}

/*

// can probably make this a pseudo-command and detect terminating and map to list()
.macro LoadZeroPageAddresses(first, second, third) {
	LoadAddress(first, ZpVariables.One)
	LoadAddress(second, ZpVariables.Two)
	LoadAddress(third, ZpVariables.Three)
	//jsr CopyMemoryZeroPageSize
}
*/
/*
ScreenBuffer:
.memblock "ScreenBuffer"
	CreateBuffer($40)

CopyMemoryZeroPageSize:
	CopyMemoryZeroPageSize()
	rts


.macro CopyMemory(source, dest, length) {
	LoadZeroPageAddresses(source, dest, length)

}
*/

.macro ASDF() {
	lda ZpVariables.One.lo
}

.macro CopyToManagedBuffer(sourceAddr, managedBuffer, size) {
	// sanity check here not too large
	LoadAddress(sourceAddr, ZpVariables.One)
	LoadAddress(managedBuffer.buffer, ZpVariables.Two)
	LoadAddress(size, ZpVariables.Three)

	CopyMemoryZeroPageSize()

	// update managed
	lda #<size
	sta managedBuffer.allocSize.lo
	lda #>size
	sta managedBuffer.allocSize.hi
}

.macro Newline() {
	.byte RETURN, NULL
}

.macro ChangeCursor(row, column) {
	lda #row
	sta cursor_row
	lda #column
	sta cursor_col
	KernalOutput(newline)	// need return to ensure pointers $d1 and $f3 update
	jmp !done+
newline:
	Newline()
!done:
}

.macro ChangeBorder(color) {
	lda #color
	sta border_color
}

.macro ChangeBackground(color) {
	lda #color
	sta background_color
}

.macro ChangeColor(color) {
	lda #color
	sta foreground_color
}

.macro ChangeScreen(background_color, foreground_color) {
	ChangeBorder(background_color)
	ChangeBackground(background_color)
	ChangeColor(foreground_color)
}

.macro Hex2Petscii() {
	ora #$30
}

// y contains the loop counter
.macro CalcReference(value, reference) {
	lda value
	cmp #reference
	bcc !done+
	ldy #$00		// counter
!loop:
	iny				// count references's
	sbc #reference
	cmp #reference
	bcs !loop-		// still larger than reference
!done:
}
	
.macro OutputNumber2Digit(value) {
	.const two_digit = $0a
	.const zp = $fe
	lda value
	cmp #two_digit
	bcc !oneDigit+
	CalcReference(value, two_digit)
	tya
	pha
	Hex2Petscii() 					// display value
	KernalOutputA()
	pla
	tay
	lda value
!subby:
	sec
	sbc #two_digit
	dey
	bne !subby-
	Hex2Petscii() 					// display value
	KernalOutputA()
	jmp !done+
!oneDigit:
	Hex2Petscii() 					// display value
	KernalOutputA()
!done:	
}

// output to the screen the value stored at the passed in address
// only up to 255 is supported	
.macro OutputNumber(value) {
	.const three_digit = $64
	.const zp = $fe
	lda value
	cmp #three_digit
	bcc !twoDigit+
	CalcReference(value, three_digit)
	tya
	pha
	Hex2Petscii() 					// display value
	KernalOutputA()
	pla
	tay
	lda value
!subby:
	sec
	sbc #three_digit
	dey
	bne !subby-
	sta zp
	OutputNumber2Digit(zp)
	jmp !done+
!twoDigit:
	OutputNumber2Digit(value)
!done:	
}

.macro ClearScreen(color) {
	.const screen = $0400       // Default memory location of screen RAM	
	.const background_color = $d021 // Background color
	ldx #color
	stx background_color
	lda #spacebar
	ldx #$00
!loop:
	sta screen,x
	sta screen+$100,x
	sta screen+$200,x
	sta screen+$300,x
	inx
	bne !loop-
}

// KarnAl spelt the way CBM intended (for better or worse)
.macro KernalOutput(msg) {
	ldx #$00
!loop:
	lda msg,x
	beq !done+
	jsr kernal_chrout
	inx
	jmp !loop-
!done:	
}

// KarnAl spelt the way CBM intended (for better or worse)
.macro KernalOutputA() {
	jsr kernal_chrout
}

.macro OutputInColor(msg, color) {
	lda foreground_color
	pha
	ChangeColor(color)
	KernalOutput(msg)
	pla
	sta foreground_color
}

.segment Default