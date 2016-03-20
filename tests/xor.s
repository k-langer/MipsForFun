# Test xor instruction
addi $1, $0, 5
addi $2, $0, 8
xor  $3, $1, $2
sw $3, 0($0)
# EXPECTED: 13
# DEBUG
