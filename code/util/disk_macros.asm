.importonce

// Loading a file to memory at address stored in file
// Reference: https://codebase64.org/doku.php?id=base:loading_a_file
// BASIC equivalent: LOAD "JUST A FILENAME",8,1
.macro LoadPrgFile(filename, length) {
    CopyToManagedBuffer(filename, ManagedBuffer256, length)
    LoadAddress(ManagedBuffer256, ZpVar.One)
    jsr LoadPrgFileFromManagedBuffer
}
/*
// Loading a file to memory at address stored in file
// Reference: https://codebase64.org/doku.php?id=base:loading_a_file
// BASIC equivalent: LOAD "JUST A FILENAME",8,1
.macro LoadPrgFileOriginal(filename, length) {
    lda #length
    ldx #<fname
    ldy #>fname
    jsr $ffbd     // call setnam
    lda #$01
    ldx $ba       // last used device number
    bne !skip+
    ldx #$08      // default to device 8
!skip:
   ldy #$01      // not $01 means: load to address stored in file
   jsr $ffba     // call setlfs

   lda #$00      // $00 means: load to memory (not verify)
   jsr $ffd5     // call load
   bcs !error+    // if carry set, a load error has happened
   jmp !done+
!error:
    .label Error = *
	// accumulator contains basic error code

	// most likely errors:
	// a = $05 (device not present)
	// a = $04 (file not found)
	// a = $1d (load error)
	// a = $00 (break, run/stop has been pressed during loading)
	// ... error handling ...
    rts
fname:
    .text filename
!done:
}*/


.function FormatFilename(name, border) {
    .return FormatFilename(name, border, " ")
}

.function FormatFilename(name, border, spacer) {
    .return FormatFilename(name, border, spacer, 999)
}

.function FormatFilename(name, border, spacer, lengthOverride) {
    .const dumpDebug = false;
    .const totalLength = 16
    .var length = min(totalLength, lengthOverride)
    .eval spacer = spacer.charAt(0)
    .var toFill = length - name.size() - border.size() * 2    
    .errorif (name.size() + border.size() * 2 > length), "Name too long, must be less than " + (length + border.size() * 2).string()
    
    .var retval = border;
    .var left = mod(toFill, 2) + floor(toFill / 2);
    .var right = floor(toFill / 2);
    .for (var i = 0; i < left; i++) {
        .eval retval += spacer
    }
    .eval retval = retval + name.toUpperCase()
    .for (var i = 0; i < right; i++) {
        .eval retval += spacer
    }
    .eval retval += border;
    
    .if (dumpDebug) {
.print "[" + retval + "] " + retval.size()
    }
    .return retval
}
