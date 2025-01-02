# Tetris in MIPS Assembly

## Overview
This project is a fully functional Tetris game implemented in MIPS assembly using the MARS simulator. The game includes fundamental gameplay mechanics, colorful tetrominoes, collision detection, and animations. It showcases advanced logic and bitmap display handling.
## Controls and Basic Setup
### Bitmap Display Configuration
- **Unit Width**: 8 pixels
- **Unit Height**: 8 pixels
- **Display Width**: 128 pixels
- **Display Height**: 256 pixels
- **Base Address**: `0x10008000` (`$gp`)

### Controls
- **A**: Move left
- **S**: Move down
- **D**: Move right
- **Q**: Quit game
- **R**: Rotate piece
- **E**: Restart the game after losing
- **P**: Pause game (not an official feature)

## How to Play
1. Download and open the MARS simulator.
2. Load the `tetris.asm` file into MARS.
3. Configure the Bitmap Display Tool in MARS with the parameters listed above.
4. Run the program and enjoy the game!

## Video Demonstration
[![Tetris in MIPS Assembly](https://img.youtube.com/vi/p6Ui7m8ddMo/0.jpg)](https://www.youtube.com/watch?v=p6Ui7m8ddMo)

Click the image above to watch the demonstration.


## Logic
### Block Position Logic
- The position of each tetromino is tracked using a structure stored in register `$s0`.
- An iterator variable keeps track of the current block being written.
- Every new block starts at **position 1**.

### Game Loop Steps
1. **Redraw the Background**: Clears the screen and prepares it for updates.
2. **Check for Keyboard Input**: Captures user actions.
3. **Check for Collision Events**: Determines if the tetromino can move or rotate.
4. **Update Tetromino Location/Orientation**: Adjusts the position or rotation of the active piece.
5. **Redraw the Screen**: Displays the updated game state.
6. **Sleep**: Adds a brief delay for smooth gameplay.
7. **Repeat**: Goes back to Step 1.

### Tetromino Handling
- A series of `beq` statements determine which tetromino shape to draw based on the current shape identifier.
- Labels handle specific manipulations for each tetromino’s shape and orientation.
- `$s1` is used to determine the current operation state:
  - **1**: Editing the active tetromino.
  - **0**: Drawing a new tetromino.
