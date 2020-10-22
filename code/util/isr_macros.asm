.importonce 

.const IsrAddress = $314
.const IsrMaskRegister = $d01a

.macro InstallIsr(storeExistingIsr, newIsrAddress) {
	sei

	lda #$01    // Set Interrupt Request Mask
	sta IsrMaskRegister   // IRQ by Rasterbeam

	lda IsrAddress			// save previous vector
	ldx IsrAddress + 1
	sta storeExistingIsr
	stx storeExistingIsr + 1

	lda #<newIsrAddress			// install our IRQ
	ldx #>newIsrAddress
	sta IsrAddress
	stx IsrAddress + 1

	cli
}

.macro UninstallIsr(previousIsr) {
	sei 

	lda #$00    // Unset Interrupt Request Mask
	sta IsrMaskRegister   // IRQ by Rasterbeam

	lda previousIsr
	ldx previousIsr + 1
	sta IsrAddress
	stx IsrAddress + 1

	cli
}

.macro InitIsr() {
	sei 

	ldy #$7f    // $7f = %01111111
	sty $dc0d   // Turn off CIAs Timer interrupts
	sty $dd0d   // Turn off CIAs Timer interrupts
	lda $dc0d   // cancel all CIA-IRQs in queue/unprocessed
	lda $dd0d   // cancel all CIA-IRQs in queue/unprocessed

	cli	
}
