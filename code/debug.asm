// Code for creating the breakpoint file sent to VICE
// telnet localhost 6510 to get to remote monitor
.var _useBinFolderForBreakpoints = cmdLineVars.get("usebin") == "true"
.var keys = cmdLineVars.keys()
.for (var i=0; i<keys.size(); i++) {
    .print keys.get(i)
}
.var _createDebugFiles = true //cmdLineVars.get("afo") == "true"
.print "File creation " + [_createDebugFiles ? "enabled (creating breakpoint file)" : "disabled (no breakpoint file created)"]
.var brkFile
.if(_createDebugFiles) {
	.if(_useBinFolderForBreakpoints)
		.eval brkFile = createFile("bin/breakpoints.txt")
	else
		.eval brkFile = createFile("breakpoints.txt")
}

.macro break() {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("break exec " + toHexString(*))
	}
#endif
}

.macro trace() {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("trace exec " + toHexString(*))
	}
#endif
}

.macro trace_read_addr(addr) {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("trace exec " + toHexString(addr))
	}
#endif
}

.macro trace_write_addr(addr) {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("trace store " + toHexString(addr))
	}
#endif
}

.macro watch_write() {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("watch store " + toHexString(*))
	}
#endif
}

.macro watch_write_addr(addr) {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("watch store " + toHexString(addr))
	}
#endif
}

.macro watch_read_addr(addr) {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("watch exec " + toHexString(addr))
	}
#endif
}

.macro watch_read() {
#if DEBUG
	.if(_createDebugFiles) {
		.eval brkFile.writeln("watch exec " + toHexString(*))
	}
#endif
}

.macro label(name, addr) {
#if DEBUG
	.if(_createDebugFiles) {
		.var finalAddr = addr <= 255 ? "00" + toHexString(addr) : toHexString(addr)
		.eval brkFile.writeln("al C:" + finalAddr + " ." + name)
	}
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
	
	
