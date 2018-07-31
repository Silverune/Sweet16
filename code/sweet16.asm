// SWEET 16 INTERPRETER
// APPLE-II  PSEUDO MACHINE INTERPRETER
// COPYRIGHT (C) 1977 APPLE COMPUTER,  INC ALL  RIGHTS RESERVED S. WOZNIAK

//#define TRACE_MODE
	
.const ZP_BASE = $17 // C64 start of 16 bit registers in zero page end at $37

.function RL(register) {
	.return ZP_BASE + (register * 2)
}

.function RH(register) {
	.return ZP_BASE + (register * 2) + 1
}

#if TRACE_MODE
.for (var i = 0; i < 16; i++) {
	label("RL" + i, RL(i))
	label("RH" + i, RH(i))
	trace_write_addr(RL(i))
	trace_read_addr(RL(i))
	trace_write_addr(RH(i))
	trace_read_addr(RH(i))
}

watch_write_addr($0035)
watch_read_addr($0035)
#endif

.const R0L = RL(0)   // ACC
.const R0H = RH(0)
.const R12L = RL(12) // RSP
.const R12H = RH(12)
.const R13L = RL(13) // CPR
.const R13H = RH(13)
.const R14L = RL(14) // SR
.const R14H = RH(14)
.const R15L = RL(15) // PC
.const R15H = RH(15)

