# Expected: 32
addi $2, $0, -8
sra  $3, $2, 2
sub  $4, $0, $3
sll $1, $4, 2
srl $4, $1, 3
sll $1, $4, 5
sll $2, $1, 0
sra $2, $2, 0
srl $2, $1, 0
srl $2, $2, 1
sll $2, $2, 1
sw $2, 0($0)

# DEBUG
