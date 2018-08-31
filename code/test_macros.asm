TEST_COUNT:
	.byte $00

TEST_PASS_COUNT:
	.byte $00

TEST_TITLE:	
	.text "SWEET16 TEST RUNNER"
	Newline()
	
.macro TestStart() {
	ChangeScreen(BACKGROUND_COLOR, TITLE_COLOR)
	ClearScreenZeroPage()
	ChangeCursor(0,0)
	KernalOutput(TEST_TITLE)
	ChangeColor(FOREGROUND_COLOR)

	lda #$00
	sta TEST_COUNT
	sta TEST_PASS_COUNT
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
/*color:
	.byte	$00*/
!done:	
}
	
.macro TestName(name) {
	.const spacing = 2
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

.macro TestAssertEqualMemoryRegister(register, value, desc) {
	TestAssertEqualMemoryDirect(rl(register), value, desc)
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
	break()
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
