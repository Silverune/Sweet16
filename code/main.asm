.segment Main

BasicUpstart2(Main)

Main:	
	jsr init
	jsr loadAll
	jsr ready

init: {
	InitIsr()
	rts
}

install_update_isr: {
	InstallIsr(oldIrq, irq)
	rts
}

uninstall_update_isr: {
	UninstallIsr(oldIrq)
	rts
}

irq:
	dec $d019				// ack interrrupt
	TimerSub(ZpVar.One, showWhirl, %00000100)
	jmp (oldIrq)			// back to previous IRQ

storeCursor: {
	StoreCursorRom(ZpVarWord.One)
	rts
}

restoreCursor: {
	RestoreCursorRom(ZpVarWord.One)
	rts
}

showWhirl: {
	jsr storeCursor
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
	jsr restoreCursor
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
	jmp ($FFFC)			// kernal reset vector

oldIrq:
	.byte 00, 00		// buffer for previous vector
whirl:
	.byte $2d, $cd, $dd, $ce 	// - \ | /
whirlLength:
	.byte $04
whirlIndex:
	.byte $ff
