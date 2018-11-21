# Makefile for Sweet16
# The following variables need to be set:
#  EMULATOR_PATH - full path to where the x64 VICE emulator is
#  COMPILER_PATH - full path to where the KickAssembler .JAR file is
#
# e.g., 
# export EMULATOR_PATH=/usr/local/bin
# export COMPILER_PATH=~/Documents/C64/KickAssembler

COMPILER	= java -jar $(COMPILER_PATH)/KickAss.jar
CFLAGS		= -o $(OUTPUT)/$(PRG) -afo -aom $(SYMBOLS) -libdir $(LIB_DIR) -excludeillegal
DEBUG_DEFINES   = -define DEBUG
BYTE_DUMP       = -bytedumpfile $(OUTPUT)/$(APP)_bytedump.txt
SYMBOLS		= -symbolfiledir $(OUTPUT)
LOG		= -log $(OUTPUT)/$(APP)_log.txt
LIB_DIR		= resources
CFLAGS_DEBUG = $(CFLAGS) -debug $(DEBUG_DEFINES) -showmem -bytedump -debugdump -vicesymbols $(LOG) $(BYTE_DUMP) $(SYMBOLS)
PROGS		= index
APP			= sweet16
PRG			= $(APP).prg
OUTPUT		= build
OUTPUT_PRG	= $(OUTPUT)/$(PRG)
DEBUG_FLAGS_VICE= -moncommands $(shell pwd)/breakpoints.txt +remotemonitor -remotemonitoraddress 6510 -autostartprgmode 1 -autostart-warp +truedrive +cart
RUN_FLAGS	= -autostartprgmode 1 -autostart-warp +truedrive +cart
DEBUG_FLAGS	= -vicesymbols $(OUTPUT)/index.vs -prg $(OUTPUT_PRG)
EMULATOR	= $(EMULATOR_PATH)/x64
RUN       = $(EMULATOR) $(RUN_FLAGS) $(OUTPUT_PRG)
DEBUG_VICE= $(EMULATOR) $(DEBUG_FLAGS_VICE) $(OUTPUT_PRG)
DRIVE	= $(EMULATOR_PATH)/c1541


all:	$(PROGS)

index:	index.asm
		$(COMPILER) $(CFLAGS) index.asm

debugonly:	
		$(COMPILER) $(CFLAGS_DEBUG) index.asm

debug:	
		$(COMPILER) $(CFLAGS_DEBUG) index.asm
		cat $(OUTPUT)/index.vs | sort >> breakpoints.txt
		$(DEBUG_VICE)

run:		
		$(RUN)

andrun: all
		$(COMPILER) $(CFLAGS) index.asm
		$(RUN)

encode:	all
		zip $(OUTPUT)/$(APP).zip $(OUTPUT_PRG)	
		cat $(OUTPUT)/$(APP).zip | base64 > $(OUTPUT)/$(APP).b64

disk:
		$(DRIVE) -format $(APP),DF $(FORMAT) $(OUTPUT)/$(APP).$(FORMAT)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT) -write $(OUTPUT_PRG)
		$(DRIVE) -attach $(OUTPUT)/$(APP).$(FORMAT) -list
