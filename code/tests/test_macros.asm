#importonce

.macro TestStart() {
	TestSetupScreen(BACKGROUND_COLOR, TITLE_COLOR)	
	ScreenOutputStringLine("SWEET16 TEST RUNNER")
	ScreenColor(FOREGROUND_COLOR)

	lda #$00
	sta TEST_COUNT
	sta TEST_PASS_COUNT
	sta TEST_NAME_COUNT
}

.macro TestInc() {
	inc TEST_COUNT
}

.macro TestSetupScreen(background_color, foreground_color) {
	ScreenBorder(background_color)
	ScreenBackground(background_color)
	ScreenColor(foreground_color)
	jsr KernalJump.ClearScreen
	CursorRowColumn(0,0)
}

.macro TestPassed() {
	inc TEST_PASS_COUNT
}

.macro TestFinished() {
	ScreenOutputColor(memory, TITLE_COLOR)
	ScreenOutputNumber(TEST_PASS_COUNT)
	ScreenOutputColor(memory_2, TITLE_COLOR)
	ScreenOutputNumber(TEST_COUNT)
	ScreenOutputColor(memory_3, TITLE_COLOR)
	jmp !done+
memory:
	.byte Petscii.RETURN
	.text "TESTS COMPLETE: "
	.byte Petscii.NULL
memory_2:
	.text " / "
	.byte Petscii.NULL
memory_3:
	 ScreenNewlineReturn()
!done:
}
	
.macro TestName(name) {
	.const spacing = 2
	inc TEST_NAME_COUNT
	ScreenOutputStringColor(name, NAME_COLOR)
	jmp !done+
memory:
	.fill spacing, Petscii.SPACEBAR
	.text name
	.text "..."
	.byte Petscii.NULL
!done:
}

.macro TestAssertDescription(description) {
	TestInc()
	ScreenOutputColor(memory, DESC_COLOR)
	jmp !done+
memory:
	.byte Petscii.SPACEBAR
	.text description
	.text ":"
	.byte Petscii.NULL
!done:
}

.macro TestSuccess() {
	TestPassed()
	ScreenOutputColor(TEST_SUCCESS, SUCCESS_COLOR)
}

.macro TestFailure() {
	ScreenOutputColor(TEST_FAILURE, FAILURE_COLOR)
}

.macro TestComplete() {
	ScreenOutput(memory)
	jmp !done+
memory:
	ScreenNewlineReturn()
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
	ScreenOutputColor(memory, WHITE)
	jmp !no_key+
memory:
	.byte Petscii.RETURN
	.text "PRESS ANY KEY TO CONTINUE..."
	ScreenNewlineReturn()
!no_key:
	GetKey()
	beq !no_key-
	ScreenOutput(!newline+)
	jmp !done+
!newline:
	ScreenNewlineReturn()
!done:
}

.segment Default