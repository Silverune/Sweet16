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
	cpy address
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
	
.macro TestAssertEqual(register, value, desc) {
	TestAssertDescription(desc)
	ldxy register
	cpx #>value
	bne !failed+
	cpy #<value
	bne !failed+
	TestSuccess()
	jmp !done+
!failed:
	TestFailure()
!done:	
}
