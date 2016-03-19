ori $1, $0, 5
addi $2, $0, -8
addi $3, $0, 2
addi $4, $0, -4
bltz $4, jump4
bltz $2, jump2
sw  $1, 0($0)
jump: sw $2, 0($0)
jump2: sw $3, 0($0)
bltz $4, jump3
sw $4, 0($0)
jump3: sw $1, 0($0)
jump4: sw $1, 0($0)
add $5, $4, $1
bgtz $5, jump5
sw $1, 0($0)
jump5: sw $2, 0($0)

# Expected: -8
