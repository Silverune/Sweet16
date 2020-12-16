#importonce

// Loading a file to memory at address stored in file
// Reference: https://codebase64.org/doku.php?id=base:loading_a_file
// BASIC equivalent: LOAD "JUST A FILENAME",8,1
.macro LoadPrgFile(filename, length) {
   LoadFile(filename, length)
   cpx #$00
   beq !done+
    // error
    pha
    Output("Load Error: ")
    pla
    KernalOutputA()
    jmp *
   !done:   
}

.macro LoadFile(filenameAddr, length) {
    lda #length
    Load(filenameAddr)
}

.macro Load(filenameAddr) {
    ldx #<filenameAddr
    ldy #>filenameAddr
    jsr KernalLoad
}

.macro KernalLoad() {
    jsr $ffbd     // call setnam
    lda #$01
    ldx $ba       // last used device number
    bne !skip+
    ldx #$08      // default to device 8
!skip:
   ldy #$01       // not $01 means: load to address stored in file
   jsr $ffba      // call setlfs

   lda #$00       // $00 means: load to memory (not verify)
   jsr $ffd5      // call load
   bcs !error+    // if carry set, a load error has happened
   jmp !done+
!error:
	// most likely errors:
	// a = $05 (device not present)
	// a = $04 (file not found)
	// a = $1d (load error)
	// a = $00 (break, run/stop has been pressed during loading)
    ldx #1
    rts
!done:
    ldx #0         // clear error flag in case set
    rts
}

.macro LoadAllIfMissing(token) {
	Output("CHECKING FOR RESOURCES...")
	CheckPatchPlaceholder(token)
	beq !alreadyLoaded+
	Output("LOADING...")
	jsr install_update_isr
    jsr loadFiles
	//LoadPrgFile(!filenameInMemory+, filename.size())
	jsr uninstall_update_isr
	OutputLine(" DONE")
	jmp !done+
!alreadyLoaded:
	OutputLine("FOUND")
	jmp !done+
!done:
}

.macro LoadIfMissing(destAddress, description, filename) {
	Output("CHECKING FOR " + description + " ")
	CheckPatchPlaceholder(destAddress)
	beq !alreadyLoaded+
	Output("LOADING...")
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
