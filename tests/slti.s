addi $2, $0, 5
slti $3, $2, 10
slti $4, $2, 5
slti $5, $2, 3 # 1
slti $6, $2, 0 # 1
slti $7, $2, -3 # 1
addi $2, $0, -5
slti $8, $2, 5
slti $9, $2, 0
slti $10, $2, -2
slti $11, $2, -123 # 1
add $12, $11, $10
add $12, $9, $12
add $12, $8, $12
add $12, $7, $12
add $12, $6, $12
add $12, $5, $12
add $12, $4, $12
add $12, $3, $12
sw $12, 0($0)
# Expected: 4
# DEBUG
