.importonce

.segment UtilData

Newline:
    Newline()

.const MagicPatch = $feed;

.macro PatchCode() {
    .byte >MagicPatch, <MagicPatch
}

.macro CheckPatchPlaceholder(baseAddr) {
	// checks if the patch placeholder is there - A non-zero if found
	lda baseAddr
	cmp #(>MagicPatch) // opposite to normal so reads natural in memory inspection
	bne !nope+
	lda baseAddr+1
	cmp #(<MagicPatch)
	bne !nope+
	lda #$01
    jmp !done+
!nope:
	lda #$00
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

// Uses Kernal routines to load in file, assumes registers already setup
// Assumes:
//  A - length
//  X - LSB of filename
//  Y - MSB of filename
// Returns:
//  X - non-zero if error has occurred
//  A - error code if X non-zero
KernalLoad:
    KernalLoad()
    rts

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
    jmp *
    ldx #1
    rts
!done:
    ldx #0         // clear error flag in case set
    rts
}

.segment Default