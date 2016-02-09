# Test shift instruction
addi $1, $0, 1
addi $2, $0, 4
srlv $3, $2, $1
sw $3, 0($0)
srlv $3, $2, $1
sllv $3, $3, $3
sw $3, 0($0)
sllv $3, $3, $1
sw $3, 0($0)
sllv $3, $3, $1
sllv $3, $1, $3
# Expected: 16
