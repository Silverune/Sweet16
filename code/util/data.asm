.importonce
.segment UtilData

Newline:
    Newline()

ManagedBuffer256: {
    totalSize:
        LoHi($ff)
    allocSize: 
        LoHi(0)
    buffer:
        .fill $ff, $00
}

.segment Default

*=0 virtual
ZpVariables: {
*= $fb virtual
One: 
	WordAddr($fb)
*= $fd virtual
Two: 
	WordAddr($fd)
*= $4e virtual
Three: 
	WordAddr($4e)
*=$50 virtual
Four: 
	WordAddr($50)
}
