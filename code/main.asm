BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
/*	jsr SET_TEST
	jsr LD_TEST
	jsr ADD_TEST
	*/
	jsr TEST0
//	jsr TEST1
/*	jsr TEST2
	jsr TEST3*/

	lda #$00
	sta $d020
	sta $d021
	rts
