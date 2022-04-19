#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

uint32_t m_w;
uint32_t m_z;
char board[6][9] = {
    {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
    {'H', '.', '.', '.', '.', '.', '.', '.', 'H'},
    {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
    {'H', '.', '.', '.', '.', '.', '.', '.', 'H'},
    {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
    {'H', '.', '.', '.', '.', '.', '.', '.', 'H'}
};

uint32_t get_random() {
    uint32_t result;
    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
    result = (m_z << 16) + m_w;
    return result;
}

uint32_t random_in_range(uint32_t low, uint32_t high) {
    uint32_t range = high-low+1;
    uint32_t rand_num = get_random();
    return (rand_num % range) + low;
}

void printBoard() {
    printf("  1 2 3 4 5 6 7\n");
    printf("-----------------\n");
    for(int row = 0; row < 6; row++) {
        for(int col = 0; col < 9; col++) {
            printf("%c ", board[row][col]);
        }
        printf("\n");
    }
    printf("-----------------\n");
}

bool validMove(uint32_t col) {
    if(col < 0 || col >= 9) return false;
    if(board[0][col] != '.') return false;
    return true;
}

void placeMove(uint32_t col, char token) {
    for(int row = 5; row >= 0; row--) {
        if(board[row][col] == '.') {
            board[row][col] = token;
            break;
        }
    }
    return;
}

bool checkWin(char token) {
    // Four directions: /, |, \, and -
    int rowOffsets[] = {1, 1, 1, 0};
    int colOffsets[] = {-1, 0, 1, 1};
    // Iterate over every starting position
    for(int row = 0; row < 6; row++) {
        for(int col = 0; col < 9; col++) {
            // Try every direction: /, |, \, and -
            for(int k = 0; k < 4; k++) {
                int newRow = row;
                int newCol = col;
                int l = 0;
                while(newRow >= 0 && newRow < 6 && newCol >= 0 && newCol < 9 && board[newRow][newCol] == token) {
                    newRow += rowOffsets[k];
                    newCol += colOffsets[k];
                    l++;
                }
                if(l >= 5) {
                    return true;
                }
            }
        }
    }
    return false;
}

bool checkDraw() {
    for(int col = 0; col < 9; col++) {
        if(validMove(col)) {
            return false;
        }
    }
    return true;
}

    
int main() {
    printf("Enter two positive numbers to initialize the random number generator.\n");
    printf("Number 1: ");
    scanf("%u", &m_w);
    printf("Number 2: ");
    scanf("%u", &m_z);
    printf("Human player (H)\n");
    printf("Computer player (C)\n");

    // Determine who has the first move
    bool humanTurn; 
    humanTurn = random_in_range(0, 1);

    printf("Coin toss... %s goes first.\n", humanTurn ? "HUMAN" : "COMPUTER");

    while(true) {
        // Check for a draw
        if(checkDraw()) {
            printf("No moves available. It's a draw!\n");
            break;
        }
        u_int32_t col;
        if(humanTurn) {
            // Print board
            printBoard();
            while(true) {
                // Receive input column from human
                printf("What column would you like to drop token into? Enter 1-7: ");
                scanf("%u", &col);
                // If invalid position, loop. 
                if(validMove(col)) {
                    break;
                } else {
                    printf("Invalid move. ");
                }
            }
        } 
        else {
            while(true) {
                // Generate random input column.
                col = random_in_range(1, 7);
                // If invalid position, loop.
                if(validMove(col)) {
                    break;
                }
            }
            printf("Computer player selected column %u\n", col);
        }
        char token = humanTurn ? 'H' : 'C';
        // Place piece in column.
        placeMove(col, token);
        // If win, break.
        if(checkWin(token)) {
            printBoard();
            printf("Congratulations, %s Winner!\n", humanTurn ? "Human" : "Computer");
            break;
        }
        humanTurn = !humanTurn;
    }
    return 0;
}
