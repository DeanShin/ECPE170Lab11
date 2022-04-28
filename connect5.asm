	# Declare main as a global function
	.globl main 

	# All program code is placed after the
	# .text assembler directive
	.text 		

# get_random function
# Arguments: None
# Return value: $v0
#-------------------------------------------------------------------
get_random:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $s1,0($sp)		# Save $s1
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s2,0($sp)		# Save $s2
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $s3,0($sp)		# Save $s3
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s4,0($sp)		# Save $s4

    # Initialize variables
    la $s0, m_z     # s0 = address of m_z
    la $s1, m_w     # s1 = address of m_w
    lw $s2, 0($s0)  # s2 = m_z
    lw $s3, 0($s1)  # s3 = m_w
    li $s4, 0       # s4 = result

    # m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    li $t0, 65535       # t0 = 65535
    and $t0, $s2, $t0   # t0 = m_z & 65535
    li $t1, 36969       # t1 = 36969
    mul $t0, $t1, $t0   # t0 = 36969 * (m_z & 65535)
    srl $t1, $s2, 16    # t1 = m_z >> 16
    addu $s2, $t0, $t1   # m_z = 36969 * (m_z & 65535) + (m_z >> 16)
    sw $s2, 0($s0)      # Store m_z in memory

    # m_w = 36969 * (m_w & 65535) + (m_w >> 16);
    li $t0, 65535       # t0 = 65535
    and $t0, $s3, $t0   # t0 = m_w & 65535
    li $t1, 18000       # t1 = 18000
    mul $t0, $t1, $t0   # t0 = 18000 * (m_w & 65535)
    srl $t1, $s3, 16    # t1 = m_w >> 16
    addu $s3, $t0, $t1   # m_w = 18000 * (m_w & 65535) + (m_w >> 16)
    sw $s3, 0($s1)      # Store m_w in memory

    # result = (m_z << 16) + m_w
    sll $t0, $s2, 16    # t0 = m_z << 16
    addu $s4, $t0, $s3   # result = (m_z << 16) + m_w
    move $v0, $s4       # save result in v0

    # Pop from stack
    lw $s4,0($sp)		# Restore $s4
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s3,0($sp)		# Restore $s3
	addi $sp,$sp,4		# Adjust stack pointer
	lw $s2,0($sp)		# Restore $s2
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
	lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra              # Jump to address stored in $ra



# random_in_range function
# Arguments: a0 = low, a1 = high
# Return value: $v0
#-------------------------------------------------------------------
random_in_range:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $s1,0($sp)		# Save $s1
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra

    # Variable mapping:
    # s0 = range
    # s1 = rand_num
    
    # uint32_t range = high-low+1;
    sub $t0, $a1, $a0   # t0 = high - low
    addi $s0, $t0, 1    # range = high - low + 1

    # uint32_t rand_num = get_random();

    # Before calling get_random(), save $a0 = low onto the stack.
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $a0,0($sp)		# Save $s0

    jal get_random      # Call the get_random function

    # Pop $a0 = low from the stack
    lw $a0,0($sp)		# Restore $a0
	addi $sp,$sp,4		# Adjust stack pointer

    move $s1, $v0       # rand_num = get_random();

    # return (rand_num % range) + low
    divu $s1, $s0        # hi = rand_num % range
    mfhi $t0            # t0 = rand_num % range
    addu $v0, $t0, $a0   # Save (rand_num % range) + low in v0.

    # Pop from stack
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
	lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra



