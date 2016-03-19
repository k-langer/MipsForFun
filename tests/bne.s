addi $1, $0, 5
addi $2, $0, 0
addi $3, $0, -5
addi $4, $0, 1
addi $5, $0, -5
addi $6, $0, -6
addi $7, $0, -7
addi $8, $0, -8
addi $9, $0, -9
addi $10, $0, -10
addi $11, $0, -11
bne $1, $0, branch_taken 
sw $5, 0($0)
add $2, $0, $4
branch_taken: add $3, $0, $1
sw $6, 0($0)
add $2, $4, $0
blez $3, branch_taken
sw $7, 0($0)
add $2, $4, $0
bgez $0, branch_gez
sw $8, 0($0)
branch_gez: add $2, $4, $0 
bgtz $0, branch_gez
sw $9, 0($0)
add $2, $4, $0
bltz $0, branch_gez 
sw $10, 0($0)
add $2, $4, $0
sw $2, 0($0)

# Expected: 1
