# ------------------------------------------------
# Forthress 2, a Forth dialect
#
# Author: igorjirkov@gmail.com
# Date  : 13-03-2019
#
# ------------------------------------------------

ASM			    = nasm
ASMFLAGS	  = -felf64 -g -Isrc/

LINKER 		  = ld
LINKERFLAGS = -g
LIBS        =


all: bin/forthress

bin/forthress: obj/forthress.o
	mkdir -p bin 
	$(LINKER) -o bin/forthress  $(LINKERFLAGS) -o bin/forthress obj/forthress.o  $(LIBS)

obj/forthress.o: src/forthress.asm src/macro.inc src/words.inc
	mkdir -p obj
	$(ASM) $(ASMFLAGS) src/forthress.asm -o obj/forthress.o

clean:
	rm -rf build obj

.PHONY: clean

