BasicUpstart2(Program)

*=$0810 "Program"          // $080d is end of BASIC

Program:
	break()
	jsr TEST0
	jsr TEST1
	jsr TEST2
	jsr TEST3
	rts