# printBoard function
# Arguments: None
# Return value: None
#-------------------------------------------------------------------
printBoard:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s1,0($sp)		# Save $s1

    # Print "  1 2 3 4 5 6 7\n"
    la $a0, printBoardMsg1  # load address of msg1
    li $v0, 4               # select print_string
    syscall                 # print
    # Print "-----------------\n"
    la $a0, printBoardMsg2  # load address of msg2
    li $v0, 4               # select print_string
    syscall                 # print

    # Mapping: 
    # s0 = row
    # s1 = col
    li $s0, 0 # row = 0
    PRINT_BOARD_FOR_1_START:    # mark start of for loop
        # row < 6
        li $t0, 6 # t0 = 6
        bge $s0, $t0, PRINT_BOARD_FOR_1_END # if row >= 6, exit for loop

        li $s1, 0 # col = 0
        PRINT_BOARD_FOR_2_START:    # mark start of for loop
            # col < 9
            li $t0, 9   # t0 = 9
            bge $s1, $t0, PRINT_BOARD_FOR_2_END # if row >= 9, exit for loop

            # t0 = row * 9 + col
            li $t0, 9           # t0 = 9
            mul $t0, $s0, $t0   # t0 = 9 * row
            add $t0, $t0, $s1   # t0 = 9 * row + col
            # t0 = board[row][col]
            la $t1, board       # t1 = board
            add $t0, $t0, $t1   # t0 = &board[row][col]
            lb $t0, 0($t0)      # t0 = board[row][col]
            # Print board[row][col]
            move $a0, $t0       # prepare board[row][col] for printing
            li $v0, 11          # select print_char
            syscall             # print

            # Print " "
            la $a0, printBoardMsg3  # load address of msg3
            li $v0, 4               # select print_string
            syscall                 # print

            addi $s1, $s1, 1    # col++
            j PRINT_BOARD_FOR_2_START # go back to top of for loop
        PRINT_BOARD_FOR_2_END:      # mark end of for loop

        # Print "\n"
        la $a0, printBoardMsg4  # load address of msg4
        li $v0, 4               # select print_string
        syscall                 # print

        addi $s0, $s0, 1    # row++
        j PRINT_BOARD_FOR_1_START   # go back to top of for loop
    PRINT_BOARD_FOR_1_END:      # mark end of for loop

    # Print "-----------------\n"
    la $a0, printBoardMsg2  # load address of msg2
    li $v0, 4               # select print_string
    syscall                 # print 

    # Pop from stack
    lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra  # return

# validMove function
# Arguments: a0 = col
# Return value: v0 = 0 (invalid move), 1 (valid move)
#-------------------------------------------------------------------
validMove:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra

    # col < 0
    li $t0, 0   # t0 = 0
    blt $a0, $t0, VALID_MOVE_IF_1   # if col < 0, go into if statement
    # col >= 9
    li $t0, 9   # t0 = 9
    bge $a0, $t0, VALID_MOVE_IF_1   # if col >= 9, go into if statement
    j VALID_MOVE_IF_END_1   # otherwise, do not go into if statement
    VALID_MOVE_IF_1:        # start of if
        # Return false
        li $v0, 0           # set 0/false as return value
        j VALID_MOVE_RETURN # return
    VALID_MOVE_IF_END_1:    # end of if

    # board[0][col] != '.'
    # t0 = board[0][col]
    la $t1, board       # t1 = board
    add $t0, $a0, $t1   # t0 = &board[0][col]
    lb $t0, 0($t0)      # t0 = board[0][col]

    li $t1, 46 # t1 = ascii for '.'
    bne $t0, $t1, VALID_MOVE_IF_2   # if board[0][col] != '.', go into if statement.
    j VALID_MOVE_IF_END_2           # otherwise, do not go into if statement.

    VALID_MOVE_IF_2:        # start of if
        # Return false
        li $v0, 0           # set 0/false as return value
        j VALID_MOVE_RETURN # return
    VALID_MOVE_IF_END_2:    # end of if

    # Return true
    li $v0, 1           # set 1/true as return value
    j VALID_MOVE_RETURN # return
    VALID_MOVE_RETURN:
    # Pop from stack
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra

