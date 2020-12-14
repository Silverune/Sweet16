#importonce
.filenamespace Sweet16

.label ZP_BASE = $17    // C64 start of 16 bit registers in zero page

.label ACC = 0          // accumulator
.label RSP = 12			// subroutine return pointer
.label CIR = 13	        // compare instruction result
.label SR = 14          // stack register
.label PC = 15			// program counter
.label ZP = 16			// Extension - Zero Page location used by SETI

.label R0L = RL(ACC)
.label R0H = RH(ACC)
.label R12L = RL(RSP)
.label R12H = RH(RSP)
.label R13L = RL(CIR)
.label R13H = RH(CIR)
.label R14L = RL(SR)
.label R14H = RH(SR)
.label R15L = RL(PC)
.label R15H = RH(PC)
.label R16L = RL(ZP)
.label R16H = RH(ZP)
