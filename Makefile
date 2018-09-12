# Makefile for Sweet16
# Support for Ubuntu and OSX.  Most of the OSX versions have the letter "x" appended
COMPILER_PATH   = $(3RD_PARTY_DIR)/KickAssembler
COMPILER	= java -jar $(COMPILER_PATH)/KickAss.jar
CFLAGS		= -o $(OUTPUT)/$(PRG) -afo -aom $(SYMBOLS) -libdir $(LIB_DIR) -excludeillegal
CRT_CFLAGS	= -o $(OUTPUT)/$(CRT) -afo -aom $(SYMBOLS) -libdir $(LIB_DIR) -excludeillegal
CFLAGS_DISK	= -o $(OUTPUT)/$(DISK) -afo -aom $(SYMBOLS) -libdir $(LIB_DIR) -excludeillegal
DEBUG_DEFINES   = -define DEBUG
BYTE_DUMP       = -bytedumpfile $(OUTPUT)/$(APP)_bytedump.txt
SYMBOLS		= -symbolfiledir $(OUTPUT)
LOG		= -log $(OUTPUT)/$(APP)_log.txt
SOURCE_DIR	= ~/Documents/Source
APP_DIR		= ~/Documents/Source
3RD_PARTY_DIR   = ~/Documents/C64
LIB_DIR		= resources
CFLAGS_DEBUG = $(CFLAGS) -debug $(DEBUG_DEFINES) -showmem -vicesymbols $(LOG) $(BYTE_DUMP) $(SYMBOLS)
PROGS		= index
APP			= sweet16
PRG			= $(APP).prg
DISK        = $(APP).d64
DRIVE		= c1541
OUTPUT		= build
OUTPUT_PRG	= $(OUTPUT)/$(PRG)
DEBUG_FLAGS_VICE= -moncommands $(shell pwd)/breakpoints.txt +remotemonitor -remotemonitoraddress 6510 -autostartprgmode 1 -autostart-warp +truedrive +cart
RUN_FLAGS	= -autostartprgmode 1 -autostart-warp +truedrive +cart
DEBUG_FLAGS	= -vicesymbols $(OUTPUT)/index.vs -prg $(OUTPUT_PRG)

# OSX / MacOS
EMULATOR_PATH_OSX = /Applications/Vice64
EMULATOR_OSX	= $(EMULATOR_PATH_OSX)/x64.app
DEBUGGER_OSX    = open -a $(3RD_PARTY_DIR)/C64Debugger/C64Debugger.app $(OUTPUT_PRG)
RUN_OSX         = open -a $(EMULATOR_OSX) $(OUTPUT_PRG) --args $(RUN_FLAGS)
DEBUG_VICE_OSX  = open -a $(EMULATOR_OSX) $(OUTPUT_PRG) --args $(DEBUG_FLAGS_VICE)
DRIVE_OSX	= $(EMULATOR_PATH_OSX)/tools/$(DRIVE)

# Linux / Ubuntu
EMULATOR_PATH_LINUX = /usr/local/bin
EMULATOR_LINUX	= $(EMULATOR_PATH_LINUX)/x64
DEBUGGER_LINUX  = $(3RD_PARTY_DIR)/C64Debugger/C64Debugger
RUN_LINUX       = $(EMULATOR_LINUX) $(RUN_FLAGS) $(OUTPUT_PRG)
DEBUG_VICE_LINUX= $(EMULATOR_LINUX) $(DEBUG_FLAGS_VICE) $(OUTPUT_PRG)
DRIVE_LINUX	= $(EMULATOR_PATH_LINUX)/$(DRIVE)

all:	$(PROGS)

index:	index.asm
		$(COMPILER) $(CFLAGS) index.asm

debugold:	all
		$(COMPILER) $(CFLAGS_DEBUG) index.asm
		$(DEBUGGER_LINUX) $(DEBUG_FLAGS)

debugoldx:	all
		$(COMPILER) $(CFLAGS_DEBUG) index.asm
		$(DEBUGGER_OSX) --args $(DEBUG_FLAGS)

debugonly:	
		$(COMPILER) $(CFLAGS_DEBUG) index.asm

debug:	
		$(COMPILER) $(CFLAGS_DEBUG) index.asm
		cat $(OUTPUT)/index.vs | sort >> breakpoints.txt
		$(DEBUG_VICE_LINUX)

debugx:	all
		$(COMPILER) $(CFLAGS_DEBUG) index.asm
		cat $(OUTPUT)/index.vs | sort >> breakpoints.txt
		$(DEBUG_VICE_OSX)

runx:		
		$(RUN_OSX)

run:		
		$(RUN_LINUX)

andrun: all
		$(COMPILER) $(CFLAGS) index.asm
		$(RUN_LINUX)

andrunx: all
		$(COMPILER) $(CFLAGS) index.asm
		$(RUN_OSX)

encode:	all
		zip $(OUTPUT)/$(APP).zip $(OUTPUT_PRG)	
		cat $(OUTPUT)/$(APP).zip | base64 > $(OUTPUT)/$(APP).b64

diskx:
		$(DRIVE_OSX) -format $(APP),DF d64 $(OUTPUT)/$(DISK)
		$(DRIVE_OSX) -attach $(OUTPUT)/$(DISK) -write $(OUTPUT_PRG)
disk:
		$(DRIVE_LINUX) -format $(APP),DF d64 $(OUTPUT)/$(DISK)
		$(DRIVE_LINUX) -attach $(OUTPUT)/$(DISK) -write $(OUTPUT_PRG)
