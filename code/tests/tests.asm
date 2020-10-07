.segment Tests

// Simple tests for Sweet16.  Most of these are converted versions of Woz's originals in the description of each of the mnemonics / opcodes (http://www.6502.org/source/interpreters/sweet16.htm#Register_Instructions_).

// The 2-byte constant is loaded into Rn (n=0 to F, Hex) and branch conditions set accordingly. The carry is cleared.
SET_TEST: {
	.const REGISTER = 5			// arbitrary register
	.const VALUE = $1234
	TestName("SET")
	sweet16
	set REGISTER : VALUE		// R5 now contains $A034
	rtn
	TestAssertEqual(REGISTER, VALUE, "VALUE")	
	TestComplete()
	rts
}

// The ACC (R0) is loaded from Rn and branch conditions set according to the data transferred. The carry is cleared and contents of Rn are not disturbed.
LOAD_TEST: {
	.const REGISTER = 5			// arbitrary register
	.const VALUE = $4321
	TestName("LOAD")
	sweet16
    set REGISTER : VALUE
    ld REGISTER					// ACC now contains VALUE
	rtn
	TestAssertEqual(ACC, VALUE, "ACC")
	TestComplete()
	rts
}

// The ACC is stored into Rn and branch conditions set according to the data transferred. The carry is cleared and the ACC contents are not disturbed.
STORE_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	.const VALUE = $1234
	TestName("STORE")
	sweet16
	set SOURCE : VALUE
	ld SOURCE					// Copy the contents
	st DEST						// of R5 to R6
	rtn
	TestAssertEqual(DEST, VALUE, "VALUE")
	TestComplete()
	rts
}
	
// The low-order ACC byte is loaded from the memory location whose address resides in Rn and the high-order ACC byte is cleared. Branch conditions reflect the final ACC contents which will always be positive and never minus 1. The carry is cleared. After the transfer, Rn is incremented by 1.	
LOAD_INDIRECT_TEST: {
	.const REGISTER = 5			// arbitrary register
	TestName("LOAD INDIRECT")
	sweet16
	set REGISTER : TEST_MEMORY  // Load from 
	ldi REGISTER				// ACC is loaded from memory where TEST_MEMORY ($00, $12)
								// R5 is incr by one (TEST_MEMORY + 1)
	rtn
	TestAssertEqualIndirectByte(ACC, TEST_MEMORY, "ACC")
	TestAssertEqual(REGISTER, TEST_MEMORY + 1, "REG")
	TestComplete()
	rts
}
	
// The low-order ACC byte is stored into the memory location whose address resides in Rn. Branch conditions reflect the 2-byte ACC contents. The carry is cleared. After the transfer Rn is incremented by 1.
STORE_INDIRECT_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	TestName("STORE INDIRECT")
	sweet16
	set SOURCE : TEST_MEMORY	// Load pointers R5, R6 with
	set DEST : TEST_MEMORY_2	// memory values
    ldi SOURCE            		// Move byte from TEST_MEMORY to TEST_MEMORY_2
    sti DEST			        // Both ptrs are incremented	
	rtn						
	TestAssertEqualMemory(TEST_MEMORY, TEST_MEMORY_2, 1, "MEM")
	TestAssertEqual(SOURCE, TEST_MEMORY+1, "SRC")
	TestAssertEqual(DEST, TEST_MEMORY_2+1, "DST")
	TestComplete()
	rts
}
	
// The low order ACC byte is loaded from memory location whose address resides in Rn, and Rn is then incremented by 1. The high order ACC byte is loaded from the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the final ACC contents. The carry is cleared.
LOAD_DOUBLE_BYTE_INDIRECT_TEST: {
	.const REGISTER = 5			// arbitrary register
	TestName("LOAD DOUBLE INDIRECT")
	sweet16
	set REGISTER : TEST_MEMORY	// The low-order ACC byte is loaded from
	lddi REGISTER				// TEST_MEMORY, high-order from TEST_MEMORY+1
								// NOTE - original had error of specifying "R6"
								// R5 is incr by 2	
	rtn
	TestAssertEqualIndirect(ACC, TEST_MEMORY, "ACC")
	TestAssertEqual(REGISTER, TEST_MEMORY+2, "+2")
	TestComplete()
	rts
}

