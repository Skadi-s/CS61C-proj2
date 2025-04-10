.globl read_matrix

.text
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
    # Prologue: 保存寄存器
    addi sp, sp, -24
    sw ra, 20(sp)
    sw s0, 16(sp)
    sw s1, 12(sp)
    sw s2, 8(sp)
    sw s3, 4(sp)
    sw s4, 0(sp)

    # 保存参数
    mv s0, a0        # 文件名指针
    mv s1, a1        # save row
    mv s2, a2        # save col

    # fopen
    mv a1, s0
    li a2, 0         # 模式字符串"r"
    jal fopen        # 调用fopen
    mv s3, a0        # 保存文件描述符 --> s3
    li t0, -1
    beq s3, t0, fopen_error

    # fread
    mv a1, s0
    addi sp, sp, -8
    mv a2, sp
    li a3, 8
    jal fread
    li t0, 8
    bne a0, t0, fread_error

    addi sp, sp, 8
    lw t0, -4(sp)
    lw t1, -8(sp)
    sw t0, 0(s1)
    sw t1, 0(s2)


    # malloc
    mul t0, s1, s1
    slli t0, 2
    mv a0, t0
    jal malloc
    beqz a0, malloc_error
    mv s4, a0
    mv a1, s3
    mv a2, s4
    mv a3, t0
    jal fread
    bne a0, t0, fread_error

    lw ra, 20(sp)
    lw s0, 16(sp)
    lw s1, 12(sp)
    lw s2, 8(sp)
    lw s3, 4(sp)
    lw s4, 0(sp)

    addi sp, sp, 24
    ret

malloc_error:
    li a1, 89
    jal exit2

fopen_error:
    li a1, 90
    jal exit2

fread_error:
    li a1, 91
    jal exit2

fclose_error:
    li a1, 92
    jal exit2
