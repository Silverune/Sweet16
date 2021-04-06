// Broad configuration settings
.const BACKGROUND_COLOR = BLACK
.const FOREGROUND_COLOR = GREY
.const SUCCESS_COLOR = GREEN
.const FAILURE_COLOR = RED
.const TITLE_COLOR = WHITE
.const NAME_COLOR = LIGHT_GREY
.const DESC_COLOR = LIGHT_BLUE

// test config
.const TESTS_PER_PAGE = 21
.const TEST_WORD_ONE = $1234
.const TEST_WORD_TWO = $5678
.const TEST_MEMORY_SEQUENCE_SIZE = 16
.const TEST_STACK_SIZE = 16

// ZP locations to use
.const ScreenZp = Zw.One
.const TempByteZp = Zb.One
.const TestCount = Zw.Two
.const TestPassCount = Zw.Three
.const TestNameCount = Zw.Four
.const TestMemoryOne = Zw.Five
.const TestMemoryTwo = Zw.Six
