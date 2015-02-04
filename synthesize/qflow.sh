cp ../mips_singlecycle/mips.v data/mips.raw.v
rm -f data/mips.v
cp SynVRtl.pl data 
cd data
./SynVRtl.pl

qflow synthesize mips.v | tee synthesize.log
qflow sta mips.v  | tee sta.log 

date >> synthesize.log 
date >> sta.log 

gzip sta.log
gzip synthesize.log

mv data/*gz logs/


