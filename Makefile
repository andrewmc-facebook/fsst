SHELL := /bin/bash

OPT=-O3 -march=native -DNDEBUG

all: fsst 
clean:
	-@rm -f libfsst.[oa] fsst_avx512.o fsst 
fsst: fsst.cpp libfsst.a 
	g++ -std=c++17 -W -Wall -ofsst $(OPT) -g fsst.cpp -L. -lfsst -lpthread 
libfsst.a: libfsst.cpp libfsst.hpp fsst.h fsst_avx512.o
	g++ -std=c++17 -W -Wall -c $(OPT) -g libfsst.cpp 
	ar ru $@ libfsst.o fsst_avx512.o 
	ranlib $@
.fsst_avx512_unroll%.inc: fsst_avx512.inc
	awk '{ for(i=1;i<='$*';i++) {s=$$0; gsub(/X/,i,s); print s}}' fsst_avx512.inc > .fsst_avx512_unroll$*.inc;
fsst_avx512.o: fsst_avx512.cpp .fsst_avx512_unroll1.inc .fsst_avx512_unroll2.inc .fsst_avx512_unroll3.inc .fsst_avx512_unroll4.inc
	g++ -std=c++17 -W -Wall -g -O1 -march=native -c fsst_avx512.cpp # -O1: no constant propagation reduces register pressure and improves unrolling
