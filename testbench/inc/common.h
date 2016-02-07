#ifndef __common__h
#define __common__h
#include "Vmips.h"
#include "verilated.h"
#include <iostream>
#include <fstream>
#include "verilated_vcd_c.h"
#include "runtest.h"
using namespace std;

int run_regressions(Vmips * cpu); 

#endif
