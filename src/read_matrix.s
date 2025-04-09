.include "utils.s"

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
read_matrix:
    # Prologue: 保存寄存器
    addi sp, sp, -32
    sw ra, 28(sp)
    sw s0, 24(sp)
    sw s1, 20(sp)
    sw s2, 16(sp)
    sw s3, 12(sp)
    sw s4, 8(sp)
    sw s5, 4(sp)
    sw s6, 0(sp)

    # 保存参数
    mv s0, a0        # 文件名指针
    mv s3, a1        # 行数指针
    mv s4, a2        # 列数指针

    # 打开文件
    mv a0, s0
    la a1, .L.str    # 模式字符串"r"
    jal fopen        # 调用fopen
    mv s5, a0        # 保存文件描述符
    li t0, -1
    beq s5, t0, fopen_error

    # 读取行和列
    addi sp, sp, -8  # 分配8字节缓冲区
    mv a1, s5        # 文件描述符
    mv a2, sp        # 缓冲区地址
    li a3, 2         # 读取2个元素
    li a4, 4         # 每个元素4字节
    jal fread        # 调用fread
    addi sp, sp, 8   # 恢复栈
    li t0, 2
    bne a0, t0, fread_error1

    lw s1, -8(sp)    # 读取行数
    lw s2, -4(sp)    # 读取列数

    # 分配内存
    mul t0, s1, s2   # 总元素数
    slli a0, t0, 2   # 总字节数
    jal malloc
    beq a0, zero, malloc_error
    mv s6, a0        # 保存矩阵指针

    # 读取矩阵数据
    mv a1, s5        # 文件描述符
    mv a2, s6        # 缓冲区地址
    mv a3, t0        # 元素个数
    li a4, 4         # 每个元素4字节
    jal fread
    bne a0, t0, fread_error2

    # 关闭文件
    mv a1, s5
    jal fclose
    bne a0, zero, fclose_error

    # 保存行和列到指针
    sw s1, 0(s3)
    sw s2, 0(s4)

    # 设置返回值
    mv a0, s6

    # Epilogue: 恢复寄存器
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

    # 错误处理部分
fopen_error:
    li a0, 90
    j exit2

fread_error1:
    mv a1, s5        # 关闭文件
    jal fclose
    li t0, 0
    bne a0, t0, fread_error1_fclose_fail
    li a0, 91
    j exit2

fread_error1_fclose_fail:
    li a0, 92
    j exit2

malloc_error:
    mv a1, s5        # 关闭文件
    jal fclose
    li t0, 0
    bne a0, t0, malloc_error_fclose_fail
    li a0, 88
    j exit2

malloc_error_fclose_fail:
    li a0, 92
    j exit2

fread_error2:
    mv a1, s5        # 关闭文件
    jal fclose
    li t0, 0
    bne a0, t0, fread_error2_fclose_fail
    li a0, 91
    j exit2

fread_error2_fclose_fail:
    li a0, 92
    j exit2

fclose_error:
    li a0, 92
    j exit2

.section .rodata
.L.str:
    .asciz "r"