.segment Main

BasicUpstart2(Main)

Main:	
.memblock "Main"
	//jsr eightBitDemo

	jsr loadAll
	jsr ready

eightBitDemo: {
	// 10 PRINT CHR$(205+RND(1)*2); : GOTO 10
	// setup random
	RandomInit()

	// generate piece
!next:
	RandomRange(205,206)
	KernalOutputA()
	jmp !next-
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
	Output("CHECKING FOR ")
	Output(description)
	Output("...")
	CheckPatchPlaceholder(destAddress)
	beq !alreadyLoaded+
	Output("LOADING...[" + filename + "]")
	LoadPrgFile(!filenameInMemory+, filename.size())
	OutputLine("DONE.")
	jmp !done+
!alreadyLoaded:
	OutputLine("OK.")
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

.macro RandomInit() {
                .const SID_VOICE_3 = $d40f
                .const SID_VOICE_3_CONTROL = $d412 
                lda #$FF                // maximum frequency value
                sta SID_VOICE_3         // voice 3 frequency low byte
                sta SID_VOICE_3 + 1     // voice 3 frequency high byte
                lda #$80                // noise waveform, gate bit off
                sta SID_VOICE_3_CONTROL // voice 3 control register             
}

.macro Random(register) {
                .const SID_VOICE_3_WAVEFORM_OUTPUT = $d41b
    .if (register == 'a' || register == 'A')
                lda SID_VOICE_3_WAVEFORM_OUTPUT
    .if (register == 'x' || register == 'X')
                ldx SID_VOICE_3_WAVEFORM_OUTPUT
    .if (register == 'y' || register == 'Y')
                ldy SID_VOICE_3_WAVEFORM_OUTPUT
}

.macro RandomRange(low, high) {
                .var range = high - low + 1
!loop:          
                Random('a')             // get random value from 0-255   
                cmp #range              // compare to U-L+1
                bcs !loop-              // branch if value >  U-L+1
                adc #low                // add L (don't need 'clc' as can't get here if carry set)
            }
