lui $2, 1027
ori $2, $2, 513
xor $3, $3, $3

sw $2, 8($0)

lb $4, 8($0) 
sw $4, 0($0)
add $3, $3, $4

lb $5, 9($0) 
sw $5, 0($0)
add $3, $3, $5

lb $6, 10($0) 
sw $6, 0($0)
add $3, $3, $6

lb $7, 11($0) 
sw $7, 0($0)
add $3, $3, $7

sw $3, 0($0)
# EXPECTED: 10
