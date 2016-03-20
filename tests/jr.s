# Jump register. Is really way too simple, but wve it works for now
addi $2, $0, 12
jr   $2
addi  $2, $0, 16
sw $2, 0($0)
# Expected : 12