// The low-order ACC byte is stored into memory location whose address resides in Rn, and Rn is the incremented by 1. The high-order ACC byte is stored into the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the ACC contents which are not disturbed. The carry is cleared.
STORE_DOUBLE_BYTE_INDIRECT_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	TestName("STORE DBL IND")
	sweet16
	set SOURCE : TEST_MEMORY	// Load pointers R5, R6 with
	set DEST : TEST_MEMORY_2	// memory values
	lddi SOURCE					// Move double byte from
    stdi DEST            		// TEST_MEMORY to TEST_MEMORY_2
                                // Both pointers incremented by 2.
	rtn
	TestAssertEqualMemory(TEST_MEMORY, TEST_MEMORY_2, 2, "MEM")
	TestAssertEqual(SOURCE, TEST_MEMORY+2, "S+2")
	TestAssertEqual(DEST, TEST_MEMORY_2+2, "D+2")
	TestComplete()
	rts
}
	
// The low-order ACC byte is loaded from the memory location whose address resides in Rn after Rn is decremented by 1, and the high order ACC byte is cleared. Branch conditions reflect the final 2-byte ACC contents which will always be positive and never minus one. The carry is cleared. Because Rn is decremented prior to loading the ACC, single byte stacks may be implemented with the STI Rn and POP Rn ops (Rn is the stack pointer).  Note - as trying to inspect the intermediate values using the extension "XJSR" to output the test assertions
POP_INDIRECT_TEST: {
	.const STACK = 5			// Arbitrary register
	.const VAL_1 = $04			// Arbitrary low order used
	.const VAL_2 = $05			// Arbitrary low order used
	.const VAL_3 = $06			// Arbitrary low order used
	TestName("POP INDIRECT 1")
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set ACC : VAL_1				// Load into ACC
	sti STACK					// Push onto stack
	xjsr !assert1+
	set ACC : VAL_2				// Load into ACC
	sti STACK					// Push onto stack
	xjsr !assert2+
	set ACC : VAL_3				// Load into ACC
	sti STACK					// Push onto stack
	xjsr !assert3+
	popi STACK					// Pop 6 off stack into ACC
	xjsr !assertP3+
	popi STACK					// Pop 5 off stack into ACC
	xjsr !assertP2+
	popi STACK					// Pop 4 off stack into ACC
	xjsr !assertP1+
	rtn					
	TestComplete()
	rts

!assert1:
	TestAssertEqualIndirectByte(ACC, STACK_MEMORY, "1")
	rts
!assert2:
	TestAssertEqualIndirectByte(ACC, STACK_MEMORY+1, "2")
	rts
!assert3:
	TestAssertEqualIndirectByte(ACC, STACK_MEMORY+2, "3")
	rts
!assertP3:
	TestComplete()
	TestName("POP INDIRECT 2")
	TestAssertEqual(ACC, VAL_3, "P3")
	rts
!assertP2:
	TestAssertEqual(ACC, VAL_2, "P2")
	rts
!assertP1:
	TestAssertEqual(ACC, VAL_1, "P1")
	rts
}
	
// The low-order ACC byte is stored into the memory location whose address resides in Rn after Rn is decremented by 1. Branch conditions will reflect the 2-byte ACC contents which are not modified. STP Rn and POP Rn are used together to move data blocks beginning at the greatest address and working down. Additionally, single-byte stacks may be implemented with the STP Rn ops.
STORE_POP_INDIRECT_TEST: {
	.const SOURCE = 4				// Arbitrary register
	.const DEST = 5					// Arbitrary register
	TestName("STORE POP IND")
	sweet16
	set SOURCE : TEST_MEMORY + 2	// Init pointers with 2 byte offset
	set DEST : TEST_MEMORY_2 + 2 	// as moves down from this address -1 then -2
	popi	SOURCE						// Move byte from
    stpi DEST            			// TEST_MEMORY + 1 to TEST_MEMORY_2 + 1
	popi SOURCE						// Move byte from
	stpi DEST						// TEST_MEMORY to TEST_MEMORY_2
	rtn
	TestAssertEqualMemory(TEST_MEMORY, TEST_MEMORY, 2, "MEM")
	TestComplete()
	rts
}

