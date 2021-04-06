#importonce

.segment TestData

TEST_PETSCII_SUCCESS:
	.byte $73, 0

TEST_PETSCII_FAILURE:
	.byte $76, 0

TestMemoryOne_SEQUENCE:
	.fill TEST_MEMORY_SEQUENCE_SIZE, i

TestMemoryOne_SEQUENCE_2:
	.fill TEST_MEMORY_SEQUENCE_SIZE, $ff

STACK_MEMORY:
	.fill TEST_STACK_SIZE, 0

.segment Default