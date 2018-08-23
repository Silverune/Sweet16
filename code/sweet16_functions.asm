.function RL(register) {
	.return ZP_BASE + (register * 2)
}

.function RH(register) {
	.return ZP_BASE + (register * 2) + 1
}

.function rl(register) {
	.return RL(register)
}

.function rh(register) {
	.return RH(register)
}

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

// An effective address (ea) is calculated by adding the signed displacement byte (d) to the PC. The PC contains the address of the instruction immediately following the BR, or the address of the BR op plus 2. The displacement is a signed two's complement value from -128 to +127. Branch conditions are not changed.	
.function calc_effective_address(d, currentAddress) {
	.var finalAddress
	.if (d >= $80) {
		.eval finalAddress = currentAddress + 2 - ($100 - d)
	}
	else {	
		.eval finalAddress = currentAddress + 2 + d 
	}
	.errorif finalAddress < 0, "PC cannot be negative"
	.return finalAddress
}

.function test_calculate_effective_address(currentAddress) {
	.var values = List().add($80, $81, $ff, $00, $01, $7e, $7f)
	.for (var i = 0	; i < values.size(); i++) {
		.print "i = $" + toHexString(values.get(i)) + " -> $" + toHexString(calc_effective_address(values.get(i), currentAddress))
	}
}
	
.function effective_address(ea, currentAddress) {
	.if (ea.getType() == AT_ABSOLUTE)
	{
		.var relativeAddress = <(ea.getValue() - currentAddress - 2) // account for byte offset
#if DEBUG
		.print "ea: $" + toHexString(ea.getValue()) + " currentAddress: $" + toHexString(currentAddress)
		.print "Relative address: $" + toHexString(relativeAddress)
#endif
		.return relativeAddress
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
	
