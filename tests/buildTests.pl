#!/usr/bin/perl

use strict;
use warnings;
use Cwd            qw( abs_path );
use File::Basename qw( dirname );
use File::Copy;

my $dir = dirname(abs_path($0));
my $max_cycles = 1000;
my @files ;
my $file ;
my %files_errors = (); 
my %files_expected = (); 
my %files_debug = (); 

print "$dir\n"; 
opendir(DIR, $dir) or die $!;

while (my $file = readdir(DIR)) {

    if ($file =~ /(.*)\.s$/) {
        push @files, $1
    }
}
foreach $file (@files) {
    print "Reading: ".$file."\n";
    $files_errors    { $file } = 1; 
    $files_debug     { $file } = 0; 
    $files_expected  { $file } = 9999; 
    if ( system("$dir/../asm/ASM", "$dir/$file.s", "$dir/../testbench/tests/$file.dat", " >/dev/null") != 0 ) {
        $files_errors    { $file } = 2; 
        print "Build ERRORs in $file, ignoring file\n";
    }
    print "$dir/$file.s\n";
    open(my $fh, "<", "$dir/$file.s")  or $files_errors    { $file } = 2;
    if ($files_errors    { $file } == 2 ) { next; } 
    while (my $row = <$fh> ) {
        chomp $row;
        if ( $row =~ /^#\s*[Ee]\w+\s*:\s*([-\d\.]+)/) {
            $files_expected  { $file } = $1; 
            $files_errors    { $file } =  0;
        }
        if ( $row =~ /^#\s*[Dd][EBUGebug]+\s*/) {
            $files_debug     { $file } = 1;
            $files_errors    { $file } =  0;
        }
    }
    copy("$dir/$file.s","$dir/../testbench/tests/$file.s") or die "Copy failed: $!";
    if ( $files_errors    { $file } == 0 ) {
        print "SUCESS Assembling: ".$file."\n"; 
    } else {
        print "ERRORs detected in " . $file . " aborting\n";
    }
    close($fh);
}
open(my $fh, '>', "$dir/../testbench/regr.cpp") or die "ERROR: Could not open file runtest.cpp\n";
print $fh "//GENERATED CODE BELOW (by tests/buildTests.pl)\n#include \"inc/common.h\"\n\n";
print $fh "int run_regressions(Vmips* cpu ) {\n";
print $fh "\tint test;\n\tVerilatedVcdC* vcd;\n";

foreach $file (@files) {
  my $expected = $files_expected  { $file }; 
  my $debug = $files_debug     { $file } == 1 ? "vcd" : "0"; 
  my $run_test = $files_errors    { $file } == 0; 
  print $fh "\t// Test $file"."\n"; 
  if ($debug) { print $fh "\tvcd = new VerilatedVcdC;\n\tcpu->trace (vcd, 99);\n"; } 
  if ($debug) { print $fh "\tvcd->open (\"waves/$file.vcd\");\n"; }
  if ($debug) { print $fh "\tprintf(\"DEBUG $file\\n\");\n"; }
  if ($run_test) { print $fh "\tloadInstrMemory(cpu, \"tests/$file.dat\");\n"; } 
  if ($run_test) { print $fh "\ttest = runTest(cpu, $expected, $max_cycles, $debug );\n"; } 
  if ($run_test) { print $fh "\tprintf(\"%20s: %11s\\n\", \"$file\",passFail(test));\n";  } 
  else {           print $fh "\tprintf(\"%20s: %11s\\n\",\"$file\",\"BUILD ERROR\");\n"; }  
  if ($debug) { print $fh "\tvcd->close();\n\tdelete(vcd);\n"; } 
}
print $fh "}\n";
close $fh;
closedir(DIR);
exit 0;

