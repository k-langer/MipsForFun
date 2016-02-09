# Multiply function 
# Do a booth alogirthm till I get around
# To implementing hardware multiply
            addi $1, $0, -3
            addi $2, $0, 4
            j   mul
mul:        addi $3, $0, 0
            slt  $4, $1, $2
            slt  $5, $0, $1 
            beq  $5, $0, sign
mull:       beq  $1, $0, fixsign
            add  $3, $2, $3
            addi $1, $1, -1
            j   mull
sign:       sub $1, $0, $1 
            j mull
fixsign:    beq $5, $0, csign
            j end
csign:      sub $3, $0, $3
            j end
end:        sw   $3, 0($0)
# Expected:  12
#DEBUG
