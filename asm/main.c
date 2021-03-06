#include "asm.h"
#include "inst.h" 
#include "common.h"
int main(int argc, char *argv[])
{
    char *inFileString, *outFileString;
    FILE *inFilePtr, *outFilePtr;
    char verbose = TRUE; 
    if (argc < 2) {
        printf("[0]error: usage: %s <assembly-code-file> \n"            ,argv[0]);
        exit(1);
    }
    if (argc > 2) { verbose = FALSE; }        
    inFileString = argv[1];

    inFilePtr = fopen(inFileString, "r");
    if (inFilePtr == NULL) {
        printf("[1]error in opening %s\n", inFileString);
        exit(1);
    }
    if (verbose || !argv[2]) 
    outFilePtr = fopen("m.dat", "w");
    else 
    outFilePtr = fopen(argv[2], "w");
    if (outFilePtr == NULL) {
        printf("[2]error in opening %s\n", outFileString);
        exit(1);
    }
    char * neof = (char*) 1; 
    int labelLength = 0, opcodeLength = 0; 
    BranchLabel_t pcs;  
    labelSizes(&opcodeLength, &labelLength, inFilePtr);
    pcs.labels = malloc(labelLength*sizeof(char*)); 
    pcs.addrs = malloc(labelLength*sizeof(int));
    pcs.length = labelLength;
    pcs.pc = 0;
    assignLabels(inFilePtr, &pcs);
    int i;
    neof = (char*) 1;
    int count = 0;  
    line = 0; 
    while (neof) {
        neof = readAndParse(inFilePtr, lineString, 
            &label, &opcode, &arg0, &arg1, &arg2);
        line++; 
        if (neof) {
            //printf("%d\n",place);
            updatePC(&pcs);
            specialInstResolve(&opcode, &arg0, &arg1, &arg2);
            int inst = getOpcode(opcode);
            int word = getMachineCode(&pcs, inst, opcode, arg0, arg1, arg2);
            if (verbose) { printf("%08x\n", word); }
            fprintf(outFilePtr, "%08x\n", word);
            count++;
        }
    }
    if (!PAD) { count = IMEM-1; } 
    for (i = count; i < IMEM; i++) { 
        if (verbose) { printf("ac000004\n"); } 
        fprintf(outFilePtr, "ac000004\n");
    }
    fclose(outFilePtr);
    fclose(inFilePtr);
    exit(0);
}
