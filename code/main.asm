BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC
Program:
	TestStart()

	// core sweet16
	jsr SET_TEST
	jsr LOAD_TEST
	jsr STORE_TEST
	jsr LOAD_INDIRECT_TEST
	jsr STORE_INDIRECT_TEST
	jsr LOAD_DOUBLE_BYTE_INDIRECT_TEST
	jsr STORE_DOUBLE_BYTE_INDIRECT_TEST
	jsr POP_INDIRECT_TEST
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

	// extensions
	jsr ABSOLUTE_JUMP_TEST
	jsr EXTERNAL_JSR_TEST
	jsr SET_INDIRECT_TEST
	jsr SET_MEMORY_TEST
	jsr INTERRUPT_BREAK_TEST
	
	TestFinished()

	// not a real test as routine not required in this implementation
#if DEBUG
	.eval test_calculate_effective_address($1000)
#endif

	rts
