#include "Vmips.h"
#include "verilated.h"
#include <iostream>
#include <fstream>
#include "verilated_vcd_c.h"
#include "inc/common.h"
#include "inc/runtest.h"

int main(int argc, char **argv) {
  int i;
  int clk;
  int main_time; 
  int test; 
  Verilated::commandArgs(argc, argv);
  Verilated::traceEverOn(true);
  VerilatedVcdC* tfp = new VerilatedVcdC;
  // init top verilog instance
  Vmips* top = new Vmips;
  top->trace (tfp, 99);
  tfp->open ("waves/simx.vcd");
  // initialize simulation inputs
  // run simulation for 100 clock periods
  //loadInstrMemory(top, "tests/sqr.dat");
  //test = runTest(top, 4096, 1000000, tfp );
  //printf("Mul: %s\n", passFail(test));
  run_regressions(top ); 
  tfp->close();
  int cycles = top->v__DOT__me__DOT__Cycles_ME;
  int insts  = top->v__DOT__me__DOT__Instr_ME;
  printf("#Instr: %d\n#Cycles: %d\nIPC: %f\n",insts,cycles,insts/(cycles+0.0));
  exit(0);
}
