.segmentdef Main [start=$810]
.segmentdef Sweet16 [startAfter="Main"]
.segmentdef Tests [segments="TestRoutines, TestData", startAfter="Sweet16"]

.file [
    name="sweet16.prg",
    segments="Main, Sweet16, Tests",
    modify="BasicUpstart",
    _start=Main]

#import "code/util/util.lib"
#import "code/sweet16/sweet16.lib"
#import "code/tests/test.lib"
#import "code/main.asm"
