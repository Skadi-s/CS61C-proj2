.globl read_matrix

# ==============================================================================
# FUNCTION: Allocates memory and reads in a binary file as a matrix of integers
#
# FILE FORMAT:
#   The first 8 bytes are two 4 byte ints representing the # of rows and columns
#   in the matrix. Every 4 bytes afterwards is an element of the matrix in
#   row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is a pointer to an integer, we will set it to the number of rows
#   a2 (int*)  is a pointer to an integer, we will set it to the number of columns
# Returns:
#   a0 (int*)  is the pointer to the matrix in memory
# Exceptions:
# - If malloc returns an error,
#   this function terminates the program with error code 88.
# - If you receive an fopen error or eof, 
#   this function terminates the program with error code 90.
# - If you receive an fread error or eof,
#   this function terminates the program with error code 91.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 92.
# ==============================================================================
.text
read_matrix:
    # Prologue: Save caller-saved registers
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    # Save function arguments
    mv s0, a0        # Save filename pointer
    mv s1, a1        # Save pointer to store rows
    mv s2, a2        # Save pointer to store columns

    # Open file using fopen
    mv a1, s0        # Load filename into a1
    li a2, 0         # Mode "r" (read-only)
    jal fopen        # Call fopen
    mv s3, a0        # Save file descriptor in s3
    li t0, -1
    beq s3, t0, fopen_error  # If fopen fails, jump to error handler

    # Read the first 8 bytes (rows and columns)
    mv a1, s3        # File descriptor
    addi sp, sp, -8  # Allocate space for 8 bytes on the stack
    mv a2, sp        # Buffer pointer
    li a3, 8         # Number of bytes to read
    jal fread        # Call fread
    li t0, 8
    bne a0, t0, fread_error  # If fread fails, jump to error handler

    # Load rows and columns from the buffer
    lw t0, 4(sp)     # Load rows
    lw t1, 0(sp)     # Load columns
    addi sp, sp, 8   # Deallocate buffer space
    sw t0, 0(s1)     # Store rows in the provided pointer
    sw t1, 0(s2)     # Store columns in the provided pointer

    # Allocate memory for the matrix
    mul t0, t0, t1   # rows * columns
    slli s6, t0, 2   # Multiply by 4 (size of int)
    mv a0, s6        # Load size into a0
    jal malloc       # Call malloc
    beqz a0, malloc_error  # If malloc fails, jump to error handler
    mv s4, a0        # Save matrix pointer

    # Read matrix data into allocated memory
    mv a1, s3        # File descriptor
    mv a2, s4        # Buffer pointer (matrix memory)
    mv a3, s6        # Number of bytes to read
    jal fread        # Call fread
    bne a0, s6, fread_error  # If fread fails, jump to error handler

    # Close the file
    mv a1, s3        # File descriptor
    jal fclose       # Call fclose
    li t0, -1
    beq a0, t0, fclose_error  # If fclose fails, jump to error handler

    # Return the matrix pointer
    mv a0, s4

    # Epilogue: Restore caller-saved registers
    lw ra, 28(sp)
    lw s0, 24(sp)
    lw s1, 20(sp)
    lw s2, 16(sp)
    lw s3, 12(sp)
    lw s4, 8(sp)
    lw s5, 4(sp)
    lw s6, 0(sp)
    addi sp, sp, 32
    ret

# Error handlers
malloc_error:
    li a1, 88        # Error code for malloc failure
    jal exit2

fopen_error:
    li a1, 90        # Error code for fopen failure
    jal exit2

fread_error:
    li a1, 91        # Error code for fread failure
    jal exit2

fclose_error:
    li a1, 92        # Error code for fclose failure
    jal exit2