# placeMove function
# Arguments: a0 = col, a1 = token
# Return value: None
#-------------------------------------------------------------------
placeMove:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0

    # Mapping: 
    # s0 = i
    li $s0, 5 # i = 5
    PLACE_MOVE_FOR_1_START: # start of for
        # i >= 0
        li $t0, 0   # t0 = 0
        blt $s0, $t0, PLACE_MOVE_FOR_1_END # if i < 0, exit for loop

        # t0 = row * 9 + col
        li $t0, 9   # t0 = 9
        mul $t0, $s0, $t0   # t0 = row * 9
        add $t0, $t0, $a0   # t0 = row * 9 + col
        # t0 = &board[row][col]
        la $t1, board       # t1 = board
        add $t0, $t0, $t1   # t0 = &board[row][col]
        # t1 = board[row][col]
        lb $t1, 0($t0)

        # board[row][col] == '.'
        li $t2, 46 # t2 = ascii for '.'
        beq $t1, $t2, PLACE_MOVE_IF_1   # if board[row][col] == '.', then go into if statement
        j PLACE_MOVE_IF_1_END           # otherwise, skip if statement.
        PLACE_MOVE_IF_1:    # start of if
            sb $a1, 0($t0)  # board[row][col] = token
            j PLACE_MOVE_FOR_1_END  # break
        PLACE_MOVE_IF_1_END:    # end of if

        addi $s0, $s0, -1    # i--
        j PLACE_MOVE_FOR_1_START    # jump back to start of for loop
    PLACE_MOVE_FOR_1_END:   # end of for

    # Pop from stack
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra  # return

# checkWin function
# Arguments: a0 = token
# Return value: v0 = 0 (not won), 1 (won)
#-------------------------------------------------------------------
checkWin:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s1,0($sp)		# Save $s1
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s2,0($sp)		# Save $s2
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s3,0($sp)		# Save $s3
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s4,0($sp)		# Save $s4
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s5,0($sp)		# Save $s5

    # Mapping: 
    # s0 = row
    # s1 = col
    # s2 = k
    # s3 = newRow
    # s4 = newCol
    # s5 = l
    li $s0, 0 # row = 0
    CHECK_WIN_FOR_1_START:  # for start
        # row < 6
        li $t0, 6   # t0 = 6
        bge $s0, $t0, CHECK_WIN_FOR_1_END   # if row >= 6, exit for

        li $s1, 0 # col = 0
        CHECK_WIN_FOR_2_START: # for start
            # col < 9
            li $t0, 9   # t0 = 9
            bge $s1, $t0, CHECK_WIN_FOR_2_END   # if col >= 9, exit for

            li $s2, 0 # k = 0
            CHECK_WIN_FOR_3_START: # for start
                # k < 4
                li $t0, 4   # t0 = 4
                bge $s2, $t0, CHECK_WIN_FOR_3_END   # if k >= 4, exit for
            
                move $s3, $s0 # int newRow = row
                move $s4, $s1 # int newCol = col
                li $s5, 0     # l = 0
                CHECK_WIN_WHILE_START: # while start
                    # newRow >= 0
                    li $t0, 0   # t0 = 0
                    blt $s3, $t0, CHECK_WIN_WHILE_END   # if newRow < 0, exit while
                    # newRow < 6
                    li $t0, 6   # t0 = 6
                    bge $s3, $t0, CHECK_WIN_WHILE_END   # if newRow >= 6, exit while
                    # newCol >= 0
                    li $t0, 0   # t0 = 0
                    blt $s4, $t0, CHECK_WIN_WHILE_END   # if newCol < 0, exit while
                    # newCol < 9
                    li $t0, 9   # t0 = 9
                    bge $s4, $t0, CHECK_WIN_WHILE_END   # if newCol >= 9, exit while
                    
                    # board[newRow][newCol] == token
                    
                    li $t0, 9   # t0 = 9
                    mul $t0, $t0, $s3   # t0 = newRow * 9
                    add $t0, $t0, $s4   # t0 = newRow * 9 + col
                    la $t1, board       # t1 = board
                    add $t0, $t0, $t1   # t0 = &board[newRow][newCol]
                    lb $t0, 0($t0)      # t0 = board[newRow][newCol]
                    bne $t0, $a0, CHECK_WIN_WHILE_END   # if board[newRow][newCol] != token, exit while loop

                    # newRow += rowOffsets[k]
                    li $t0, 4           # t0 = 4
                    mul $t0, $t0, $s2   # t0 = k * 4
                    la $t1, rowOffsets  # t1 = rowOffsets
                    add $t0, $t0, $t1   # t0 = &rowOffsets[k]
                    lw $t0, 0($t0)      # t0 = rowOffsets[k]
                    add $s3, $s3, $t0   # newRow += rowOffsets[k]
                    
                    # newRow += colOffsets[k]
                    li $t0, 4           # t0 = 4
                    mul $t0, $t0, $s2   # t0 = k * 4
                    la $t1, colOffsets  # t1 = colOffsets
                    add $t0, $t0, $t1   # t0 = &colOffsets[k]
                    lw $t0, 0($t0)      # t0 = colOffsets[k]
                    add $s4, $s4, $t0   # newCol = colOffsets[k]

                    # l++
                    addi $s5, $s5, 1    # l++

                    j CHECK_WIN_WHILE_START # loop
                CHECK_WIN_WHILE_END:
                # l >= 5
                li $t0, 5                       # t0 = 5
                blt $s5, $t0, CHECK_WIN_IF_END  # if l < 5, skip if statement
                j CHECK_WIN_IF_START            # otherwise, go into if statement
                CHECK_WIN_IF_START:             # if start
                    # return true
                    li $v0, 1                   # set return value as 1/true
                    j CHECK_WIN_RETURN          # return
                CHECK_WIN_IF_END:               # if end
                
                addi $s2, $s2, 1        # k++
                j CHECK_WIN_FOR_3_START # loop
            CHECK_WIN_FOR_3_END:        # for end

            addi $s1, $s1, 1        # col++
            j CHECK_WIN_FOR_2_START # loop
        CHECK_WIN_FOR_2_END:        # for end

        addi $s0, $s0, 1        # row++
        j CHECK_WIN_FOR_1_START # loop
    CHECK_WIN_FOR_1_END:        # for end

    # return false
    li $v0, 0   # set return value as 0/false
    j CHECK_WIN_RETURN  # return
    
    CHECK_WIN_RETURN:
    # Pop from stack
    lw $s5,0($sp)		# Restore $s5
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s4,0($sp)		# Restore $s4
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s3,0($sp)		# Restore $s3
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s2,0($sp)		# Restore $s2
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra  # return



