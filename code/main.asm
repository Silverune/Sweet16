BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
/*	jsr SET_TEST
	jsr LOAD_TEST
	jsr STORE_TEST
	jsr LOAD_INDIRECT_TEST
	jsr STORE_INDIRECT_TEST
	jsr LOAD_DOUBLE_BYTE_INDIRECT_TEST
	jsr STORE_DOUBLE_BYTE_INDIRECT_TEST
	*/
	jsr POP_INDIRECT
	/*
	jsr ADD_TEST
	*/
	
	lda #$00
	sta $d020
	sta $d021
	rts