// The contents of Rn are added to the contents of ACC (R0), and the low-order 16 bits of the sum restored in ACC. the 17th sum bit becomes the carry and the other branch conditions reflect the final ACC contents.
ADD_TEST: {
	.const REGISTER = 1
	.const VAL_1 = $7634
	.const VAL_2 = $4227
	TestName("ADDITION")
	sweet16
	set ACC : VAL_1 		// Init R0 (ACC)
    set REGISTER : VAL_2	// Init REGSITER
    add REGISTER            // Add REGISTER (sum, C clear)
	xjsr !assertAdd+
    add ACC					// Double ACC (R0) with carry set.
	rtn
	TestAssertEqual(ACC, (VAL_1 + VAL_2) * 2, "X2")
	TestComplete()
	rts
!assertAdd:
	TestAssertEqual(ACC, VAL_1 + VAL_2, "ADD")
	rts
}
	
// The contents of Rn are subtracted from the ACC contents by performing a two's complement addition:
//
// ACC = ACC + Rn + 1
//
//The low order 16 bits of the subtraction are restored in the ACC, the 17th sum bit becomes the carry and other branch conditions reflect the final ACC contents. If the 16-bit unsigned ACC contents are greater than or equal to the 16-bit unsigned Rn contents, then the carry is set, otherwise it is cleared. Rn is not disturbed.
SUBTRACT_TEST: {
	.const REGISTER = 1		// Arbitrary register
	.const VAL_1 = $7634
	.const VAL_2 = $4227
	TestName("SUBTRACTION")
	sweet16
	set ACC : VAL_1     	// Init R0 (ACC) 
	set REGISTER : VAL_2	// and REGISTER
	sub REGISTER			// subtract R1 (diff=$340D with c set)
	xjsr !assertSub+
	sub ACC					// clears ACC. (R0)
	rtn
	TestAssertEqual(ACC, 0, "0")
	TestComplete()
	rts
!assertSub:
	TestAssertEqual(ACC, VAL_1 - VAL_2, "SUB")
	rts	
}
	
// Rn is decremented by 1 and the high-order ACC byte is loaded from the memory location whose address now resides in Rn. Rn is again decremented by 1 and the low-order ACC byte is loaded from the corresponding memory location. Branch conditions reflect the final ACC contents. The carry is cleared. Because Rn is decremented prior to loading each of the ACC halves, double-byte stacks may be implemented with the STD @Rn and POPD @Rn ops (Rn is the stack pointer).
POP_DOUBLE_BYTE_INDIRECT_TEST: {
	.const STACK = 5			// Arbitrary register
	TestName("POP DBL-B IND")
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set ACC : TEST_MEMORY		// Load TEST_MEMORY into ACC
	stdi STACK					// Push TEST_MEMORY onto stack
	xjsr !assertStd1+
	set ACC : TEST_MEMORY_2		// Load TEST_MEMORY_2 into ACC
	stdi STACK					// Push TEST_MEMORY_2 onto stack
	xjsr !assertStd2+
	popdi STACK					// Pop TEST_MEMORY_2 off stack
	xjsr !assertPop2+
	popdi STACK					// Pop TEST_MEMORY off stack
	rtn
	TestAssertEqualMemoryRegister(ACC, TEST_MEMORY, "P1")
	TestComplete()
	rts
!assertStd1:
	TestAssertEqualMemoryDirect(STACK_MEMORY, TEST_MEMORY, "1")
	rts
!assertStd2:
	TestAssertEqualMemoryDirect(STACK_MEMORY+2, TEST_MEMORY_2, "2")
	rts
!assertPop2:
	TestAssertEqualMemoryRegister(ACC, TEST_MEMORY_2, "P2")
	rts
}

// The ACC (R0) contents are compared to Rn by performing the 16 bit binary subtraction ACC-Rn and storing the low order 16 difference bits in R13 for subsequent branch tests. If the 16 bit unsigned ACC contents are greater than or equal to the 16 bit unsigned Rn contents, then the carry is set, otherwise it is cleared. No other registers, including ACC and Rn, are disturbed.
COMPARE_TEST: {
	.const DATA_REGISTER = 5
	.const LIMIT_REGISTER = 6
	.const COUNT_REGISTER = 4
	TestName("COMPARE")
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE				// pointer to memory
	set LIMIT_REGISTER : TEST_MEMORY_SEQUENCE + TMS_SIZE	// limit address
	set COUNT_REGISTER : $000								// clear counter
!loop:
	inr COUNT_REGISTER	// inc counter
	sub ACC				// zero data
	stdi DATA_REGISTER	// clear 2 locations
	ld DATA_REGISTER	// compare pointer R5
	cpr LIMIT_REGISTER	// to limit R6
	bnc !loop-			// loop if C clear
	rtn
	TestAssertEqual(COUNT_REGISTER, TMS_SIZE / 2, "COUNT")	// 16-bit
	TestComplete()
	rts	
}

