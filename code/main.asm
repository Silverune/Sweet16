BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
	break()
	jsr TEST1
	break()
	jsr TEST2
	break()
	jsr TEST3
	break()
	rts
