/*
SET_TEST2: *=* "SET_TEST2"
	.const r = 1
	sweet16
	set 0 : $9ABC
	set r : $1234
	set 2 : $5678
//	add 2
	rtn
	ldx RL(r)
	ldy RH(r)
	break()
	rts
	
TEST0:	 *=* "Test 0"
	jsr SW16
	.byte $11,$00,$70 // SET R1,$7000
	.byte $12,$02,$70 // SET R2,$7002
	.byte $13,$01,$00 // SET R3,1
!LOOP:
	.byte $41   // LD @R1
	.byte $52   // ST @R2
	.byte $F3   // DCR R3
	.byte $07,$FB // BNZ LOOP
	.byte $00   // RTN
	ldxy ACC
	break()
	rts

TEST2: *=* "Test 2"
	sweet16
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
//	break()
	rts

TEST3: *=* "Test 3"
	jsr SW16    // Yes, call SWEET 16
!MLOOP:
	ld 1		// R1 holds source
	st 2		// R2 holds dest. addr.
	dcr 3		// Decr. length
	bnz !MLOOP- // Loop until done
	rtn			// Return to 6502 mode.
//	break()
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
*/
	
