.macro TestStart() {
	ChangeScreen(BACKGROUND_COLOR, TITLE_COLOR)
	ClearScreen(BACKGROUND_COLOR)
	ChangeCursor(0,0)
	KernalOutput(TEST_TITLE)
	ChangeColor(FOREGROUND_COLOR)

	lda #$00
	sta TEST_COUNT
	sta TEST_PASS_COUNT
	sta TEST_NAME_COUNT
}

.macro TestInc() {
	inc TEST_COUNT
}

.macro TestPassed() {
	inc TEST_PASS_COUNT
}

.macro TestFinished() {
	OutputInColor(memory, TITLE_COLOR)
	OutputNumber(TEST_PASS_COUNT)
	OutputInColor(memory_2, TITLE_COLOR)
	OutputNumber(TEST_COUNT)
	OutputInColor(memory_3, TITLE_COLOR)
	jmp !done+
memory:
	.byte RETURN
	.text "TESTS COMPLETE: "
	.byte NULL
memory_2:
	.text " / "
	.byte NULL
memory_3:
	Newline()
!done:
}
	
.macro TestName(name) {
	.const spacing = 2
	inc TEST_NAME_COUNT
	OutputInColor(memory, NAME_COLOR)
	jmp !done+
memory:
	.fill spacing, spacebar
	.text name
	.text "..."
	.byte NULL
!done:
}

.macro TestAssertDescription(description) {
	TestInc()
	OutputInColor(memory, DESC_COLOR)
	jmp !done+
memory:
	.byte spacebar
	.text description
	.text ":"
	.byte NULL
!done:
}

.macro TestSuccess() {
	TestPassed()
	OutputInColor(TEST_SUCCESS, SUCCESS_COLOR)
}

.macro TestFailure() {
	OutputInColor(TEST_FAILURE, FAILURE_COLOR)
}

.macro TestComplete() {
	KernalOutput(memory)
	jmp !done+
memory:
	Newline()
!done:
	ldx TEST_NAME_COUNT
	cpx #TESTS_PER_PAGE
	bne !exit+
	TestPause()
	ldx #$00
	stx TEST_NAME_COUNT
!exit:	
}

.macro TestAssertEqualIndirectByte(register, address, desc) {
	TestAssertDescription(desc)
	ldxy register
	cpx address
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

.macro TestAssertEqualMemory(source, dest, size, desc) {
	TestAssertDescription(desc)
	ldx #$ff
!loop:
	inx
	cpx #size
	beq !success+
	lda source,x
	cmp dest,x
	beq !loop-
	jmp !failed+
!success:
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

.macro TestAssertEqualMemoryToConstant(source, constant, size, desc) {
	TestAssertDescription(desc)
	ldx #$ff
!loop:
	inx
	cpx #size
	beq !success+
	lda #constant
	cmp source,x
	beq !loop-
	jmp !failed+
!success:
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// compares the two bytes at the passed in address with the value off the address passed in (assumes its a 2-byte address)
.macro TestAssertEqualMemoryDirect(addr, value, desc) {
	TestAssertDescription(desc)
	ldx addr
	cpx #<value
	bne !failed+
	ldx addr+1
	cpx #>value
	bne !failed+
!success:
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// simply adds a convenience of doing the register lookup
.macro TestAssertEqualMemoryRegister(register, value, desc) {
	TestAssertEqualMemoryDirect(Sweet16_rl(register), value, desc)
}

// compares the value in the register with the value stored at the address which has been stpred Low byte then High byte which is how SWEET16 keeps its values
.macro TestAssertEqualIndirectAddress(register, address, desc) {
	TestAssertDescription(desc)
	ldxy register
	cpy address
	bne !failed+
	cpx address+1
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// equal to the value at the address passed in
.macro TestAssertEqualIndirect(register, address, desc) {
	TestAssertDescription(desc)
	ldxy register
	cpx address
	bne !failed+
	cpy address+1
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// compares the value in the register with the absolute value passed in
.macro TestAssertEqual(register, value, desc) {
	TestAssertDescription(desc)
	ldxy register
	cpx #<value
	bne !failed+
	cpy #>value
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// mainly used to output desc and result - actual test performed externally	
.macro TestAssertNonZero(value, desc) {
	TestAssertDescription(desc)
	ldx #value
	beq !failed+
!success:
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// compares two SWEET16 register contents
.macro TestAssertEqualRegisters(register1, register2, desc) {
	TestAssertDescription(desc)
	lda Sweet16.rl(register1)
	cmp Sweet16.rl(register2)
	bne !failed+
	lda Sweet16.rh(register1)
	cmp Sweet16.rh(register2)
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// pauses output until the user hits a key to ensure all results are shown
.macro TestPause() {
	OutputInColor(memory, WHITE)
	jmp !no_key+
memory:
	.byte RETURN
	.text "PRESS ANY KEY TO CONTINUE..."
	Newline()
!no_key:
	GetKey()
	beq !no_key-
	KernalOutput(newline)
	jmp !done+
newline:
	Newline()
!done:
}

.segment Default