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

// Nonregister Ops	
.pseudocommand rtn {
	.byte $00
}

.pseudocommand br ea {
	.byte $01, effective_address(ea,*)
}

.pseudocommand bnc ea {
	.byte $02, effective_address(ea,*)
}

.pseudocommand bc ea {
	.byte $03, effective_address(ea,*)
}

.pseudocommand bp ea {
	.byte $04, effective_address(ea,*)
}

.pseudocommand bm ea {
	.byte $05, effective_address(ea,*)
}

.pseudocommand bz ea {
	.byte $06, effective_address(ea,*)
}

.pseudocommand bnz ea {
	.byte $07, effective_address(ea,*)
}

.pseudocommand bm1 ea {
	.byte $08, effective_address(ea,*)
}

.pseudocommand bnm1 ea {
	.byte $09, effective_address(ea,*)
}

.pseudocommand bk ea {
	.byte $0a, effective_address(ea,*)
}

.pseudocommand rs {
	.byte $0b
}

.pseudocommand bs ea {
	.byte $0c, effective_address(ea,*)
}
	
// Register Ops
.macro register_encode(op, register, address) {
	.byte opcode(op, register)
	.word address.getValue()
}

.pseudocommand set register : address {
	register_encode($10, register, address)
}

.pseudocommand ld register {
	.byte opcode($20, register)
}

.pseudocommand st register {
	.byte opcode($30, register)
}
	
.pseudocommand ldi register {
	.byte opcode($40, register)
}
	
.pseudocommand sti register {
	.byte opcode($50, register)
}
	
.pseudocommand ldd register : address {
	register_encode($60, register, address)
}

.pseudocommand std register : address {
	register_encode($70, register, address)
}

.pseudocommand pop register : address {
	register_encode($80, register, address)
}

.pseudocommand stp register : address {
	register_encode($90, register, address)
}

.pseudocommand add register : address {
	register_encode($a0, register, address)
}

.pseudocommand sub register : address {
	register_encode($b0, register, address)
}

.pseudocommand popd register : address {
	register_encode($c0, register, address)
}

.pseudocommand cpr register : address {
	register_encode($d0, register, address)
}

.pseudocommand inr register : address {
	register_encode($e0, register, address)
}

.pseudocommand dcr register : address {
	.byte opcode($f0, register)
}
