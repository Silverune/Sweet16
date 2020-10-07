.segment Main

BasicUpstart2(Main)

Main:	
.memblock "Main"
	jsr loadAll
	jsr ready

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
