.segmentdef TestData
.segment TestData

TEST_SUCCESS:
	.byte $73, $00
	
TEST_FAILURE:
	.byte $76, $00

TEST_COUNT:
	.byte $00

TEST_PASS_COUNT:
	.byte $00

TEST_NAME_COUNT:
	.byte $00
	
TEST_TITLE:	
	.text "SWEET16 TEST RUNNER"
	Newline()

// Setup some common blocks of memory to use for the testing
TEST_MEMORY:
	.byte $12,$34

TEST_MEMORY_2:
	.byte $56,$78

TEST_MEMORY_3:
	.byte $9a,$bc

.const TMS_SIZE = 16
TEST_MEMORY_SEQUENCE:
	.fill TMS_SIZE, i

TEST_MEMORY_SEQUENCE_2:
	.fill TMS_SIZE, $ff
	
STACK_MEMORY: {
	.const STACK_SIZE = 16
	.fill STACK_SIZE, 0
}

.segment Default