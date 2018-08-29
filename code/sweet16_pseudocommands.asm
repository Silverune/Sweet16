
// convenience entry point
// save - (optional) if non-zero will save registers on entry and restore on exit
// break_handler - (optional) installs a ISR to called if the "bk" command is in ever used (6502 "brk" as well).  The routine restores the state and sets up to continue execution.  Useful for debugging in assembly monitors 
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
.pseudocommand SWEET16 save : break_handler { sweet16 save : break_handler }

// debugging conveniece to load into the X and Y regsiters the specified SWEET16 register
.pseudocommand ldxy register {
	ldx rh(register.getValue())
	ldy rl(register.getValue())
}

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

// extensions
.pseudocommand xjsr address {
	.byte $0d
	.byte >(address.getValue()-1)
	.byte <(address.getValue()-1)
}
.pseudocommand XJSR address { xjsr address }

.pseudocommand ibk { .byte $0e }
.pseudocommand IBK { ibk }

	
// Register Ops
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


// extensions
.pseudocommand seti register : address {
	.byte $0f
	.word address.getValue()
	.byte rl(register.getValue())
}
.pseudocommand SETI register : address { seti register : address }
	
// "You can perform absolute jumps within SWEET 16 by loading the ACC (R0) with the address you wish to jump to (minus 1) and executing a ST R15 instruction."  This is not a core SWEET16 instruction
.pseudocommand ajmp address {
	set ACC : address.getValue()-1
	st PC
}
.pseudocommand AJMP address { ajmp address }
