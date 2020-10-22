.importonce

.macro LoadAddress(address, lowByte) {
	LoadAddressFull(address, lowByte, lowByte + 1)
}

.macro LoadAddressFull(address, lowByte, highByte) {
	lda #<address
    sta lowByte
    lda #>address 
    sta highByte
}

.macro WordAddr(addr) {
    .label lo = *       // naming consistency with .lohifill
    .label hi = *+1     // naming consistency with .lohifill
	.word $0000
}

.macro ByteAddr(addr) {
    .label val = *       // naming consistency with .lohifill
	.byte $0000
}

.macro LoHi(value) {
    .label lo = *       // naming consistency with .lohifill
    .label hi = *+1     // naming consistency with .lohifill
    .byte <value, >value
}
