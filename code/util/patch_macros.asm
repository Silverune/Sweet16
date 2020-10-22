.importonce

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
