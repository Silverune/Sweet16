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
    ldi 5            			// Move byte from TEST_MEMORY to TEST_MEMORY_@
    sti 6			            // Both ptrs are incremented	
	rtn						
	ldxy 5
	break()
	ldxy 6
	break()
	rts

// The low order ACC byte is loaded from memory location whose address resides in Rn, and Rn is then incremented by 1. The high order ACC byte is loaded from the memory location whose address resides in the incremented Rn, and Rn is again incremented by 1. Branch conditions reflect the final ACC contents. The carry is cleared.
LOAD_DOUBLE_BYTE_INDIRECT_TEST: // TODO - test
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
POP_INDIRECT:	
	sweet16
	set 5 : TEST_MEMORY			// Init stack pointer
	set ACC : 4					// Load 4 into ACC
	sti 5						// Push 4 onto stack
	set ACC : 5					// Load 5 into ACC
	sti 5						// Push 5 onto stack
	set ACC : 6					// Load 6 into ACC
	sti 5						// Push 6 onto stack
	pop 5						// Pop 6 off stack into ACC
	pop 5						// Pop 5 off stack into ACC
	pop 5						// Pop 4 off stack into ACC
	rtn						
	ldxy ACC
	break()
	ldxy 5
	break()
	rts


// The contents of Rn are added to the contents of ACC (R0), and the low-order 16 bits of the sum restored in ACC. the 17th sum bit becomes the carry and the other branch conditions reflect the final ACC contents.
ADD_TEST:
	sweet16
	set 0 : $7634   // Init R0 (ACC) and R1
    set 1 : $4227
    add 1           // Add R1 (sum=B85B, C clear)
    add 0			// Double ACC (R0) to $70B6 with carry set.
	rtn
	ldxy ACC
	break()
	rts

// Used for indirect testing
TEST_MEMORY:
	.byte $12,$34

TEST_MEMORY_2:
	.byte $56,$78	
