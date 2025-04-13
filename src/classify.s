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
    addi sp, sp, -48
    sw ra, 0(sp)
    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)
    sw s6, 28(sp)
    sw s7, 32(sp)
    sw s8, 36(sp)
    sw s9, 40(sp)
    sw s10, 44(sp)

    # Check if argc is equal to 5 (program name + 4 arguments)
    li t0, 5              # Load 5 into t0
    bne a0, t0, args_error   # If argc != 5, exit with code 89

    # save args pointer to s0
    mv s0, a1       # s0 save the argv
    mv s1, a2       # s1 save the print flag

	# =====================================
    # LOAD MATRICES
    # =====================================

    # Load pretrained m0
    li a0, 8
    jal malloc
    bnez a0, malloc_error
    mv s2, a0       # s2 save m0 rows and cols

    lw a0, 4(s0)    # argv[1] = m1_path
    lw a1, 0(s2)
    lw a2, 4(s2)
    jal read_matrix
    mv s3, a0       # s3 save m0 pointer

    # Load pretrained m1
    li a0, 8
    jal malloc
    bnez a0, malloc_error
    mv s4, a0       # s4 save m1 rows and cols

    lw a0, 8(s0)    # argv[2] = m1_path
    lw a1, 0(s4)
    lw a2, 4(s4)
    jal read_matrix
    mv s5, a0       # s5 save m1 pointer

    # Load input matrix
    li   a0, 8
    jal  malloc
    beqz a0, malloc_error
    mv   s6, a0        # s6 save input rows and cols

    lw   a1, 12(s0)    # argv[3] = input_path
    lw   a2, 0(s6)
    lw   a3, 4(s6)
    jal  read_matrix
    mv   s7, a0        # s7 save input matrix pointer

    # =====================================
    # RUN LAYERS
    # =====================================

    # allocate memory for layer
    lw   t0, 0(s2)     # m0_rows
    lw   t1, 4(s6)     # input_cols
    mul  a0, t0, t1    # item
    slli a0, a0, 2     # bytes  
    jal  malloc
    beqz a0, malloc_error
    mv   s8, a0       # s8 save the hidden_layer

    # 1. LINEAR LAYER:    m0 * input
    mv   a0, s3
    lw   a1, 0(s2)
    lw   a2, 4(s2)
    mv   a3, s7
    lw   a4, 0(s6)
    lw   a5, 4(s6)
    mv   a6, s8
    jal  matmul
    
    # 2. NONLINEAR LAYER: ReLU(m0 * input)
    lw   t0, 0(s2)     # m0_rows
    lw   t1, 4(s6)     # input_cols
    mul  a1, t0, t1    # items
    mv   a0, s8
    jal  relu

    # 3. LINEAR LAYER:    m1 * ReLU(m0 * input)
    lw   t0, 0(s4)     # m1_rows
    lw   t1, 4(s6)     # input_cols
    mul  a0, t0, t1
    slli a0, a0, 2
    jal  malloc
    beqz a0, malloc_error
    mv   s9, a0       # s9 save scores layer

    mv   a0, s5
    lw   a1, 0(s4)
    lw   a2, 4(s4)
    mv   a3, s8
    lw   a4, 0(s2)    # hidden_layer行数=m0_rows
    lw   a5, 4(s6)    # hidden_layer列数=input_cols
    mv   a6, s9
    jal  matmul

    # =====================================
    # WRITE OUTPUT
    # =====================================
    # Write output matrix
    lw   a0, 16(s0)     # argv[4] = output_path
    mv   a1, s9
    lw   a2, 0(s2)     # scores_rows = m1_rows
    lw   a3, 4(s6)     # scores_cols = input_cols
    jal  write_matrix

    # =====================================
    # CALCULATE CLASSIFICATION/LABEL
    # =====================================
    # Call argmax
    lw   t0, 0(s4)
    lw   t1, 4(s6)
    mul  a1, t0, t1    
    mv   a0, s9
    jal  argmax
    mv   s10, a0

    # Print classification
    bnez s1, skip_print
    mv   a0, s10
    jal  print_int

    # Print newline afterwards for clarity
    li   a0, '\n'
    jal  print_char

skip_print:
    mv   a0, s2
    jal  free
    mv   a0, s3
    jal free
    mv   a0, s4
    jal  free
    mv   a0, s5
    jal free
    mv   a0, s6
    jal free
    mv   a0, s7
    jal  free
    mv   a0, s8
    jal  free
    mv   a0, s9
    jal  free

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
    lw s9, 40(sp)
    lw s10, 44(sp)
    addi sp, sp, 48

    ret

args_error:
    li a1, 89
    jal exit2

malloc_error:
    li a1, 88
    jal exit2
