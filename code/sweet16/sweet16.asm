#importonce
.filenamespace Sweet16

// SWEET 16 INTERPRETER
// APPLE-II  PSEUDO MACHINE INTERPRETER
// COPYRIGHT (C) 1977 APPLE COMPUTER,  INC ALL  RIGHTS RESERVED S. WOZNIAK
// Additional Code: Copyright (C) 2018 Enable Software Pty Ltd, Inc All Rights Reserved Rhett D. Jacobs
// In general - capitalized code / comments are part of the original source while lower-case as not

#if DEBUG
.for (var i = 0; i < 17; i++) { // +1 for the ZP used by the extensions
	Register(RL(i), RH(i))
}
#endif

.segment Sweet16

.macro @Sweet16() {

@SW16_NONE:			    // Entry point if no need to preserve registers
	lda #$00
	sta SW16_SAVE_RESTORE
	jmp SW160
	
@SW16:				    // Main entry point - should be called via pseudocommand "sweet16"
	lda #$01
	sta SW16_SAVE_RESTORE
	
SW160:
	beq SW16A
	jsr SAVE            // PRESERVE 6502 REG CONTENTS
	
SW16A:
	pla
	sta R15L            // INIT SWEET16 PC
	pla                 // FROM RETURN
	sta R15H	        // ADDRESS

SW16B:
	jsr  SW16C          // INTERPRET and EXECUTE
    jmp  SW16B          // ONE SWEET16 INSTR.

SW16C:
	inc  R15L
    bne  SW16D          // INCR SWEET16 PC FOR FETCH
    inc  R15H
	
@SW16D:
	lda  #>SET          // COMMON HIGH BYTE FOR ALL ROUTINES
    pha                 // PUSH ON STACK FOR RTS
    ldy  #$00
    lda  (R15L),Y       // FETCH INSTR
    and  #$0F           // MASK REG SPECIFICATION
    asl                 // DOUBLE FOR TWO BYTE REGISTERS
    tax                 // TO X REG FOR INDEXING
    lsr
    eor  (R15L),Y       // NOW HAVE OPCODE
    beq  TOBR           // IF ZERO THEN NON-REG OP
    stx  R14H           // INDICATE "PRIOR RESULT REG"
    lsr
    lsr                 // OPCODE*2 TO LSB'S
    lsr
    tay                 // TO Y REG FOR INDEXING
    lda  OPTBL-2,Y      // LOW ORDER ADR BYTE
    pha                 // ONTO STACK
    rts                 // GOTO REG-OP ROUTINE

TOBR:
	inc  R15L
    bne  TOBR2          // INCR PC
    inc  R15H
	
TOBR2:
	lda  BRTBL,X        // LOW ORDER ADR BYTE
    pha                 // ONTO STACK FOR NON-REG OP
    lda  R14H           // "PRIOR RESULT REG" INDEX
    lsr                 // PREPARE CARRY FOR BC, BNC.
    rts                 // GOTO NON-REG OP ROUTINE

SETZ:
	lda  (R15L),Y       // HIGH ORDER BYTE OF CONSTANT
    sta  R0H,X
    dey
    lda  (R15L),Y       // LOW ORDER BYTE OF CONSTANT
    sta  R0L,X
    tya                 // Y REG CONTAINS 1
    sec
    adc  R15L           // ADD 2 TO PC
    sta  R15L
    bcc  SET2
    inc  R15H

SET2:
	rts

.segment Sweet16JumpTable

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
    .byte  <XJSR-1         // D
    .byte  <DCR-1          // FX
    .byte  <SETM-1         // E
    .byte  <NUL-1          // UNUSED
    .byte  <SETI-1         // F

// THE FOLLOWING CODE MUST BE CONTAINED ON A SINGLE PAGE!
.segment Sweet16Page 
//.align $100            // ensures page aligned
.var page_start = *
RTS_FIX:
	nop                // otherwise RTS "cleverness" not so clever
					   // due to minus -1 yeilding $FF if SET is placed at $00	
SET:
	jmp SETZ           // ALWAYS TAKEN (moved out of page)

LD:
	lda  R0L,X
    sta  R0L
    lda  R0H,X          // MOVE RX TO R0
    sta  R0H
    rts

BK:						// set this explicity
	brk

SETM:
	jmp SETM_OUTOFPAGE 	// code will make block larger than 255 if placed here

XJSR:
	jmp XJSR_OUTOFPAGE 	// code will make block larger than 255 if placed here

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
	
LDDAT:
	jsr  LDAT           // LOW ORDER BYTE TO R0, INCR RX
    lda  (R0L,X)        // HIGH ORDER BYTE TO R0
    sta  R0H
    jmp  INR            // INCR RX
	
STDAT:
	jsr  STAT           // STORE INDIRECT LOW ORDER
    lda  R0H            // BYTE AND INCR RX. THEN
    sta  (R0L,X)        // STORE HIGH ORDER BYTE.
    jmp  INR            // INCR RX AND RETURN
	
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
	sec                 // NOTE Y REG = 13*2 FOR CPR
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
	lda  (R15L),Y       // DISPLACEMENT BYTE
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
	ldx  #$18           // 12*2 FOR R12 AS STACK POINTER
    jsr  DCR            // DECR STACK POINTER
    lda  (R0L,X)        // POP HIGH RETURN ADDRESS TO PC
    sta  R15H
    jsr  DCR            // SAME FOR LOW ORDER BYTE
    lda  (R0L,X)
    sta  R15L
    rts

POP:
	ldy  #$00           // HIGH ORDER BYTE = 0
    beq  POP2           // ALWAYS TAKEN

POPD:
	jsr  DCR            // DECR RX
    lda  (R0L,X)        // POP HIGH ORDER BYTE @RX
    tay                 // SAVE IN Y REG	
	jmp POP2
	
SETI:
	jmp SETI_OUTOFPAGE
	
RTN:
	.var page_size = * - page_start	// sanity check
	.errorif page_size > 255, "All table entries must jump to same 255 byte page, currently: " + page_size
	jmp  RTNZ

POP2:
	jsr  DCR            // DECR RX
    lda  (R0L,X)        // LOW ORDER BYTE
    sta  R0L            // TO R0
    sty  R0H
POP3:
	ldy  #$00           // INDICATE R0 AS LAST RESULT REG
    sty  R14H
    rts

RTNZ:
	pla                 // POP RETURN ADDRESS
    pla
	lda SW16_SAVE_RESTORE
	beq RESTORED
    jsr RESTORE        // RESTORE 6502 REG CONTENTS

RESTORED:
    jmp  (R15L)         // RETURN TO 6502 CODE VIA PC

SAVE:
    sta ACCUMULATOR
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
    lda ACCUMULATOR
    ldx XREG
    ldy YREG
    plp
    rts

@SW16_BREAK_HANDLER:
	pla		// Y
	tay		// restore Y
	pla		// X
	tax		// restore X
	pla		// restore A
	sta RL(ZP)
	plp		// restore Status Flags
	pla		// PCL discard - not useful
	pla		// PCH discard - not useful
	lda RL(ZP)
	jmp SW16D

SETIM_COMMON:
	lda (R15L),Y       		// dest addr high
	sta RL(ZP)
	IncPC()
	lda (R15L),Y       		// dest addr low
	sta RH(ZP)
	IncPC()
	lda (R15L),Y       		// dest register
	IncPC()
	tay
	inc RL(ZP)
	ldx #RL(ZP)
	rts
	
.segment Sweet16OutOfPage

SETI_OUTOFPAGE:
	jsr SETIM_COMMON
	lda ($00,X)
	sta $00,Y				// low order
	dec RL(ZP)
	lda ($00,X)
	sta $01,Y				// high order
	jmp SW16D				// back to SWEET16

SETM_OUTOFPAGE:
	jsr SETIM_COMMON
	lda ($00,X)
	sta $01,Y				// high order
	dec RL(ZP)
	lda ($00,X)
	sta $00,Y				// low order
	jmp SW16D				// back to SWEET16

XJSR_OUTOFPAGE: {
	lda #>((!returned+)-1)	// so we know where to come back to as we're
	pha						// using rts as jmps here
	lda #<((!returned+)-1)
	pha
	lda (R15L),Y       		// high order byte
	pha
	IncPC()
	lda (R15L),Y       		// low order byte
	pha
	IncPC()
	rts				   		// this performs jump from stack
!returned:
	jmp SW16D				// back to SWEET16
}

.segment Sweet16Data	

ACCUMULATOR:
	.byte 0
XREG:
	.byte 0
YREG:
	.byte 0
STATUS:
	.byte 0
SW16_SAVE_RESTORE:
	.byte 0

.segment Default
}

