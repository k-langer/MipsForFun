CC=gcc
TARGET= mips
#VWARN=-Wall
VFLAGS=--trace --public
OBJS = mips.v \
       fetch.v \
       decode.v \
       execute.v \
       system.v

all: build

cp: 
	ln -fs ../mips_pipelined/*v . && rm -f *tb.v *orig* *sav && touch regr.cpp && ../tests/buildTests.pl
compile: cp
	verilator $(VWARN) $(VFLAGS) --cc mips.v -y . --top-module mips  --exe \
	mips_tb.cpp regr.cpp runtest.cpp -clk clk
build: compile
	make -j -C obj_dir/ -f Vmips.mk Vmips
run: build
	rm -f waves/*gz && obj_dir/Vmips && gzip -f waves/*
clean:  
	rm -f *.v && rm -fr obj_dir/ && rm -f waves/*gz && rm regr.cpp

