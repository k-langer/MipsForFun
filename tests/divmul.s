# Test xor instruction
addi $1, $0, 5
addi $2, $0, 8
mult  $1, $2
mflo  $3
sw $3, 0($0)
