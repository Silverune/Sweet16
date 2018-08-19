// The 2-byte constant is loaded into Rn (n=0 to F, Hex) and branch conditions set accordingly. The carry is cleared.
SET_TEST:
	sweet16
	set 5 : $a034		// R5 now contains $A034
	rtn
	ldxy 5
	break()
	rts

// The ACC (R0) is loaded from Rn and branch conditions set according to the data transferred. The carry is cleared and contents of Rn are not disturbed.
LOAD_TEST:
	sweet16
    set 5 : $A034
    ld 5			// ACC now contains $A034	
	rtn
	ldxy ACC
	break()
	rts

// The ACC is stored into Rn and branch conditions set according to the data transferred. The carry is cleared and the ACC contents are not disturbed.
STORE_TEST:
	sweet16
	set 5 : $1234
	ld 5			// Copy the contents
	st 6			// of R5 to R6
	rtn
	ldxy 6
	break()
	rts

// The low-order ACC byte is loaded from the memory location whose address resides in Rn and the high-order ACC byte is cleared. Branch conditions reflect the final ACC contents which will always be positive and never minus 1. The carry is cleared. After the transfer, Rn is incremented by 1.	
LOAD_INDIRECT_TEST:
	sweet16
	set 5 : TEST_MEMORY  // TEST_MEMORY contains value $12
	ldi 5				 // ACC is loaded from memory where TEST_MEMORY ($00, $12)
						 // R5 is incr by one (TEST_MEMORY + 1)
	rtn
	ldxy ACC
	break()
	ldxy 5
	break()
	rts

	// The low-order ACC byte is stored into the memory location whose address resides in Rn. Branch conditions reflect the 2-byte ACC contents. The carry is cleared. After the transfer Rn is incremented by 1.
STORE_INDIRECT_TEST:
	sweet16
	set 5 : TEST_MEMORY			// Load pointers R5, R6 with
	set 6 : TEST_MEMORY_2		// memory values
    ldi 5            			// Move byte from TEST_MEMORY to TEST_MEMORY_2
    sti 6			            // Both ptrs are incremented	
	rtn						
	ldxy 5
	break()
	ldxy 6
	break()
	rts

// The low order ACC byte is loaded from memory location whose address resides in Rn, and Rn is then incremented by 1. The high order ACC byte is loaded from the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the final ACC contents. The carry is cleared.
LOAD_DOUBLE_BYTE_INDIRECT_TEST:
	sweet16
	set 5 : TEST_MEMORY			// The low-order ACC byte is loaded from
	ldd 5						// TEST_MEMORY, high-order from TEST_MEMORY+1
								// NOTE - original had error of specifying "R6"
								// R5 is incr by 2	
	rtn
	ldxy ACC
	break()
	ldxy 5
	break()
	ldxy 6
	break()
	rts

// The low-order ACC byte is stored into memory location whose address resides in Rn, and Rn is the incremented by 1. The high-order ACC byte is stored into the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the ACC contents which are not disturbed. The carry is cleared.
STORE_DOUBLE_BYTE_INDIRECT_TEST:
	sweet16
	set 5 : TEST_MEMORY			// Load pointers R5, R6 with
	set 6 : TEST_MEMORY_2		// memory values
	ldd 5						// Move double byte from
    std 6            			// TEST_MEMORY to TEST_MEMORY_2
                                // Both pointers incremented by 2.
	rtn						
	ldxy 5
	break()
	ldxy 6
	break()
	rts

// The low-order ACC byte is loaded from the memory location whose address resides in Rn after Rn is decremented by 1, and the high order ACC byte is cleared. Branch conditions reflect the final 2-byte ACC contents which will always be positive and never minus one. The carry is cleared. Because Rn is decremented prior to loading the ACC, single byte stacks may be implemented with the STI Rn and POP Rn ops (Rn is the stack pointer).
POP_INDIRECT: {
	.const STACK = 5			// Arbitrary register to use
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
	.const FROM = 4				// Arbitrary register
	.const TO = 5				// Arbitrary register
	sweet16
	set FROM : TEST_MEMORY + 2	// Init pointers with 2 byte offset
	set TO : TEST_MEMORY_2 + 2  // as moves down from this address -1 then -2
	pop	FROM					// Move byte from
    stp TO            			// TEST_MEMORY + 1 to TEST_MEMORY_2 + 1
	pop FROM					// Move byte from
	stp TO						// TEST_MEMORY_2 to TEST_MEMORY_2
	rtn		
	break()
	rts
}

// The contents of Rn are added to the contents of ACC (R0), and the low-order 16 bits of the sum restored in ACC. the 17th sum bit becomes the carry and the other branch conditions reflect the final ACC contents.
ADD_TEST:
	sweet16
	set ACC : $7634 // Init R0 (ACC)
    set 1 : $4227	// Init R1
    add 1           // Add R1 (sum = $B85B, C clear)
    add ACC			// Double ACC (R0) to $70B6 with carry set.
	rtn
	ldxy ACC
	break()
	rts

// The contents of Rn are subtracted from the ACC contents by performing a two's complement addition:
//
// ACC = ACC + Rn + 1
//
//The low order 16 bits of the subtraction are restored in the ACC, the 17th sum bit becomes the carry and other branch conditions reflect the final ACC contents. If the 16-bit unsigned ACC contents are greater than or equal to the 16-bit unsigned Rn contents, then the carry is set, otherwise it is cleared. Rn is not disturbed.
SUBTRACT_TEST:
	sweet16
	set ACC : $7634     // Init R0 (ACC) 
	set 1 : $4227		// and R1
	sub 1				// subtract R1 (diff=$340D with c set)
	sub ACC				// clears ACC. (R0)
	rtn
	ldxy ACC
	break()
	rts

// Rn is decremented by 1 and the high-order ACC byte is loaded from the memory location whose address now resides in Rn. Rn is again decremented by 1 and the low-order ACC byte is loaded from the corresponding memory location. Branch conditions reflect the final ACC contents. The carry is cleared. Because Rn is decremented prior to loading each of the ACC halves, double-byte stacks may be implemented with the STD @Rn and POPD @Rn ops (Rn is the stack pointer).
POP_DOUBLE_BYTE_INDIRECT_TEST: {
	.const STACK = 5			// Arbitrary register to use
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
COMPARE_TEST:
	sweet16  // TODO
	rtn
	break()
	rts	

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
	
// Used for indirect testing
TEST_MEMORY:
	.byte $12,$34

TEST_MEMORY_2:
	.byte $56,$78

TEST_MEMORY_3:
	.byte $9a,$bc

STACK_MEMORY: {
	.const STACK_SIZE = 16		// bytes
	.fill STACK_SIZE, 0
}
