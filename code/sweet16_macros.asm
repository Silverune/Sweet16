.macro register_encode(op, register, address) {
	.byte opcode(op, register)
	.word address.getValue()
}

.macro InstallHandler(address, handler) {
	lda #<handler
    sta address
    lda #>handler
    sta address+1
}

.macro BreakOnBrk() {
	.const BRKVEC = $0316
	InstallHandler(BRKVEC, BREAK_HANDLER)
}

.macro IncPC() {
	inc R15L
    bne !incremented+ 		// inc PC
    inc R15H
!incremented:
}
