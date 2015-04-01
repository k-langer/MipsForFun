# square function 

addi $1, $0, -2
addi $3, $0, 6
j   sqr


sqr:    sw $1, 8($0)
        sw $2, 12($0)
        addi $3, $3, -1
        sw $3, 16($0)
        add $2, $1, $0
loop:     j   mul
          sw $3, 0($0)
sqrret:  lw $1, 8($0)
          add $2, $3, $0
          lw $3, 16($0)
          addi $3, $3, -1
          sw $3, 16($0)
          bgtz $3, loop
          sw $2, 0($0)
          sw $0, 4($0)







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
end:        j sqrret
