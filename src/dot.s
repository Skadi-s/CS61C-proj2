.globl dot

.text
# =======================================================
# FUNCTION: Dot product of 2 int vectors
# Arguments:
#   a0 (int*) is the pointer to the start of v0
#   a1 (int*) is the pointer to the start of v1
#   a2 (int)  is the length of the vectors
#   a3 (int)  is the stride of v0
#   a4 (int)  is the stride of v1
# Returns:
#   a0 (int)  is the dot product of v0 and v1
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 75.
# - If the stride of either vector is less than 1,
#   this function terminates the program with error code 76.
# =======================================================
dot:
    # Check for invalid length (a2 < 1)
    li t0, 1
    
    blt a2, t0, error_length  # Check length first
    blt a3, t0, error_stride   # Then check stride0
    blt a4, t0, error_stride   # Finally check stride1

    # Initialize sum and loop counter
    li t6, 0            # t6 = sum
    li t0, 0            # t0 = loop index (i)

loop_start:
    bge t0, a2, loop_end  # Exit loop when all elements processed

    # Calculate v0 element address
    mul t1, t0, a3      # t1 = i * stride0
    slli t1, t1, 2      # Convert to byte offset
    add t2, a0, t1      # t2 = &v0[i*stride0]
    lw t3, 0(t2)        # t3 = v0 element value

    # Calculate v1 element address
    mul t1, t0, a4      # t1 = i * stride1
    slli t1, t1, 2      # Convert to byte offset
    add t2, a1, t1      # t2 = &v1[i*stride1]
    lw t4, 0(t2)        # t4 = v1 element value

    # Accumulate product
    mul t5, t3, t4      # Multiply elements
    add t6, t6, t5      # Add to sum

    addi t0, t0, 1      # Increment loop counter
    j loop_start

loop_end:
    mv a0, t6           # Return sum in a0
    ret

error_length:
    li a0, 75           # Load error code 75
    li a7, 93           # Exit syscall
    ecall

error_stride:
    li a0, 76           # Load error code 76
    li a7, 93           # Exit syscall
    ecall
