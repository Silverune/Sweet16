.segment Main

BasicUpstart2(Main)

Main: {
.break
	Cookie_Check(LibLocation)					// looks for byte sequence indicating code placeholder meaning actual code needs to be loaded
 	bcc !already_loaded+						// segment data already there - not being loaded from disk
 	jsr LoadCode								// load library and tests
!already_loaded:
	jsr Ready
}

ErrorHandler:
	pha
	TestOutputString("Error: ")
	pla
	jsr Kernal.CHROUT
	jmp *

Load: {
	Disk_Load(ErrorHandler)
	rts
}

LoadCode: {
	TestOutputString("LOADING CODE...")
	Disk_LoadList(codeFiles, Load)
	rts
}

Ready: {
	jsr TestRun
	Keyboard_Any()
	jmp (Kernal.RESET)
}

.segment Default