# checkDraw function
# Arguments: None
# Return value: v0 = 0 (not drawn), 1 (drawn)
#-------------------------------------------------------------------
checkDraw:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0

    # Mapping: 
    # s0 = col
    li $s0, 0 # col = 0
    CHECK_DRAW_FOR_START:   # for start
        # col < 9
        li $t0, 9                           # t0 = 9
        bge $s0, $t0, CHECK_DRAW_FOR_END    # if col >= 9, then exit for loop
    
        # if(validMove(col))
        move $a0, $s0                   # col parameter = col
        jal validMove                   # call validMove(col)
        bne $v0, 1, CHECK_DRAW_IF_END   # if !validMove(col), then skip if statement
        j CHECK_DRAW_IF_START           # otherwise, enter if statement
        CHECK_DRAW_IF_START:    # if start
            # return false  
            li $v0, 0           # set return value as 0/false
            j CHECK_DRAW_RETURN # return
        CHECK_DRAW_IF_END:      # if end

        addi $s0, $s0, 1    # col++
        j CHECK_DRAW_FOR_START  # loop
    CHECK_DRAW_FOR_END:     # for end

    # return true
    li $v0, 1           # set return value as 1/true
    j CHECK_DRAW_RETURN # return

    CHECK_DRAW_RETURN:
    # Pop from stack
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra  # return



