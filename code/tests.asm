// Setup some common blocks of memory to use for the testing
TEST_MEMORY:
	.byte $12,$34

TEST_MEMORY_2:
	.byte $56,$78

TEST_MEMORY_3:
	.byte $9a,$bc

.const TMS_SIZE = 16
TEST_MEMORY_SEQUENCE:
	.fill TMS_SIZE, i

STACK_MEMORY: {
	.const STACK_SIZE = 16		// bytes
	.fill STACK_SIZE, 0
}

// The 2-byte constant is loaded into Rn (n=0 to F, Hex) and branch conditions set accordingly. The carry is cleared.
SET_TEST: {
	.const REGISTER = 5			// arbitrary register	
	sweet16
	set REGISTER : $a034		// R5 now contains $A034
	rtn
	ldxy REGISTER
	break()
	rts
}
	
// The ACC (R0) is loaded from Rn and branch conditions set according to the data transferred. The carry is cleared and contents of Rn are not disturbed.
LOAD_TEST: {
	.const REGISTER = 5			// arbitrary register
	sweet16
    set REGISTER : $A034
    ld REGISTER					// ACC now contains $A034	
	rtn
	ldxy ACC
	break()
	rts
}

// The ACC is stored into Rn and branch conditions set according to the data transferred. The carry is cleared and the ACC contents are not disturbed.
STORE_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	sweet16
	set SOURCE : $1234
	ld SOURCE					// Copy the contents
	st DEST						// of R5 to R6
	rtn
	ldxy DEST
	break()
	rts
}
	
// The low-order ACC byte is loaded from the memory location whose address resides in Rn and the high-order ACC byte is cleared. Branch conditions reflect the final ACC contents which will always be positive and never minus 1. The carry is cleared. After the transfer, Rn is incremented by 1.	
LOAD_INDIRECT_TEST: {
	.const REGISTER = 5			// arbitrary register
	sweet16
	set REGISTER : TEST_MEMORY  // TEST_MEMORY contains value $12
	ldi REGISTER				// ACC is loaded from memory where TEST_MEMORY ($00, $12)
								// R5 is incr by one (TEST_MEMORY + 1)
	rtn
	ldxy ACC
	break()
	ldxy REGISTER
	break()
	rts
}
	
// The low-order ACC byte is stored into the memory location whose address resides in Rn. Branch conditions reflect the 2-byte ACC contents. The carry is cleared. After the transfer Rn is incremented by 1.
STORE_INDIRECT_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	sweet16
	set SOURCE : TEST_MEMORY	// Load pointers R5, R6 with
	set DEST : TEST_MEMORY_2	// memory values
    ldi SOURCE            		// Move byte from TEST_MEMORY to TEST_MEMORY_2
    sti DEST			        // Both ptrs are incremented	
	rtn						
	ldxy SOURCE
	break()
	ldxy DEST
	break()
	rts
}
	
// The low order ACC byte is loaded from memory location whose address resides in Rn, and Rn is then incremented by 1. The high order ACC byte is loaded from the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the final ACC contents. The carry is cleared.
LOAD_DOUBLE_BYTE_INDIRECT_TEST: {
	.const REGISTER = 5			// arbitrary register
	sweet16
	set REGISTER : TEST_MEMORY	// The low-order ACC byte is loaded from
	ldd REGISTER				// TEST_MEMORY, high-order from TEST_MEMORY+1
								// NOTE - original had error of specifying "R6"
								// R5 is incr by 2	
	rtn
	ldxy ACC
	break()
	ldxy REGISTER
	break()
	rts
}

// The low-order ACC byte is stored into memory location whose address resides in Rn, and Rn is the incremented by 1. The high-order ACC byte is stored into the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the ACC contents which are not disturbed. The carry is cleared.
STORE_DOUBLE_BYTE_INDIRECT_TEST: {
	.const SOURCE = 5			// arbitrary register
	.const DEST = 6				// arbitrary register
	sweet16
	set SOURCE : TEST_MEMORY	// Load pointers R5, R6 with
	set DEST : TEST_MEMORY_2	// memory values
	ldd SOURCE					// Move double byte from
    std DEST            		// TEST_MEMORY to TEST_MEMORY_2
                                // Both pointers incremented by 2.
	rtn						
	ldxy SOURCE
	break()
	ldxy DEST
	break()
	rts
}
	
