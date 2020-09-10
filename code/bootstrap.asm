// Startup routines for when loaded from disk
.segment Bootstrap

Bootstrap:
!:
    .break
    LoadPrgFile(libraryFilename, libraryFilename.size())
    inx 
    stx $d021
    jmp !-

    // TODO - load Sweet16
    // TODO - load Tests16
//    jmp Main
    rts

// Loading a file to memory at address stored in file
// Reference: https://codebase64.org/doku.php?id=base:loading_a_file
// BASIC equivalent: LOAD "JUST A FILENAME",8,1
.macro LoadPrgFile(filename, length) {
    lda #length
    ldx #<fname
    ldy #>fname
    jsr $ffbd     // call setnam
    lda #$01
    ldx $ba       // last used device number
    bne !skip+
    ldx #$08      // default to device 8
!skip:
   ldy #$01      // not $01 means: load to address stored in file
   jsr $ffba     // call setlfs

   lda #$00      // $00 means: load to memory (not verify)
   jsr $ffd5     // call load
   bcs !error+    // if carry set, a load error has happened
   rts
!error:
.label Error = *
	// accumulator contains basic error code

	// most likely errors:
	// a = $05 (device not present)
	// a = $04 (file not found)
	// a = $1d (load error)
	// a = $00 (break, run/stop has been pressed during loading)
	// ... error handling ...
    rts
fname:
    .text filename
}