# Main function
#-------------------------------------------------------------------
main:
    # printf("Enter two positive numbers to initialize the random number generator.\n");
    la $a0, msg1    # load msg1 for print
    li $v0, 4       # select print_string
    syscall         # print
    # printf("Number 1: ");
    la $a0, msg2    # load msg2 for print
    li $v0, 4       # select print_string
    syscall         # print
    # scanf("%u", &m_w);
    li $v0, 5       # select read_int
    syscall         # read
    la $t0, m_w     # t0 = &m_w
    sw $v0, 0($t0)  # m_w = inputted integer
    # printf("Number 2: ");
    la $a0, msg3    # load msg3 for print
    li $v0, 4       # select print_string
    syscall         # print
    # scanf("%u", &m_z);
    li $v0, 5       # select read_int
    syscall         # read
    la $t0, m_z     # t0 = &m_z
    sw $v0, 0($t0)  # m_z = inputted integer
    # printf("Human player (H)\nComputer player (C)\n");
    la $a0, msg4    # load msg4 for print
    li $v0, 4       # select print_string
    syscall         # print

    # MAPPING: 
    # s0 = bool humanTurn, 
    # s1 = u_int32_t col,
    # s2 = char token

    # bool humanTurn;
    li $s0, 0   # bool humanTurn;
    # humanTurn = random_in_range(0, 1);
    li $a0, 0   # low = 0
    li $a1, 1   # high = 1
    jal random_in_range # random_in_range(0, 1)
    move $s0, $v0   # humanTurn = random_in_range(0, 1)

    # humanTurn ? "HUMAN" : "COMPUTER"
    li $t0, 1   # t0 = true
    beq $s0, $t0, TERNARY_1_TRUE # if humanTurn == true, then go to ternary true
    j TERNARY_1_FALSE   # otherwise, go to ternary false
    TERNARY_1_TRUE:
        # printf("Coin toss... HUMAN goes first.\n");
        la $a0, msg5    # load msg5 for print
        li $v0, 4       # select print_string
        syscall         # print
        j TERNARY_1_END # exit ternary
    TERNARY_1_FALSE:
        # printf("Coin toss... COMPUTER goes first.\n");
        la $a0, msg6    # laod msg6 for print
        li $v0, 4       # select print_string
        syscall         # print
        j TERNARY_1_END # exit ternary
    TERNARY_1_END:
    
    # while(true)
    WHILE_1_START:
        # if(checkDraw())
        jal checkDraw   # checkDraw()
        li $t0, 1       # t0 = true
        beq $v0, $t0, IF_1_START    # if checkDraw() == true, then enter if statement
        j IF_1_END                  # otherwise, skip if statement
        IF_1_START:
            # printf("No moves available. It's a draw!\n");
            la $a0, msg7    # load msg7 for print
            li $v0, 4       # select print_string
            syscall         # print
            j WHILE_1_END   # break
        IF_1_END:

        # s1 = col = 0
        li $s1, 0   # col = 0
        
        # if(humanTurn)
        li $t0, 1   # t0 = 1
        beq $s0, $t0, IF_2_START # if humanTurn == true, then enter if statement.
        j ELSE_2                 # otherwise, enter else statement
        IF_2_START:
            # printBoard();
            jal printBoard  # call printBoard() function
            # while(true)
            WHILE_2_START:
                # printf("What column would you like to drop token into? Enter 1-7: ");
                la $a0, msg8    # load msg8 for print
                li $v0, 4       # select print_string
                syscall         # print

                # scanf("%u", &col)
                li $v0, 5       # select read_int
                syscall         # read int
                move $s1, $v0   # s1 = inputted int

                # if(validMove(col))
                move $a0, $s1   # initialize col parameter
                jal validMove   # call validMove
                li $t0, 1       # t0 = true
                beq $v0, $t0, IF_3_START    # if validMove(col) == true, then enter if statement
                j ELSE_3                    # otherwise, enter else statement
                IF_3_START:
                    # break;
                    j WHILE_2_END   # break
                ELSE_3:
                    # printf("Invalid move. ");
                    la $a0, msg9    # load msg9 for print
                    li $v0, 4       # select print_string
                    syscall         # print
                    j IF_3_END      # exit if statement
                IF_3_END:
                j WHILE_2_START     # loop
            WHILE_2_END:
            j IF_2_END  # exit if statement
        ELSE_2:
            # while(true)
            WHILE_3_START:
                # col = random_in_range(1, 7);
                li $a0, 1   # initialize low = 1
                li $a1, 7   # initialize high = 7
                jal random_in_range # call random_in_range(1, 7)
                move $s1, $v0   # col = random_in_range(1, 7)

                # if(validMove(col))
                move $a0, $s1   # intialize col parameter = col
                jal validMove   # call validMove(col)
                li $t0, 1       # t0 = true
                beq $v0, $t0, IF_4_START    # if validMove(col) == true, then enter if statement
                j IF_4_END                  # otherwise, skip if statement
                IF_4_START:
                    # break
                    j WHILE_3_END   # break
                IF_4_END:
                j WHILE_3_START     # loop
            WHILE_3_END:

            # printf("Computer player selected column ");
            la $a0, msg10   # load msg10 for print
            li $v0, 4       # select print_string
            syscall         # print

            # print col
            move $a0, $s1   # load col for print
            li $v0, 1       # select print_int
            syscall         # print

            # printf("\n");
            la $a0, msg11   # load msg11 for print
            li $v0, 4       # select print_string
            syscall         # print

            j IF_2_END      # exit if statement
        IF_2_END:

        # token = humanTurn ? 'H' : 'C'
        li $t0, 1   # t0 = true
        beq $s0, $t0, TERNARY_2_TRUE    # if humanTurn == true, ternary true
        j TERNARY_2_FALSE               # otherwise, ternary false
        TERNARY_2_TRUE:
            li $s2, 72      # token = 'H'
            j TERNARY_2_END # exit ternary
        TERNARY_2_FALSE:
            li $s2, 67      # token = 'C'
            j TERNARY_2_END # exit ternary
        TERNARY_2_END:

        # placeMove(col, token);
        move $a0, $s1   # col parameter = col
        move $a1, $s2   # token parameter = token
        jal placeMove   # call placeMove(col, token)

        # checkWin(token)
        move $a0, $s2   # token parameter = token
        jal checkWin    # call checkWin(token)
        li $t0, 1       # t0 = true
        beq $v0, $t0, IF_5_START    # if checkWin(token) == true, then enter if
        j IF_5_END                  # otherwise, skip if
        IF_5_START:
            jal printBoard  # call printBoard()

            li $t0, 1   # t0 = true
            beq $s0, $t0, TERNARY_3_TRUE    # if humanTurn == true, then enter ternary true
            j TERNARY_3_FALSE               # otherwise, enter ternary false
            
            TERNARY_3_TRUE:
                # printf("Congratulations, HUMAN Winner!\n");
                la $a0, msg12   # load msg12 for print
                li $v0, 4       # select print_string
                syscall         # print
                j TERNARY_3_END # exit ternary
            TERNARY_3_FALSE:
                # printf("Congratulations, COMPUTER Winner!\n");
                la $a0, msg13   # load msg13 for print
                li $v0, 4       # select print_string
                syscall         # print
                j TERNARY_3_END # exit ternary
            TERNARY_3_END:

            # break;
            j WHILE_1_END   # break
        IF_5_END:

        # humanTurn = !humanTurn
        li $t0, 1   # t0 = 1
        xor $s0, $s0, $t0   # humanTurn = !humanTurn
        j WHILE_1_START # loop
    WHILE_1_END:

    # Exit program
	li $v0, 10  # Sets $v0 to "10" to select exit syscall
	syscall     # Exit


