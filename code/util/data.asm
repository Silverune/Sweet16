.importonce

.segment UtilData

Newline:
    Newline()

.memblock "ManagedBuffer256"
ManagedBuffer256: {
    totalSize:
        LoHi($ff)
    allocSize: 
        LoHi(0)
    buffer:
        .fill $ff, $00
}

CopyMemoryZeroPageSize: {
    CopyMemoryZeroPageSize()
    rts
}

// ZpVars.One - managed buffer containing filename
// TODO - deal with ManagedBuffer fields
LoadPrgFileFromManagedBuffer: {
    .memblock "HERE"
    ldy #2
    lda (ZpVar.One),Y
    pha           // store length on stack

    clc
    lda #$4
    adc ZpVar.One
    tax

    ldy ZpVar.One.hi

    pla

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
   jmp !done+
!error:
	// accumulator contains basic error code
    .label LoadPrgFileFromManagedBufferError = *
//    sta $d021
 //   sta $d020
    sta ZpVar.Four
    KernalOutput(errormessage)
    OutputNumber(ZpVar.Four)
    lda ZpVar.Four
    cmp #$04
    beq !fileNotFound+
    jmp *
	// most likely errors:
	// a = $05 (device not present)
	// a = $04 (file not found)
	// a = $1d (load error)
	// a = $00 (break, run/stop has been pressed during loading)

fileNotFoundMessage:
    .text " > FILE NOT FOUND: "
    .byte NULL

!fileNotFound:
    KernalOutput(fileNotFoundMessage)
    jmp *
    rts
errormessage:
    .text "ERROR: "
    .byte NULL

!done:
    rts
}

.segment Default