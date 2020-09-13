// Startup routines for when loaded from disk
.segment Bootstrap

BasicUpstart2(Bootstrap)

Bootstrap:
	KernalOutput(Verbose)
    LoadPrgFile(LibFile, libraryFilename.size())        
	KernalOutput(Verbose)
    LoadPrgFile(TestsFile, testsFilename.size())
    jmp Main
TestLoHi:
.memblock "TestLoHi"
    LoHi($ff)
LibFile:
.memblock "LibFile"
    .text libraryFilename
TestsFile:
    .text testsFilename

Verbose:
    .text "LOADING...."
    .byte RETURN, NULL

.segment Default

