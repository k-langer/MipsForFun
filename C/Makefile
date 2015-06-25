CC=mips-gcc
CFLAGS=-std=gnu99 -S
WARNING=-Wall
TARGET= hash
OBJS = hash.o \

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS)

clean:  
	rm -f *.o *.dat *.s *.out
