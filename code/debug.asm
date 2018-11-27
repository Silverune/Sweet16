// Code for creating the breakpoint file sent to VICE
#if DEBUG
.var brkFile = createFile(cmdLineVars.get( "BREAKPOINTS" ))
#endif

.macro break() {
#if DEBUG
	.eval brkFile.writeln("break exec " + toHexString(*))
#endif
}

.macro trace() {
#if DEBUG
	.eval brkFile.writeln("trace exec " + toHexString(*))
#endif
}

.macro label(name, addr) {
#if DEBUG
	.var finalAddr = addr <= 255 ? "00" + toHexString(addr) : toHexString(addr)
	.eval brkFile.writeln("al C:" + finalAddr + " ." + name)
#endif
}