// The contents of Rn are incremented by 1. The carry is cleared and other branch conditions reflect the incremented value.
INCREMENT_TEST: {
	.const REGISTER = 5			// arbitrary register
	TestName("INCREMENT")
	sweet16
	set REGISTER : TEST_MEMORY	// setup pointer
	sub ACC						// clear ACC
	sti REGISTER				// clear location TEST_MEMORY
	inr REGISTER				// increment R5 to TEST_MEMORY + 2
	rtn
	TestAssertEqual(REGISTER, TEST_MEMORY + 2, "+2")
	TestComplete()
	rts
}

// The contents of Rn are decremented by 1. The carry is cleared and other branch conditions reflect the decremented value. e.g., to clear 9 bytes beginning at location TEST_MEMORY_SEQUENCE
DECREMENT_TEST: {
	.const DATA_REGISTER = 5
	.const COUNT_REGISTER = 4
	TestName("DECREMENT")
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE	// Init pointer
	set COUNT_REGISTER : TMS_SIZE				// Init counter
	sub ACC									    // Zero ACC
!loop:
	sti DATA_REGISTER							// Clear a mem byte
	dcr COUNT_REGISTER							// Decrement count
	bnz !loop-
	rtn
	TestAssertEqual(COUNT_REGISTER, $0000, "0")
	TestComplete()
	rts
}

// Control is returned to the 6502 and program execution continues at the location immediately following the RTN instruction. the 6502 registers and status conditions are restored to their original contents (prior to entering SWEET 16 mode).
RETURN_TO_6502_MODE_TEST: {
	TestName("6502 MODE")
	sweet16
	rtn
	TestAssertNonZero(1, "RTN")
	TestComplete()
	rts
}
	
// An effective address (ea) is calculated by adding the signed displacement byte (d) to the PC. The PC contains the address of the instruction immediately following the BR, or the address of the BR op plus 2. The displacement is a signed two's complement value from -128 to +127. Branch conditions are not changed.
BRANCH_ALWAYS_TEST: {
	TestName("BRANCH ALWAYS")
	sweet16
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_1, "1")
	TestComplete()
	rts
}

// A branch to the effective address is taken only is the carry is clear, otherwise execution resumes as normal with the next instruction. Branch conditions are not changed.	
BRANCH_IF_NO_CARRY_TEST: {
	.const REGISTER = 5
	TestName("BRANCH NO CARRY")
	sweet16
	set REGISTER : $1000
	set ACC : $ffff
	add REGISTER
	bnc !setVal1+
	br !setVal2+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the carry is set. Branch conditions are not changed.
BRANCH_IF_CARRY_SET_TEST: {
	.const REGISTER = 5
	TestName("BRANCH IF CARRY")
	sweet16
	set REGISTER : $1000
	set ACC : $ffff
	add REGISTER
	bc !setVal1+
	br !setVal2+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_1, "1")
	TestComplete()
	rts
}

// A branch is effected only if the prior 'result' (or most recently transferred data) was positive. Branch conditions are not changed. e.g., Clear mem from TEST_MEMORY_SEQUENCE to SIZE
BRANCH_IF_PLUS_TEST: {
	.const DATA_REGISTER = 5
	.const LIMIT_REGISTER = 4
	TestName("BRANCH IF +VE")
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE		 		// Init pointer
	set LIMIT_REGISTER : TEST_MEMORY_SEQUENCE + TMS_SIZE 	// Init limit
!loop:
	sub ACC									// Clear mem byte
	sti DATA_REGISTER						// Increment R5
	ld LIMIT_REGISTER						// Compare limit
	cpr DATA_REGISTER						// to Pointer
	bp !loop-								// Loop until done
	rtn
	TestAssertEqualMemoryToConstant(TEST_MEMORY_SEQUENCE, $00, TMS_SIZE, "CLR")
	TestComplete()
	rts
}
	
