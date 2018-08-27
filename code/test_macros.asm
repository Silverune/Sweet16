.macro TestName(name) {
	.const spacing = 2
	KernalOutput(memory)
	jmp !done+
memory:
	.fill spacing, spacebar
	.text name
	.text "..."
	.byte NULL
!done:
}

.macro TestSuccess() {
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

.macro TestAssertEqualIndirectByte(register, address) {
	ldxy register
	cpy address
	bne !failed+
	TestSuccess()
	jmp !done+
	rts
!failed:
	TestFailure()
!done:	
}

.macro TestAssertEqualIndirect(register, address) {
	ldxy register
	cpx address
	bne !failed+
	cpy address+1
	bne !failed+
	TestSuccess()
	jmp !done+
	rts
!failed:
	TestFailure()
!done:	
}
	
.macro TestAssertEqual(register, value) {
	ldxy register
	cpx #>value
	bne !failed+
	cpy #<value
	bne !failed+
	TestSuccess()
	jmp !done+
	rts
!failed:
	TestFailure()
!done:	
}
