#importonce

.segment Util

.macro Newline() {
	.byte Petscii.RETURN, Petscii.NULL
}

.macro ChangeCursor(row, column) {
	lda #row
	sta Zero.CursorLogicalColumn
	lda #column
	sta Zero.CursorPhysicalLineNumber
	KernalOutput(newline)	// need return to ensure pointers $d1 and $f3 update
	jmp !done+
newline:
	Newline()
!done:
}

.macro ChangeBorder(color) {
	lda #color
	sta VIC.BorderColor
}

.macro ChangeBackground(color) {
	lda #color
	sta VIC.BackgroundColor
}

.macro ChangeColor(color) {
	lda #color
	sta Two.CurrentCharColor
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
	lda #Petscii.SPACEBAR
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
	jsr Kernal.CHROUT
	inx
	jmp !loop-
!done:	
}

// KernAl spelt the way CBM intended (for better or worse)
.macro KernalOutputA() {
	jsr Kernal.CHROUT
}

.macro OutputInColor(msg, color) {
	lda Two.CurrentCharColor
	pha
	ChangeColor(color)
	KernalOutput(msg)
	pla
	sta Two.CurrentCharColor
}

.macro Output(msg) {
	KernalOutput(!data+)
	jmp !done+
!data:
	.text msg
	.byte Petscii.NULL
!done:
}

.macro OutputLine(msg) {
	KernalOutput(!data+)
	jmp !done+
!data:
	.text msg
	.byte Petscii.RETURN, Petscii.NULL
!done:
}

.segment Default