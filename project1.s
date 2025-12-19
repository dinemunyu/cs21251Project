.data
buffer: .zero 4
row_border: .asciz "+---+---+---+\n"
column_border: .asciz "|"
#checkpoint: .asciz " 2 "
new_line: .asciz "\n"
game_over: .asciz "Game over."
empty_cell: .asciz "   "
space: .asciz " "

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

inner_main:
    jal read_input
    jal add
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
    j inner_main
end:    
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
    sw t0 24(sp)
    sw t1 20(sp)
    li t0 9
    li t1 99
    beq s4 zero print_row_entries_empty
    blt s4 t0 print_space_ones
    blt s4 t1 print_space_tens
    mv a0 s4
    li a7 1
    ecall
back:
    lw t1 20(sp)
    lw t0 24(sp)
    lw ra 28(sp)
    addi sp sp 32
    jalr ra

print_row_entries_empty:
    la a0 empty_cell
    li a7 4
    ecall
    j back

print_space_ones:
    la a0 space
    li a7 4 
    ecall
    mv a0 s4
    li a7 1
    ecall
    la a0 space
    li a7 4 
    ecall
    j back
    
print_space_tens:
    la a0 space
    li a7 4 
    ecall
    mv a0 s4
    li a7 1
    ecall
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
    
    la t0 buffer      
    lb t0 0(t0)       # DO NOT TOUCH!!!!
    li t1 0x77 # w
    li t2 0x61 # a
    li t3 0x73 # s
    li t4 0x64 # d     
    beq t0 t1 proceed
    beq t0 t2 proceed
    beq t0 t3 proceed
    beq t0 t4 proceed  
    j read_input  
proceed:
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
update_grid_state:
    # FOR GENERATING A "2" 
    # RULE: TOP LEFT MOST CELL MUNA
    # NEEDS TO KNOW THE CURRENT STATE
    
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
    lw s0 24(sp)
    mv a0 s0
    jal mask # MASK TAKES IN ao AS INPUT
    jal generate_2
    mv a4 s4      
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED
    
    addi s4 s4 1
    # ELSE, TRY NEXT ROW
    lw s1 20(sp)
    mv a0 s1 
    jal mask
    jal generate_2
    mv a4 s4     
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED
    
    addi s4 s4 1 
    #ELSE, TRY LAST ROW
    lw s2 16(sp)
    mv a0 s2
    jal mask
    jal generate_2
    mv a4 s4      
    bne s3 zero update_grid_state_exit # IF SUCCESSFULLY UPDATED
    
    addi s4 s4 1
    #ELSE, GRID IS FULL
    la a0 game_over
    li a7 4
    ecall
    li a7 10 
    ecall

update_grid_state_exit:
    jal reverse_mask
    lw ra 28(sp)
    lw s0 24(sp)
    lw s1 20(sp)
    lw s2 16(sp)
    lw s3 12(sp)
    lw s4 8(sp)
    lw s5 4(sp)
    lw s6 0(sp)
    addi sp sp 32
    # MOVE OUTPUT OF REVERSE_MASK TO AFFECTED ROW
    beq a4 zero update_row_0
    li t0 1
    beq a4 t0 update_row_1
    li t0 2
    beq a4 t0 update_row_2
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
    
    add a0 zero s2 # RIGHTMOST COLUMN
    slli s1 s1 10
    add a0 a0 s1 # MIDDLE COLUMN
    slli s0 s0 20
    add a0 a0 s0 # LEFTMOST COLUMN
    
    lw ra 28(sp)
    addi sp sp 32
    ret
    
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

add:
    addi sp sp -32
    sw ra 28(sp)
    mv a0 s0
    mv a1 s1
    mv a2 s2
    li a3 0
    jal move
    lw ra 28(sp)
    addi sp sp 32
    jalr ra
    
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
    li t1 0x77 # w
    li t2 0x61 # a
    li t3 0x73 # s
    li t4 0x64 # d     
    beq t0 t2 left
    beq t0 t4 right
    beq t0 t1 up
    beq t0 t3 down
    
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
    mv s0 t4
    mv s1 t5
    mv s2 t6
    jalr ra
    
move_group:
    beq a0 zero CASE_0
    beq a0 a1 CASE_1
    beq a1 zero CASE_2
    beq a1 a2 CASE_3
    # if it reaches this point, it does not need to update this row
    jalr ra
    
CASE_0:
    beq a1 zero CASE_0_1
    mv a0 a1
    mv a1 a2
    li a2 0
    jalr ra
    
CASE_0_1:
    mv a0 a2
    li a2 0
    jalr ra

CASE_1:
    add a0 a0 a1
    add a1 zero a2
    add a2 zero zero
    jalr ra
    
CASE_2:
    beq a0 a2 CASE_2_1
    add a1 zero a2
    add a2 zero zero
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

    mv a0 s11
    mv a1 s8
    mv a2 s5
    jal move_group
    # load output back
    mv s11 a0 
    mv s8 a1 
    mv s5 a2 
    j move_return