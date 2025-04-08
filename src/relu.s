.globl relu

.text
# ==============================================================================
# FUNCTION: Performs an inplace element-wise ReLU on an array of ints
# Arguments:
# 	a0 (int*) is the pointer to the array
#	a1 (int)  is the # of elements in the array
# Returns:
#	None
# Exceptions:
# - If the length of the vector is less than 1,
#   this function terminates the program with error code 78.
# ==============================================================================
relu:
    # Check if the number of elements is <= 0
    li t0, 0
    bge t0, a1, error_exit  # If a1 <= 0, jump to error_exit

    # Initialize loop index (t0) to 0
    li t0, 0

loop_start:
    # Check if all elements are processed
    bge t0, a1, loop_end

    # Calculate address of current element
    slli t1, t0, 2       # t1 = t0 * 4 (byte offset)
    add t1, a0, t1       # t1 = base address + offset

    # Load current element and apply ReLU
    lw t2, 0(t1)         # t2 = current element value
    bge t2, zero, skip_set_zero  # Skip if element is non-negative
    li t2, 0             # Set element to 0 if negative

skip_set_zero:
    sw t2, 0(t1)         # Store the value back to memory

    # Increment loop index
    addi t0, t0, 1
    j loop_start

loop_end:
    ret

error_exit:
    # Exit with error code 78
    li a0, 78            # Load exit code 78 into a0
    li a7, 93            # Load exit syscall code into a7
    ecall
    