.globl write_matrix

.text
# ==============================================================================
# FUNCTION: Writes a matrix of integers into a binary file
# FILE FORMAT:
#   The first 8 bytes of the file will be two 4 byte ints representing the
#   numbers of rows and columns respectively. Every 4 bytes thereafter is an
#   element of the matrix in row-major order.
# Arguments:
#   a0 (char*) is the pointer to string representing the filename
#   a1 (int*)  is the pointer to the start of the matrix in memory
#   a2 (int)   is the number of rows in the matrix
#   a3 (int)   is the number of columns in the matrix
# Returns:
#   None
# Exceptions:
# - If you receive an fopen error or eof,
#   this function terminates the program with error code 93.
# - If you receive an fwrite error or eof,
#   this function terminates the program with error code 94.
# - If you receive an fclose error or eof,
#   this function terminates the program with error code 95.
# ==============================================================================
write_matrix:
    # Prologue
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)

    mv s0, a0   # Save filename pointer
    mv s1, a1   # Save matrix pointer
    mv s2, a2   # Save rows
    mv s3, a3   # Save cols

    # Open file
    li a1, 1    # 'w' mode (encoded as 1 for simplicity)
    jal fopen
    li t0, -1
    beq a0, t0, fopen_error
    mv s4, a0   # Save file descriptor

    # Write dimensions
    addi sp, sp, -8
    sw s2, 0(sp)
    sw s3, 4(sp)
    mv a1, s4
    mv a2, sp
    li a3, 2
    li a4, 4
    jal fwrite
    addi sp, sp, 8

    li t0, 2
    bne a0, t0, fwrite_dims_error

    # Write matrix data
    mv a1, s4
    mv a2, s1
    mul a3, s2, s3
    li a4, 4
    jal fwrite

    mul t0, s2, s3
    bne a0, t0, fwrite_data_error

    # Close file
    mv a1, s4
    jal fclose
    li t0, 0
    bne a0, t0, fclose_error

    # Epilogue
    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)
    addi sp, sp, 24
    ret

fopen_error:
    li a1, 93
    jal exit2

fwrite_dims_error:
    li a1, 94
    jal exit2

fwrite_data_error:
    li a1, 94
    jal exit2

fclose_error:
    li a1, 95
    jal exit2