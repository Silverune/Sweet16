.const MainLocation = $0810
.const LibLocation = $1000
.const TestLocation = $2000

.segmentdef Main [start=MainLocation]
.segmentdef Loader[startAfter="Main"]
.segmentdef Util[startAfter="Loader", segments="UtilData"]

.segmentdef Sweet16Patch [start=LibLocation, allowOverlap]
.segmentdef Sweet16 [start=LibLocation, allowOverlap]

.segmentdef TestsPatch[start=TestLocation, allowOverlap]
.segmentdef Tests[start=TestLocation, segments="TestData", allowOverlap]

.var name = cmdLineVars.get("name").string()

.file [
    name=name + ".prg",
    segments="Main, Util, Sweet16, Tests, ",
]

.var flair = "-";
.var border = flair + flair + flair
.var separator = FormatFilename("", "", flair)
.var mainFilename = FormatFilename(name, border)
.var libraryFilename=FormatFilename("lib", border)
.var testsFilename=FormatFilename("tests", border)

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {

    [name=separator, type="rel" ],
    [name=mainFilename, type="prg", segments="Main, Util, Sweet16Patch, TestsPatch, Loader"],
    [name=separator, type="rel" ],
    [name=libraryFilename, type="prg", segments="Sweet16" ],
    [name=testsFilename, type="prg", segments="Tests" ],
    [name=separator, type="rel" ],
}

#import "core.lib"
#import "code/util/util.lib"
#import "code/tests/test.lib"
#import "code/loader.asm"
#import "code/main.asm"
