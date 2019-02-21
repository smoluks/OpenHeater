###############################################################################
# Makefile for project 
###############################################################################

## General options
PROJECT = 
MCU = ATmega8
COMPILER = "AVRASM (Proteus)"
TARGET = Debug
CLOCK = 8000000
SHELL = C:\Windows\system32\cmd.exe

## Tools general options
ASMFLAGS=-i"C:\Program Files (x86)\Labcenter Electronics\Proteus 7 Professional\tools\AVRASM\appnotes\m8def.inc" -fI

## Processing Tools
ASM=avrasm2.exe
DDX=avrddx.exe
#  D:/proj/Heater/Firmware/Main/Debug/Debug.hex: TOOL=ASM
#  Post: $(DDX) $(DDXFLAGS) Debug.lst
#  Post: "C:\Program Files (x86)\Labcenter Electronics\VSM Studio for Proteus 7\BIN\mv" "Debug.SDI" "Debug/Debug.SDI"
#     D:/proj/Heater/Firmware/Main/main.asm

# Build tree:
all:	Debug

Debug:	Debug/Debug.hex

Debug/Debug.hex:	main.asm 
	$(ASM) $(ASMFLAGS)  -o "Debug\Debug.hex" -l Debug.lst "main.asm"
	$(DDX) $(DDXFLAGS) Debug.lst
	"C:\Program Files (x86)\Labcenter Electronics\VSM Studio for Proteus 7\BIN\mv" "Debug.SDI" "Debug/Debug.SDI"

# tidy - delete all temporary files which are not involved in the target generation
tidy:
	rm -rf Debug/Debug.SDI
	rm -rf Debug.lst

# cleanup - delete all generated files
clean:	tidy
	rm -rf Debug/Debug.hex
