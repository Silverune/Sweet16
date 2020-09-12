// Startup routines for when loaded from disk
.segment Bootstrap

BasicUpstart2(Bootstrap)

Bootstrap:
    LoadPrgFile(LibFile, libraryFilename.size())        
    LoadPrgFile(TestsFile, testsFilename.size())
    jmp Main

LibFile:
.memblock "LibFile"
    .text libraryFilename
TestsFile:
    .text testsFilename

.segment Default

