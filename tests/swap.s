ori $1, $0, 15
addi $2, $0, 21
# Test funcionality 
xor $2, $2, $1
xor $1, $2, $1
xor $2, $2, $1
# Test properties 
xor $2, $1, $2
xor $1, $1, $2
xor $2, $1, $2
xor $2, $2, $1
xor $1, $1, $2
xor $2, $2, $1
# 
xor $3, $2, $2
bne $3, $0, nottaken
sw $1, 0($0)
nottaken: sw $0, 4($0)

