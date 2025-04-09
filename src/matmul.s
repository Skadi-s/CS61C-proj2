.globl matmul

.text
# =======================================================
# FUNCTION: Matrix Multiplication of 2 integer matrices
# 	d = matmul(m0, m1)
# Arguments:
# 	a0 (int*)  is the pointer to the start of m0 
#	a1 (int)   is the # of rows (height) of m0
#	a2 (int)   is the # of columns (width) of m0
#	a3 (int*)  is the pointer to the start of m1
# 	a4 (int)   is the # of rows (height) of m1
#	a5 (int)   is the # of columns (width) of m1
#	a6 (int*)  is the pointer to the the start of d
# Returns:
#	None (void), sets d = matmul(m0, m1)
# Exceptions:
#   Make sure to check in top to bottom order!
#   - If the dimensions of m0 do not make sense,
#     this function terminates the program with exit code 72.
#   - If the dimensions of m1 do not make sense,
#     this function terminates the program with exit code 73.
#   - If the dimensions of m0 and m1 don't match,
#     this function terminates the program with exit code 74.
# =======================================================
matmul:
    # Error checks for m0 dimensions
    li t0, 1
    blt a1, t0, m0_error        # Check m0 rows >= 1
    blt a2, t0, m0_error        # Check m0 cols >= 1

    # Error checks for m1 dimensions
    blt a4, t0, m1_error        # Check m1 rows >= 1
    blt a5, t0, m1_error        # Check m1 cols >= 1

    # Check if m0 cols != m1 rows
    bne a2, a4, mismatch_error  # Check m0 cols == m1 rows

    # Prologue: save registers on the stack
    addi sp, sp, -28
    sw s0, 0(sp)
    sw s1, 4(sp)
    sw s2, 8(sp)
    sw s3, 12(sp)
    sw s4, 16(sp)
    sw s5, 20(sp)
    sw s6, 24(sp)

    # Save arguments in saved registers
    mv s0, a0   # m0 pointer
    mv s1, a1   # m0 rows
    mv s2, a2   # m0 cols
    mv s3, a3   # m1 pointer
    mv s4, a4   # m1 rows (unused after check)
    mv s5, a5   # m1 cols
    mv s6, a6   # d pointer

    # Initialize outer loop counter (i)
    li t0, 0

outer_loop_start:
    bge t0, s1, outer_loop_end  # Exit if i >= m0 rows

    # Initialize middle loop counter (j)
    li t1, 0

middle_loop_start:
    bge t1, s5, middle_loop_end  # Exit if j >= m1 cols

    # Initialize sum and inner loop counter (k)
    li t3, 0    # sum = 0
    li t2, 0    # k = 0

inner_loop_start:
    bge t2, s2, inner_loop_end  # Exit if k >= m0 cols

    # Calculate address of m0[i][k]
    mul t4, t0, s2      # i * m0 cols
    add t4, t4, t2      # + k
    slli t4, t4, 2      # Convert to byte offset
    add t4, s0, t4      # m0 + byte offset
    lw t5, 0(t4)        # Load m0[i][k]

    # Calculate address of m1[k][j]
    mul t6, t2, s5      # k * m1 cols
    add t6, t6, t1      # + j
    slli t6, t6, 2      # Convert to byte offset
    add t6, s3, t6      # m1 + byte offset
    lw t6, 0(t6)        # Load m1[k][j]

    # Multiply and accumulate
    mul t5, t5, t6
    add t3, t3, t5

    addi t2, t2, 1      # k++
    j inner_loop_start

inner_loop_end:
    # Store result in d[i][j]
    mul t4, t0, s5      # i * m1 cols
    add t4, t4, t1      # + j
    slli t4, t4, 2      # Convert to byte offset
    add t4, s6, t4      # d + byte offset
    sw t3, 0(t4)        # Store sum

    addi t1, t1, 1      # j++
    j middle_loop_start

middle_loop_end:
    addi t0, t0, 1      # i++
    j outer_loop_start

outer_loop_end:
    # Epilogue: restore registers
    lw s0, 0(sp)
    lw s1, 4(sp)
    lw s2, 8(sp)
    lw s3, 12(sp)
    lw s4, 16(sp)
    lw s5, 20(sp)
    lw s6, 24(sp)
    addi sp, sp, 28
    ret

m0_error:
    li a0, 72
    li a7, 93
    ecall

m1_error:
    li a0, 73
    li a7, 93
    ecall

mismatch_error:
    li a0, 74
    li a7, 93
    ecall
