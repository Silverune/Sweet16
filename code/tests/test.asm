// Create instance of Sweet16
.segment Sweet16
	Sweet16()
.segment Sweet16Patch
sweet16_patch:
    Cookie_WriteCode()

.segment Tests

// Simple tests for Sweet16.  Most of these are converted versions of Woz's originals in the description of each of the mnemonics / opcodes (http://www.6502.org/source/interpreters/sweet16.htm#Register_Instructions_).

// The 2-byte constant783 is loaded into Rn (n=0 to F, Hex) and branch conditions set accordingly. The carry is cleared.
TestSet: {
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

// The Sweet16_ACC is loaded from Rn and branch conditions set according to the data transferred. The carry is cleared and contents of Rn are not disturbed.
TestLoad: {
	.const REGISTER = 5			// arbitrary register
	.const VALUE = $4321
	TestName("LOAD")
	sweet16
    set REGISTER : VALUE
    ld REGISTER					// Sweet16_ACC now contains VALUE
	rtn
	TestAssertEqual(Sweet16_ACC, VALUE, "ACC")
	TestComplete()
	rts
}

// The Sweet16_ACC is stored into Rn and branch conditions set according to the data transferred. The carry is cleared and the Sweet16_ACC contents are not disturbed.
TestStore: {
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
	
// The low-order Sweet16_ACC byte is loaded from the memory location whose address resides in Rn and the high-order Sweet16_ACC byte is cleared. Branch conditions reflect the final Sweet16_ACC contents which will always be positive and never minus 1. The carry is cleared. After the transfer, Rn is incremented by 1.	
TestLoadIndirect: {
	.const REGISTER = 5			// arbitrary register
	TestName("LOAD INDIRECT")
	sweet16
	set REGISTER : TEST_MEMORY  // Load from 
	ldi REGISTER				// Sweet16_ACC is loaded from memory where TEST_MEMORY ($00, $12)
								// R5 is incr by one (TEST_MEMORY + 1)
	rtn
	TestAssertEqualIndirectByte(Sweet16_ACC, TEST_MEMORY, "ACC")
	TestAssertEqual(REGISTER, TEST_MEMORY + 1, "REG")
	TestComplete()
	rts
}
	
// The low-order Sweet16_ACC byte is stored into the memory location whose address resides in Rn. Branch conditions reflect the 2-byte Sweet16_ACC contents. The carry is cleared. After the transfer Rn is incremented by 1.
TestStoreIndirect: {
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
	
// The low order Sweet16_ACC byte is loaded from memory location whose address resides in Rn, and Rn is then incremented by 1. The high order Sweet16_ACC byte is loaded from the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the final Sweet16_ACC contents. The carry is cleared.
TestLoadDoubleByteIndirect: {
	.const REGISTER = 5			// arbitrary register
	TestName("LOAD DOUBLE INDIRECT")
	sweet16
	set REGISTER : TEST_MEMORY	// The low-order Sweet16_ACC byte is loaded from
	lddi REGISTER				// TEST_MEMORY, high-order from TEST_MEMORY+1
								// NOTE - original had error of specifying "R6"
								// R5 is incr by 2	
	rtn
	TestAssertEqualIndirect(Sweet16_ACC, TEST_MEMORY, "ACC")
	TestAssertEqual(REGISTER, TEST_MEMORY+2, "+2")
	TestComplete()
	rts
}

// The low-order Sweet16_ACC byte is stored into memory location whose address resides in Rn, and Rn is the incremented by 1. The high-order Sweet16_ACC byte is stored into the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the Sweet16_ACC contents which are not disturbed. The carry is cleared.
TestStoreDoubleByteIndirect: {
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
	
// The low-order Sweet16_ACC byte is loaded from the memory location whose address resides in Rn after Rn is decremented by 1, and the high order Sweet16_ACC byte is cleared. Branch conditions reflect the final 2-byte Sweet16_ACC contents which will always be positive and never minus one. The carry is cleared. Because Rn is decremented prior to loading the ACC, single byte stacks may be implemented with the STI Rn and POP Rn ops (Rn is the stack pointer).  Note - as trying to inspect the intermediate values using the extension "XJSR" to output the test assertions
TestPopIndirect: {
	.const STACK = 5			// Arbitrary register
	.const VAL_1 = $04			// Arbitrary low order used
	.const VAL_2 = $05			// Arbitrary low order used
	.const VAL_3 = $06			// Arbitrary low order used
	TestName("POP INDIRECT 1")
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set Sweet16_ACC : VAL_1				// Load into ACC
	sti STACK					// Push onto stack
	xjsr !assert1+
	set Sweet16_ACC : VAL_2				// Load into ACC
	sti STACK					// Push onto stack
	xjsr !assert2+
	set Sweet16_ACC : VAL_3				// Load into ACC
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
	TestAssertEqualIndirectByte(Sweet16_ACC, STACK_MEMORY, "1")
	rts
!assert2:
	TestAssertEqualIndirectByte(Sweet16_ACC, STACK_MEMORY+1, "2")
	rts
!assert3:
	TestAssertEqualIndirectByte(Sweet16_ACC, STACK_MEMORY+2, "3")
	rts
!assertP3:
	TestComplete()
	TestName("POP INDIRECT 2")
	TestAssertEqual(Sweet16_ACC, VAL_3, "P3")
	rts
!assertP2:
	TestAssertEqual(Sweet16_ACC, VAL_2, "P2")
	rts
!assertP1:
	TestAssertEqual(Sweet16_ACC, VAL_1, "P1")
	rts
}
	
// The low-order Sweet16_ACC byte is stored into the memory location whose address resides in Rn after Rn is decremented by 1. Branch conditions will reflect the 2-byte Sweet16_ACC contents which are not modified. STP Rn and POP Rn are used together to move data blocks beginning at the greatest address and working down. Additionally, single-byte stacks may be implemented with the STP Rn ops.
TestStorePopIndirect: {
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

// The contents of Rn are added to the contents of Sweet16_ACC, and the low-order 16 bits of the sum restored in ACC. the 17th sum bit becomes the carry and the other branch conditions reflect the final Sweet16_ACC contents.
TestAdd: {
	.const REGISTER = 1
	.const VAL_1 = $7634
	.const VAL_2 = $4227
	TestName("ADDITION")
	sweet16
	set Sweet16_ACC : VAL_1 		// Init Sweet16_ACC
    set REGISTER : VAL_2			// Init REGSITER
    add REGISTER           			// Add REGISTER (sum, C clear)
	xjsr !assertAdd+
    add Sweet16_ACC					// Double Sweet16_ACC with carry set.
	rtn
	TestAssertEqual(Sweet16_ACC, (VAL_1 + VAL_2) * 2, "X2")
	TestComplete()
	rts
!assertAdd:
	TestAssertEqual(Sweet16_ACC, VAL_1 + VAL_2, "ADD")
	rts
}
	
// The contents of Rn are subtracted from the Sweet16_ACC contents by performing a two's complement addition:
//
// Sweet16_ACC = Sweet16_ACC + Rn + 1
//
//The low order 16 bits of the subtraction are restored in the ACC, the 17th sum bit becomes the carry and other branch conditions reflect the final Sweet16_ACC contents. If the 16-bit unsigned Sweet16_ACC contents are greater than or equal to the 16-bit unsigned Rn contents, then the carry is set, otherwise it is cleared. Rn is not disturbed.
TestSubtract: {
	.const REGISTER = 1		// Arbitrary register
	.const VAL_1 = $7634
	.const VAL_2 = $4227
	TestName("SUBTRACTION")
	sweet16
	set Sweet16_ACC : VAL_1     	// Init Sweet16_ACC
	set REGISTER : VAL_2	// and REGISTER
	sub REGISTER			// subtract R1 (diff=$340D with c set)
	xjsr !assertSub+
	sub Sweet16_ACC					// clears Sweet16_ACC
	rtn
	TestAssertEqual(Sweet16_ACC, 0, "0")
	TestComplete()
	rts
!assertSub:
	TestAssertEqual(Sweet16_ACC, VAL_1 - VAL_2, "SUB")
	rts	
}
	
// Rn is decremented by 1 and the high-order Sweet16_ACC byte is loaded from the memory location whose address now resides in Rn. Rn is again decremented by 1 and the low-order Sweet16_ACC byte is loaded from the corresponding memory location. Branch conditions reflect the final Sweet16_ACC contents. The carry is cleared. Because Rn is decremented prior to loading each of the Sweet16_ACC halves, double-byte stacks may be implemented with the STD @Rn and POPD @Rn ops (Rn is the stack pointer).
TestPopDoubleByteIndirect: {
	.const STACK = 5			// Arbitrary register
	TestName("POP DBL-B IND")
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set Sweet16_ACC : TEST_MEMORY		// Load TEST_MEMORY into ACC
	stdi STACK					// Push TEST_MEMORY onto stack
	xjsr !assertStd1+
	set Sweet16_ACC : TEST_MEMORY_2		// Load TEST_MEMORY_2 into ACC
	stdi STACK					// Push TEST_MEMORY_2 onto stack
	xjsr !assertStd2+
	popdi STACK					// Pop TEST_MEMORY_2 off stack
	xjsr !assertPop2+
	popdi STACK					// Pop TEST_MEMORY off stack
	rtn
	TestAssertEqualMemoryRegister(Sweet16_ACC,  TEST_MEMORY, "P1")
	TestComplete()
	rts
!assertStd1:
	TestAssertEqualMemoryDirect(STACK_MEMORY, TEST_MEMORY, "1")
	rts
!assertStd2:
	TestAssertEqualMemoryDirect(STACK_MEMORY+2, TEST_MEMORY_2, "2")
	rts
!assertPop2:
	TestAssertEqualMemoryRegister(Sweet16_ACC,  TEST_MEMORY_2, "P2")
	rts
}

// The Sweet16_ACC contents are compared to Rn by performing the 16 bit binary subtraction ACC-Rn and storing the low order 16 difference bits in R13 for subsequent branch tests. If the 16 bit unsigned Sweet16_ACC contents are greater than or equal to the 16 bit unsigned Rn contents, then the carry is set, otherwise it is cleared. No other registers, including Sweet16_ACC and Rn, are disturbed.
TestCompare: {
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
	sub Sweet16_ACC		// zero data
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
TestIncrement: {
	.const REGISTER = 5			// arbitrary register
	TestName("INCREMENT")
	sweet16
	set REGISTER : TEST_MEMORY	// setup pointer
	sub Sweet16_ACC				// clear ACC
	sti REGISTER				// clear location TEST_MEMORY
	inr REGISTER				// increment R5 to TEST_MEMORY + 2
	rtn
	TestAssertEqual(REGISTER, TEST_MEMORY + 2, "+2")
	TestComplete()
	rts
}

// The contents of Rn are decremented by 1. The carry is cleared and other branch conditions reflect the decremented value. e.g., to clear 9 bytes beginning at location TEST_MEMORY_SEQUENCE
TestDecrement: {
	.const DATA_REGISTER = 5
	.const COUNT_REGISTER = 4
	TestName("DECREMENT")
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE	// Init pointer
	set COUNT_REGISTER : TMS_SIZE				// Init counter
	sub Sweet16_ACC							    // Zero ACC
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
TestReturnTo6502Mode: {
	TestName("6502 MODE")
	sweet16
	rtn
	TestAssertNonZero(1, "RTN")
	TestComplete()
	rts
}
	
// An effective address (ea) is calculated by adding the signed displacement byte (d) to the PC. The PC contains the address of the instruction immediately following the BR, or the address of the BR op plus 2. The displacement is a signed two's complement value from -128 to +127. Branch conditions are not changed.
TestBranchAlways: {
	TestName("BRANCH ALWAYS")
	sweet16
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_1, "1")
	TestComplete()
	rts
}

// A branch to the effective address is taken only is the carry is clear, otherwise execution resumes as normal with the next instruction. Branch conditions are not changed.	
TestBranchIfNoCarry: {
	.const REGISTER = 5
	TestName("BRANCH NO CARRY")
	sweet16
	set REGISTER : $1000
	set Sweet16_ACC : $ffff
	add REGISTER
	bnc !setVal1+
	br !setVal2+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the carry is set. Branch conditions are not changed.
TestBranchIfCarrySet: {
	.const REGISTER = 5
	TestName("BRANCH IF CARRY")
	sweet16
	set REGISTER : $1000
	set Sweet16_ACC : $ffff
	add REGISTER
	bc !setVal1+
	br !setVal2+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_1, "1")
	TestComplete()
	rts
}

// A branch is effected only if the prior 'result' (or most recently transferred data) was positive. Branch conditions are not changed. e.g., Clear mem from TEST_MEMORY_SEQUENCE to SIZE
TestBranchIfPlus: {
	.const DATA_REGISTER = 5
	.const LIMIT_REGISTER = 4
	TestName("BRANCH IF +VE")
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE		 		// Init pointer
	set LIMIT_REGISTER : TEST_MEMORY_SEQUENCE + TMS_SIZE 	// Init limit
!loop:
	sub Sweet16_ACC							// Clear mem byte
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
TestBranchIfMinus: {
	.const DATA_REGISTER = 5
	.const VALUE = $0A
	TestName("BRANCH IF -VE")
	sweet16
	set DATA_REGISTER : #VALUE
	sub Sweet16_ACC							// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bm !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A Branch is effected only if the prior 'result' was zero. Branch conditions are not changed.
TestBranchIfZero: {
	TestName("BRANCH IF 0")
	sweet16
	sub Sweet16_ACC							// Clear mem byte
	bz !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the priot 'result' was non-zero Branch conditions are not changed.
TestBranchIfNonZero: {
	.const DATA_REGISTER = 5
	.const VALUE = $0A
	TestName("BRANCH IF !0")
	sweet16
	set DATA_REGISTER : #VALUE
	sub Sweet16_ACC							// Clear mem byte
	add DATA_REGISTER                       // Add from R5 value to 0 
	bnz !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A branch is effected only if the prior 'result' was minus one ($FFFF Hex). Branch conditions are not changed.
TestBranchIfMinus1: {
	.const DATA_REGISTER = 5
	.const VALUE = 1
	TestName("BRANCH IF -1")
	sweet16
	set DATA_REGISTER : #VALUE
	sub Sweet16_ACC							// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bm1 !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A branch effected only if the prior 'result' was not minus 1. Branch conditions are not changed
TestBranchIfNotMinus1: {
	.const DATA_REGISTER = 5
	.const VALUE = 2
	TestName("BRANCH IF !-1")
	sweet16
	set DATA_REGISTER : #VALUE
	sub Sweet16_ACC							// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bnm1 !setVal2+
	br !setVal1+
!setVal1:
	.const VAL_1 = $fedc
	set Sweet16_ACC : VAL_1
	br !finish+
!setVal2:
	.const VAL_2 = $0123
	set Sweet16_ACC : VAL_2
	br !finish+
!finish:
	rtn
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	TestComplete()
	rts
}

// A 6502 BRK (break) instruction is executed. SWEET 16 may be re-entered non destructively at Sweet16_Next after correcting the stack pointer to its value prior to executing the BRK.   This test uses an extension to SWEET16 which inserts a VICE break when the BK instruction is encountered after restoring the SP, Registers and Flags.  Note the additional argument to sweet16 to ensure the handler is setup as it is not by default.  The handler also deals with the setting up for the stack pointer and conntinuing execution from Sweet16_Execute
TestBreak: {
	.const REGISTER = Sweet16_ACC
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
TestInterruptBreak: {
	.const VAL_1 = $feed
	.const VAL_2 = $0123
	TestName("INT BREAK")
	Address_Load(!breakHandler+, Three.BRK)
	sweet16
	set Sweet16_ACC : VAL_1
	bk
	xjsr !assert1+
	set Sweet16_ACC : VAL_2
	bk
	xjsr !assert2+
	rtn
	TestComplete()
	rts
!assert1:
	TestAssertEqual(Sweet16_ACC,  VAL_1, "1")
	rts
!assert2:
	TestAssertEqual(Sweet16_ACC,  VAL_2, "2")
	rts
!breakHandler:
	pla		// Y
	tay		// restore Y
	pla		// X
	tax		// restore X
	pla		// restore A
	sta Sweet16_RL(Sweet16_ZP)
	plp		// restore Status Flags
	pla		// PCL discard - not useful
	pla		// PCH discard - not useful
	lda Sweet16_RL(Sweet16_ZP)
	jmp Sweet16_Execute
}

// A branch to the effective address (PC + 2 + d) is taken and execution is resumed in SWEET 16 mode. The current PC is pushed onto a SWEET 16 subroutine return address stack whose pointer is R12, and R12 is incremented by 2. The carry is cleared and branch conditions set to indicate the current Sweet16_ACC contents. EXAMPLE: Calling a 'memory move' subroutine to move TEST_MEMORY_SEQUENCE to TEST_MEMORY_SEQUENCE_2
TestBranchToSubroutine: {
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
TestReturnFromSubroutine: {
	.const REGISTER = Sweet16_ACC
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
	


// Test the pseudocommand AJMP which allows SWEET16 to perform absolute jumps by directly setting the address of the PC (minus 1) in the Sweet16_ACC register.  Affect the value in the Sweet16_ACC and PC registers
TestAbsoluteJump: {
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
TestExternalJSR: {
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
	sta Sweet16_RH(REGISTER)
	lda #<VALUE_3
	sta Sweet16_RL(REGISTER)
	ldxy REGISTER
	TestAssertEqual(REGISTER, VALUE_3, "6502")
	rts
}

// SETI is an extension added to the standard SWEET16 instructions to allow for a setting a register value indirectly by providing a memory location to source.
TestSetIndirect: {
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
TestSetMemory: {
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

	jsr TestSet
	jsr TestLoad
	jsr TestStore
	jsr TestLoadIndirect
	jsr TestStoreIndirect
	jsr TestLoadDoubleByteIndirect
	jsr TestStoreDoubleByteIndirect
	jsr TestPopIndirect
	jsr TestStorePopIndirect
	jsr TestAdd
	jsr TestSubtract
	jsr TestPopDoubleByteIndirect
	jsr TestCompare
	jsr TestIncrement
	jsr TestDecrement
	jsr TestReturnTo6502Mode
	jsr TestBranchAlways
	jsr TestBranchIfNoCarry
	jsr TestBranchIfCarrySet
	jsr TestBranchIfPlus
	jsr TestBranchIfMinus
	jsr TestBranchIfZero
	jsr TestBranchIfNonZero
	jsr TestBranchIfMinus1
	jsr TestBranchIfNotMinus1
	jsr TestBreak
	jsr TestBranchToSubroutine
	jsr TestReturnFromSubroutine

	// extensions
	jsr TestAbsoluteJump
	jsr TestExternalJSR
	jsr TestSetIndirect
	jsr TestSetMemory
	jsr TestInterruptBreak
		
	TestFinished()

	// not a real test as routine not required in this implementation
#if DEBUG
	//.eval test_calculate_effective_address($1000)
#endif
	rts

.segment TestsPatch
tests_patch:
	Cookie_WriteCode()

.segment Default