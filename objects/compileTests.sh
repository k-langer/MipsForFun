for ts in `ls -1 ../tests/ | sed 's/\.s//g'`; do
    echo "Assembling $ts"
    ../asm/ASM ../tests/$ts.s > $ts.dat
    set sol `tail -n1 ../tests/$ts.s | awk '{print $2}'`
    #if [[ $sol =~ ^-?[0-9]+$ ]] ; then
    #    echo "Solution: $sol"
    #fi 
done 

rm -f m.dat
