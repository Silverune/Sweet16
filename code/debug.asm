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

.macro trace_read_addr(addr) {
#if DEBUG
	.eval brkFile.writeln("trace exec " + toHexString(addr))
#endif
}

.macro trace_write_addr(addr) {
#if DEBUG
	.eval brkFile.writeln("trace store " + toHexString(addr))
#endif
}

.macro watch_write() {
#if DEBUG
	.eval brkFile.writeln("watch store " + toHexString(*))
#endif
}

.macro watch_write_addr(addr) {
#if DEBUG
	.eval brkFile.writeln("watch store " + toHexString(addr))
#endif
}

.macro watch_read_addr(addr) {
#if DEBUG
	.eval brkFile.writeln("watch exec " + toHexString(addr))
#endif
}

.macro watch_read() {
#if DEBUG
	.eval brkFile.writeln("watch exec " + toHexString(*))
#endif
}

.macro label(name, addr) {
#if DEBUG
	.var finalAddr = addr <= 255 ? "00" + toHexString(addr) : toHexString(addr)
	.eval brkFile.writeln("al C:" + finalAddr + " ." + name)
#endif
}

// repeatedly calls the subroutine (for tracing execution times)	
.macro repeat(subroutine, times) {
	.errorif times > $ff, "repeat maximum of 255"
	trace()
	lda #$00
	ldx #times
	beq !exit+ // zero value passed in
!loop:
	pha
	jsr subroutine
	pla
	clc
	adc #$01
	bne !loop-
!exit:
	trace()
}
	
	
