BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
/*	.eval test_calculate_effective_address($1000)
	jsr SET_TEST
	jsr LOAD_TEST
	jsr STORE_TEST
	jsr LOAD_INDIRECT_TEST
	jsr STORE_INDIRECT_TEST
	jsr LOAD_DOUBLE_BYTE_INDIRECT_TEST
	jsr STORE_DOUBLE_BYTE_INDIRECT_TEST
	jsr POP_INDIRECT
	jsr STORE_POP_INDIRECT_TEST
	jsr ADD_TEST
	jsr SUBTRACT_TEST
	jsr POP_DOUBLE_BYTE_INDIRECT_TEST

	jsr BRANCH_ALWAYS_TEST

	*/

	jsr COMPARE_TEST

	lda #$00
	sta $d020
	sta $d021
	rts
