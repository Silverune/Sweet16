# Makefile
# The following variables need to be set:
#  EMULATOR_PATH - full path and executable to the x64 VICE emulator
#  COMPILER_PATH - full path to where the KickAssembler .JAR file is
#  DRIVE_PATH - full path and executable to c1541
# Output file can be changed by passing in different APP.  e.g., make APP=blah
#
# e.g., 
# export EMULATOR_PATH="/usr/local/bin/x64"
# export COMPILER_PATH="/usr/local/blah/Documents/C64/KickAssembler/KickAss.jar"
# export DRIVE_PATH="/usr/local/bin/c1541"
#
APP=							sweet16
PROG=							startup
OUTPUT=							bin
LIB_DIR=						resources -libdir ../Sweet16Core/code
FORMAT_D64=						d64
FORMAT_D71=						d71
FORMAT_D81=						d81
BREAKPOINTS=					breakpoints.txt
COMPILE=						java -jar $(COMPILER)
KICK_VARS=						:name="$(APP)" :id="5150!" :format="$(FORMAT_D64)"
CFLAGS=							-odir $(OUTPUT) -o $(OUTPUT_PRG) -excludeillegal -afo -aom -libdir $(LIB_DIR) -asminfo all $(PRG_DEFINES) $(KICK_VARS)
DEBUG_DEFINES=					-define DEBUG
DISK_DEFINES=					-define DISK
PRG_DEFINES=					-define PRG
BYTE_DUMP=						-bytedumpfile $(APP)_bytedump.txt
LOG=							-log $(OUTPUT)/$(APP)_log.txt
CFLAGS_DEBUG=					$(CFLAGS) -debug $(DEBUG_DEFINES) :BREAKPOINTS=$(BREAKPOINTS) -showmem -bytedump -debugdump -vicesymbols $(LOG) $(BYTE_DUMP) $(SYMBOLS)
PROGRAM=						$(PROG).asm
PRG=							$(APP).prg
OUTPUT_PRG=						$(OUTPUT)/$(PRG)
RUN_COMMON=						-autostart-warp -truedrive 
RUN_PRG_FLAGS=					$(RUN_COMMON) -autostartprgmode 1

