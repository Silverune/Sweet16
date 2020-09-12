// Mapping of zero page variables for use in util routines

.segment Default

*=0 virtual
ZpVar: {
*=$fb virtual
One: 
	WordAddr($fb)
*=$fd virtual
Two: 
	WordAddr($fd)
*=$4e virtual
Three: 
	WordAddr($4e)
*=$50 virtual
Four: 
	WordAddr($50)
}