# Data section
#-------------------------------------------------------------------
	.data # Mark the start of the data section

	m_w: .word 0    # Initialize m_w = 0
    m_z: .word 0    # Initialize m_z = 0
    board: .ascii "C.......CH.......HC.......CH.......HC.......CH.......H"
    rowOffsets: .word 1 1 1 0   # rowOffsets = {1, 1, 1, 0}
    colOffsets: .word -1 0 1 1  # colOffsets = {-1, 0, 1, 1}
    printBoardMsg1: .asciiz "  1 2 3 4 5 6 7\n"
    printBoardMsg2: .asciiz "-----------------\n"
    printBoardMsg3: .asciiz " "
    printBoardMsg4: .asciiz "\n"

    msg1: .asciiz "Enter two positive numbers to initialize the random number generator.\n"
    msg2: .asciiz "Number 1: "
    msg3: .asciiz "Number 2: "
    msg4: .asciiz "Human player (H)\nComputer player (C)\n"
    msg5: .asciiz "Coin toss... HUMAN goes first.\n"
    msg6: .asciiz "Coin toss... COMPUTER goes first.\n"
    msg7: .asciiz "No moves available. It's a draw!\n"
    msg8: .asciiz "What column would you like to drop token into? Enter 1-7: "
    msg9: .asciiz "Invalid move. "
    msg10: .asciiz "Computer player selected column "
    msg11: .asciiz "\n"
    msg12: .asciiz "Congratulations, HUMAN Winner!\n"
    msg13: .asciiz "Congratulations, COMPUTER Winner!\n"