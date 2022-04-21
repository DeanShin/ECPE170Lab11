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
    la $a0, printBoardMsg1
    li $v0, 4
    syscall
    # Print "-----------------\n"
    la $a0, printBoardMsg2
    li $v0, 4
    syscall

    # Mapping: 
    # s0 = row
    # s1 = col
    li $s0, 0 # row = 0
    PRINT_BOARD_FOR_1_START:
        # row < 6
        li $t0, 6
        bge $s0, $t0, PRINT_BOARD_FOR_1_END

        li $s1, 0 # col = 0
        PRINT_BOARD_FOR_2_START:
            # col < 9
            li $t0, 9
            bge $s1, $t0, PRINT_BOARD_FOR_2_END

            # t0 = row * 9 + col
            li $t0, 9
            mul $t0, $s0, $t0
            add $t0, $t0, $s1
            # t0 = board[row][col]
            la $t1, board   
            add $t0, $t0, $t1
            lb $t0, 0($t0)
            # Print board[row][col]
            move $a0, $t0
            li $v0, 11
            syscall

            # Print " "
            la $a0, printBoardMsg3
            li $v0, 4
            syscall

            addi $s1, $s1, 1    # col++
            j PRINT_BOARD_FOR_2_START
        PRINT_BOARD_FOR_2_END:

        # Print "\n"
        la $a0, printBoardMsg4
        li $v0, 4
        syscall

        addi $s0, $s0, 1    # row++
        j PRINT_BOARD_FOR_1_START
    PRINT_BOARD_FOR_1_END:

    # Print "-----------------\n"
    la $a0, printBoardMsg2
    li $v0, 4
    syscall

    # Pop from stack
    lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra

