.segment Main

	.var testString = "1234567890"
Main:
.break

	CopyToManagedBuffer(Debug, ManagedBuffer256, testString.size())
	
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

Debug:
.memblock "Debug"
	.text testString