// A branch is effected only if prior 'result' was minus (negative, MSB = 1). Branch conditions are not changed.
BRANCH_IF_MINUS_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = $0A
	TestName("BRANCH IF -VE")
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bm !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A Branch is effected only if the prior 'result' was zero. Branch conditions are not changed.
BRANCH_IF_ZERO_TEST: {
	TestName("BRANCH IF 0")
	sweet16
	sub ACC									// Clear mem byte
	bz !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the priot 'result' was non-zero Branch conditions are not changed.
BRANCH_IF_NONZERO_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = $0A
	TestName("BRANCH IF !0")
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	add DATA_REGISTER                       // Add from R5 value to 0 
	bnz !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the prior 'result' was minus one ($FFFF Hex). Branch conditions are not changed.
BRANCH_IF_MINUS_ONE_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = 1
	TestName("BRANCH IF -1")
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bm1 !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A branch effected only if the prior 'result' was not minus 1. Branch conditions are not changed
BRANCH_IF_NOT_MINUS_ONE_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = 2
	TestName("BRANCH IF !-1")
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bnm1 !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(ACC, VAL_2, "2")
	TestComplete()
	rts
}

// A 6502 BRK (break) instruction is executed. SWEET 16 may be re-entered non destructively at SW16d after correcting the stack pointer to its value prior to executing the BRK.   This test uses an extension to SWEET16 which inserts a VICE break when the BK instruction is encountered after restoring the SP, Registers and Flags.  Note the additional argument to sweet16 to ensure the handler is setup as it is not by default.  The handler also deals with the setting up for the stack pointer and conntinuing execution from SW16D
BREAK_TEST: {
	.const REGISTER = ACC
	.const VAL_1 = $feed
	.const VAL_2 = $0123
	TestName("BREAK")
	sweet16 : 1					// NOTE: Installing handler to bring up VICE monitor if emulating
	set REGISTER : VAL_1
	bk
	xjsr !assertVal1+
	set REGISTER : VAL_2
	bk
	rtn
	TestAssertEqual(REGISTER, VAL_2, "2")
	TestComplete()
	rts
!assertVal1:
	TestAssertEqual(REGISTER, VAL_1, "1")
	rts
}

// Shows the use of the extension "IBK" which operates like "BK" except that it is responsible for installing the 6502 "brk" which can also be done by starting SWEET16 with a "sweet16 : 1".  Once the interrupt handler has been set there is no need to call ibk again
INTERRUPT_BREAK_TEST: {
	.const VAL_1 = $feed
	.const VAL_2 = $0123
	TestName("INT BREAK")	
	BreakOnBrk()
	sweet16
	set ACC : VAL_1
	bk
	xjsr !assert1+
	set ACC : VAL_2
	bk
	xjsr !assert2+
	rtn
	TestComplete()
	rts
!assert1:
	TestAssertEqual(ACC, VAL_1, "1")
	rts
!assert2:
	TestAssertEqual(ACC, VAL_2, "2")
	rts
}

// A branch to the effective address (PC + 2 + d) is taken and execution is resumed in SWEET 16 mode. The current PC is pushed onto a SWEET 16 subroutine return address stack whose pointer is R12, and R12 is incremented by 2. The carry is cleared and branch conditions set to indicate the current ACC contents. EXAMPLE: Calling a 'memory move' subroutine to move TEST_MEMORY_SEQUENCE to TEST_MEMORY_SEQUENCE_2
BRANCH_TO_SUBROUTINE_TEST: {
	.const SOURCE = 5
	.const SOURCE_LIMIT = 4
	.const DEST = 6
	TestName("BRANCH TO SUB")
	sweet16
	set SOURCE : TEST_MEMORY_SEQUENCE					// Init source register
	set SOURCE_LIMIT : TEST_MEMORY_SEQUENCE + TMS_SIZE 	// Init limit register
	set DEST : TEST_MEMORY_SEQUENCE_2					// Init dest register
	bs !move+											// call subroutine
	rtn
	jmp !done+
!move:
	ldi SOURCE											// move one byte
	sti DEST
	ld SOURCE_LIMIT
	cpr SOURCE											// test if done
	bp !move-
	rs													// return
!done:
	TestAssertEqualMemory(TEST_MEMORY_SEQUENCE, TEST_MEMORY_SEQUENCE_2, TMS_SIZE, "MEM")
	TestComplete()
	rts
}
	
