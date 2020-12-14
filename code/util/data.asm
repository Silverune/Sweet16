#importonce

.segment UtilData

Newline:
    Newline()

// Uses Kernal routines to load in file, assumes registers already setup
// Assumes:
//  A - length
//  X - LSB of filename
//  Y - MSB of filename
// Returns:
//  X - non-zero if error has occurred
//  A - error code if X non-zero
KernalLoad:
    KernalLoad()
    rts

.segment Default