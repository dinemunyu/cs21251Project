.data
buffer: .zero 4
row_border: .asciz "+---+---+---+\n"
column_border: .asciz "|"
checkpoint: .asciz " 2 "
new_line: .asciz "\n"
game_over: .asciz "Game over."
empty_cell: .asciz "   "

.text

prologue: 
    j main

print_row_border: 
    addi sp sp -32
    sw ra 28(sp)
    
    la a0 row_border
    li a7 4 
    ecall
    
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
print_column_border:
    addi sp sp -32
    sw ra 28(sp)
    
    la a0 column_border
    li a7 4
    ecall
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
mask:
    # ASSUMES ROW INPUT IS IN a0 REGISTER
    # ASSUMES OUTPUT USES REGISTERS s0, s1, s2
    addi sp sp -32
    sw ra 28(sp)
    sw s7 24(sp)
    sw s8 20(sp)
    
    li t0 3 # MAX NUMBER FOR INDEX
    li t1 0 # COUNTER FOR NUMBER INDEX IN COLUMN
    li t2 0b111111111100000000000000000000 # MASK, starts at rightmost number
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
    li s0 0b000000000000000000000000000000
    li s1 0b000000000000000000000000000000
    li s2 0b000000000000000000000000000000

    li s9 0
    jal update_grid_state
    jal print_row_border
    mv a0 s0
    jal print_row_entries
    
    jal print_row_border
    mv a0 s1
    jal print_row_entries
    
    jal print_row_border
    mv a0 s2
    jal print_row_entries
    jal print_row_border
    
    li a7 10
    ecall

#######################
print_row_entries:
    # ASSUMES INPUT A0
    addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s4 12(sp)
    
    jal mask
    # OUTPUT IN S0, S1, S2
    
    jal print_column_border
    
    mv s4 s0
    jal print_row_entry
    
    jal print_column_border
    
    mv s4 s1
    jal print_row_entry
    
    jal print_column_border
    
    mv s4 s2
    jal print_row_entry
    
    jal print_column_border
    
    la a0 new_line
    li a7 4
    ecall
    
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s4 12(sp)
    
    addi sp sp 32
    jalr ra

print_row_entry:
    addi sp sp -32
    sw ra 28(sp)
    bne s4 zero print_row_entries_2 
    beq s4 zero print_row_entries_empty
back: li a7 4
    ecall
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra

print_row_entries_2:
     la a0 checkpoint
     j back
print_row_entries_empty:
    la a0 empty_cell
    j back

##########################
read_input:
    addi sp sp -32
    sw ra 28(sp)
    
    li a7 63
    li a0 0
    la a1 buffer 
    # USER INPUT IS STORED IN ADDRESS BUFFER
    li a2 30
    ecall
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
update_grid_state:
    # FOR GENERATING A "2" 
    # RULE: TOP LEFT MOST CELL MUNA
    # NEEDS TO KNOW THE CURRENT STATE
    
    mv a0 s0
    
    addi sp sp -32
    sw ra 28(sp)
    sw s0 24(sp)
    sw s1 20(sp)
    sw s2 16(sp)
    sw s3 12(sp)
    sw s4 8(sp)
    sw s5 4(sp)
    sw s6 0(sp)
    
    li s4 0 # ROW COUNTER
    li s5 1 # CONSTANT
    li s6 2 # CONSTANT
    jal mask # MASK TAKES IN ao AS INPUT
    # OUTPUT IS STORED IN s0, s1, s2
    jal generate_2
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED 
    
    addi s4 s4 1
    # ELSE, TRY NEXT ROW
    lw s1 20(sp)
    mv a0 s1 
    jal mask
    jal generate_2
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED 
    
    addi s4 s4 1 
    #ELSE, TRY LAST ROW
    lw s2 16(sp)
    mv a0 s2
    jal mask
    jal generate_2
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED 
    
    addi s4 s4 1
    #ELSE, GRID IS FULL
    la a0 game_over
    li a7 4
    ecall
    

update_grid_state_exit:
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s3 12(sp)
    lw s4 8(sp)
    lw s5 4(sp)
    lw s6 0(sp)
    addi sp sp 32

    jal reverse_mask
    # MOVE OUTPUT OF REVERSE_MASK TO AFFECTED ROW
    beq a4 zero update_row_0
    beq a4 s5 update_row_1
    beq a4 s6 update_row_2
    jalr ra
    
update_back:    jr ra

update_row_0:
    mv s0 a0
    j update_back
    
update_row_1:
    mv s1 a0
    j update_back
    
update_row_2:
    mv s2 a0
    j update_back

generate_2:
    addi sp sp -32
    sw ra 28(sp)
    li s3 0 # SETS S3 TO FALSE
    
    beq s0 zero put_2_s0
    beq s1 zero put_2_s1
    beq s2 zero put_2_s2
gen_2_exit:
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
put_2_s0:
    li s0 2
    li s3 1 # SETS S3 TO TRUE
    j gen_2_exit

put_2_s1:
    li s1 2
    li s3 1 # SETS S3 TO TRUE
    j gen_2_exit

put_2_s2:
    li s2 2
    li s3 1 # SETS S3 TO TRUE
    j gen_2_exit
    
reverse_mask:
    # ASSUMES INPUT IS IN S0, S1, S2
    # ASSUMES OUTPUT IS IN a0
    addi sp sp -32
    sw ra 28(sp)
    
    add a0 a0 s2 # RIGHTMOST COLUMN
    slli s1 s1 10
    add a0 a0 s1 # MIDDLE COLUMN
    slli s0 s0 20
    add a0 a0 s0 # LEFTMOST COLUMN
    
    lw ra 28(sp)
    addi sp sp 32
    jalr ra

    