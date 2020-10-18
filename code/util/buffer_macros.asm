.importonce

// ZpVar.One		$fb/$fc - L/H source address
// ZpVar.Two		$fd/$fe - L/H destination address
// ZpVar.Three	$4e/$4f - L/H size
// ZpVar.Four		$50/$51 - used by routine
// .macro CopyMemoryZeroPageSize() {
// 	ldy #$00
//    	sty ZpVar.Four.lo     // LSB size
//    	sty ZpVar.Four.hi     // MSH size
// !loop:
//    	lda ZpVar.Three.hi
//    	cmp ZpVar.Four.hi
//    	beq !msb_match+
// !copy:   
//    	lda (ZpVar.One.lo),y 
// 	sta (ZpVar.Two.lo),y
// 	inc ZpVar.Four.lo
//    	beq inc_msb
// !cont:
//    	iny
//    	bne !loop-
// !next:
//    	inc ZpVar.One.hi 	// inc MSB source 
//    	inc ZpVar.Two.hi 	// inc MSB dest 
//  	jmp !loop-

// inc_msb:
//    	inc ZpVar.Four.hi
//    	jmp !cont-

// !msb_match:
//    	lda ZpVar.Three.lo
//    	cmp ZpVar.Four.lo
//    	beq !done+
//    	jmp !copy-

// !done:
// }