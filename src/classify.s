.globl classify

.text
classify:
    # Prologue
    addi sp, sp, -40
    sw ra, 0(sp)
    sw s0, 4(sp)    # argc
    sw s1, 8(sp)    # argv
    sw s2, 12(sp)   # print flag
    sw s3, 16(sp)   # m0 pointer
    sw s4, 20(sp)   # m0 rows/cols
    sw s5, 24(sp)   # m1 pointer
    sw s6, 28(sp)   # m1 rows/cols
    sw s7, 32(sp)   # input pointer
    sw s8, 36(sp)   # input rows/cols

    mv s0, a0       # Save argc
    mv s1, a1       # Save argv
    mv s2, a2       # Save print flag

    # Check command line arguments
    li t0, 5
    bne s0, t0, argc_error

    # =====================================
    # LOAD MATRICES
    # =====================================

    # Load m0
    lw a0, 4(s1)            # M0_PATH
    la a1, m0_rows
    la a2, m0_cols
    jal ra, read_matrix
    mv s3, a0               # Save m0 pointer
    lw s4, m0_rows          # m0 rows
    lw t0, m0_cols          # m0 cols

    # Load m1
    lw a0, 8(s1)            # M1_PATH
    la a1, m1_rows
    la a2, m1_cols
    jal ra, read_matrix
    mv s5, a0               # Save m1 pointer
    lw t1, m1_rows          # m1 rows
    lw s6, m1_cols          # m1 cols

    # Verify m0 cols == m1 rows
    bne t0, t1, dim_error1

    # Load input
    lw a0, 12(s1)           # INPUT_PATH
    la a1, input_rows
    la a2, input_cols
    jal ra, read_matrix
    mv s7, a0               # Save input pointer
    lw t0, input_rows       # input rows
    lw t1, input_cols       # input cols

    # Verify input dimensions
    li t2, 1
    bne t1, t2, dim_error2

    # =====================================
    # RUN LAYERS
    # =====================================

    # Allocate hidden layer (m0_rows * input_cols)
    mul a0, s4, t1
    slli a0, a0, 2          # Multiply by 4 (int size)
    jal ra, malloc
    beqz a0, malloc_error
    mv t2, a0               # hidden_layer pointer

    # m0 * input
    mv a0, s3               # m0
    mv a1, s4               # m0_rows
    lw a2, m0_cols          # m0_cols
    mv a3, s7               # input
    lw a4, input_rows       # input_rows
    lw a5, input_cols       # input_cols
    mv a6, t2               # result
    jal ra, matmul

    # ReLU activation
    mv a0, t2
    mul a1, s4, t1          # num elements
    jal ra, relu

    # Allocate scores (m1_rows * input_cols)
    lw t0, m1_rows
    mul a0, t0, t1
    slli a0, a0, 2          # Multiply by 4
    jal ra, malloc
    beqz a0, malloc_error
    mv t3, a0               # scores pointer

    # m1 * hidden_layer
    mv a0, s5               # m1
    lw a1, m1_rows          # m1_rows
    mv a2, s6               # m1_cols
    mv a3, t2               # hidden_layer
    mv a4, s4               # hidden_layer rows
    mv a5, t1               # hidden_layer cols
    mv a6, t3               # result
    jal ra, matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    lw a0, 16(s1)           # OUTPUT_PATH
    mv a1, t3               # scores
    lw a2, m1_rows
    lw a3, input_cols
    jal ra, write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION
    # =====================================
    mv a0, t3
    lw t0, m1_rows
    lw t1, input_cols
    mul a1, t0, t1
    jal ra, argmax
    mv s9, a0               # Save classification

    # =====================================
    # FREE ALLOCATED MEMORY
    # =====================================
    mv a0, t2
    jal ra, free
    mv a0, t3
    jal ra, free
    mv a0, s3
    jal ra, free
    mv a0, s5
    jal ra, free
    mv a0, s7
    jal ra, free

    # Print classification if needed
    bnez s2, skip_print
    mv a0, s9
    jal ra, print_int
    li a0, '\n'
    jal ra, print_char

skip_print:
    mv a0, s9               # Return classification

    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    lw s6, 28(sp)
    lw s7, 32(sp)
    lw s8, 36(sp)
    addi sp, sp, 40
    ret

argc_error:
    li a1, 89
    j exit2_error

dim_error1:
    li a1, 72
    j exit2_error

dim_error2:
    li a1, 73
    j exit2_error

malloc_error:
    li a1, 88
    j exit2_error

exit2_error:
    # Free any allocated memory before exiting
    mv a0, s3
    beqz a0, 1f
    jal ra, free
1:
    mv a0, s5
    beqz a0, 2f
    jal ra, free
2:
    mv a0, s7
    beqz a0, 3f
    jal ra, free
3:
    mv a0, a1
    jal ra, exit2

# Data section for matrix dimensions
.data
m0_rows:  .word 0
m0_cols:  .word 0
m1_rows:  .word 0
m1_cols:  .word 0
input_rows: .word 0
input_cols: .word 0