// RS terminates execution of a SWEET 16 subroutine and returns to the SWEET 16 calling program which resumes execution (in SWEET 16 mode). R12, which is the SWEET 16 subroutine return stack pointer, is decremented twice. Branch conditions are not changed.
RETURN_FROM_SUBROUTINE_TEST: {
	.const REGISTER = ACC
	.const DEFAULT_VALUE = $1234
	.const SUB_SET_VALUE = $5678
	TestName("RETURN FROM SUB")
	sweet16
	set REGISTER : DEFAULT_VALUE
	bs !overwrite+
	rtn
	jmp !done+
!overwrite:
	set REGISTER : SUB_SET_VALUE
	rs
!done:
	TestAssertEqual(REGISTER, SUB_SET_VALUE, "SUB")
	TestComplete()
	rts
}
	


// Test the pseudocommand AJMP which allows SWEET16 to perform absolute jumps by directly setting the address of the PC (minus 1) in the ACC register.  Affect the value in the ACC and PC registers
ABSOLUTE_JUMP_TEST: {
	.const INITIAL_VALUE = $0000
	.const SET_VALUE = $1234
	.const NON_ACC_REGISTER = 5
	TestName("ABSOLUTE JUMP")
	sweet16
	set NON_ACC_REGISTER : INITIAL_VALUE	// initial value
	ajmp !setter+							// absolute jump to setter

!finished:
	rtn										// exit SWEET16
	TestAssertEqual(NON_ACC_REGISTER, SET_VALUE, "SET")
	TestComplete()
	rts

!setter:
	set NON_ACC_REGISTER : SET_VALUE		// overwrite value
	ajmp !finished-							// absolute jmp to finish
}

// XJSR is an extension added to the standard SWEET16 instructions to allow for a mix of SWEET16 calls and 6502.  When "XJSR" is called the address is executed normally as if we were in 6502 instruction set mode.  Once the RTS is encountered regular SWEET16 execution continues
EXTERNAL_JSR_TEST: {
	TestName("EXTERNAL JSR")
	.const REGISTER = 5			// arbitrary register
	.const VALUE = $4321		// arbitrary value
	.const VALUE_2 = $1234		// arbitrary value
	.const VALUE_3 = $feed		// different value (will be set using 6502 calls)
	sweet16
	set REGISTER : VALUE		// R5 now contains VALUE
	xjsr !assertAssigned+
	set REGISTER : VALUE_2		// R5 now contains VALUE_2
	xjsr !code6502+
	set REGISTER : VALUE		// R5 now contains VALUE (again)
	rtn
	TestAssertEqual(REGISTER, VALUE, "SAME")
	TestComplete()
	rts

!assertAssigned:
	TestAssertEqual(REGISTER, VALUE, "VALUE")
	rts
	
!code6502:						// native 6502 code
	lda #>VALUE_3
	sta rh(REGISTER)
	lda #<VALUE_3
	sta rl(REGISTER)
	ldxy REGISTER
	TestAssertEqual(REGISTER, VALUE_3, "6502")
	rts
}

// SETI is an extension added to the standard SWEET16 instructions to allow for a setting a register value indirectly by providing a memory location to source.
SET_INDIRECT_TEST: {
	.const REGISTER = 5			// arbitrary register
	TestName("SET INDIRECT")
	sweet16
	seti REGISTER : TEST_MEMORY	// set register with value at TEST_MEMORT
	rtn
	TestAssertEqualIndirectAddress(REGISTER, TEST_MEMORY, "TEST MEM")	
	TestComplete()
	rts
}

// SETM is an extension added to the standard SWEET16 instructions to allow for a setting a register value indirectly by providing a memory location to source.  It puts the exact bytes into the register not Hight byte Low byte
SET_MEMORY_TEST: {
	.const REGISTER = 5			// arbitrary register
	TestName("SET MEMORY")
	sweet16
	setm REGISTER : TEST_MEMORY	// set register with value at TEST_MEMORT
	rtn
	TestAssertEqualIndirect(REGISTER, TEST_MEMORY, "TEST MEM")	
	TestComplete()
	rts
}

TestRun:
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

.segment TestsPatch
tests_patch:
    PatchCode()

.segment Default