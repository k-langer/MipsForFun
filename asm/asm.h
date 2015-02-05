#include<stdio.h>
#include<stdlib.h>
#include <string.h>
#define MAXLINELENGTH 1000
#define ERROR 1
#define WARNING 0 
#define TRUE 1
#define FALSE 0
 
const unsigned int R_type     = 0b000000;
const unsigned int LW_type    = 0b100011;
const unsigned int SW_type    = 0b101011;
const unsigned int BEQ_type   = 0b000100;
const unsigned int ADDI_type  = 0b001000;
const unsigned int ADDIU_type = 0b001001;
const unsigned int ANDI_type  = 0b001100;
const unsigned int ORI_type   = 0b001101;
const unsigned int XORI_type  = 0b001110;
const unsigned int J_type     = 0b000010;
const unsigned int BNE_type   = 0b000101; 
 
const unsigned int SRLV_funct = 0b000110;
const unsigned int SLLV_funct = 0b000100;
const unsigned int ADD_funct  = 0b100000;
const unsigned int ADDU_funct = 0b100001;
const unsigned int SUB_funct  = 0b100010;
const unsigned int SUBU_funct = 0b100011;
const unsigned int AND_funct  = 0b100100;
const unsigned int OR_funct   = 0b100101;
const unsigned int SLT_funct  = 0b101010;
const unsigned int SLTU_funct = 0b101011;
const unsigned int XOR_funct  = 0b100110;
char *label, *opcode, *arg0, *arg1, *arg2;
char lineString[MAXLINELENGTH+1];
typedef int flags_e;

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
int getOpcode(char *);
int getFunct(char *);
int onesMask(int start, int length); 
int fieldMask(int field, int start, int length); 
int labelSizes(int * opcodeLength, int * labelLength, FILE * inFilePtr );
int specialInstResolve(char **opcodePtr, char **arg0Ptr, char **arg1Ptr, char **arg2Ptr); 
int getMachineCode(BranchLabel_t *pcs, int inst, char* opcode, char* arg0, char* arg1, char* arg2);
int assignLabels(FILE *, BranchLabel_t *); 
int branchResolveToInt(char * branch, BranchLabel_t * lbls);
int updatePC(BranchLabel_t * branches); 
void flag(char * msg, flags_e type);
int jumpTo(char * jump, BranchLabel_t * lbls);

void flag(char * msg, flags_e type) {

    if (type == ERROR) {
        printf("ERROR: %s!!\n",msg);
        exit(1);
    } 
    printf("WARNING: %s!\n",msg);
}
int updatePC(BranchLabel_t * branches) {
    branches->pc = branches->pc+4; 
    return branches->pc;
}
int branchResolveToInt(char * branch, BranchLabel_t * lbls) {
    for (int i = 0; i < lbls->length; i++) { 
        if (!strcmp(branch, lbls->labels[i])) {
            return (lbls->addrs[i]/4) - (lbls->pc/4);
        }
    }
    
    flag(branch,ERROR);
    return 0; 
}
int assignLabels(FILE * inFilePtr, BranchLabel_t * branches) {
    char ** labels = branches->labels; 
    int * labelAddr = branches->addrs; 
    int length = branches->length; 
    char * neof = (char*) 1; 
    int addr = 0;
    length--;   
    while (neof) {
        neof = readAndParse(inFilePtr, lineString, 
            &label, &opcode, &arg0, &arg1, &arg2);
        if (neof) {
            if (opcode) { 
                if (label) { 
                    if (length < 0) { return -1; } 
                    labels[length] = malloc(strlen(label)*sizeof(char*));
                    char * lb = labels[length];
                    char * lb1 = label;
                    memcpy(lb,lb1,strlen(label));
                    labelAddr[length--] = addr; 
                }     
                addr += 4;  
            }
        }
    }
    rewind(inFilePtr); 
}
int specialInstResolve(char **opcodePtr, char **arg0Ptr, char **arg1Ptr, char **arg2Ptr) { 
    if (!strcmp(*opcodePtr, "print")) {
    }
    if (!strcmp(*opcodePtr, "nop")) {
    }
    return -1;
}

