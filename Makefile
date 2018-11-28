# Makefile for Sweet16
# The following variables need to be set:
#  EMULATOR_PATH - full path and executable to the x64 VICE emulator
#  COMPILER_PATH - full path to where the KickAssembler .JAR file is
#  DRIVE_PATH - full path and executable to c1541
#
# e.g., 
# export EMULATOR_PATH=/usr/local/bin/x64
# export COMPILER_PATH=~/Documents/C64/KickAssembler/KickAss.jar
# export DRIVE_PATH=/usr/local/bin/c1541
#
# TODO
# - Cleanup null endings on all strings
# - Make breakpoints file more consistent.  Kick and Make using "breakpoints.txt" VSC using "startup.breakpoints"
# - VSA needs ability to pass in directives depending on debug or not
# - VSA needs user configurable breakfile naming
#
COMPILER	= java -jar $(COMPILER_PATH)
CFLAGS		= -odir $(OUTPUT) -o $(OUTPUT_PRG) -afo -aom -libdir $(LIB_DIR) -excludeillegal
DEBUG_DEFINES	= -define DEBUG
BYTE_DUMP   = -bytedumpfile $(APP)_bytedump.txt
LOG			= -log $(OUTPUT)/$(APP)_log.txt
LIB_DIR		= resources
BREAKPOINTS = breakpoints.txt
CFLAGS_DEBUG	= $(CFLAGS) -debug $(DEBUG_DEFINES) :BREAKPOINTS=$(BREAKPOINTS) -showmem -bytedump -debugdump -vicesymbols $(LOG) $(BYTE_DUMP) $(SYMBOLS)
APP			= sweet16
PROG		= startup
PROGRAM		= $(PROG).asm
PRG			= $(APP).prg
OUTPUT		= bin
OUTPUT_PRG	= $(OUTPUT)/$(PRG)
DEBUG_FLAGS_VICE	= -moncommands $(shell pwd)/$(OUTPUT)/$(BREAKPOINTS) +remotemonitor -remotemonitoraddress 6510 -autostartprgmode 1 -autostart-warp +truedrive +cart
RUN_FLAGS	= -autostartprgmode 1 -autostart-warp +truedrive +cart
DEBUG_FLAGS	= -vicesymbols $(OUTPUT)/$(PROG).vs -prg $(OUTPUT_PRG)
EMULATOR	= $(EMULATOR_PATH)
RUN       	= $(EMULATOR) $(RUN_FLAGS) $(OUTPUT_PRG)
DEBUG_VICE	= $(EMULATOR) $(DEBUG_FLAGS_VICE) $(OUTPUT_PRG)
DRIVE		= $(DRIVE_PATH)

all:	index

index: $(PROGRAM)
		$(COMPILER) $(CFLAGS) $(PROGRAM)

debugonly:	
		$(COMPILER) $(CFLAGS_DEBUG) $(PROGRAM)

debug:	
		$(COMPILER) $(CFLAGS_DEBUG) $(PROGRAM)
		cat $(OUTPUT)/$(PROG).vs | sort >> $(OUTPUT)/$(BREAKPOINTS)
		$(DEBUG_VICE)

run:		
		$(RUN)

andrun: all
		$(COMPILER) $(CFLAGS) $(PROGRAM)
		$(RUN)

encode:	all
		zip $(OUTPUT)/$(APP).zip $(OUTPUT_PRG)	
		cat $(OUTPUT)/$(APP).zip | base64 > $(OUTPUT)/$(APP).b64

disk:
		$(DRIVE) -format $(APP),DF $(FORMAT) $(OUTPUT)/$(APP).$(FORMAT)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT) -write $(OUTPUT_PRG)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT) -list
