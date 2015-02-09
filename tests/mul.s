# Multiply function 
# Do a booth alogirthm till I get around
# To implementing hardware multiply
            addi $1, $0, -3
            addi $2, $0, 4
            jal   mul
mul:        addi $3, $0, 0
            slt  $4, $1, $2
            slt  $5, $0, $1 
            beq  $5, $0, sign
mull:       beq  $1, $0, fixsign
            add  $3, $2, $3
            addi $1, $1, -1
            jal   mull
sign:       sub $1, $0, $1 
            jal mull
fixsign:    beq $5, $0, csign
            jal end
csign:      sub $3, $0, $3
            jal end
end:        sw   $3, 0($0)
#   13
