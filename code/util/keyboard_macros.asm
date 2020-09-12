.importonce

// Macros dealing with reading keyboard state

// pressed keycode is stored in A
.macro KernalGetKey() {
	.const getin = $ffe4
	.const scnkey = $ff9f
	jsr scnkey  // scan keyboard
	jsr getin	// put result into A
}
