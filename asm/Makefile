C=gcc
CFLAGS=-std=gnu99 -Wno-unused-result -lm
WARNING=-Wall
TARGET= ASM
OBJS = asm.c \
       asm.h
all: $(TARGET)

%.o: %.c 
	$(CC) $(CFLAGS) -c $<
$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS)
run: 
	../mips_singlecycle/mips.sim 
clean:  
	rm -f *.o ASM
