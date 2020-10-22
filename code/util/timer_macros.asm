.importonce

.segment Util

.macro TimerSub(timerAddress, subroutine, updateMask) {
	inc timerAddress
	lda #updateMask
	bit timerAddress
	bne !callSub+
	jmp !+
!callSub:
	jsr subroutine
	lda #$ff			// reset
	sta timerAddress
!:
}

.segment Default