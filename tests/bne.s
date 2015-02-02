addi $1, $0, 5
addi $2, $0, 4
bne $1, $0, branch_taken 
sw $2, 0($0)
branch_taken: add $0, $0, $0
sw $1. 0($0)
sw $2, 0($0)
sw $0, 4($0)
