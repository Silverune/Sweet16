.segmentdef Main [start=$810]
.segmentdef Util[startAfter="Main", segments="UtilData"]

.const LibLocation = $1000
.segmentdef Sweet16Patch [start=LibLocation, allowOverlap]
.segmentdef Sweet16 [start=LibLocation, segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data", allowOverlap]

.const TestLocation = $2000
.segmentdef TestsPatch[start=TestLocation, allowOverlap]
.segmentdef Tests[start=TestLocation, segments="TestData", allowOverlap]

.var name = cmdLineVars.get("name").string()
//#if PRG
.file [
    name=name + ".prg",
    segments="Main, Util, Sweet16, Tests",
]
//#endif

/*
.function FancyFilename(name, border, lengthOverride) {
   .const totalLength = 16
   .var length = min(totalLength, lengthOverride)
   .errorif (name.size() + border.size() * 2 > length), "Name too long, must be less than " + (length + 1).string()

    .var retval = border + " " + name.toUpperCase() + " " + border
    .return retval
}
*/
//.print FancyFilename("sweet16", "--", 15)
//.print FancyFilename("lib", "--", 15)
// .print FancyFilename("tests", "--", 15)

.var libraryFilename="---    LIB    ---"
.var testsFilename="---   TESTS   ---"

//#if DISK

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {
    [name="---------------", type="rel" ],
    [name="--  SWEET16  --", type="prg", segments="Main, Util, Sweet16Patch, TestsPatch"],
    [name="---------------", type="rel" ],
    [name=libraryFilename, type="prg", segments="Sweet16" ],
    [name=testsFilename, type="prg", segments="Tests" ],
    [name="---------------", type="rel" ],
}

//#endif

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"
