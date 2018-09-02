// Code for creating the breakpoint file sent to VICE
.var brkFile = createFile("breakpoints.txt")

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
