#ifndef __inst__h
#define __inst__h
#include<stdio.h>
#include<stdlib.h>
#include <string.h>

const unsigned int R_type     ;
const unsigned int LW_type    ;
const unsigned int SW_type    ;
const unsigned int LB_type    ;
const unsigned int SB_type    ;
const unsigned int BEQ_type   ;
const unsigned int ADDI_type  ;
const unsigned int ADDIU_type ;
const unsigned int ANDI_type  ;
const unsigned int SLTIU_type ;
const unsigned int SLTI_type  ;
const unsigned int ORI_type   ;
const unsigned int XORI_type  ;
const unsigned int J_type     ;
const unsigned int JAL_type   ;
const unsigned int BNE_type   ; 
const unsigned int BLTZ_type  ;
const unsigned int BLEZ_type  ; 
const unsigned int BGTZ_type  ;
const unsigned int BGEZ_type  ;
const unsigned int LUI_type  ;

int getOpcode(char *);
int getFunct(char *);
int isShamt(char *);

#endif
