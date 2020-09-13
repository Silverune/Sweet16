//.importonce

/*
// ZpVar.One		$fb/$fc - L/H source address
// ZpVar.Two 		$fd/$fe - L/H destination address
// ZpVar.Three 	$4e/$4f - L/H source end address
.macro CopyMemoryZeroPage() {
 	ldy #$00
!comp:
   tya
   clc
   adc ZpVar.One.lo
   bcs !overflow+

   cmp ZpVar.Three.lo
   bne !loop+
   ldx ZpVar.One.hi
   cpx ZpVar.Three.hi
   beq !done+
   jmp !loop+

 !overflow:
   cmp ZpVar.Three.lo  // overflow with end address
   bne !loop+
   ldx ZpVar.One.hi  
   inx
   cpx ZpVar.Three.hi
   beq !done+

!loop:
	lda (ZpVar.One.lo),y 
	sta (ZpVar.Two.lo),y
	iny
 	bne !comp-				// next block
    inc ZpVar.One.hi 	// inc MSB source 
    inc ZpVar.Two.hi 	// inc MSB dest 
    jmp !comp-
!done:
}
*/
// ZpVar.One		$fb/$fc - L/H source address
// ZpVar.Two		$fd/$fe - L/H destination address
// ZpVar.Three	$4e/$4f - L/H size
// ZpVar.Four		$50/$51 - used by routine
.macro CopyMemoryZeroPageSize() {
	ldy #$00
   	sty ZpVar.Four.lo     // LSB size
   	sty ZpVar.Four.hi     // MSH size
!loop:
   	lda ZpVar.Three.hi
   	cmp ZpVar.Four.hi
   	beq !msb_match+
!copy:   
   	lda (ZpVar.One.lo),y 
	sta (ZpVar.Two.lo),y
	inc ZpVar.Four.lo
   	beq inc_msb
!cont:
   	iny
   	bne !loop-
!next:
   	inc ZpVar.One.hi 	// inc MSB source 
   	inc ZpVar.Two.hi 	// inc MSB dest 
 	jmp !loop-

inc_msb:
   	inc ZpVar.Four.hi
   	jmp !cont-

!msb_match:
   	lda ZpVar.Three.lo
   	cmp ZpVar.Four.lo
   	beq !done+
   	jmp !copy-

!done:
}

.macro CopyToManagedBuffer(sourceAddr, managedBuffer, size) {
	// TODO - sanity check here not too large

    *=* "WHEREAMI"
	LoadAddress(sourceAddr, ZpVar.One)
	LoadAddress(managedBuffer.buffer, ZpVar.Two)
	LoadAddress(size, ZpVar.Three)

	jsr CopyMemoryZeroPageSize

	// update managed
    .memblock "SIZE_SET"
    lda #<size
	sta managedBuffer.allocSize.lo
	lda #>size
	sta managedBuffer.allocSize.hi
}
