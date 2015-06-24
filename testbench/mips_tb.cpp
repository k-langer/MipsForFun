#include "Vmips.h"
#include "verilated.h"

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
    top->reset = (i < 2);
    for (clk=0; clk<2; clk++) {
      top->clk = !top->clk;
      top->eval ();
    }
    printf("%d\n",top->v__DOT__fe__DOT__dff_PC__DOT__q);
    printf("%d\n",top->v__DOT__de__DOT__dff_imm__DOT__q);
    if (Verilated::gotFinish())  exit(0);
  }
  exit(0);
}