SWEET16: *=* "Sweet16"
SW16:	{
	jsr SAVE           // PRESERVE 6502 REG CONTENTS
	
SW16A:
	pla
	sta R15L           // INIT SWEET16 PC
	pla                // FROM RETURN
	sta R15H	       // ADDRESS

SW16B:
	jsr  SW16C          // INTERPRET and EXECUTE
    jmp  SW16B          // ONE SWEET16 INSTR.

SW16C:
	inc  R15L
    bne  SW16D          // INCR SWEET16 PC FOR FETCH
    inc  R15H
	
SW16D:
	lda  #>SET          // COMMON HIGH BYTE FOR ALL ROUTINES
    pha                 // PUSH ON staCK FOR rts
    ldy  #$00
    lda  (R15L),Y       // FETCH INSTR
    and  #$0F           // MASK REG SPECIFICATION
    asl                 // DOUBLE FOR TWO BYTE REGISTERS
    tax                 // TO X REG FOR INDEXING
    lsr
    eor  (R15L),Y       // NOW HAVE OPCODE
#if TRACE_MODE
label("OPCODE_A", *)
trace_read_addr(*)
#endif
    beq  TOBR           // IF ZERO THEN NON-REG OP
    stx  R14H           // INDICATE "PRIOR RESULT REG"
    lsr
    lsr                 // OPCODE*2 TO LSB'S
    lsr
    tay                 // TO Y REG FOR INDEXING
    lda  OPTBL-2,Y      // LOW ORDER ADR BYTE
    pha                 // ONTO staCK
    rts                 // GOTO REG-OP ROUTINE

TOBR:
	inc  R15L
    bne  TOBR2          // INCRR PC
    inc  R15H
	
TOBR2:
	lda  BRTBL,X        // LOW ORDER ADR BYTE
    pha                 // ONTO staCK FOR NON-REG OP
    lda  R14H           // "PRIOR RESULT REG" INDEX
    lsr                 // PREPARE CARRY FOR BC, BNC.
    rts                 // GOTO NON-REG OP ROUTINE

RTNZ:
	pla                 // POP RETURN ADDRESS
    pla
    jsr  RESTORE        // RESTORE 6502 REG CONTENTS
    jmp  (R15L)         // RETURN TO 6502 CODE VIA PC

SETZ:
	lda  (R15L),Y       // HIGH ORDER BYTE OF CONSTANT
#if TRACE_MODE
	label("HIGH_CONSTANT_A", *)
	trace_read_addr(*)
#endif
    sta  R0H,X
    dey
    lda  (R15L),Y       // LOW ORDER BYTE OF CONSTANT
#if TRACE_MODE
	label("LOW_CONSTANT_A", *)
	trace_read_addr(*)
#endif
    sta  R0L,X
    tya                 // Y REG CONTAINS 1
    sec
    adc  R15L           // ADD 2 TO PC
    sta  R15L
    bcc  SET2
    inc  R15H

SET2:
	rts

OPTBL:
	.byte <SET-1          // 1X

BRTBL:
	.byte  <RTN-1          // 0
    .byte  <LD-1           // 2X
    .byte  <BR-1           // 1
    .byte  <ST-1           // 3X
    .byte  <BNC-1          // 2
    .byte  <LDAT-1         // 4X
    .byte  <BC-1           // 3
    .byte  <STAT-1         // 5X
    .byte  <BP-1           // 4
    .byte  <LDDAT-1        // 6X
    .byte  <BM-1           // 5
    .byte  <STDAT-1        // 7X
    .byte  <BZ-1           // 6
    .byte  <POP-1          // 8X
    .byte  <BNZ-1          // 7
    .byte  <STPAT-1        // 9X
    .byte  <BM1-1          // 8
    .byte  <ADD-1          // AX
    .byte  <BNM1-1         // 9
    .byte  <SUB-1          // BX
    .byte  <BK-1           // A
    .byte  <POPD-1         // CX
    .byte  <RS-1           // B
    .byte  <CPR-1          // DX
    .byte  <BS-1           // C
    .byte  <INR-1          // EX
    .byte  <NUL-1          // D
    .byte  <DCR-1          // FX
    .byte  <NUL-1          // E
    .byte  <NUL-1          // UNUSED
    .byte  <NUL-1          // F

// FOLLOWING CODE MUST BE CONTAINED ON A SINGLE PAGE!
.align $100            // ensures page aligned
.var page_start = *	
SET:
	jmp SETZ           // ALWAYS TAKEN

LD:
	lda  R0L,X
	
BK: *=*-1
    sta  R0L
    lda  R0H,X          // MOVE RX TO R0
    sta  R0H
    rts

ST:
	lda  R0L
    sta  R0L,X          // MOVE R0 TO RX
    lda  R0H
    sta  R0H,X
    rts

STAT:
	lda  R0L
	
STAT2:
	sta  (R0L,X)        // STORE BYTE INDIRECT
    ldy  #$00
	
STAT3:
	sty  R14H           // INDICATE R0 IS RESULT NEG
	
INR:
	inc  R0L,X
    bne  INR2           // INCR RX
    inc  R0H,X
	
INR2:
	rts
	
LDAT:
	lda  (R0L,X)        // LOAD INDIRECT (RX)
    sta  R0L            // TO R0
    ldy  #$00
    sty  R0H            // ZERO HIGH ORDER R0 BYTE
    beq  STAT3          // ALWAYS TAKEN
	
POP:
	ldy  #$00           // HIGH ORDER BYTE = 0
    beq  POP2           // ALWAYS TAKEN
	
POPD:
	jsr  DCR            // DECR RX
    lda  (R0L,X)        // POP HIGH ORDER BYTE @RX
    tay                 // SAVE IN Y REG
	
POP2:
	jsr  DCR            // DECR RX
    lda  (R0L,X)        // LOW ORDER BYTE
    sta  R0L            // TO R0
    sty  R0H
	
POP3:
	ldy  #$00           // INDICATE R0 AS LAST RESULT REG
    sty  R14H
    rts
	
LDDAT:
	jsr  LDAT           // LOW ORDER BYTE TO R0, incR RX
    lda  (R0L,X)        // HIGH ORDER BYTE TO R0
    sta  R0H
    jmp  INR            // INCR RX
	
STDAT:
	jsr  STAT           // STORE INDIRECT LOW ORDER
    lda  R0H            // BYTE and incR RX. THEN
    sta  (R0L,X)        // STORE HIGH ORDER BYTE.
    jmp  INR            // INCR RX and RETURN
	
STPAT:
	jsr  DCR            // DECR RX
    lda  R0L
    sta  (R0L,X)        // STORE R0 LOW BYTE @RX
    jmp  POP3           // INDICATE R0 AS LAST RESULT REG

DCR:
	lda  R0L,X
    bne  DCR2           // DECR RX
    dec  R0H,X
	
DCR2:
	dec  R0L,X
    rts
	
SUB:
	ldy  #$00           // RESULT TO R0

CPR:
	sec                 // NOTE Y REG = 13*2 FOR cpr
    lda  R0L
    sbc  R0L,X
    sta  R0L,Y          // R0-RX TO RY
    lda  R0H
    sbc  R0H,X
	
SUB2:
	sta  R0H,Y
    tya                 // LAST RESULT REG*2
    adc  #$00           // CARRY TO LSB
    sta  R14H
    rts

ADD:
	lda  R0L
    adc  R0L,X
    sta  R0L            // R0+RX TO R0
    lda  R0H
    adc  R0H,X
    ldy  #$00           // R0 FOR RESULT
    beq  SUB2           // FINISH ADD
	
BS:
	lda  R15L           // NOTE X REG IS 12*2!
    jsr  STAT2          // PUSH LOW PC BYTE VIA R12
    lda  R15H
    jsr  STAT2          // PUSH HIGH ORDER PC BYTE
	
BR:
	clc
	
BNC:
	bcs  BNC2           // NO CARRY TEST
	
BR1:
	lda  (R15L),Y       // DISplaCEMENT BYTE
    bpl  BR2
    dey

BR2:
	adc  R15L           // ADD TO PC
    sta  R15L
    tya
    adc  R15H
    sta  R15H

BNC2:
	rts

BC:
	bcs  BR
    rts

BP:
	asl                 // DOUBLE RESULT-REG INDEX
    tax                 // TO X REG FOR INDEXING
    lda  R0H,X          // TEST FOR PLUS
    bpl  BR1            // BRANCH IF SO
    rts
	
BM:
	asl                 // DOUBLE RESULT-REG INDEX
    tax
    lda  R0H,X          // TEST FOR MINUS
    bmi  BR1
    rts

BZ:
	asl                 // DOUBLE RESULT-REG INDEX
    tax
    lda  R0L,X          // TEST FOR ZERO
    ora  R0H,X          // (BOTH BYTES)
    beq  BR1            // BRANCH IF SO
    rts
	
BNZ:
	asl                 // DOUBLE RESULT-REG INDEX
    tax
    lda  R0L,X          // TEST FOR NON-ZERO
    ora  R0H,X          // (BOTH BYTES)
    bne  BR1            // BRANCH IF SO
    rts
	
BM1:
	asl                 // DOUBLE RESULT-REG INDEX
    tax
    lda  R0L,X          // CHECK BOTH BYTES
    and  R0H,X          // FOR $FF (MINUS 1)
    eor  #$FF
    beq  BR1            // BRANCH IF SO
    rts
	
BNM1:
	asl                 // DOUBLE RESULT-REG INDEX
    tax
    lda  R0L,X
    and  R0H,X          // CHECK BOTH BYTES FOR NO $FF
    eor  #$FF
    bne  BR1            // BRANCH IF NOT MINUS 1
	
NUL:
	rts
	
RS:
	ldx  #$18           // 12*2 FOR R12 AS staCK POINTER
    jsr  DCR            // DECR STACK POINTER
    lda  (R0L,X)        // POP HIGH RETURN ADDRESS TO PC
    sta  R15H
    jsr  DCR            // SAME FOR LOW ORDER BYTE
    lda  (R0L,X)
    sta  R15L
    rts

RTN:
	.var page_size = * - page_start
	.errorif page_size > 255, "Must be located on same page"
#if DEBUG
	.print "Page Size = " + page_size
#endif
	jmp  RTNZ

SAVE:
    sta ACC
    stx XREG
    sty YREG
    php
    pla
    sta STATUS
    cld
    rts

RESTORE:
    lda STATUS
    pha
    lda ACC
    ldx XREG
    ldy YREG
    plp
    rts

ACC:
#if TRACE_MODE
	trace_write_addr(*)
	trace_read_addr(*)
#endif
	.byte 0
XREG:
#if TRACE_MODE
	trace_write_addr(*)
	trace_read_addr(*)
#endif
	.byte 0
YREG:
#if TRACE_MODE
	trace_write_addr(*)
	trace_read_addr(*)
#endif
	.byte 0
STATUS:
#if TRACE_MODE
	trace_write_addr(*)
	trace_read_addr(*)
#endif
	.byte 0
}
