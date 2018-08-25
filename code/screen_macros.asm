.const kernal_chrout = $ffd2    // kernel CHROUT subroutine
.const border_color = $d020     // Border color
.const background_color = $d021     // Background color
.const spacebar = $20           // Code for the SPACEBAR
.const NULL = $00
.const RETURN = $0D

.macro Newline() {
	.byte RETURN, NULL
}
	
.macro ChangeBorder(color) {
	lda #color
	sta border_color
}

.macro ChangeBackground(color) {
	lda #color
	sta background_color
}

.macro ChangeScreen(color) {
	ChangeBorder(color)
	ChangeBackground(color)
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
