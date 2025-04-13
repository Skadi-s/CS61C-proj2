.globl classify

.text
classify:
    # =====================================
    # COMMAND LINE ARGUMENTS
    # =====================================
    # Args:
    #   a0 (int)    argc
    #   a1 (char**) argv
    #   a2 (int)    print_classification, if this is zero, 
    #               you should print the classification. Otherwise,
    #               this function should not print ANYTHING.
    # Returns:
    #   a0 (int)    Classification
    # Exceptions:
    # - If there are an incorrect number of command line args,
    #   this function terminates the program with exit code 89.
    # - If malloc fails, this function terminats the program with exit code 88.
    #
    # Usage:
    #   main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>

    # Save registers that will be used
    addi sp, sp, -40
    sw   ra, 0(sp)
    sw   s0, 4(sp)    # argv
    sw   s1, 8(sp)    # m0_ptr
    sw   s2, 12(sp)   # m0_rows
    sw   s3, 16(sp)   # m0_cols
    sw   s4, 20(sp)   # m1_ptr
    sw   s5, 24(sp)   # m1_rows
    sw   s6, 28(sp)   # m1_cols
    sw   s7, 32(sp)   # input_ptr
    sw   s8, 36(sp)   # input_rows, input_cols

    # Check if argc is equal to 5 (program name + 4 arguments)
    li t0, 5              # Load 5 into t0
    bne a0, t0, args_error   # If argc != 5, exit with code 89

    # save args pointer to s0
    mv s0, a1
    mv t2, a2

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    li a0, 8
    jal malloc
    bnez a0, malloc_error
    mv s2, a0       # save m0 rows
    addi s3, a0, 4   # save m0 cols

    lw a0, 4(s0)
    mv a1, s2
    mv a2, s3
    jal read_matrix
    mv s1, a0       # save m0 pointer

    # Load pretrained m1
    li a0, 8
    jal malloc
    bnez a0, malloc_error
    mv s5, a0       # save m1 rows
    addi s6, a0, 4   # save m1 cols

    lw a0, 8(s0)
    mv a1, s5
    mv a2, s6
    jal read_matrix
    mv s4, a0       # save m1 pointer

    # Load input matrix
    li   a0, 8
    jal  malloc
    beqz a0, malloc_error
    mv   s7, a0        # save input rows
    addi s8, a0, 4     # save input cols

    lw   a1, 12(s0)    # argv[3] = input_path
    mv   a2, s7
    mv   a3, s8
    jal  read_matrix
    mv   s9, a0        # save input matrix pointer

    # =====================================
    # RUN LAYERS
    # =====================================

    # allocate memory for layer
    lw   t0, 0(s2)     # m0_rows
    lw   t1, 0(s8)     # input_cols
    mul  a0, t0, t1    # item
    slli a0, a0, 2     # bytes  
    jal  malloc
    beqz a0, malloc_error
    mv   s10, a0       # s10 save the hidden_layer

    # 1. LINEAR LAYER:    m0 * input
    mv   a0, s1
    lw   a1, 0(s2)
    lw   a2, 0(s3)
    mv   a3, s9
    lw   a4, 0(s7)
    lw   a5, 0(s8)
    mv   a6, s10
    jal  matmul
    
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    lw   t0, 0(s2)     # m0_rows
    lw   t1, 0(s8)     # input_cols
    mul  a1, t0, t1    # items
    mv   a0, s10
    jal  relu

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw   t0, 0(s5)     # m1_rows
    lw   t1, 0(s8)     # input_cols
    mul  a0, t0, t1
    slli a0, a0, 2
    jal  malloc
    beqz a0, malloc_error
    mv   s11, a0       # s11 save scores layer

    mv   a0, s4
    lw   a1, 0(s5)
    lw   a2, 0(s6)
    mv   a3, s10
    lw   a4, 0(s2)    # hidden_layer行数=m0_rows
    lw   a5, 0(s8)    # hidden_layer列数=input_cols
    mv   a6, s11
    jal  matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw   a0, 16(s0)     # argv[4] = output_path
    mv   a1, s11
    lw   a2, 0(s5)     # scores_rows = m1_rows
    lw   a3, 0(s8)     # scores_cols = input_cols
    jal  write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw   t0, 0(s5)
    lw   t1, 0(s8)
    mul  a1, t0, t1    
    mv   a0, s11
    jal  argmax
    mv   t3, a0

    # Print classification
    bnez t2, skip_print
    mv   a0, t3
    jal  print_int


    # Print newline afterwards for clarity
    li   a0, '\n'
    jal  print_char

skip_print:
    mv   a0, s1
    jal  free
    mv   a0, s2
    jal free
    mv   a0, s4
    jal  free
    mv   a0, s5
    jal free
    mv   a0, s7
    jal free
    mv   a0, s9
    jal  free
    mv   a0, s10
    jal  free
    mv   a0, s11
    jal  free

    # Epilogue
    li   a0, 0         # 返回0表示成功
    lw   ra, 0(sp)
    lw   s0, 4(sp)    # argv
    lw   s1, 8(sp)    # m0_ptr
    lw   s2, 12(sp)   # m0_rows
    lw   s3, 16(sp)   # m0_cols
    lw   s4, 20(sp)   # m1_ptr
    lw   s5, 24(sp)   # m1_rows
    lw   s6, 28(sp)   # m1_cols
    lw   s7, 32(sp)   # input_ptr
    lw   s8, 36(sp)   # input_rows, input_cols
    addi sp, sp, 40

    ret

args_error:
    li a1, 89
    jal exit2

malloc_error:
    li a1, 88
    jal exit2
