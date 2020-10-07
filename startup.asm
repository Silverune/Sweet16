.const MainLocation = $0810
.const LibLocation = $1000
.const TestLocation = $2000

.segmentdef Main [start=MainLocation]
.segmentdef Util[startAfter="Main", segments="UtilData"]

.segmentdef Sweet16Patch [start=LibLocation, allowOverlap]
.segmentdef Sweet16 [start=LibLocation, segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data", allowOverlap]

.segmentdef TestsPatch[start=TestLocation, allowOverlap]
.segmentdef Tests[start=TestLocation, segments="TestData", allowOverlap]

.var name = cmdLineVars.get("name").string()
.file [
    name=name + ".prg",
    segments="Main, Util, Sweet16, Tests",
]

.var libraryFilename="---    LIB    ---"
.var testsFilename="---   TESTS   ---"

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {
    [name="---------------", type="rel" ],
    [name="--  SWEET16  --", type="prg", segments="Main, Util, Sweet16Patch, TestsPatch"],
    [name="---------------", type="rel" ],
    [name=libraryFilename, type="prg", segments="Sweet16" ],
    [name=testsFilename, type="prg", segments="Tests" ],
    [name="---------------", type="rel" ],
}

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"