ifeq ($(OS),Windows_NT)
	COMPILER=					$(COMPILER_PATH)
	DEBUG_CLEAN=				del $(OUTPUT)\$(BREAKPOINTS)
	DEBUG_VICE=					$(EMULATOR) $(DEBUG_FLAGS_VICE) $(OUTPUT_PRG)
	DEBUG_DISK_VICE=			$(EMULATOR) $(DEBUG_DISK_FLAGS_VICE) 
	DEBUG_FLAGS_VICE=			-moncommands "$(shell chdir)\$(OUTPUT)\$(BREAKPOINTS)" -remotemonitor -remotemonitoraddress 6510 -autostartprgmode 1 -autostart-warp -truedrive "$(shell chdir)\$(OUTPUT)\$(APP).$(FORMAT_D64)"
	DEBUG_DISK_FLAGS_VICE=		-moncommands "$(shell chdir)\$(OUTPUT)\$(BREAKPOINTS)" -remotemonitor -remotemonitoraddress 6510 -autostart-warp -autostart "$(shell chdir)\$(OUTPUT)\$(APP).$(FORMAT_D64)"
	EMULATOR=					$(EMULATOR_PATH)
	RUN_PRG=					$(EMULATOR) $(RUN_PRG_FLAGS) $(OUTPUT_PRG)
	RUN_DISK=					$(EMULATOR) $(RUN_DISK_FLAGS)
	RUN_DISK_FLAGS=				$(RUN_COMMON) -8 "$(shell chdir)\$(OUTPUT)\$(APP).$(FORMAT_D64)"
	GENERATE_BREAKPOINTS=		type $(OUTPUT)\$(PROG).vs | sort >> $(OUTPUT)\$(BREAKPOINTS)
	DRIVE=						$(DRIVE_PATH)
	ZIP=						tar.exe -a -c -f 
	GENERATE_ENCODING=			certutil -f -encode $(OUTPUT)\$(APP).zip $(OUTPUT)\$(APP).b64
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
		UNIX=					true
		RUN_PRG=				$(EMULATOR) $(RUN_PRG_FLAGS) $(OUTPUT_PRG)
		RUN_DISK=				$(EMULATOR) $(RUN_DISK_FLAGS)
		DEBUG_VICE=				$(EMULATOR) $(DEBUG_FLAGS_VICE) $(OUTPUT_PRG)
		DEBUG_DISK_VICE=		$(EMULATOR) $(DEBUG_DISK_FLAGS_VICE)
    endif
    ifeq ($(UNAME_S),Darwin)
		UNIX=					true
		RUN_PRG=				open -a $(EMULATOR) $(OUTPUT_PRG) --args $(RUN_PRG_FLAGS)
		RUN_DISK=				open -a $(EMULATOR) --args $(RUN_DISK_FLAGS)
		DEBUG_VICE=				open -a $(EMULATOR) $(OUTPUT_PRG) --args $(DEBUG_FLAGS_VICE)
		DEBUG_DISK_VICE=		open -a $(EMULATOR) --args $(DEBUG_DISK_FLAGS_VICE)
    endif
    UNAME_P := $(shell uname -p)
    ifeq ($(UNAME_P),x86_64)
        # TODO: amd64
		UNSUPPORTED=true
    endif
    ifneq ($(filter %86,$(UNAME_P)),)
		# TODO: ia32
		UNSUPPORTED=true
    endif
    ifneq ($(filter arm%,$(UNAME_P)),)
		# TODO: arm
		UNSUPPORTED=true
    endif

	ifdef UNIX
		COMPILER=				"$(COMPILER_PATH)"
		DEBUG_CLEAN=			rm -f $(OUTPUT)/$(BREAKPOINTS)
		DEBUG_FLAGS_VICE=		-moncommands "$(shell pwd)/$(OUTPUT)/$(BREAKPOINTS)" -remotemonitor -remotemonitoraddress 6510 -autostartprgmode 1 -autostart-warp -truedrive
		DEBUG_DISK_FLAGS_VICE=	-moncommands "$(shell pwd)/$(OUTPUT)/$(BREAKPOINTS)" -remotemonitor -remotemonitoraddress 6510 -autostart-warp -truedrive -8 "$(shell pwd)/$(OUTPUT)/$(APP).$(FORMAT_D64)"
		RUN_DISK_FLAGS=			$(RUN_COMMON) -8 "$(shell pwd)/$(OUTPUT)/$(APP).$(FORMAT_D64)"
		EMULATOR= 				"$(EMULATOR_PATH)"
		GENERATE_BREAKPOINTS=	cat $(OUTPUT)/$(PROG).vs | sort >> $(OUTPUT)/$(BREAKPOINTS)
		DRIVE=					"$(DRIVE_PATH)"
		ZIP=					zip
		GENERATE_ENCODING=		cat $(OUTPUT)/$(APP).zip | base64 > $(OUTPUT)/$(APP).b64
	endif
endif

all:	index

index:  $(PROGRAM)
		$(COMPILE) $(CFLAGS) $(PROGRAM)

debugonly:	
		$(DEBUG_VICE)

debug:	
		$(DEBUG_CLEAN)
		$(COMPILE) $(CFLAGS_DEBUG) $(PROGRAM)
		$(GENERATE_BREAKPOINTS)
		$(DEBUG_VICE)

debugdisk:	
		$(DEBUG_CLEAN)
		$(COMPILE) $(CFLAGS_DEBUG) $(PROGRAM)
		$(GENERATE_BREAKPOINTS)
		$(DEBUG_DISK_VICE)

run:		
		$(RUN_PRG)

andrun: all
		$(COMPILE) $(CFLAGS) $(PROGRAM)
		$(RUN_PRG)

encode:
		$(ZIP) $(OUTPUT)/$(APP).zip $(OUTPUT_PRG)	
		$(GENERATE_ENCODING)

rundisk:
		$(RUN_DISK)

disk: 	$(PROGRAM)
		$(COMPILE) $(CFLAGS) $(DISK_DEFINES) $(PROGRAM) $(D64_FORMAT)

# Legacy disk creation calls using third party c1541.

d64:
		$(DRIVE) -format $(APP),DF $(FORMAT_D64) $(OUTPUT)/$(APP).$(FORMAT_D64)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D64) -write $(OUTPUT_PRG)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D64) -list


d71:
		$(DRIVE) -format $(APP),DF $(FORMAT_D71) $(OUTPUT)/$(APP).$(FORMAT_D71)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D71) -write $(OUTPUT_PRG)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D71) -list

d81:
		$(DRIVE) -format $(APP),DF $(FORMAT_D81) $(OUTPUT)/$(APP).$(FORMAT_D81)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D81) -write $(OUTPUT_PRG)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT_D81) -list
