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

.macro LoHi(value) {
    .label lo = *       // naming consistency with .lohifill
    .label hi = *+1     // naming consistency with .lohifill
    .byte <value, >value
}

.macro ByteTable(tableAddress, index, zpTempAddress) {
    WordTable(tableAddress, index * 2, zpTempAddress)
}

.macro WordTable(tableAddress, index, zpTempAddress) {
    LoadAddress(tableAddress, zpTempAddress)
    ldy index
    lda (zpTempAddress), Y
}