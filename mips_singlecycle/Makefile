CC=iverilog
TARGET= mips.sim
OBJS = mips.v 

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS)
run: 
	./mips.sim
clean:  
	rm -f *.sim *.dat