int fieldMask(int field, int start, int length) { 
    int mask = onesMask(start,length); 
    mask &= field << start;
    return mask;
} 
int labelSizes(int * opcodeLength, int * labelLength, FILE * inFilePtr ) {
    int len;
    *labelLength =0; 
    *opcodeLength = 0;
    char * neof = (char *) 1;
    while (neof) {
        neof = readAndParse(inFilePtr, lineString, 
            &label, &opcode, &arg0, &arg1, &arg2);
            if (neof && opcode) {
                if (label) {
                    (*labelLength)++;
                }
                *opcodeLength++;
            }
    }
    rewind(inFilePtr);
}

int onesMask(int start, int length) { 
    int i, ret = 0; 
    for (i = 0; i < length; i++) {
        ret |= 1 << (start+i);
    }
    return ret; 
} 

char * readAndParse(FILE *inFilePtr, char *lineString,
    char **labelPtr, char **opcodePtr, char **arg0Ptr,
    char **arg1Ptr, char **arg2Ptr)
{
    char *statusString, *firsttoken;
    statusString = fgets(lineString, MAXLINELENGTH, inFilePtr);
    if (statusString != NULL) {
        firsttoken = (char *) strtok(lineString, " \t\n");
        if (firsttoken == NULL || firsttoken[0] == '#') {
            return readAndParse(inFilePtr, lineString, labelPtr, opcodePtr, arg0Ptr, arg1Ptr, arg2Ptr);
        } else if (firsttoken[strlen(firsttoken) - 1] == ':') {
            *labelPtr = firsttoken;
            *opcodePtr = (char *) strtok(NULL, " \t\n");
            firsttoken[strlen(firsttoken) - 1] = '\0';
        } else {
            *labelPtr = NULL;
            *opcodePtr = firsttoken;
        }
        *arg0Ptr = (char *) strtok(NULL, ", \t\n");
        *arg1Ptr = (char *) strtok(NULL, ", \t\n");
        *arg2Ptr = (char *) strtok(NULL, ", \t\n");
    }
    return(statusString);
}

int isRegister(char *string) {
    if (!string) { return -1; }
    int regnum;
    int ret = ( (sscanf(string, "$%d", &regnum)) == 1) &&
        regnum >= 0 &&
        regnum < 16;
    if (ret == 1) { return regnum; } 
    flag("Not a valid register",ERROR); 
    return -1; 
}

int isAddress(char *string, int * addr) {
    if (!string) { return -1; }
    int regnum;
    int ret = ( (sscanf(string, "%d($%d)", addr, &regnum)) == 2) &&
        regnum >= 0 &&
        regnum < 16 &&
        *addr   >= 0 &&
        *addr  < 65536;
    if (ret == 1) { return regnum; }
    flag("Not a valid address",ERROR); 
     return -1; 

}
    
