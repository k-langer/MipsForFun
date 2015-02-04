#!/usr/bin/perl

use strict;
use warnings;

my $inFile = "mips.raw.v"; 
my $outFile = "mips.v";

my $insideCmt = 0; 

open(my $of, '>>', $outFile) or die "Error parsing verilog"; 
open(my $if, '<:encoding(UTF-8)', $inFile) or die "Error parsing verilog"; 

while (my $row = <$if>) {
    chomp $row;
    if ( $row =~ /testbench/) { $insideCmt = 1; }
    if ( $row =~ /readmem/) { $insideCmt = 1; }
    if ( $row =~ /initial.*readmem/) { $insideCmt = 1; }
    if ( $insideCmt == 0) {
        print $of "$row\n";
    } else {
        print $of "//$row\n";
    } 
    if ( $row =~ /readmem/) { $insideCmt = 0; }
    if ( $row =~ /endmodule/) { $insideCmt = 0; }
    if ( $row =~ /initial.*readmem/) { $insideCmt = 0; }
}

close($if);
close($of);


