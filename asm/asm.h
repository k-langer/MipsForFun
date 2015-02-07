#ifndef __asm__h
#define __asm__h
#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#define MAXLINELENGTH 1000
#define TRUE 1
#define FALSE 0

char *label, *opcode, *arg0, *arg1, *arg2;
char lineString[MAXLINELENGTH+1];

typedef struct BranchLabel {
    char ** labels; 
    int * addrs;
    int length;
    int pc;  
} BranchLabel_t; 

char * readAndParse(FILE *, char *, char **, char **, char **,
    char **, char **);
int isNumber(char *);
int isRegister(char *);
int isAddress(char *, int * addr);
int onesMask(int start, int length); 
int fieldMask(int field, int start, int length); 
int labelSizes(int * opcodeLength, int * labelLength, FILE * inFilePtr );
int specialInstResolve(char **opcodePtr, char **arg0Ptr, char **arg1Ptr, char **arg2Ptr); 
int getMachineCode(BranchLabel_t *pcs, int inst, char* opcode, char* arg0, char* arg1, char* arg2);
int assignLabels(FILE *, BranchLabel_t *); 
int branchResolveToInt(char * branch, BranchLabel_t * lbls);
int updatePC(BranchLabel_t * branches); 
int jumpTo(char * jump, BranchLabel_t * lbls);
#endif
