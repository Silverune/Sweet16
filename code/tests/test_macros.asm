#importonce

.macro TestStart() {
    Screen_SetUpperLowerCase()
	TestInitializeCounters()
	TestSetupScreen(BACKGROUND_COLOR, TITLE_COLOR)	
	TestOutputString("Sweet16 Test Runner")
	Screen_OutputNewline()
	Screen_Color(FOREGROUND_COLOR)
}

.macro TestInitializeCounters() {
	lda #00
	sta TestCount
	sta TestPassCount
	sta TestNameCount
}

.macro TestInc() {
	inc TestCount
}

.macro TestSetupScreen(background_color, foreground_color) {
	Screen_Border(background_color)
	Screen_Background(background_color)
	Screen_Color(foreground_color)
	jsr KernalJump.ClearScreen
	Cursor_RowColumn(0,0)
}

.macro TestPassed() {
	inc TestPassCount
}

.macro TestFinished() {
	TestOutputColor(memory, TITLE_COLOR)
	Screen_OutputNumber(TestPassCount, TempByteZp)
	TestOutputColor(memory_2, TITLE_COLOR)
	Screen_OutputNumber(TestCount, TempByteZp)
	TestOutputColor(memory_3, TITLE_COLOR)
	jmp !done+
memory:
	.byte Ascii.RETURN
	Kick_PetsciiMixed("Tests Complete: ")
	.byte 0
memory_2:
	Kick_PetsciiMixed(" / ")
	.byte 0
memory_3:
	 .byte Ascii.RETURN, 0
!done:
}

.macro TestEffectiveAddress(opcode, description) {
	TestName(opcode, "ea", description)
}

.macro TestValue(opcode, description) {
	TestName(opcode, "n", description)
}

.macro TestCommand(opcode, description) {
	TestName(opcode, "-", description)
}

.macro TestName(opcode, args, description) {
	.const spacing = 1
	inc TestNameCount
	.encoding "petscii_mixed"
	TestOutputStringColor(opcode, OPCODE_COLOR)
	TestOutput(!space+)
	TestOutputStringColor(args, ARG_COLOR)
	TestOutput(!space+)
	TestOutputStringColor(description, NAME_COLOR)
	jmp !done+
!space:
	.text " "
	.byte 0
!done:
}

.macro TestAssertDescription(description) {
	TestInc()
	TestOutputColor(memory, DESC_COLOR)
	jmp !done+
memory:
	.byte Ascii.SPACEBAR
	Kick_PetsciiMixed(description)
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
	.byte Ascii.RETURN, 0
!done:
	ldx TestNameCount
	cpx #TESTS_PER_PAGE
	bne !exit+
	TestPause()
	ldx #0
	stx TestNameCount
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
	.byte Ascii.RETURN
	Kick_PetsciiMixed("Press any keu to continue...")
	.byte Ascii.RETURN, 0
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