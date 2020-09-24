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

.macro ChangeExistingTextColor(color) {
	lda #color
	sta $0286
}

.macro KernalClearScreen() {
	jsr $e544
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

// KernAl spelt the way CBM intended (for better or worse)
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

.macro Output(msg) {
	KernalOutput(!data+)
	jmp !done+
!data:
	.text msg
	.byte NULL
!done:
}

.macro OutputLine(msg) {
	KernalOutput(!data+)
	jmp !done+
!data:
	.text msg
	.byte RETURN, NULL
!done:
}

.segment Default