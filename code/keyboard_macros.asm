// Macros dealing with reading keyboard state

.macro SetupKeyboard() {
.const ddra = $dc02            // CIA#1 (Data Direction Register A)
.const ddrb = $dc03            // CIA#1 (Data Direction Register B)
	lda #%11111111  // CIA#1 Port A set to output 
    sta ddra             
    lda #%00000000  // CIA#1 Port B set to input
    sta ddrb
}

.macro CheckKey(row, column, address) {
.const pra  = $dc00            // CIA#1 (Port Register A)
.const prb  = $dc01            // CIA#1 (Port Register B)
	lda #row
    sta pra 
    lda prb         // load column information
    and #column
    beq address
}

.macro CheckSpace(address) {
	CheckKey(%01111111, %00010000, address)
}

.macro CheckQ(address) {
	CheckKey(%01111111, %01000000, address)
}

// pressed keycode is stored in A
.macro KernalGetKey() {
	.const getin = $ffe4
	.const scnkey = $ff9f
	jsr scnkey  // scan keyboard
	jsr getin	// put result into A
}

// assumes value in A
.macro TwosComplimentA() {
	eor #$ff
	adc #$01
}

