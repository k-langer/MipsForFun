#ifndef __runtest__h
#define __runtest__h
#include "common.h" 

int * instrMemory(const char * assembly); 
int   loadInstrMemory(Vmips* cpu, const char * assembly); 
int   runTest(Vmips* cpu, int expected, int max_cycles, VerilatedVcdC* vcd ); 
const char * passFail(int result);
int   printIPC(Vmips* cpu);  

#endif
