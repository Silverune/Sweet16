.function opcode(operand, register) {
	.if (register.getType() == AT_IMMEDIATE || register.getType() == AT_ABSOLUTE)
		.return operand + register.getValue()
	.error "Register must be a number"
}

.function _16bitnextArgument(arg) {
	.if (arg.getType()==AT_IMMEDIATE)
		.return CmdArgument(arg.getType(),>arg.getValue())
	.return CmdArgument(arg.getType(),arg.getValue()+1)
}

.function effective_address(ea, currentAddress) {
	.if (ea.getType() == AT_ABSOLUTE)
	{
		.var relative = <(ea.getValue() - currentAddress - 2) // account for byte offset
#if DEBUG
		.print "Relative equivalent: $" + toHexString(relative)
#endif
		.return relative
	}

	.if (ea.getType()==AT_IMMEDIATE) {
#if DEBUG
		.print "Immediate: #" + ea.getValue
#endif
		.return ea.getValue()
	}

	.var value = CmdArgument(ea.getType(),ea.getValue()+1).getValue()
#if DEBUG
	.print "Type: " + ea.getType() + " Value: $"+ toHexString(value)
#endif	
	.return value
}

// Convenience	
.pseudocommand sweet16 save {
	.var save_restore = 1
	.if (save.getType() != AT_NONE)
		.eval save_restore = save.getValue()
	.if (save_restore != 0)
		jsr SW16
	else
		jsr SW16_NONE
}

.pseudocommand ldxy register {	
	ldx rh(register.getValue())
	ldy rl(register.getValue())
}

.pseudocommand SWEET16 save { sweet16 save }

// Nonregister Ops	
.pseudocommand rtn { .byte $00 }
.pseudocommand RTN { rtn }

.pseudocommand br ea { .byte $01, effective_address(ea,*) }
.pseudocommand BR ea { br ea }

.pseudocommand bnc ea {	.byte $02, effective_address(ea,*) }
.pseudocommand BNC ea {	bnc ea }

.pseudocommand bc ea { .byte $03, effective_address(ea,*) }
.pseudocommand BC ea { bc ea }

.pseudocommand bp ea { .byte $04, effective_address(ea,*) }
.pseudocommand BP ea { bp ea }

.pseudocommand bm ea { .byte $05, effective_address(ea,*) }
.pseudocommand BM ea { bm ea }

.pseudocommand bz ea { .byte $06, effective_address(ea,*) }
.pseudocommand BZ ea { bz ea }

.pseudocommand bnz ea {	.byte $07, effective_address(ea,*) }
.pseudocommand BNZ ea {	bnz ea }

.pseudocommand bm1 ea {	.byte $08, effective_address(ea,*) }
.pseudocommand BM1 ea {	bm1 ea }

.pseudocommand bnm1 ea { .byte $09, effective_address(ea,*) }
.pseudocommand BNM1 ea { bnm1 ea }

.pseudocommand bk ea { .byte $0a }
.pseudocommand BK ea { bk ea }

.pseudocommand rs {	.byte $0b }
.pseudocommand RS {	rs }

.pseudocommand bs ea { .byte $0c, effective_address(ea,*) }
.pseudocommand BS ea { bs ea }
	
// Register Ops
.macro register_encode(op, register, address) {
	.byte opcode(op, register)
	.word address.getValue()
}

.pseudocommand set register : address {	register_encode($10, register, address) }
.pseudocommand SET register : address { set register : address }

.pseudocommand ld register { .byte opcode($20, register) }
.pseudocommand LD register { ld register }

.pseudocommand st register { .byte opcode($30, register) }
.pseudocommand ST register { st register }

.pseudocommand ldi register { .byte opcode($40, register) }
.pseudocommand LDI register { ldi register }

.pseudocommand sti register { .byte opcode($50, register) }
.pseudocommand STI register { sti register }

.pseudocommand ldd register { .byte opcode($60, register) }
.pseudocommand LDD register { ldd register }

.pseudocommand std register { .byte opcode($70, register) }
.pseudocommand STD register { std register }

.pseudocommand pop register { .byte opcode($80, register) }
.pseudocommand POP register { pop register }

.pseudocommand stp register { .byte opcode($90, register) }
.pseudocommand STP register { stp register }

.pseudocommand add register { .byte opcode($a0, register) }
.pseudocommand ADD register { add register }

.pseudocommand sub register { .byte opcode($b0, register) }
.pseudocommand SUB register { sub register }

.pseudocommand popd register { .byte opcode($c0, register) }
.pseudocommand POPD register { popd register }

.pseudocommand cpr register { .byte opcode($d0, register) }
.pseudocommand CPR register { cpr register }

.pseudocommand inr register { .byte opcode($e0, register) }
.pseudocommand INR register { inr register }

.pseudocommand dcr register { .byte opcode($f0, register) }
.pseudocommand DCR register { dcr register }