# validMove function
# Arguments: a0 = col
# Return value: v0 = 0 (invalid move), 1 (valid move)
#-------------------------------------------------------------------
validMove:
    # Add to stack
    addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra

    # col < 0
    li $t0, 0
    blt $a0, $t0, VALID_MOVE_IF_1
    # col >= 9
    li $t0, 9
    bge $a0, $t0, VALID_MOVE_IF_1
    j VALID_MOVE_IF_END_1
    VALID_MOVE_IF_1:
        # Return false
        li $v0, 0   
        j VALID_MOVE_RETURN
    VALID_MOVE_IF_END_1:

    # board[0][col] != '.'
    # t0 = board[0][col]
    la $t1, board   
    add $t0, $a0, $t1
    lb $t0, 0($t0)

    li $t1, 46 # t1 = ascii for '.'
    bne $t0, $t1, VALID_MOVE_IF_2
    j VALID_MOVE_IF_END_2

    VALID_MOVE_IF_2:
        # Return false
        li $v0, 0   
        j VALID_MOVE_RETURN
    VALID_MOVE_IF_END_2:

    # Return true
    li $v0, 1
    j VALID_MOVE_RETURN
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
    PLACE_MOVE_FOR_1_START:
        # i >= 0
        li $t0, 0
        blt $s0, $t0, PLACE_MOVE_FOR_1_END

        # t0 = row * 9 + col
        li $t0, 9
        mul $t0, $s0, $t0
        add $t0, $t0, $a0
        # t0 = &board[row][col]
        la $t1, board   
        add $t0, $t0, $t1
        # t1 = board[row][col]
        lb $t1, 0($t0)

        # board[row][col] == '.'
        li $t2, 46 # t2 = ascii for '.'
        beq $t1, $t2, PLACE_MOVE_IF_1
        j PLACE_MOVE_IF_1_END
        PLACE_MOVE_IF_1:
            sb $a1, 0($t0)
            j PLACE_MOVE_FOR_1_END
        PLACE_MOVE_IF_1_END:

        addi $s0, $s0, -1    # i--
        j PLACE_MOVE_FOR_1_START
    PLACE_MOVE_FOR_1_END:

    # Pop from stack
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra

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
    CHECK_WIN_FOR_1_START:
        # row < 6
        li $t0, 6
        bge $s0, $t0, CHECK_WIN_FOR_1_END

        li $s1, 0 # col = 0
        CHECK_WIN_FOR_2_START:
            # col < 9
            li $t0, 9
            bge $s1, $t0, CHECK_WIN_FOR_2_END

            li $s2, 0 # k = 0
            CHECK_WIN_FOR_3_START:
                # k < 4
                li $t0, 4
                bge $s2, $t0, CHECK_WIN_FOR_3_END
            
                move $s3, $s0 # int newRow = row
                move $s4, $s1 # int newCol = col
                li $s5, 0     # l = 0
                CHECK_WIN_WHILE_START:
                    # newRow >= 0
                    li $t0, 0
                    blt $s3, $t0, CHECK_WIN_WHILE_END
                    # newRow < 6
                    li $t0, 6
                    bge $s3, $t0, CHECK_WIN_WHILE_END
                    # newCol >= 0
                    li $t0, 0
                    blt $s4, $t0, CHECK_WIN_WHILE_END
                    # newCol < 6
                    li $t0, 6
                    bge $s4, $t0, CHECK_WIN_WHILE_END
                    
                    # board[newRow][newCol] == token
                    
                    # t0 = newRow * 9 + newCol
                    li $t0, 9
                    mul $t0, $t0, $s3
                    add $t0, $t0, $s4
                    # t0 = &board[newRow][newCol]
                    la $t1, board   
                    add $t0, $t0, $t1
                    # t0 = board[newRow][newCol]
                    lb $t0, 0($t0)
                    # board[newRow][newCol] == token
                    bne $t0, $a0, CHECK_WIN_WHILE_END

                    # newRow += rowOffsets[k]
                    # t0 = k * 4
                    li $t0, 4
                    mul $t0, $t0, $s2
                    # t0 = &rowOffsets[k]
                    la $t1, rowOffsets
                    add $t0, $t0, $t1
                    # t0 = rowOffsets[k]
                    lw $t0, 0($t0)
                    # newRow += rowOffsets[k]
                    add $s3, $s3, $t0
                    
                    # newRow += colOffsets[k]
                    # t0 = k * 4
                    li $t0, 4
                    mul $t0, $t0, $s2
                    # t0 = &colOffsets[k]
                    la $t1, colOffsets
                    add $t0, $t0, $t1
                    # t0 = colOffsets[k]
                    lw $t0, 0($t0)
                    # newCol += colOffsets[k]
                    add $s4, $s4, $t0

                    # l++
                    addi $s5, $s5, 1

                    j CHECK_WIN_WHILE_START
                CHECK_WIN_WHILE_END:
                # l >= 5
                li $t0, 5
                blt $s5, $t0, CHECK_WIN_IF_END
                j CHECK_WIN_IF_START
                CHECK_WIN_IF_START:
                    # return true
                    li $v0, 1
                    j CHECK_WIN_RETURN
                CHECK_WIN_IF_END:
                
                addi $s2, $s2, 1    # k++
                j CHECK_WIN_FOR_3_START
            CHECK_WIN_FOR_3_END:

            addi $s1, $s1, 1    # col++
            j CHECK_WIN_FOR_2_START
        CHECK_WIN_FOR_2_END:
        addi $s0, $s0, 1    # row++
        j CHECK_WIN_FOR_1_START
    CHECK_WIN_FOR_1_END:

    # return false
    li $v0, 0
    j CHECK_WIN_RETURN
    
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
    jr $ra



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
    CHECK_DRAW_FOR_START:
        # col < 9
        li $t0, 9
        bge $s0, $t0, CHECK_DRAW_FOR_END
    
        # if(validMove(col))
        move $a0, $s0
        jal validMove
        bne $v0, 1, CHECK_DRAW_IF_END
        j CHECK_DRAW_IF_START
        CHECK_DRAW_IF_START:
            # return false
            li $v0, 0
            j CHECK_DRAW_RETURN
        CHECK_DRAW_IF_END:

        addi $s0, $s0, 1    # col++
        j CHECK_DRAW_FOR_START
    CHECK_DRAW_FOR_END:

    # return true
    li $v0, 1
    j CHECK_DRAW_RETURN

    CHECK_DRAW_RETURN:
    # Pop from stack
    lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
    lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

    # Return from function
    jr $ra



