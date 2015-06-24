CC=gcc
TARGET= mips
#VWARN=-Wall
VFLAGS=--trace --public
OBJS = mips.v \
       fetch.v \
       decode.v \
       execute.v 

all: build

cp: 
	ln -s ../mips_pipelined/*v . && cp ../objects/jmp.dat m.dat && rm -f *tb.v *orig*
compile: cp
	verilator $(VWARN) $(VFLAGS) --cc mips.v -y . --top-module mips  --exe mips_tb.cpp
build: compile
	make -j -C obj_dir/ -f Vmips.mk Vmips
run: build
	obj_dir/Vmips
clean:  
	rm -f *.v *dat && rm -fr obj_dir/

