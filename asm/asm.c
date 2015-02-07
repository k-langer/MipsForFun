#include "asm.h" 
#include "common.h"
#include "inst.h" 

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
int getMachineCode(BranchLabel_t *pcs, int inst, char* opcode, char* arg0, char* arg1, char* arg2) { 
       int word = fieldMask(inst, 26, 6); 
       if (inst == R_type) {
            if (arg1) {
            word |= fieldMask(isRegister(arg1),21,5); 
            }
            if (arg2) {
            word |= fieldMask(isRegister(arg2),16,5); 
            }
            if (arg0) {
            word |= fieldMask(isRegister(arg0),11,5); 
            }
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


