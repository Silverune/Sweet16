.segmentdef Main [start=$810]
.segmentdef Sweet16Patch [startAfter="Main", allowOverlap]
.segmentdef Sweet16 [startAfter="Main", segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data", allowOverlap]
.segmentdef Util[startAfter="Sweet16Data", segments="UtilData"]

.segmentdef TestsPatch[startAfter="UtilData", allowOverlap]
.segmentdef Tests[startAfter="UtilData", segments="TestData", allowOverlap]

.var name = cmdLineVars.get("name").string()
#if PRG
.file [
    name=name + ".prg",
    segments="Main, Sweet16, Util, Tests",
    modify="BasicUpstart",
    _start=Main
]
#endif

#if DISK
BasicUpstart2(Main)
#endif

.var libraryFilename="---    LIB    ---"
.var testsFilename="---   TESTS   ---"

#if DISK

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {
    [name="-----------------", type="rel" ],
    [name="---  SWEET16  ---", type="prg", segments="Main, Sweet16Patch, Util, TestsPatch"],
    [name="-----------------", type="rel" ],
    [name=libraryFilename, type="prg", segments="Sweet16" ],
    [name=testsFilename, type="prg", segments="Tests" ],
    [name="-----------------", type="rel" ],
}

#endif

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"
