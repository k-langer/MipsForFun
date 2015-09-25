#include "Vmips.h"
#include "verilated.h"
#include <iostream>
#include <fstream>
using namespace std;

int * instrMemory(char * assembly);

void printEx(Vmips* top) {

    int imm = top->v__DOT__ex__DOT__SignImm_ID;
    int result = top->v__DOT__ex__DOT__Result_EXM1;
    int WrReg = top->v__DOT__ex__DOT__WriteReg_EXM1;
    int RegWrite = top->v__DOT__ex__DOT__RegWrite_EXM1;
    int Alu = top->v__DOT__de__DOT__funct;
    int a = top->v__DOT__ex__DOT__a;
    int b = top->v__DOT__ex__DOT__b;
    printf("imm: %d result: %d a: %d b: %d aluc: %d\n",imm,result,a,b,Alu);
    //printf("WrReg: %d RegWrite: %d\n",WrReg,RegWrite);
}
int main(int argc, char **argv) {
  int i;
  int clk;
  /*
  int * imem = instrMemory("m.dat"); 
  if (imem) {
  for (int i = 1; i < imem[0]; i++) {
    printf("%x\n",imem[i]);
  }
  }
  */
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vmips* top = new Vmips;
  // initialize simulation inputs
  top->clk = 1;
  // run simulation for 100 clock periods
  for (i=0; i<1000000; i++) {
    top->reset = (i < 1);
    for (clk=0; clk<2; clk++) {
      top->clk = !top->clk;
      top->eval ();
    }
    int pc, aluRes, regDst, wrDat, npc, WrEn, WrAddr; 
    pc = top->v__DOT__fe__DOT__dff_PC__DOT__q; 
    aluRes = top->v__DOT__ex__DOT__dff_Result__DOT__q; 
    regDst = top->v__DOT__me__DOT__dff_WriteReg__DOT__q;
    //wrDat  = top->v__DOT__de__DOT__WrDat;
    npc    = top->v__DOT__fe__DOT__nPc_IFM1; 
    wrDat  = top->v__DOT__me__DOT__WrDat_EX;
    WrEn   = top->v__DOT__me__DOT__WrEn;   
    WrAddr = top->v__DOT__me__DOT__Result_EX;
    //printf("%2d: aluRes: %d regDst: %d wrDat: %d\n",i,aluRes, regDst,wrDat);
    //printEx(top);
    //printf("pc: %d %d\n",pc,aluRes);
    if (WrEn) {
        if( WrAddr == 0 ) { printf("%d\n",wrDat); }
        if (WrAddr == 4 ) { break; }
    }
    if (Verilated::gotFinish())  exit(0);
  }
  int cycles = top->v__DOT__me__DOT__Cycles_ME;
  int insts  = top->v__DOT__me__DOT__Instr_ME;
  printf("#Instr: %d\n#Cycles: %d\nIPC: %f\n",insts,cycles,insts/(cycles+0.0));
  exit(0);
}
int charToHex(char digit) {
    switch (digit) {
        case 'A':
        case 'a':
        return 10;
        case 'B':
        case 'b':
        return 11;
        case 'C':
        case 'c':
        return 12;
        case 'D':
        case 'd':
        return 13;
        case 'E':
        case 'e':
        return 14;
        case 'F':
        case 'f':
        return 15;
        case '0':
        return 0;
        case '1':
        return 1;
        case '2':
        return 2; 
        case '3':
        return 3; 
        case '4':
        return 4;
        case '5':
        return 5;
        case '6':
        return 6;
        case '7':
        return 7;
        case '8':
        return 8;
        case '9':
        return 9; 
    } 
    return -1;
}
int * instrMemory(char * assembly) {
  ifstream asmm;
  asmm.open (assembly);
  if (!asmm) { return NULL; }
  string instrS;
  int lines; 
  while(!asmm.eof()) {
    asmm >> instrS;
    if (instrS.size() != 8) {
        lines = 0; 
        break;
    }
    for (int i = 0; i < 8; i++) {
        if (charToHex(instrS[i]) == -1) {
            lines = 0;
            break;
        }
    } 
    lines+=1; 
  }
  asmm.close();
  if (lines == 0 ) {
    return NULL;
  }
  int * imem = (int *) calloc(lines+1,4);
  
  int instr; 
  asmm.open (assembly);
  imem[0] = lines;
  lines = 0;
  while(!asmm.eof()) {
    asmm >> instrS;
    instr = 0; 
    for (int i = 0; i < 8; i++) {
        instr |= charToHex(instrS[i])<<((7-i)*4);
    }
    //skip first line
    imem[++lines] = instr;
  }
  return imem;
}

