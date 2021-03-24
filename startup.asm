.const MainLocation = $0810
.const LibLocation = $1000
.const TestLocation = $2000

.segmentdef Main [start=MainLocation]
.segmentdef Loader[startAfter="Main"]

.segmentdef Sweet16Patch [start=LibLocation, allowOverlap]
.segmentdef Sweet16 [start=LibLocation, allowOverlap]

.segmentdef TestsPatch[start=TestLocation, allowOverlap]
.segmentdef Tests[start=TestLocation, segments="TestData", allowOverlap]
.segmentdef TestData [startAfter="Tests"]

.var name = cmdLineVars.get("name").string()
.var format = cmdLineVars.get("format").string()

.file [
    name=name + ".prg",
    segments="Main, Sweet16, Tests",
]

.var flair = "-";
.var border = flair + flair + flair
.var separator = Kick_FormatFilename("", "", flair)
.var mainFilename = Kick_FormatFilename(name, border)
.var libraryFilename = Kick_FormatFilename("lib", border)
.var testsFilename = Kick_FormatFilename("tests", border)
.const codeFiles = List().add(libraryFilename, testsFilename).lock()

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {

    [name=separator, type="rel" ],
    [name=mainFilename, type="prg", segments="Main, Sweet16Patch, TestsPatch, Loader"],
    [name=separator, type="rel" ],
    [name=libraryFilename, type="prg", segments="Sweet16" ],
    [name=testsFilename, type="prg", segments="Tests" ],
    [name=separator, type="rel" ],
}

#import "core.lib"              // -libdir

#import "code/tests/test.lib"
#import "code/main.asm"
