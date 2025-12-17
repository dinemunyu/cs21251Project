.text
prologue:
    j main

# ASSUMES INPUT IS IN a0, a1, a2, a3
# a0 = first row, a1 = second row, a2 = third row
# a3 = index of row
# ASSUMES OUTPUT IS in s0, s1, s2
get_column:
    addi sp sp -32
    sw ra 28(sp)
    
    li t2 0b111111111000000000000000000000 #MASK
    li t4 20
    beq a3 zero get_column_proceed
    
    srli t2 t2 10
    li t3 1
    li t4 10
    beq a3 t3 get_column_proceed
    
    srli t2 t2 10
    li t3 2
    li t4 0
    beq a3 t3 get_column_proceed
    
get_column_proceed:   
    and s0 t2 a0 # FIRST ROW
    srl s0 s0 t4
    
    and s1 t2 a1 # SECOND ROW
    srl s1 s1 t4
    
    and s2 t2 a2 # THIRD ROW
    srl s2 s2 t4
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra

# ASSUMES INPUT IS IN a0, a1, a2 
# a0 = the row to edit
# a1 = index to put the new value
# a2 = the new value
# ASSUMES OUTPUT IS IN s0
put_column:
    addi sp sp -32
    sw ra 28(sp)
    
    
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
    
    
# USES SAVED REGISTERS TO STORE STATE OF GRID
# S0 = 1ST ROW
# S1 = 2ND ROW
# S2 = 3RD ROW

# USES TEMPORARY REGISTERS    
# T0 = 1ST COLUMN
# T1 = 2ND COLUMN
# T2 = 3RD COLUMN

main:
    li s0 0b000000001000000000100000000010
    li s1 0b000000001000000000100000100000
    li s2 0b010000000000100000000001000000
    
    mv a0 s0
    mv a1 s1
    mv a2 s2
    li a3 0
    jal merge_left
    
    li a7 10
    ecall
    

merge_left_outer:
    addi sp sp -32 
    sw ra 28(sp)
    
    li a3 0
    li a4 1
    jal merge_left
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    


# ASSUMES INPUT IS IN a0, a1, a2, a3, a4
# a0 = first row, a1 = second row, a2 = third row
# a3 = index of first col, a4 = index of second col

# ASSUMES OUTPUT IS IN s0, s1, s2
merge_left:
    addi sp sp -32
    sw ra 28(sp)
    
    jal get_column
    
    mv t0 s0
    mv t1 s1
    mv t2 s2
    
    sw t0 24(sp)
    sw t1 20(sp)
    sw t2 16(sp)
    
    mv a3 a4 
    jal get_column
    
    lw t0 24(sp)
    lw t1 20(sp)
    lw t2 16(sp)
    
    bne t0 s0 check_2nd_index
    add s0 s0 t0
    
check_2nd_index:
    bne t1 s1 check_3rd_index
    add s1 s1 t1
    
check_3rd_index:
    bne t2 s2 merge_left_exit
    add s2 s2 t2
    
merge_left_exit:
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    


    
    