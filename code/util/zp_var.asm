// Mapping of zero page variables for use in util routines

.segment Default

*=0 virtual
ZpVarWord: {
*=$fb virtual
One: 
	WordAddr($fb)
*=$fd virtual
Two: 
	WordAddr($fd)
}

ZpVar: {
*=$4e virtual
One: 
	ByteAddr($4e)
*=$4f virtual
Two: 
	ByteAddr($4f)
*=$50 virtual
Three: 
	ByteAddr($50)
*=$51 virtual
Four: 
	ByteAddr($51)
}
