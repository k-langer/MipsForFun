CC=iverilog
TARGET= mips.sim
OBJS = mips.v 

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS)
clean:  
	rm -f *.sim *.dat
