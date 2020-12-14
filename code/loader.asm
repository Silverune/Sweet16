.importonce

// Should be first loaded module which can be configured to display loading screen / text & music while loading 
// other modules

.segment Loader


loadFiles: {
    jmp !+
.memblock "f1"
!f1:
    .text libraryFilename
.memblock "f2"
!f2:
    .text testsFilename
.memblock "Lo"
!filenamesLo:
    .byte <!f1-, <!f2- 
.memblock "Hi"
!filenamesHi:
    .byte >!f1-, >!f2- 
.memblock "Len"
!lengths:
    .byte libraryFilename.size(), testsFilename.size()
.memblock "Num"
!num:
    .byte $02
!:
    ldy #$00        // table counter
!loadNext:
    tya
    pha             // stack counter
    lda !lengths-,y
    pha             // stack length
    lda !filenamesLo-,y
    tax
    lda !filenamesHi-,y
    tay
    pla             // pop length
    jsr KernalLoad
    .break
    pla             // pop counter
    tay
    iny
    cpy !num-
    bne !loadNext-
    rts
}

.segment Default