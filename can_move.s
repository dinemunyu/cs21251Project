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
    jal can_move
    
    li a7 10
    ecall
    

# output is in t6 very helpful comment
can_move:
    addi sp sp -64
    sw ra 60(sp)
    sw s3 56(sp)
    sw s4 52(sp)
    sw s5 48(sp)
    sw s6 44(sp)
    sw s7 40(sp)
    sw s8 36(sp)
    sw s9 32(sp)
    sw s10 28(sp)
    sw s11 24(sp)
    sw s0 20(sp)
    sw s1 16(sp)
    sw s2 12(sp)
    
    #input get column
    mv a0 s0
    mv a1 s1
    mv a2 s2
    
    # 1st col
    li a3 0
    jal get_column
    mv s3 s0
    mv s6 s1
    mv s9 s2
    
    # 2nd col
    li a3 1
    jal get_column
    mv s4 s0
    mv s7 s1
    mv s10 s2
    
    # 3rd col
    li a3 2
    jal get_column
    mv s5 s0
    mv s8 s1
    mv s11 s2
    
    li t6 0 # currently false
    # if reg is 0
    beq s3 zero can_move_true
    beq s4 zero can_move_true
    beq s5 zero can_move_true
    beq s6 zero can_move_true
    beq s7 zero can_move_true
    beq s8 zero can_move_true
    beq s9 zero can_move_true
    beq s10 zero can_move_true
    beq s11 zero can_move_true
    
    # check cardinal direction equality
    beq s3 s4 can_move_true
    beq s3 s6 can_move_true
    
    beq s4 s5 can_move_true
    beq s4 s7 can_move_true
    
    beq s5 s8 can_move_true
    
    beq s6 s7 can_move_true
    beq s6 s9 can_move_true
    
    beq s7 s8 can_move_true
    beq s7 s10 can_move_true
    
    beq s8 s11 can_move_true
    
    beq s9 s10 can_move_true
    
    beq s10 s11 can_move_true
can_move_end:
    lw s0 20(sp)
    lw s1 16(sp)
    lw s2 12(sp)
    lw ra 60(sp)
    lw ra 60(sp)
    lw s3 56(sp)
    lw s4 52(sp)
    lw s5 48(sp)
    lw s6 44(sp)
    lw s7 40(sp)
    lw s8 36(sp)
    lw s9 32(sp)
    lw s10 28(sp)
    lw s11 24(sp)
    addi sp sp 64
    jalr ra
    
can_move_true:
    li t6 1
    j can_move_end