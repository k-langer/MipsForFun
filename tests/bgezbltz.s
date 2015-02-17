addi $2, $0, -5
addi $3, $0, 4
bgez $0 , taken1
sw $2, 0($0)
taken1: bgez $5, nottaken1
bltz $3, nottaken2 
bltz $3, nottaken2
bltz $2, taken2
sw $2, 0($0)
taken2: sw $3, 0($0)
sw $2, 4($0)



nottaken1:  sw $2, 0($0)
nottaken2:  sw $2, 0($0)
sw $2, 0($0)
#taken1: bltz $2, taken2
#sw $2, 0($0)
#taken2: bgtz $3, taken3
#sw $2, 0($0)
#taken3: sw $0, 0($0) 
