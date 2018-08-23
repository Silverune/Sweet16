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

//.function calculate_effective_address(ea, currentAddress) {
//	.return <(ea - currentAddress - 2) // account for byte offset
//}

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

// Convenience	
.pseudocommand sweet16 save : break_handler {
	.var install_break = 0
	.if (break_handler.getType() != AT_NONE)
		.eval install_break = break_handler.getValue()
	.if (install_break != 0)
		BreakOnBrk()
	
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

.pseudocommand SWEET16 save : break_handler { sweet16 save : break_handler }

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

.pseudocommand bk { .byte $0a }
.pseudocommand BK { bk }

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

// You can perform absolute jumps within SWEET 16 by loading the ACC (R0) with the address you wish to jump to (minus 1) and executing a ST R15 instruction.
.pseudocommand ajmp address {
	.if (address.getType() == AT_IMMEDIATE || address.getType() == AT_ABSOLUTE) {
		set ACC : address.getValue()-1
		st PC
	}
	.error "Absolute jump not supporting passed in type"
}
.pseudocommand AJMP address { ajmp address }

	
