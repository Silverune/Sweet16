#importonce

.macro TestStart() {
	TestInitializeCounters()
	TestSetupScreen(BACKGROUND_COLOR, TITLE_COLOR)	
	TestOutputString("SWEET16 TEST RUNNER")
	Screen_OutputNewline()
	Screen_Color(FOREGROUND_COLOR)
}

.macro TestInitializeCounters() {
	lda #00
	sta TEST_COUNT
	sta TEST_PASS_COUNT
	sta TEST_NAME_COUNT

	// lda #>TEST_WORD_ONE
	// sta TEST_MEMORY
	// lda #<TEST_WORD_ONE
	// sta TEST_MEMORY+1

	// lda #>TEST_WORD_TWO
	// sta TEST_MEMORY_2
	// lda #<TEST_WORD_TWO	
	// sta TEST_MEMORY_2+1
}

.macro TestInc() {
	inc TEST_COUNT
}

.macro TestSetupScreen(background_color, foreground_color) {
	Screen_Border(background_color)
	Screen_Background(background_color)
	Screen_Color(foreground_color)
	jsr KernalJump.ClearScreen
	Cursor_RowColumn(0,0)
}

.macro TestPassed() {
	inc TEST_PASS_COUNT
}

.macro TestFinished() {
	TestOutputColor(memory, TITLE_COLOR)
	Screen_OutputNumber(TEST_PASS_COUNT, TempByteZp)
	TestOutputColor(memory_2, TITLE_COLOR)
	Screen_OutputNumber(TEST_COUNT, TempByteZp)
	TestOutputColor(memory_3, TITLE_COLOR)
	jmp !done+
memory:
	.byte Petscii.RETURN
	.text "TESTS COMPLETE: "
	.byte 0
memory_2:
	.text " / "
	.byte 0
memory_3:
	 .byte Petscii.RETURN, 0
!done:
}
	
.macro TestName(preprocessorString) {
	.const spacing = 2
	inc TEST_NAME_COUNT
	TestOutputStringColor(preprocessorString, NAME_COLOR)
	TestOutput(memory)

	jmp !done+
memory:
	.fill spacing, Petscii.SPACEBAR
	.text "..."
	.byte 0
!done:
}

.macro TestAssertDescription(description) {
	TestInc()
	TestOutputColor(memory, DESC_COLOR)
	jmp !done+
memory:
	.byte Petscii.SPACEBAR
	.text description
	.text ":"
	.byte 0
!done:
}

.macro TestSuccess() {
	TestPassed()
	TestOutputColor(TEST_PETSCII_SUCCESS, SUCCESS_COLOR)
}

.macro TestFailure() {
	TestOutputColor(TEST_PETSCII_FAILURE, FAILURE_COLOR)
}

.macro TestComplete() {
	TestOutput(memory)
	jmp !done+
memory:
	.byte Petscii.RETURN, 0
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
	TestAssertEqualMemoryDirect(Sweet16_RL(register), value, desc)
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
	lda Sweet16_RL(register1)
	cmp Sweet16_RL(register2)
	bne !failed+
	lda Sweet16_RH(register1)
	cmp Sweet16_RH(register2)
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}

// pauses output until the user hits a key to ensure all results are shown
.macro TestPause() {
	TestOutputColor(memory, WHITE)
	jmp !no_key+
memory:
	.byte Petscii.RETURN
	.text "PRESS ANY KEY TO CONTINUE..."
	.byte Petscii.RETURN, 0
!no_key:
	Keyboard_Any()
	Screen_OutputNewline()
}

.macro TestOutput(address) {
	Address_Load(address, ScreenZp)
	jsr TestOutputIndirect
}

.macro TestOutputString(preprocessorString) {
	TestOutput(!data+)
	jmp !done+
!data:
	.text preprocessorString	// store in memory
	.byte 0						// terminate
!done:
}

.macro TestOutputColor(msg, color) {
	lda Two.CurrentCharColor
	pha
	Screen_Color(color)
	TestOutput(msg)
	pla
	sta Two.CurrentCharColor
}

.macro TestOutputStringColor(preprocessorString, color) {
	lda Two.CurrentCharColor
	pha
	Screen_Color(color)
	TestOutputString(preprocessorString)
	pla
	sta Two.CurrentCharColor
}

.segment Default