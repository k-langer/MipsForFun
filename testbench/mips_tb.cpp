#include "Vmips.h"
#include "verilated.h"

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
  Verilated::commandArgs(argc, argv);
  // init top verilog instance
  Vmips* top = new Vmips;
  // initialize simulation inputs
  top->clk = 1;
  // run simulation for 100 clock periods
  for (i=0; i<20; i++) {
    top->reset = (i < 1);
    for (clk=0; clk<2; clk++) {
      top->clk = !top->clk;
      top->eval ();
    }
    int pc, aluRes, regDst, wrDat; 
    pc = top->v__DOT__fe__DOT__dff_PC__DOT__q; 
    aluRes = top->v__DOT__ex__DOT__dff_Result__DOT__q; 
    regDst = top->v__DOT__me__DOT__dff_WriteReg__DOT__q;
    wrDat  = top->v__DOT__de__DOT__WrDat;
    //printf("%2d: aluRes: %d regDst: %d wrDat: %d\n",i,aluRes, regDst,wrDat);
    printEx(top);
    if (Verilated::gotFinish())  exit(0);
  }
  exit(0);
}

