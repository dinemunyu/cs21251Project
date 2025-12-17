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
    jal move
    
    li a7 10
    ecall
    
# stores rows in t4 t5 t6
move:
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
    
    # LET t0 be output of read_int:
        # we need constants for w a s d
    li t0 0
    beq t0 zero left
    beq t0 zero right
    beq t0 zero up
    beq t0 zero down
    
move_return:
    slli s3 s3 20
    slli s4 s4 10
    add t4 s3 s4
    add t4 t4 s5

    slli s6 s6 20
    slli s7 s7 10
    add t5 s6 s7
    add t5 t5 s8
    
    slli s9 s9 20
    slli s10 s10 10
    add t6 s9 s10
    add t6 t6 s11

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
    
move_group:
    beq a0 a1 CASE_1
    beq a1 zero CASE_2
    beq a1 a2 CASE_3
    # if it reaches this point, it does not need to update this row
    jalr ra
    
CASE_1:
    add a0 a0 a1
    add a1 zero a2
    add a2 zero zero
    jalr ra
    
CASE_2:
    beq a0 a2 CASE_2_1
    jalr ra
    
CASE_2_1:
    add a0 a0 a2
    add a2 zero zero
    jalr ra
    
CASE_3:
    add a1 a1 a2
    add a2 zero zero
    jalr ra
    
left:
    mv a0 s3
    mv a1 s4
    mv a2 s5
    jal move_group
    # load output back
    mv s3 a0 
    mv s4 a1 
    mv s5 a2 
    
    mv a0 s6
    mv a1 s7
    mv a2 s8
    jal move_group
    # load output back
    mv s6 a0 
    mv s7 a1 
    mv s8 a2 

    mv a0 s9
    mv a1 s10
    mv a2 s11
    jal move_group
    # load output back
    mv s9 a0 
    mv s10 a1 
    mv s11 a2
    j move_return
    
right:
    mv a0 s5
    mv a1 s4
    mv a2 s3
    jal move_group
    # load output back
    mv s5 a0 
    mv s4 a1 
    mv s3 a2 
    
    mv a0 s8
    mv a1 s7
    mv a2 s6
    jal move_group
    # load output back
    mv s8 a0 
    mv s7 a1 
    mv s6 a2 

    mv a0 s11
    mv a1 s10
    mv a2 s9
    jal move_group
    # load output back
    mv s11 a0 
    mv s10 a1 
    mv s9 a2 
    j move_return

up:
    mv a0 s3
    mv a1 s6
    mv a2 s9
    jal move_group
    # load output back
    mv s3 a0 
    mv s6 a1 
    mv s9 a2 
    
    mv a0 s4
    mv a1 s7
    mv a2 s10
    jal move_group
    # load output back
    mv s4 a0 
    mv s7 a1 
    mv s10 a2 

    mv a0 s5
    mv a1 s8
    mv a2 s11
    jal move_group
    # load output back
    mv s5 a0 
    mv s8 a1 
    mv s11 a2 
    j move_return
    
down:
    mv a0 s9 
    mv a1 s6
    mv a2 s3
    jal move_group
    # load output back
    mv s9 a0 
    mv s6 a1 
    mv s3 a2 
    
    mv a0 s10
    mv a1 s7
    mv a2 s4
    jal move_group
    # load output back
    mv s10 a0 
    mv s7 a1 
    mv s4 a2 

    mv a0 s5
    mv a1 s8
    mv a2 s5
    jal move_group
    # load output back
    mv s11 a0 
    mv s8 a1 
    mv s5 a2 
    j move_return

    