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
