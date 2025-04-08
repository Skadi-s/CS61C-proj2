.globl argmax

.text
# =================================================================
# FUNCTION: Given a int vector, return the index of the largest
#	element. If there are multiple, return the one
#	with the smallest index.
# Arguments:
# 	a0 (int*) is the pointer to the start of the vector
#	a1 (int)  is the # of elements in the vector
# Returns:
#	a0 (int)  is the first index of the largest element
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 77.
# =================================================================
argmax:
    # Check if vector length is less than 1
    li t0, 1
    blt a1, t0, error_exit  # If a1 < 1, exit with error

    # Initialize current_max_value to first element
    lw t1, 0(a0)        # t1 = current_max_value (a0[0])
    li t2, 0            # t2 = current_max_index (0)

    # Initialize loop counter (i) to 1
    li t0, 1            # t0 = i = 1

loop_start:
    bge t0, a1, loop_end  # If i >= a1, exit loop

    # Calculate address of a0[i]
    slli t3, t0, 2      # t3 = i * 4 (byte offset)
    add t3, a0, t3      # t3 = address of a0[i]
    lw t4, 0(t3)        # t4 = a0[i]

    # Compare with current_max_value
    ble t4, t1, loop_continue  # Skip if a0[i] <= current_max_value

    # Update current_max_value and index
    mv t1, t4           # Update current_max_value
    mv t2, t0           # Update current_max_index to i

loop_continue:
    addi t0, t0, 1      # i += 1
    j loop_start

loop_end:
    mv a0, t2           # Return the index in a0
    ret

error_exit:
    # Exit with error code 77
    li a0, 77
    li a7, 93           # Syscall exit code
    ecall
    