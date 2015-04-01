#include "inst.h"
#include "common.h" 
const unsigned int R_type     = 0b000000;
const unsigned int LW_type    = 0b100011;
const unsigned int SW_type    = 0b101011;
const unsigned int BEQ_type   = 0b000100;
const unsigned int ADDI_type  = 0b001000;
const unsigned int LUI_type   = 0b001111;
const unsigned int ADDIU_type = 0b001001;
const unsigned int ANDI_type  = 0b001100;
const unsigned int ORI_type   = 0b001101;
const unsigned int XORI_type  = 0b001110;
const unsigned int J_type     = 0b000010;
const unsigned int JAL_type   = 0b000011;
const unsigned int BNE_type   = 0b000101; 
const unsigned int BLTZ_type  = 0b000001; 
const unsigned int BLEZ_type  = 0b000110; 
const unsigned int BGTZ_type  = 0b000111; 
const unsigned int BGEZ_type  = 0b111111; //special, deal with later
 
const unsigned int MFHI_funct = 0b010000;
const unsigned int MFLO_funct = 0b010010;
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
const unsigned int MULT_funct = 0b011000; 
const unsigned int DIV_funct  = 0b011010; 
const unsigned int SRA_funct  = 0b000011; 
 
int getFunct(char * opcode) {
    if (getOpcode(opcode)!=R_type) { return -1; }
    if (!strcmp(opcode, "sra")) {
        return SRA_funct; 
    }
    if (!strcmp(opcode, "mflo")) {
        return MFLO_funct; 
    }
    if (!strcmp(opcode, "mfhi")) {
        return MFHI_funct; 
    }
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
    if (!strcmp(opcode, "mult")) {
        return MULT_funct; 
    }
    if (!strcmp(opcode, "div")) {
        return DIV_funct; 
    }
    flag("Instruction not supported",WARNING); 
    return -1;
}
int getOpcode(char * opcode) { 
    if (!opcode) { return -1; }
    if (!strcmp(opcode, "sra")) {
        return R_type; 
    }
    if (!strcmp(opcode, "lui")) {
        return LUI_type; 
    }
    if (!strcmp(opcode, "bgtz")) {
        return BGTZ_type; 
    }
    if (!strcmp(opcode, "bgez")) {
        return BGEZ_type; 
    }
    if (!strcmp(opcode, "blez")) {
        return BLEZ_type; 
    }
    if (!strcmp(opcode, "bltz")) {
        return BLTZ_type; 
    }
    if (!strcmp(opcode, "mult")) {
        return R_type; 
    }
    if (!strcmp(opcode, "div")) {
        return R_type; 
    }
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
    if (!strcmp(opcode, "mfhi")) {
        return R_type; 
    }
    if (!strcmp(opcode, "mflo")) {
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
    if (!strcmp(opcode, "jal")) {
        return JAL_type;
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
