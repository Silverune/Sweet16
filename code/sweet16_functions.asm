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
