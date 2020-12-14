#importonce
.filenamespace Sweet16

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

.macro BreakHandler() {
	pla		// Y
	tay		// restore Y
	pla		// X
	tax		// restore X
	pla		// restore A
	sta RL(ZP)
	plp		// restore Status Flags
	pla		// PCL discard - not useful
	pla		// PCH discard - not useful
	lda RL(ZP)
	// jmp SW16D
}

.macro @BreakOnBrk() {
	.const BRKVEC = $0316
!instance:
    BreakHandler()
	InstallHandler(BRKVEC, !instance-)
    // jmp Sweet16.SW16D - TODO 
}

.macro IncPC() {
	inc R15L
    bne !incremented+ 		// inc PC
    inc R15H
!incremented:
}

.macro Register(addrLow, addrHigh) {
    .label RL = addrLow
    .label RH = addrHigh
}
