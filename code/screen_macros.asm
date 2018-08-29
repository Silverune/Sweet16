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

.macro ChangeScreen(background_color, foreground_color) {
	ChangeBorder(background_color)
	ChangeBackground(background_color)
	ChangeColor(foreground_color)
}

.macro CycleScreen() {
	inc border_color
	inc background_color
}

.macro ToggleBorderColor() {
	lda border_color
	eor #$7f
	sta border_color
}

.macro Petscii2Binary() {
	and #$0f
}
	
.macro Binary2Petscii() {
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
//	tax				// store till later
//	tya
!done:
}
	
.macro OutputNumber2Digit(value) {
	lda value
	cmp #$0A  		// less than 10
	bcs !biggen+	// larger than 10
	Binary2Petscii() 
	KernalOutputA()
	jmp !done+
!biggen:
	ldy #$00
!loop:
	iny				// count 10's
	sbc #$0A
	cmp #$0A
	bcs !loop-		// still larger than 10
	tax				// store till later
	tya
	Binary2Petscii() 
	KernalOutputA()
	txa
	Binary2Petscii() 
	KernalOutputA()
!done:
}
	
.macro OutputNumber(value) {
	.const three_digit = $64	
	lda value
	cmp #three_digit
	bcc twoDigit
	CalcReference(value, three_digit)
	tya
	pha
	Binary2Petscii() 					// display value
	KernalOutputA()
	pla
	tay
	break()
	lda value
!subby:
	sec
	sbc #three_digit
	dey
	bne !subby-
	sta $fe
	break()
	OutputNumber2Digit($fe)
	jmp !done+
twoDigit:
	OutputNumber2Digit(value)
!done:	
}

	
.function UnusedZeroPage() {
	.return $fe
}

.macro ClearScreenZeroPage() {
	.const zeroPageAddress = UnusedZeroPage()
	.const screenColumns = $28   // 40 cols
	.const screenRows = $19      // 25 rows
	.const screenAddressIndirect = $0288
	.var screenColumnsAddress = $00
	lda #screenColumns
	sta screenColumnsAddress
	ldx screenAddressIndirect    // pointer where where the screen RAM is
	stx zeroPageAddress+1
	lda #$00                     // address pointer only refers to high-byte
	sta zeroPageAddress
	ldx #$00
!loop:
	ldy #$00 // col offset
!nextCol:
	lda #spacebar
	sta (zeroPageAddress),y
	iny
	cpy #screenColumns
	bne !nextCol-
!nextRow:
	clc // in case carry flag is set
	lda zeroPageAddress
	adc screenColumnsAddress
	sta zeroPageAddress
	lda zeroPageAddress+1
	adc #$00
	sta zeroPageAddress+1
	inx
	cpx #screenRows
	bne !loop-
}

.macro InvertCharactersOnScreen() {	
	.const zeroPageAddress = UnusedZeroPage()
	.const screenColumns = $28   // 40 cols
	.const screenRows = $19      // 25 rows
	.const screenAddressIndirect = $0288
	.var screenColumnsAddress = $00
	lda #screenColumns
	sta screenColumnsAddress
	ldx screenAddressIndirect    // pointer where where the screen RAM is
	stx zeroPageAddress+1
	lda #$00                     // address pointer only refers to high-byte
	sta zeroPageAddress
	ldx #$00
!loop:
	ldy #$00 // col offset
!nextCol:
	lda (zeroPageAddress),y
	cmp #spacebar
	beq !ignore+
	eor #$80
!ignore:
	sta (zeroPageAddress),y
	iny
	cpy #screenColumns
	bne !nextCol-
!nextRow:
	clc // in case carry flag is set
	lda zeroPageAddress
	adc screenColumnsAddress
	sta zeroPageAddress
	lda zeroPageAddress+1
	adc #$00
	sta zeroPageAddress+1
	inx
	cpx #screenRows
	bne !loop-
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
