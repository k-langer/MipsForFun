#include "inc/common.h"
#include "inc/runtest.h"

int charToHex(char digit);
int * instrMemory(const char * assembly) {
  ifstream asmm;
  asmm.open (assembly);
  if (!asmm) { return NULL; }
  string instrS;
  int lines = 0; 
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
int loadInstrMemory(Vmips* cpu, const char * assembly) {
    int i, clk;
    int * imem; 
    imem = instrMemory(assembly);
    cpu->clk = 1;
    for (i=1; i<imem[0]; i++) {
      cpu->IntrAddr_FL0 = i-1;
      cpu->IntrFill_FL0 = imem[i];
      for (clk=0; clk<2; clk++) {
        cpu->clk = !cpu->clk;
        cpu->eval ();
      }
      //printf("%x\n",cpu->v__DOT__sy__DOT__RAM[i-1]);
    }
    /*
    if (imem) {
     for (int i = 1; i < imem[0]; i++) {
        printf("%x\n",imem[i]);
    }
    }
    */
    return imem[0]; 
}
int   runTest(Vmips* cpu, int expected, int max_cycles, VerilatedVcdC* vcd) {
  int i, clk, actual = -9999999, WrAddr, WrDat, WrEn, EndTest = 0, debug = 0 ;
  if (vcd) { debug = 1; } 
  for (i=0; i<max_cycles; i++) {
    cpu->reset = i < 1; 
    for (clk=0; clk<2; clk++) {
      cpu->clk = !cpu->clk;
      if (debug) { vcd->dump( 2*(i+1)+clk ); }
      cpu->eval ();
      if (Verilated::gotFinish())  { break; } 
    }
    WrAddr = cpu->v__DOT__me__DOT__Result_EX;
    WrDat  = cpu->v__DOT__me__DOT__WrDat_EX;
    WrEn   = cpu->v__DOT__me__DOT__WrEn;   
    if (WrEn) {
        if( WrAddr == 0 ) { 
            if ( EndTest == 0 ) { 
            actual = WrDat; 
            if (debug ) { printf("%d\n",WrDat); }
            }
        }
        if (WrAddr == 4 ) { EndTest = 1; }
    }
    if (EndTest > 0 ) { 
        if (EndTest > 10) { break; }
        else { EndTest++; }
    }
  }
  return expected==actual; 
} 
const char * passFail(int result) { 
    if (result) 
        return "PASS";
    return "FAIL";
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
