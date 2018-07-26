BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
	SetWholeScreen(BLACK)
	break()
	jsr SWEET16
S16: *=* "PRG"
	br $FF
	ld 2
	rtn
	break()
	SetWholeScreen(WHITE)
	rts

.macro SetWholeScreen(color) {
	lda #color
	sta $d020
	sta $d021
}
	
//	jsr RTN
//  .byte $11,$00,$70 // SET R1,$7000
//  .byte $12,$02,$70 // SET R2,$7002
//  .byte $13,$01,$00 // SET R3,1
//  .byte RL(1),$00,$70 // SET R1,$7000
//  .byte RL(2),$02,$70 // SET R2,$7002
//  .byte RL(3),$01,$00 // SET R3,1
/*!LOOP:
  .byte $41   ; LD @R1
  .byte $52   ; ST @R2
  .byte $F3   ; DCR R3
  .byte $07,$FB ; BNZ LOOP
  .byte $00   ; RTN*/
/*	SET  R5   $a034     // Init pointer 1
    SET  R4   $a03b     // Init limit 1
    SET  R6   $3000     // Init pointer 2
    MOVE           		// Call move subroutine
    MOVE   LD   @R5     // Move one
    ST   @R6            // byte
    LD   R4
    CPR  R5             // Test if done
    BP   MOVE
    RS*/


