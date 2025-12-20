.text 

prologue:
    j main

mask:
    # ASSUMES ROW INPUT IS IN a0 REGISTER
    # ASSUMES OUTPUT USES REGISTERS s0, s1, s2
    addi sp sp -32
    sw ra 28(sp)
    sw s7 24(sp)
    sw s8 20(sp)
    
    li t0 3 # MAX NUMBER FOR INDEX
    li t1 0 # COUNTER FOR NUMBER INDEX IN COLUMN
    li t2 0b111111111000000000000000000000 # MASK, starts at rightmost number
    li t4 10 # CONSTANT FOR DETERMINING NUM OF BITS TO SHIFT 
    li t5 2 # COUNTER INVERSE OF T1
    li s7 1 # CONSTANT
    li s8 2 # CONSTANT
    
mask_loop:
    beq t0 t1 exit_mask
    addi t1 t1 1
    and t3 a0 t2 # AND(a0, mask)
    
    # need to parse t3
    # if leftmost column then need to shift by 20 bits
    # if middle column then need to shift by 10 bits
    # if last column then need to shift by 0 bits
    
    mul t6 t5 t4 # DETERMINES NUMBER OF BITS TO SHIFT FOR PARSING
    srl t3 t3 t6 # T3 NOW CONTAINS INT STORED IN THAT COLUMN
    srl t2 t2 t4 # SHIFTS MASK
    
    addi t5 t5 -1
    
    beq t1 s7 store_s0
    beq t1 s8 store_s1
    beq t1 t0 store_s2
    
store_s0: 
    mv s0 t3
    j mask_loop
store_s1: 
    mv s1 t3
    j mask_loop
store_s2: 
    mv s2 t3
    j mask_loop
    
exit_mask:
    lw ra 28(sp)
    lw s7 24(sp)
    lw s8 20(sp)
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
    li s0 0b000000100000000001000000000010
    li s1 0b000010000000000100000000100000
    li s2 0b010000000000100000000001000000
    
    jal update_LED_matrix
    jal reset_LED_matrix
    li a7 10
    ecall
    
# GREEN = #6ebd2d
# RED = #b03221
# YELLOW = #e0c122


reset_LED_matrix:
    addi sp sp -32
    sw ra 28(sp)
    li a0 LED_MATRIX_0_BASE
    li a1 LED_MATRIX_0_HEIGHT
    li a3 0 # COUNTER: COL
    li a4 0 # COLOR: BLACK
    
LED_loop: 
    bgt a3 a1 reset_LED_matrix_exit
    li a2 0 # COUNTER: ROW
    addi a3 a3 1
LED_inner_loop:    
    beq a2 a1 LED_loop
    sw a4 0(a0)
    addi a0 a0 4
    addi a2 a2 1
    j LED_inner_loop
    
    
    
reset_LED_matrix_exit:
    lw ra 28(sp)
    addi sp sp 32
    jalr ra


update_LED_matrix:
    addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    
    # FIRST ROW: s0
    mv a0 s0
    jal mask 
    # FIRST ROW ENTRIES: s0, s1, s2
    
    li a0 LED_MATRIX_0_BASE
    mv a2 s0
    jal print_pattern_LED
    mv a2 s1
    jal print_pattern_LED
    mv a2 s2
    jal print_pattern_LED
    
    # SECOND ROW: s1
    lw s1 20(sp)
    mv a0 s1
    jal mask
    #SECOND ROW ENTRIES: s0, s1, s2
    
    li a0 LED_MATRIX_0_BASE # RESET
    addi a0 a0 48 # NEXT ROW
    mv a2 s0
    jal print_pattern_LED
    mv a2 s1
    jal print_pattern_LED
    mv a2 s2 
    jal print_pattern_LED
    
    # THIRD ROW: s2
    lw s2 16(sp)
    mv a0 s2
    jal mask
    # THIRD ROW ENTRIES: s0, s1, s2
    
    li a0 LED_MATRIX_0_BASE # RESET
    addi a0 a0 96 # NEXT ROW
    mv a2 s0
    jal print_pattern_LED
    mv a2 s1
    jal print_pattern_LED
    mv a2 s2 
    jal print_pattern_LED
    
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    addi sp sp 32
    jalr ra


# ASSUMES a2 stores the number of the current cell
print_pattern_LED:
    addi sp sp -32
    sw ra 28(sp)
    
    beq a2 zero pattern_none
    
    li t0 2
    li a1 0xb03221 # RED
    beq a2 t0 pattern_one
    
    li t0 4
    beq a2 t0 pattern_two
    
    li t0 8
    beq a2 t0 pattern_three
    
    li t0 16
    beq a2 t0 pattern_four
    
    li a1 0x6ebd2d # GREEN
    li t0 32
    beq a2 t0 pattern_one
    
    li t0 64
    beq a2 t0 pattern_two
    
    li t0 128
    beq a2 t0 pattern_three
    
    li t0 256
    beq a2 t0 pattern_four
    
    li a1 0xe0c122 # YELLOW
    li t0 512
    beq a2 t0 pattern_four
    
print_pattern_LED_exit:
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    

# ASSUMES a0 STORES THE CURRENT LED INDEX 
# ASSUMES a1 STORES THE COLOR OF THE LED
pattern_none:
    addi a0 a0 8
    j print_pattern_LED_exit
    
pattern_one:
    sw a1 0(a0) # CHANGE COLOR OF LED
    addi a0 a0 8
    j print_pattern_LED_exit

pattern_two:
    sw a1 0(a0)
    addi a0 a0 28
    sw a1 0(a0)
    addi a0 a0 -24
    addi a0 a0 4
    j print_pattern_LED_exit
    
pattern_three:    
    sw a1 0(a0) # TOP LEFT
    addi a0 a0 28
    sw a1 0(a0) # BOTTOM RIGHT
    addi a0 a0 -24
    sw a1 0(a0) # TOP RIGHT
    addi a0 a0 4
    j print_pattern_LED_exit
    
pattern_four: 
    sw a1 0(a0) # TOP LEFT
    addi a0 a0 24
    sw a1 0(a0) # BOTTOM LEFT
    addi a0 a0 4 
    sw a1 0(a0) # BOTTOM RIGHT
    addi a0 a0 -24
    sw a1 0(a0) # TOP RIGHT
    addi a0 a0 4
    j print_pattern_LED_exit
    