# Main function
#-------------------------------------------------------------------
main:
    # printf("Enter two positive numbers to initialize the random number generator.\n");
    la $a0, msg1
    li $v0, 4
    syscall
    # printf("Number 1: ");
    la $a0, msg2
    li $v0, 4
    syscall
    # scanf("%u", &m_w);
    li $v0, 5
    syscall
    la $t0, m_w
    sw $v0, 0($t0)
    # printf("Number 2: ");
    la $a0, msg3
    li $v0, 4
    syscall
    # scanf("%u", &m_z);
    li $v0, 5
    syscall
    la $t0, m_z
    sw $v0, 0($t0)
    # printf("Human player (H)\nComputer player (C)\n");
    la $a0, msg4
    li $v0, 4
    syscall

    # MAPPING: 
    # s0 = bool humanTurn, 
    # s1 = u_int32_t col,
    # s2 = char token

    # bool humanTurn;
    li $s0, 0
    # humanTurn = random_in_range(0, 1);
    li $a0, 0
    li $a1, 1
    jal random_in_range
    move $s0, $v0

    # humanTurn ? "HUMAN" : "COMPUTER"
    li $t0, 1
    beq $s0, $t0, TERNARY_1_TRUE
    j TERNARY_1_FALSE
    TERNARY_1_TRUE:
        # printf("Coin toss... HUMAN goes first.\n");
        la $a0, msg5
        li $v0, 4
        syscall
        j TERNARY_1_END
    TERNARY_1_FALSE:
        # printf("Coin toss... COMPUTER goes first.\n");
        la $a0, msg6
        li $v0, 4
        syscall
        j TERNARY_1_END
    TERNARY_1_END:
    
    # while(true)
    WHILE_1_START:
        # if(checkDraw())
        jal checkDraw
        li $t0, 1
        beq $v0, $t0, IF_1_START
        j IF_1_END
        IF_1_START:
            # printf("No moves available. It's a draw!\n");
            la $a0, msg7
            li $v0, 4
            syscall
            # break;
            j WHILE_1_END
        IF_1_END:

        # s1 = col = 0
        li $s1, 0
        
        # if(humanTurn)
        li $t0, 1
        beq $s0, $t0, IF_2_START
        j ELSE_2
        IF_2_START:
            # printBoard();
            jal printBoard
            # while(true)
            WHILE_2_START:
                # printf("What column would you like to drop token into? Enter 1-7: ");
                la $a0, msg8
                li $v0, 4
                syscall

                # scanf("%u", &col)
                li $v0, 5
                syscall
                move $s1, $v0

                # if(validMove(col))
                move $a0, $s1
                jal validMove
                li $t0, 1
                beq $v0, $t0, IF_3_START
                j ELSE_3
                IF_3_START:
                    # break;
                    j WHILE_2_END
                ELSE_3:
                    # printf("Invalid move. ");
                    la $a0, msg9
                    li $v0, 4
                    syscall
                    j IF_3_END
                IF_3_END:
                j WHILE_2_START
            WHILE_2_END:
            j IF_2_END
        ELSE_2:
            # while(true)
            WHILE_3_START:
                # col = random_in_range(1, 7);
                li $a0, 1
                li $a1, 7
                jal random_in_range
                move $s1, $v0

                # if(validMove(col))
                move $a0, $s1
                jal validMove
                li $t0, 1
                beq $v0, $t0, IF_4_START
                j IF_4_END
                IF_4_START:
                    # break
                    j WHILE_3_END
                IF_4_END:
                j WHILE_3_START
            WHILE_3_END:

            # printf("Computer player selected column ");
            la $a0, msg10
            li $v0, 4
            syscall

            # print col
            move $a0, $s1
            li $v0, 1
            syscall

            # printf("\n");
            la $a0, msg11
            li $v0, 4
            syscall

            j IF_2_END
        IF_2_END:

        # token = humanTurn ? 'H' : 'C'
        li $t0, 1
        beq $s0, $t0, TERNARY_2_TRUE
        j TERNARY_2_FALSE
        TERNARY_2_TRUE:
            li $s2, 72
            j TERNARY_2_END
        TERNARY_2_FALSE:
            li $s2, 67
            j TERNARY_2_END
        TERNARY_2_END:

        # placeMove(col, token);
        move $a0, $s1
        move $a1, $s2
        jal placeMove

        # checkWin(token)
        move $a0, $s2
        jal checkWin
        li $t0, 1
        beq $v0, $t0, IF_5_START
        j IF_5_END
        IF_5_START:
            jal printBoard

            li $t0, 1
            beq $s0, $t0, TERNARY_3_TRUE
            j TERNARY_3_FALSE
            
            TERNARY_3_TRUE:
                # printf("Congratulations, HUMAN Winner!\n");
                la $a0, msg12
                li $v0, 4
                syscall
                j TERNARY_3_END
            TERNARY_3_FALSE:
                # printf("Congratulations, COMPUTER Winner!\n");
                la $a0, msg13
                li $v0, 4
                syscall
                j TERNARY_3_END
            TERNARY_3_END:

            # break;
            j WHILE_1_END
        IF_5_END:

        # humanTurn = !humanTurn
        li $t0, 1
        xor $s0, $s0, $t0
        j WHILE_1_START
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
    rowOffsets: .word 1 1 1 0
    colOffsets: .word -1 0 1 1
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