// The low-order ACC byte is loaded from the memory location whose address resides in Rn after Rn is decremented by 1, and the high order ACC byte is cleared. Branch conditions reflect the final 2-byte ACC contents which will always be positive and never minus one. The carry is cleared. Because Rn is decremented prior to loading the ACC, single byte stacks may be implemented with the STI Rn and POP Rn ops (Rn is the stack pointer).
POP_INDIRECT: {
	.const STACK = 5			// Arbitrary register
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set ACC : 4					// Load 4 into ACC
	sti STACK					// Push 4 onto stack
	set ACC : 5					// Load 5 into ACC
	sti STACK					// Push 5 onto stack
	set ACC : 6					// Load 6 into ACC
	sti STACK					// Push 6 onto stack
	pop STACK					// Pop 6 off stack into ACC
	pop STACK					// Pop 5 off stack into ACC
	pop STACK					// Pop 4 off stack into ACC
	rtn					
	ldxy ACC
	break()
	ldxy STACK
	break()
	rts
}
	
// The low-order ACC byte is stored into the memory location whose address resides in Rn after Rn is decremented by 1. Branch conditions will reflect the 2-byte ACC contents which are not modified. STP Rn and POP Rn are used together to move data blocks beginning at the greatest address and working down. Additionally, single-byte stacks may be implemented with the STP Rn ops.
STORE_POP_INDIRECT_TEST: {
	.const SOURCE = 4				// Arbitrary register
	.const DEST = 5					// Arbitrary register
	sweet16
	set SOURCE : TEST_MEMORY + 2	// Init pointers with 2 byte offset
	set DEST : TEST_MEMORY_2 + 2 	// as moves down from this address -1 then -2
	pop	SOURCE						// Move byte from
    stp DEST            			// TEST_MEMORY + 1 to TEST_MEMORY_2 + 1
	pop SOURCE						// Move byte from
	stp DEST						// TEST_MEMORY_2 to TEST_MEMORY_2
	rtn		
	break()
	rts
}

// The contents of Rn are added to the contents of ACC (R0), and the low-order 16 bits of the sum restored in ACC. the 17th sum bit becomes the carry and the other branch conditions reflect the final ACC contents.
ADD_TEST: {
	sweet16
	set ACC : $7634 // Init R0 (ACC)
    set 1 : $4227	// Init R1
    add 1           // Add R1 (sum = $B85B, C clear)
    add ACC			// Double ACC (R0) to $70B6 with carry set.
	rtn
	ldxy ACC
	break()
	rts
}
	
// The contents of Rn are subtracted from the ACC contents by performing a two's complement addition:
//
// ACC = ACC + Rn + 1
//
//The low order 16 bits of the subtraction are restored in the ACC, the 17th sum bit becomes the carry and other branch conditions reflect the final ACC contents. If the 16-bit unsigned ACC contents are greater than or equal to the 16-bit unsigned Rn contents, then the carry is set, otherwise it is cleared. Rn is not disturbed.
SUBTRACT_TEST: {
	sweet16
	set ACC : $7634     // Init R0 (ACC) 
	set 1 : $4227		// and R1
	sub 1				// subtract R1 (diff=$340D with c set)
	sub ACC				// clears ACC. (R0)
	rtn
	ldxy ACC
	break()
	rts
}
	
// Rn is decremented by 1 and the high-order ACC byte is loaded from the memory location whose address now resides in Rn. Rn is again decremented by 1 and the low-order ACC byte is loaded from the corresponding memory location. Branch conditions reflect the final ACC contents. The carry is cleared. Because Rn is decremented prior to loading each of the ACC halves, double-byte stacks may be implemented with the STD @Rn and POPD @Rn ops (Rn is the stack pointer).
POP_DOUBLE_BYTE_INDIRECT_TEST: {
	.const STACK = 5			// Arbitrary register
	sweet16
	set STACK : STACK_MEMORY	// Init stack pointer
	set ACC : TEST_MEMORY		// Load TEST_MEMORY into ACC
	std STACK					// Push TEST_MEMORY onto stack
	set ACC : TEST_MEMORY_2		// Load TEST_MEMORY_2 into ACC
	std STACK					// Push TEST_MEMORY_2 onto stack
	popd STACK					// Pop TEST_MEMORY_2 off stack
	popd STACK					// Pop TEST_MEMORY off stack
	rtn
	ldxy ACC
	break()
	rts
}