int isNumber(char *string) {
    if (!string) { return -1; }
    int i;
    if ( (sscanf(string, "%d", &i)) == 1) {
        return i;
    }
    flag("Not a number",ERROR); 
    return -1;
}
int getFunct(char * opcode) {
    if (getOpcode(opcode)!=R_type) { return -1; }
    if (!strcmp(opcode, "add")) {
        return ADD_funct; 
    }
    if (!strcmp(opcode, "addu")) {
        return ADDU_funct; 
    }
    if (!strcmp(opcode, "srlv")) {
        return SRLV_funct; 
    }
    if (!strcmp(opcode, "sllv")) {
        return SLLV_funct; 
    }
    if (!strcmp(opcode, "or")) {
        return OR_funct;
    }
    if (!strcmp(opcode, "and")) {
        return AND_funct; 
    }
    if (!strcmp(opcode, "slt")) {
        return SLT_funct; 
    }
    if (!strcmp(opcode, "sltu")) {
        return SLTU_funct; 
    }
    if (!strcmp(opcode, "sub")) {
        return SUB_funct; 
    }
    if (!strcmp(opcode, "subu")) {
        return SUBU_funct; 
    }
    if (!strcmp(opcode, "xor")) {
        return XOR_funct; 
    }
    flag("Instruction not supported",WARNING); 
    return -1;
}
int getOpcode(char * opcode) { 
    
    if (!opcode) { return -1; }
    if (!strcmp(opcode, "addi")) {
        return ADDI_type; 
    }
    if (!strcmp(opcode, "addiu")) {
        return ADDIU_type; 
    }
    if (!strcmp(opcode, "ori")) {
        return ORI_type; 
    }
    if (!strcmp(opcode, "xori")) {
        return XORI_type; 
    }
    if (!strcmp(opcode, "andi")) {
        return ANDI_type; 
    }
    if (!strcmp(opcode, "add")) {
        return R_type; 
    }
    if (!strcmp(opcode, "or")) {
        return R_type;
    }
    if (!strcmp(opcode, "xor")) {
        return R_type;
    }
    if (!strcmp(opcode, "and")) {
        return R_type; 
    }
    if (!strcmp(opcode, "slt")) {
        return R_type; 
    }
    if (!strcmp(opcode, "sub")) {
        return R_type; 
    }
    if (!strcmp(opcode, "srlv")) {
        return R_type; 
    }
    if (!strcmp(opcode, "sllv")) {
        return R_type; 
    }
    if (!strcmp(opcode, "sw")) {
        return SW_type;
    }
    if (!strcmp(opcode, "lw")) {
        return LW_type;
    }
    if (!strcmp(opcode, "j")) {
        return J_type;
    }
    if (!strcmp(opcode, "beq")) {
        return BEQ_type;
    }
    if (!strcmp(opcode, "bne")) {
        return BNE_type;
    }
    flag("Instruction not supported",WARNING); 
    return -1;
}
int getMachineCode(BranchLabel_t *pcs, int inst, char* opcode, char* arg0, char* arg1, char* arg2) { 
       int word = fieldMask(inst, 26, 6); 
       if (inst == R_type) {
            word |= fieldMask(isRegister(arg1),21,5); 
            word |= fieldMask(isRegister(arg2),16,5); 
            word |= fieldMask(isRegister(arg0),11,5); 
            word |= fieldMask(getFunct(opcode),0,11);
        }
        if (inst == LW_type || inst == SW_type) {
            int addr; 
            int s = isAddress(arg1, &addr);
            word |= fieldMask(s,21,5); 
            word |= fieldMask(isRegister(arg0),16,5); 
            word |= fieldMask(addr,0,16); 
        }
        if (inst == ADDI_type || inst == ANDI_type 
            || inst == ORI_type || inst == XORI_type
            || inst == ADDIU_type) {
            word |= fieldMask(isRegister(arg1),21,5); 
            word |= fieldMask(isRegister(arg0),16,5); 
            word |= fieldMask(isNumber(arg2),0,16); 
        }
        if (inst == BEQ_type || inst == BNE_type) {
            word |= fieldMask(isRegister(arg0),21,5);
            word |= fieldMask(isRegister(arg1),16,5); 
            word |= fieldMask(branchResolveToInt(arg2,pcs),0,16); 
        }
        if (inst == J_type) {
            word |= fieldMask(jumpTo(arg0,pcs),0,26);
        } 
        return word; 
}
int jumpTo(char * jump, BranchLabel_t * lbls) {
    for (int i = 0; i < lbls->length; i++) {
        int addr = 0;  
        if (!strcmp(jump, lbls->labels[i])) {
            return lbls->addrs[i]/4;
        }
    }    
}


