.segment Main

BasicUpstart2(Main)

Main: {
.break
	CookieCheck(LibLocation)					// looks for byte sequence indicating code placeholder meaning actual code needs to be loaded
 	beq !already_loaded+						// segment data already there - not being loaded from disk
 	jsr LoadCode								// load library and tests
!already_loaded:
.break
	jsr Ready
}

ErrorHandler:
	pha
	ScreenOutputString("Error: ")
	pla
	jsr Kernal.CHROUT
	jmp *

Load: {
	Load(ErrorHandler)
	rts
}

LoadCode: {
	ScreenOutputString("LOADING CODE...")
	LoadList(codeFiles, Load)
	rts
}

Ready: {
	jsr TestRun
	jsr Anykey
	jmp (Kernal.RESET)
}

Anykey: {
	GetKey()
	beq Anykey
	rts
}

.segment Default