// The ACC (R0) contents are compared to Rn by performing the 16 bit binary subtraction ACC-Rn and storing the low order 16 difference bits in R13 for subsequent branch tests. If the 16 bit unsigned ACC contents are greater than or equal to the 16 bit unsigned Rn contents, then the carry is set, otherwise it is cleared. No other registers, including ACC and Rn, are disturbed.
COMPARE_TEST: {
	.const DATA_REGISTER = 5
	.const LIMIT_REGISTER = 6
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE				// pointer to memory
	set LIMIT_REGISTER : TEST_MEMORY_SEQUENCE + TMS_SIZE	// limit address
!loop:
	sub ACC				// zero data
	std	DATA_REGISTER	// clear 2 locations
	ld DATA_REGISTER	// compare pointer R5
	cpr LIMIT_REGISTER	// to limit R6
	bnc !loop-			// loop if C clear
	rtn
	ldxy CPR
	break()
	rts	
}

// The contents of Rn are incremented by 1. The carry is cleared and other branch conditions reflect the incremented value.
INCREMENT_TEST: {
	.const REGISTER = 5			// arbitrary register
	sweet16
	set REGISTER : TEST_MEMORY	// setup pointer
	sub ACC						// clear ACC
	sti REGISTER				// clear location TEST_MEMORY
	inr REGISTER				// increment R5 to TEST_MEMORY + 2
	rtn
	ldxy REGISTER
	break()
	rts
}

// The contents of Rn are decremented by 1. The carry is cleared and other branch conditions reflect the decremented value. e.g., to clear 9 bytes beginning at location TEST_MEMORY_SEQUENCE
DECREMENT_TEST: {
	.const DATA_REGISTER = 5
	.const COUNT_REGISTER = 4
	sweet16
	set DATA_REGISTER : TEST_MEMORY_SEQUENCE	// Init pointer
	set COUNT_REGISTER : TMS_SIZE				// Init counter
	sub ACC									    // Zero ACC
!loop:
	sti DATA_REGISTER							// Clear a mem byte
	dcr COUNT_REGISTER							// Decrement count
	bnz !loop-
	rtn
	ldxy DATA_REGISTER
	break()
	rts
}

// Control is returned to the 6502 and program execution continues at the location immediately following the RTN instruction. the 6502 registers and status conditions are restored to their original contents (prior to entering SWEET 16 mode).
RETURN_TO_6502_MODE_TEST: {
	sweet16
	rtn
	break()
	rts
}
	
SET_FEDC:
	set ACC : $fedc
	br BRANCH_FINISH

SET_0123:
	set ACC : $0123
	br BRANCH_FINISH

BRANCH_FINISH:
	rtn
	ldxy ACC
	break()
	rts	

// An effective address (ea) is calculated by adding the signed displacement byte (d) to the PC. The PC contains the address of the instruction immediately following the BR, or the address of the BR op plus 2. The displacement is a signed two's complement value from -128 to +127. Branch conditions are not changed.
BRANCH_ALWAYS_TEST:
	sweet16
	br SET_FEDC

// A branch to the effective address is taken only is the carry is clear, otherwise execution resumes as normal with the next instruction. Branch conditions are not changed.	
BRANCH_IF_NO_CARRY_TEST: {
	.const REGISTER = 5
	sweet16
	set REGISTER : $1000
	set ACC : $ffff
	add REGISTER
	bnc SET_FEDC
	br SET_0123
}
	
// A branch is effected only if the carry is set. Branch conditions are not changed.
BRANCH_IF_CARRY_SET_TEST: {
	.const REGISTER = 5
	sweet16
	set REGISTER : $1000
	set ACC : $ffff
	add REGISTER
	bc SET_FEDC
	br SET_0123
}

// A branch is effected only if the prior 'result' (or most recently transferred dat) was positive. Branch conditions are not changed. e.g., Clear mem from TEST_MEMORY_SEQUENCE to SIZE
BRANCH_IF_PLUS_TEST: {
	.const DATA_REGISTER = 5
	.const LIMIT_REGISTER = 4
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
	break()
	rts
}

// A branch is effected only if prior 'result' was minus (negative, MSB = 1). Branch conditions are not changed.
BRANCH_IF_MINUS_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = 10
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	sub DATA_REGISTER                       // Subtract from 0 value in R5
	bm SET_0123
	br SET_FEDC
}

// A Branch is effected only if the prior 'result' was zero. Branch conditions are not changed.
BRANCH_IF_ZERO_TEST: {
	sweet16
	sub ACC									// Clear mem byte
	bz SET_0123
	br SET_FEDC
}

// A branch is effected only if the priot 'result' was non-zero Branch conditions are not changed.
BRANCH_IF_NONZERO_TEST: {
	.const DATA_REGISTER = 5
	.const VALUE = 10
	sweet16
	set DATA_REGISTER : #VALUE
	sub ACC									// Clear mem byte
	add DATA_REGISTER                       // Add from R5 value to 0 
	bnz SET_0123
	br SET_FEDC
}



