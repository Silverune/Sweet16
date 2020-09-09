.segmentdef Main [start=$810]
.segmentdef Sweet16 [startAfter="Main", segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data"]
.segmentdef Tests[startAfter="Sweet16Data", segments="TestData"]

.file [
    name="sweet16.prg",
    segments="Main, Sweet16, Tests",
    modify="BasicUpstart",
    _start=Main
]

.disk [filename="sweet16.d64", name="SWEET16", id="5150!" ] {
    [name="-----------------", type="rel" ],
    [name="---  SWEET16  ---", type="prg", segments="Bootstrap, Main, Sweet16, Tests" ],
    [name="-----------------", type="rel" ],
    [name="---    LIB    ---", type="prg", segments="Sweet16" ],
    [name="---   TESTS   ---", type="prg", segments="Tests" ],
    [name="-----------------", type="rel" ],
}

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"

.segment Bootstrap []
BasicUpstart2(Main)
