.segment Main

Main:
	jsr Bootstrap
	jsr TestRun
	jsr Anykey
	jmp Reset
	rts

Anykey:
!:
	KernalGetKey()
	beq !-	
	rts

Reset:
	jmp ($FFFC)
