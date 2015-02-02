cp ../mips_singlecycle/mips.v data
cp SynVRtl.pl data 
cd data 
./SynVRtl.pl
qflow synthesize mips.syn.v


