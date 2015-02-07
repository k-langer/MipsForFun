C=gcc
CFLAGS=-std=gnu99 -Wno-unused-result -lm
WARNING=-Wall
OUTDIR = build
TARGET= ASM
_OBJS = asm.o \
	inst.o \
    common.o \
    main.o 
OBJS = $(patsubst %,$(OUTDIR)/%,$(_OBJS))

all: $(TARGET)

$(OUTDIR)/%.o: %.c 
	$(CC) -c $(CFLAGS) $^ -o $@

$(TARGET): $(OBJS)
	$(CC) -o $@ $^ $(CFLAGS)

run: 
	../mips_singlecycle/mips.sim 

clean:  
	rm -f *.o *.dat build/*.o ASM
