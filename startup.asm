.segmentdef Main [start=$810]
.segmentdef Sweet16 [startAfter="Main", segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data"]
.segmentdef Tests[startAfter="Sweet16Data", segments="TestData"]

.var name = cmdLineVars.get("name").string()
#if PRG
.file [
    name=name + ".prg",
    segments="Main, Sweet16, Tests",
    modify="BasicUpstart",
    _start=Main
]

#endif

#if DISK

.disk [filename=name + "." + cmdLineVars.get("format").string(), name=name.toUpperCase(), id=cmdLineVars.get("id").string(), showInfo ] {
    [name="-----------------", type="rel" ],
    [name="---  SWEET16  ---", type="prg", segments="Bootstrap, Main, Sweet16, Tests" ],
    [name="-----------------", type="rel" ],
    [name="---    LIB    ---", type="prg", segments="Sweet16" ],
    [name="---   TESTS   ---", type="prg", segments="Tests" ],
    [name="-----------------", type="rel" ],
}

.segment Bootstrap []
BasicUpstart2(Main)

// TODO - add loaders for LIB and TESTS

#endif

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"

