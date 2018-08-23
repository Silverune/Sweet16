.macro BreakOnBrk() {
	.const BRKVEC = $0316
	InstallHandler(BRKVEC, BREAK_HANDLER)
}
	
