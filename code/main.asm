.segment Main

BasicUpstart2(Main)

Main:
	Cookie_Check(LibLocation)					// looks for byte sequence indicating code placeholder meaning actual code needs to be loaded
 	beq !already_loaded+						// segment data already there - not being loaded from disk
 	jsr load_code								// load library and tests
!already_loaded:
	jsr ready

error_handler:
	pha
	ScreenOutputString("Error: ")
	pla
	jsr Kernal.CHROUT
	jmp *

load: {
	Load(error_handler)
	rts
}

load_code: {
	ScreenOutputString("LOADING CODE...")
	LoadList(codeFiles, load)
	rts
}

ready:
	jsr TestRun
	jsr Anykey
	jmp (Kernal.RESET)
	rts

Anykey:
!:
	GetKey()
	beq !-	
	rts

.segment Default
