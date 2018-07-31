TEST0:	 *=* "Test 0"
	jsr SWEET16
	.byte $11,$00,$70 // SET R1,$7000
	.byte $12,$02,$70 // SET R2,$7002
	.byte $13,$01,$00 // SET R3,1
!LOOP:
	.byte $41   // LD @R1
	.byte $52   // ST @R2
	.byte $F3   // DCR R3
	.byte $07,$FB // BNZ LOOP*/
	.byte $00   // RTN
	break()
	rts

TEST1: *=* "Test 1"
	jsr SWEET16
	set 1 : $7000		// SET R1,$7000
	set 2 : $7002		// SET R2,$7002
	set 3 : $0001		// SET R3,1
!LOOP:
	ldi 1				// LD @R1
	sti 2				// ST @R2
	dcr 3				// DCR R3
	bnz !LOOP-			// BNZ LOOP */
	rtn					// RTN
	break()
	rts
/*
	SET  R5   $a034     // Init pointer 1
    SET  R4   $a03b     // Init limit 1
    SET  R6   $3000     // Init pointer 2
    MOVE           		// Call move subroutine
    MOVE   LD   @R5     // Move one
    ST   @R6            // byte
    LD   R4
    CPR  R5             // Test if done
    BP   MOVE
    RS
*/
TEST2: *=* "Test 2"
	jsr SWEET16
	set 5 : $a034	// Init pointer 1
	set 4 : $a03b	// Initi limit 1
	set 6 : $3000	// Initi pointer 2
	// Call !MOVE subroutine?
!MOVE:
	ldi 5
	sti 6			// Move one
	ld 4			// byte
	cpr 5
	bp !MOVE-		// Test if done
	rs
	rtn
	break()
	rts

/* Woz example from: http://www.6502.org/source/interpreters/sweet16.htm
    JSR   SW16     ;Yes, call SWEET 16
	30A  41         MLOOP   LD    @R1      ;R1 holds source
	30B  52                 ST    @R2      ;R2 holds dest. addr.
	30C  F3                 DCR   R3       ;Decr. length
	30D  07 FB              BNZ   MLOOP    ;Loop until done
	30F  00                 RTN            ;Return to 6502 mode.
*/
TEST3: *=* "Test 3"
	jsr SW16    // Yes, call SWEET 16
!MLOOP:
	ld 1		// R1 holds source
	st 2		// R2 holds dest. addr.
	dcr 3		// Decr. length
	bnz !MLOOP- // Loop until done
	rtn			// Return to 6502 mode.
	break()
	rts

TEST4: *=* "Test 4"
	jsr SW16
    set 1 : $7000
    set 2 : $7002
    set 3 : 10
!LOOP:
    ldi 1
    sti 2
    dcr 3
    bnz !LOOP-
    rtn

TEST5: *=* "Test 5"
	jsr SW16


    SET 1 : $1234
/*    LD R1
    ST R2
    LD @R1
    ST @R2
    LDD @R3
    STD @R4
    POP @R5
    STP @R6
    ADD R7
;    SUB R8
    POPD @R9
    CPR R1
    INR R2
    DCR R3
    RTN
HERE:
     BR LOOP
     BNC LOOP
     BC LOOP
     BP LOOP
     BM LOOP
     BZ LOOP
     BNZ LOOP
     BM1 LOOP
     BNM1 LOOP
     BK
     RS
    BS LOOP
*/	
/*    SET R1,$7000
    SET R2,$7002
    SET R3,10
LOOP:
    LD @R1
    ST @R2
    DCR R3
    BNZ LOOP
    RTN

; Examples of opcodes (code is not meaningful).

    SET R1,$1234
    LD R1
    ST R2
    LD @R1
    ST @R2
    LDD @R3
    STD @R4
    POP @R5
    STP @R6
    ADD R7
;    SUB R8
    POPD @R9
    CPR R1
    INR R2
    DCR R3
    RTN
HERE:
     BR LOOP
     BNC LOOP
     BC LOOP
     BP LOOP
     BM LOOP
     BZ LOOP
     BNZ LOOP
     BM1 LOOP
     BNM1 LOOP
     BK
     RS
     BS LOOP	*/
