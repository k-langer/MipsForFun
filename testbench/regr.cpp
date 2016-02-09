//GENERATED CODE BELOW (by tests/buildTests.pl)
#include "inc/common.h"

int run_regressions(Vmips* cpu ) {
	int test;
	VerilatedVcdC* vcd;
	// Test shift
	loadInstrMemory(cpu, "tests/shift.dat");
	test = runTest(cpu, 16, 1000000, 0 );
	printf("%20s: %11s\n", "shift",passFail(test));
	// Test blezbgtz
	loadInstrMemory(cpu, "tests/blezbgtz.dat");
	test = runTest(cpu, 3, 1000000, 0 );
	printf("%20s: %11s\n", "blezbgtz",passFail(test));
	// Test branchtest
	printf("%20s: %11s\n","branchtest","BUILD ERROR");
	// Test bgezbltz
	loadInstrMemory(cpu, "tests/bgezbltz.dat");
	test = runTest(cpu, 4, 1000000, 0 );
	printf("%20s: %11s\n", "bgezbltz",passFail(test));
	// Test memfile
	printf("%20s: %11s\n","memfile","BUILD ERROR");
	// Test mul
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/mul.vcd");
	printf("DEBUG mul\n");
	loadInstrMemory(cpu, "tests/mul.dat");
	test = runTest(cpu, -12, 1000000, vcd );
	printf("%20s: %11s\n", "mul",passFail(test));
	vcd->close();
	delete(vcd);
	// Test add
	printf("%20s: %11s\n","add","BUILD ERROR");
	// Test bne
	printf("%20s: %11s\n","bne","BUILD ERROR");
	// Test divmul
	printf("%20s: %11s\n","divmul","BUILD ERROR");
	// Test swap
	printf("%20s: %11s\n","swap","BUILD ERROR");
	// Test xor
	loadInstrMemory(cpu, "tests/xor.dat");
	test = runTest(cpu, 13, 1000000, 0 );
	printf("%20s: %11s\n", "xor",passFail(test));
	// Test sra
	printf("%20s: %11s\n","sra","BUILD ERROR");
	// Test slti
	printf("%20s: %11s\n","slti","BUILD ERROR");
	// Test sw
	loadInstrMemory(cpu, "tests/sw.dat");
	test = runTest(cpu, -1337, 1000000, 0 );
	printf("%20s: %11s\n", "sw",passFail(test));
	// Test sqr
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/sqr.vcd");
	printf("DEBUG sqr\n");
	loadInstrMemory(cpu, "tests/sqr.dat");
	test = runTest(cpu, 4096, 1000000, vcd );
	printf("%20s: %11s\n", "sqr",passFail(test));
	vcd->close();
	delete(vcd);
}
