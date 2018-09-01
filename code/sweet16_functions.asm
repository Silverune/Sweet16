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

.function calc_effective_address_negpos(d, currentAddress) {
	.errorif d > 127, "Displacement too far forward " + d
	.errorif d < -128, "Displacement too far backward " + d

	.var dval = 0
/*	.if (d < 0) {
		.eval dval = $80
	} else {
		.eval dval = $7f
	}
*/
	.return calc_effective_address(dval, currentAddress)
}
	
.function test_calculate_effective_address(currentAddress) {
	.var values = List().add($80, $81, $ff, $00, $01, $7e, $7f)
	.for (var i = 0	; i < values.size(); i++) {
		.print "i = $" + toHexString(values.get(i)) + " -> $" + toHexString(calc_effective_address(values.get(i), currentAddress))
	}
}
	
.function effective_address_new(ea, currentAddress) {
	.print "ea: " + toHexString(ea.getValue())
	.print "d: " + (ea.getValue() - currentAddress) + " (" + toHexString(ea.getValue() - currentAddress) + ")"
	.print "*: " + toHexString(currentAddress)
	.var result = calc_effective_address_negpos(ea.getValue() - currentAddress, currentAddress)
	.print "result: " + toHexString(result)
	.return result
}

.function effective_address(ea, currentAddress) {

	.var d = (ea.getValue() - currentAddress)
	.errorif d > 127, "Displacement too far forward " + d
	.errorif d < -128, "Displacement too far backward " + d

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
	
