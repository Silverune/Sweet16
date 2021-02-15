.segment Main

BasicUpstart2(Main)

Main:
	Cookie_Check(LibLocation)					// looks for byte sequence indicating code placeholder meaning actual code needs to be loaded
 	beq !already_loaded+						// segment data already there - not being loaded from disk
// 	jsr load_splash								// load quick loading splash screen to show while main code is loading
 	jsr load_code								// load library and tests
	 .break
!already_loaded:
	jsr ready


load_splash:
	// todo
	rts

error_handler:
	.break
	pha
	Output("Error: ")
	pla
	KernalOutputA()
	jmp *

load: {
	Load(error_handler)
	rts
}

load_code: {
	Output("LOADING CODE...")
	LoadList(codeFiles, load)
	rts
// 	// TODO - test
// 	.var offset = 0;
// 	.for (var i = 0; i < codeFiles.size(); i++) {
// 		SetupLoadRegisters(files + offset, lengths + i)
// 		jsr load
// 		.eval offset += codeFiles.get(i).size()
// 	}
// 	rts
// files:
// 	.for (var i = 0; i < codeFiles.size(); i++) {
// 		.text codeFiles.get(i)
// 	}
// lengths:
// 	.for (var i = 0; i < codeFiles.size(); i++) {
// 		.byte codeFiles.get(i).size()
// 	}
}

// Main:	
// 	jsr init
// 	jsr loadAll
// 	jsr ready

// init: {
// 	InitIsr()
// 	rts
// }

// install_update_isr: {
// 	InstallIsr(oldIrq, irq)
// 	rts
// }

// uninstall_update_isr: {
// 	UninstallIsr(oldIrq)
// 	rts
// }

// irq:
// 	dec $d019				// ack interrrupt
// 	TimerSub(ZpVar.One, showWhirl, %00000100)
// 	jmp (oldIrq)			// back to previous IRQ

// storeCursor: {
// 	StoreCursorRom(ZpVarWord.One)
// 	rts
// }

// restoreCursor: {
// 	RestoreCursorRom(ZpVarWord.One)
// 	rts
// }

// showWhirl: {
// 	jsr storeCursor
// 	inc whirlIndex
// 	lda whirlIndex
// 	cmp whirlLength
// 	bcc !next+
// 	lda #$00
// 	sta whirlIndex
// !next:
// 	ldx whirlIndex
// 	lda whirl,x
// 	KernalOutputA()
// 	jsr restoreCursor
// 	rts
// }

// loadAll:
// 	// determines if the lib and tests are loaded, loads them in if not - PRG or disk image
// 	ChangeBorder(BLACK)
// 	ChangeBackground(BLACK)
// 	KernalClearScreen()
// 	OutputLine("SWEET16")
// 	OutputLine("")
// 	LoadAllIfMissing(sweet16_patch)
// 	//LoadIfMissing(sweet16_patch, "LIB", libraryFilename)
// 	//LoadIfMissing(tests_patch, "TESTS", testsFilename)
// 	KernalClearScreen()
// 	rts

ready:
	jsr TestRun
	jsr Anykey
	jmp (Kernal.RESET)
	rts

Anykey:
!:
	GetKey()
	beq !-	
	rts

// oldIrq:
// 	.byte 00, 00		// buffer for previous vector
// whirl:
// 	.byte $2d, $cd, $dd, $ce 	// - \ | /
// whirlLength:
// 	.byte $04
// whirlIndex:
// 	.byte $ff

.segment Default
