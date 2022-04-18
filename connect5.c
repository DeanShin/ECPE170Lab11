#include <stdio.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

uint32_t m_w;
uint32_t m_z;

uint32_t random_in_range(uint32_t low, uint32_t high);
uint32_t get_random();
void printBoard(char** board, uint32_t rows, uint32_t cols);
bool validMove(char** board, uint32_t cols, uint32_t col);
void placeMove(char** board, uint32_t rows, uint32_t col, char token);
bool checkWin(char** board, uint32_t rows, uint32_t cols, char token);
bool checkDraw(char** board, uint32_t cols);

uint32_t random_in_range(uint32_t low, uint32_t high) {
    uint32_t range = high-low+1;
    uint32_t rand_num = get_random();
    return (rand_num % range) + low;
}

uint32_t get_random() {
    uint32_t result;
    m_z = 36969 * (m_z & 65535) + (m_z >> 16);
    m_w = 18000 * (m_w & 65535) + (m_w >> 16);
    result = (m_z << 16) + m_w;
    return result;
}

void printBoard(char** board, uint32_t rows, uint32_t cols) {
    for(int i = 0; i < cols; i++) {
        printf("%i ", i);
    }
    for(int i = 0; i < rows; i++) {
        for(int j = 0; j < cols; j++) {
            printf("%c ", board[i][j]);
        }
        printf("\n");
    }
}

bool validMove(char** board, uint32_t cols, uint32_t col) {
    if(col < 0 || col >= cols) return false;
    if(board[0][col] != '.') return false;
    return true;
}

void placeMove(char** board, uint32_t rows, uint32_t col, char token) {
    for(int i = rows - 1; i >= 0; i--) {
        if(board[i][col] == '.') {
            board[i][col] = token;
            break;
        }
    }
    return;
}

bool checkWin(char** board, uint32_t rows, uint32_t cols, char token) {
    // Four directions: /, |, \, and -
    int rowOffsets[] = {1, 1, 1, 0};
    int colOffsets[] = {-1, 0, 1, 1};
    // Iterate over every starting position
    for(int row = 0; row < rows; row++) {
        for(int col = 0; col < cols; col++) {
            // Try every direction: /, |, \, and -
            for(int k = 0; k < 3; k++) {
                int newRow = row;
                int newCol = col;
                int l = 0;
                while(newRow >= 0 && newRow < rows && newCol >= 0 && newCol < cols && board[newRow][newCol] == token) {
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

bool checkDraw(char** board, uint32_t cols) {
    for(int i = 0; i < cols; i++) {
        if(validMove(board, cols, i)) {
            return false;
        }
    }
    return true;
}

    
int main() {
    printf("Enter two positive numbers to initialize the random number generator.\n");
    printf("Number 1: ");
    scanf("%i", &m_w);
    printf("Number 2: ");
    scanf("%i", &m_z);
    printf("Human player (H)\n");
    printf("Computer player (C)\n");

    // Determine who has the first move
    bool humanTurn; 
    humanTurn = random_in_range(0, 1);

    printf("Coin toss... %s goes first.", humanTurn ? "HUMAN" : "COMPUTER");

    // Create board
    char board[6][9] = {
        {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
        {'H', '.', '.', '.', '.', '.', '.', '.', 'H'},
        {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
        {'H', '.', '.', '.', '.', '.', '.', '.', 'H'},
        {'C', '.', '.', '.', '.', '.', '.', '.', 'C'},
        {'H', '.', '.', '.', '.', '.', '.', '.', 'H'}
    };
    uint32_t rows = 6;
    uint32_t cols = 9;

    while(true) {
        // Check for a draw
        if(checkDraw(board, cols)) {
            printf("No moves available. It's a draw!\n");
            break;
        }
        u_int32_t col;
        if(humanTurn) {
            // Print board
            printBoard(board, rows, cols);
            while(true) {
                // Receive input column from human
                printf("What column would you like to drop token into? Enter 1-7: ");
                scanf("%u", &col);
                // If invalid position, loop. 
                if(validMove(board, cols, col)) {
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
                if(validMove(board, cols, col)) {
                    break;
                }
            }
        }
        char token = humanTurn ? 'H' : 'C';
        // Place piece in column.
        placeMove(board, rows, col, token);
        // If win, break.
        if(checkWin(board, rows, cols, token)) {
            printf("Congratulations, %s Winner!\n", humanTurn ? "Human" : "Computer");
            break;
        }
    }
    return 0;
}
