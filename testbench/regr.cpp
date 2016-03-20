//GENERATED CODE BELOW (by tests/buildTests.pl)
#include "inc/common.h"

int run_regressions(Vmips* cpu ) {
	int test;
	VerilatedVcdC* vcd;
	// Test mul
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/mul.vcd");
	printf("DEBUG mul\n");
	loadInstrMemory(cpu, "tests/mul.dat");
	test = runTest(cpu, -12, 1000, vcd );
	printf("%20s: %11s\n", "mul",passFail(test));
	vcd->close();
	delete(vcd);
	// Test blezbgtz
	loadInstrMemory(cpu, "tests/blezbgtz.dat");
	test = runTest(cpu, 3, 1000, 0 );
	printf("%20s: %11s\n", "blezbgtz",passFail(test));
	// Test slti
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/slti.vcd");
	printf("DEBUG slti\n");
	loadInstrMemory(cpu, "tests/slti.dat");
	test = runTest(cpu, 4, 1000, vcd );
	printf("%20s: %11s\n", "slti",passFail(test));
	vcd->close();
	delete(vcd);
	// Test addu
	loadInstrMemory(cpu, "tests/addu.dat");
	test = runTest(cpu, 8, 1000, 0 );
	printf("%20s: %11s\n", "addu",passFail(test));
	// Test shift
	loadInstrMemory(cpu, "tests/shift.dat");
	test = runTest(cpu, 16, 1000, 0 );
	printf("%20s: %11s\n", "shift",passFail(test));
	// Test swap
	loadInstrMemory(cpu, "tests/swap.dat");
	test = runTest(cpu, 21, 1000, 0 );
	printf("%20s: %11s\n", "swap",passFail(test));
	// Test add
	loadInstrMemory(cpu, "tests/add.dat");
	test = runTest(cpu, 20, 1000, 0 );
	printf("%20s: %11s\n", "add",passFail(test));
	// Test sra
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/sra.vcd");
	printf("DEBUG sra\n");
	loadInstrMemory(cpu, "tests/sra.dat");
	test = runTest(cpu, 32, 1000, vcd );
	printf("%20s: %11s\n", "sra",passFail(test));
	vcd->close();
	delete(vcd);
	// Test divmul
	printf("%20s: %11s\n","divmul","BUILD ERROR");
	// Test xor
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/xor.vcd");
	printf("DEBUG xor\n");
	loadInstrMemory(cpu, "tests/xor.dat");
	test = runTest(cpu, 13, 1000, vcd );
	printf("%20s: %11s\n", "xor",passFail(test));
	vcd->close();
	delete(vcd);
	// Test misalignld
	loadInstrMemory(cpu, "tests/misalignld.dat");
	test = runTest(cpu, 65535, 1000, 0 );
	printf("%20s: %11s\n", "misalignld",passFail(test));
	// Test branchtest
	loadInstrMemory(cpu, "tests/branchtest.dat");
	test = runTest(cpu, -8, 1000, 0 );
	printf("%20s: %11s\n", "branchtest",passFail(test));
	// Test loadb
	loadInstrMemory(cpu, "tests/loadb.dat");
	test = runTest(cpu, 10, 1000, 0 );
	printf("%20s: %11s\n", "loadb",passFail(test));
	// Test jr
	loadInstrMemory(cpu, "tests/jr.dat");
	test = runTest(cpu, 12, 1000, 0 );
	printf("%20s: %11s\n", "jr",passFail(test));
	// Test bgezbltz
	loadInstrMemory(cpu, "tests/bgezbltz.dat");
	test = runTest(cpu, 4, 1000, 0 );
	printf("%20s: %11s\n", "bgezbltz",passFail(test));
	// Test sqr
	vcd = new VerilatedVcdC;
	cpu->trace (vcd, 99);
	vcd->open ("waves/sqr.vcd");
	printf("DEBUG sqr\n");
	loadInstrMemory(cpu, "tests/sqr.dat");
	test = runTest(cpu, 4096, 1000, vcd );
	printf("%20s: %11s\n", "sqr",passFail(test));
	vcd->close();
	delete(vcd);
	// Test memfile
	loadInstrMemory(cpu, "tests/memfile.dat");
	test = runTest(cpu, 5, 1000, 0 );
	printf("%20s: %11s\n", "memfile",passFail(test));
	// Test noop
	loadInstrMemory(cpu, "tests/noop.dat");
	test = runTest(cpu, 20, 1000, 0 );
	printf("%20s: %11s\n", "noop",passFail(test));
	// Test bne
	loadInstrMemory(cpu, "tests/bne.dat");
	test = runTest(cpu, 1, 1000, 0 );
	printf("%20s: %11s\n", "bne",passFail(test));
}
