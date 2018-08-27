BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:

	ChangeScreen(BACKGROUND_COLOR, TITLE_COLOR)
	ClearScreenZeroPage()
	ChangeCursor(0,0)
	KernalOutput(Title)
	ChangeColor(FOREGROUND_COLOR)

	TestStart()
	jsr SET_TEST
	jsr LOAD_TEST
	jsr STORE_TEST
	jsr LOAD_INDIRECT_TEST
	jsr STORE_INDIRECT_TEST
	TestFinished()
	
	/*
	jsr LOAD_DOUBLE_BYTE_INDIRECT_TEST
	jsr STORE_DOUBLE_BYTE_INDIRECT_TEST
	jsr POP_INDIRECT
	jsr STORE_POP_INDIRECT_TEST
	jsr ADD_TEST
	jsr SUBTRACT_TEST
	jsr POP_DOUBLE_BYTE_INDIRECT_TEST
	jsr COMPARE_TEST
	jsr INCREMENT_TEST
	jsr DECREMENT_TEST
	jsr RETURN_TO_6502_MODE_TEST
	jsr BRANCH_ALWAYS_TEST
	jsr BRANCH_IF_NO_CARRY_TEST
	jsr BRANCH_IF_CARRY_SET_TEST
	jsr BRANCH_IF_PLUS_TEST
	jsr BRANCH_IF_MINUS_TEST
	jsr BRANCH_IF_ZERO_TEST
	jsr BRANCH_IF_NONZERO_TEST
	jsr BRANCH_IF_MINUS_ONE_TEST
	jsr BRANCH_IF_NOT_MINUS_ONE_TEST
	jsr BREAK_TEST
	jsr BRANCH_TO_SUBROUTINE_TEST
	jsr RETURN_FROM_SUBROUTINE_TEST
	jsr ABSOLUTE_JUMP_TEST

	.eval test_calculate_effective_address($1000)
*/

//	jsr INTERRUPT_BREAK_TEST

//	lda #$00
//	sta $d020
//	sta $d021
	rts

Title:
	.text "SWEET16 TEST RUNNER"
	Newline()
	
	
