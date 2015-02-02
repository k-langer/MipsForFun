#include "asm.h"

/*
    const unsigned int R_type    = 0b000000;
    const unsigned int LW_type   = 0b100011;
    const unsigned int SW_type   = 0b101011;
    const unsigned int BEQ_type  = 0b000100;
    const unsigned int ADDI_type = 0b001000;
    const unsigned int J_type    = 0b000010;

    const unsigned int ADD_funct = 0b100000;
    const unsigned int SUB_funct = 0b100010;
    const unsigned int AND_funct = 0b100100;
    const unsigned int OR_funct  = 0b100101;
    const unsigned int SLT_funct = 0b101010;
    
    unsigned int type = LW_type << 26; 
    unsigned int aluop = type & 0b11; 
*/

int main(int argc, char *argv[])
{
    char *inFileString, *outFileString;
    FILE *inFilePtr, *outFilePtr;

    if (argc != 2) {
        printf("error: usage: %s <assembly-code-file> > <machine-code-file>\n"            ,argv[0]);
        exit(1);
    }
    inFileString = argv[1];
    //outFileString = argv[2];

    inFilePtr = fopen(inFileString, "r");
    if (inFilePtr == NULL) {
        printf("error in opening %s\n", inFileString);
        exit(1);
    }
    /*utFilePtr = fopen(outFileString, "w");
    if (outFilePtr == NULL) {
        printf("error in opening %s\n", outFileString);
        exit(1);
    }
    */
    /* here is an example for how to use readAndParse
    to read a line from inFilePtr */
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
    for (i = 0; i < labelLength; i++) {
        //printf("%s %d\n",pcs.labels[i],pcs.addrs[i]);
    } 
    neof = (char*) 1;
    while (neof) {
        neof = readAndParse(inFilePtr, lineString, 
            &label, &opcode, &arg0, &arg1, &arg2);
        if (neof) {
            //printf("%d\n",place);
            updatePC(&pcs);
            specialInstResolve(&opcode, &arg0, &arg1, &arg2);
            int inst = getOpcode(opcode);
            int word = getMachineCode(&pcs, inst, opcode, arg0, arg1, arg2);
            printf("%08x\n", word);
            //printf("%s %s %s %s %s\n",label,opcode,arg0,arg1,arg2);
            //printf("%d %d %d\n",isRegister(arg0),isRegister(arg1),isRegister(arg2));
            //printf("%d\n",isAddress(arg1, &addr));
        }
    }
    printf("ac000004\n");
    /* this is how to rewind the file ptr so that you
    start reading from the beginning of the file */
    rewind(inFilePtr);

    /* after doing a readAndParse, you may want to
    do the following to test each opcode */
}
