../asm/ASM ../tests/mul.s > mul.dat
echo "13" >> mul.sol

../asm/ASM ../tests/mbne.s > bne.dat
echo "13" >> bne.sol

../asm/ASM ../tests/mul.s > xor.dat
echo "13" >> xor.sol

../asm/ASM ../tests/mul.s > shift.dat
echo "13" >> shift.sol

rm m.dat
