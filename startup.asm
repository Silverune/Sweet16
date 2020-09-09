.segmentdef Main [start=$810]
.segmentdef Sweet16 [startAfter="Main", segments="Sweet16JumpTable, Sweet16Page, Sweet16OutOfPage, Sweet16Data"]
.segmentdef Tests[startAfter="Sweet16Data", segments="TestData"]

.file [
    name="sweet16.prg",
    segments="Main, Sweet16, Tests",
    modify="BasicUpstart",
    _start=Main
]

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"
