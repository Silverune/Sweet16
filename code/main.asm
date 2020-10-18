.segment Main

BasicUpstart2(Main)

Main:	
	.memblock "Main"

	jsr init

	//jsr install_update_isr

	//jsr *

	jsr loadAll

	jsr *
	jsr ready

install_update_isr: {
	sei

	lda #$01    // Set Interrupt Request Mask
	sta $d01a   // IRQ by Rasterbeam

	lda $314			// save previous vector
	ldx $315
	sta oldIrq
	stx oldIrq + 1

	lda #<irq			// install our IRQ
	ldx #>irq
	sta $314
	stx $315

	cli
	rts
}

uninstall_update_isr: {
	sei 

	lda #$00    // Unset Interrupt Request Mask
	sta $d01a   // IRQ by Rasterbeam

	lda oldIrq
	ldx oldIrq + 1
	sta $314
	stx $315

	cli
	rts
}

init: {
	sei 

	ldy #$7f    // $7f = %01111111
	sty $dc0d   // Turn off CIAs Timer interrupts
	sty $dd0d   // Turn off CIAs Timer interrupts
	lda $dc0d   // cancel all CIA-IRQs in queue/unprocessed
	lda $dd0d   // cancel all CIA-IRQs in queue/unprocessed

	cli
	rts
}

oldIrq:
	.byte 00, 00		// buffer for previous vector
counterDot:
	.byte $FF
counterWhirl:
	.byte $FF
whirlLength:
	.byte $04
whirl:
	// - \ | /
	.byte $2d, $cd, $dd, $ce
whirlIndex:
	.byte $ff

irq:
	dec $d019				// ack interrrupt
	
//	TimerSub(counterDot, showDot, %01000000)
	TimerSub(counterDot, showDot, %00001000)
	TimerSub(counterWhirl, showWhirl, %00000100)

	jmp (oldIrq)		// back to previous IRQ

showDot: {
	lda #$2e			// .
	KernalOutputA()
	rts
}

.macro TimerSub(timerAddress, subroutine, updateMask) {
	inc timerAddress
	lda #updateMask
	bit timerAddress
	bne !callSub+
	jmp !+
!callSub:
	jsr subroutine
	lda #$ff			// reset
	sta timerAddress
!:
}

showWhirl: {

	// get cursor position
	sec			// set carry flag
	jsr $e50a	// fetch current position
	txa
	pha			// store x on stack
	tya
	pha			// store y on stack

	inc whirlIndex
	lda whirlIndex
	cmp whirlLength
	bcc !next+
	lda #$00
	sta whirlIndex
!next:
	ldx whirlIndex
	lda whirl,x
	KernalOutputA()

	// restore cursor position
	pla
	tay
	pla
	tax
	clc
	jsr $e50a

	rts
}

loadAll:
	// determines if the lib and tests are loaded, loads them in if not - PRG or disk image
	ChangeBorder(BLACK)
	ChangeBackground(BLACK)
	KernalClearScreen()
	OutputLine("SWEET16")
	OutputLine("")
	LoadIfMissing(sweet16_patch, "LIB", libraryFilename)
	LoadIfMissing(tests_patch, "TESTS", testsFilename)
	OutputLine("")
	rts

.macro LoadIfMissing(destAddress, description, filename) {
	Output("CHECKING FOR " + description + " ")
	CheckPatchPlaceholder(destAddress)
	beq !alreadyLoaded+
	Output("LOADING")
	jsr install_update_isr
	LoadPrgFile(!filenameInMemory+, filename.size())
	jsr uninstall_update_isr
	OutputLine(" DONE")
	jmp !done+
!alreadyLoaded:
	OutputLine("FOUND")
	jmp !done+
!filenameInMemory:
	.text filename
!done:
}

ready:
	jsr TestRun
	jsr Anykey
	jmp Reset
	rts

Anykey:
!:
	KernalGetKey()
	beq !-	
	rts

Reset:
	jmp ($FFFC)		// kernal reset vector