#!/usr/bin/perl
use strict;           

print "Instruction Coverage:\n";
my %isa = (
   ADDI => '0',
   ADDIU => '0',
   ADDU => '0',
   AND => '0',
   ANDI => '0',
   BEQ => '0',
   BGEZ => '0',
   BGEZAL => '0',
   BGTZ => '0',
   BLEZ => '0',
   BLTZ => '0',
   BLTZAL => '0',
   BNE => '0',
   DIV => '0',
   DIVU => '0',
   J => '0',
   JAL => '0',
   JR => '0',
   LB => '0',
   LUI => '0',
   LW => '0',
   MFHI => '0',
   MFLO => '0',
   MULT => '0',
   MULTU => '0',
   NOOP => '0',
   OR => '0',
   ORI => '0',
   SB => '0',
   SLL => '0',
   SLLV => '0',
   SLT => '0',
   SLTI => '0',
   SLTIU => '0',
   SLTU => '0',
   SRA => '0',
   SRL => '0',
   SRLV => '0',
   SUB => '0',
   SUBU => '0',
   SW => '0',
   SYSCALL => '0',
   XOR => '0',
   XORI => '0'
);

my @tests = `cat ../tests/*.s | grep -v "#" | sed 's/^.*://g'`;
my $ln; 
my $instr; 
my @instrs = keys %isa; 
foreach $ln (@tests) {
    foreach $instr (@instrs) {
        if ($ln =~ /(^|\s)$instr/i) {
#        print $instr;
            $isa{ $instr } = '1'; 
        }
    }
#    print $ln;
}

my $cnt = 0;
my $valid = 0;  
foreach my $key ( keys %isa ) { 
    print "\t".$key." ".$isa{$key}."\n";
    if ($isa{$key} == '1') {
        $valid += 1; 
    }
    $cnt += 1; 
}
print "Coverage: ".(100*$valid)/($cnt+0.0)."%\n";
