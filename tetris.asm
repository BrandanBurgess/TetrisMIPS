#####################################################################

# CSCB58 Summer 2024 Assembly Final Project - UTSC

# Student1: Brandan Burgess, 1009576807, burge132, brandan.burgess@mail.utoronto.ca

# Student2: Hamed Dawoudzai, 1009421243, dawoudz2, hamed.dawoudz@mail.utoronto.ca

#

# Bitmap Display Configuration:

# - Unit width in pixels: 8 (update this as needed) 

# - Unit height in pixels: 8 (update this as needed)

# - Display width in pixels: 128 (update this as needed)

# - Display height in pixels: 256 (update this as needed)

# - Base Address for Display: 0x10008000 ($gp)

#

# Which milestones have been reached in this submission?

# Milestone 5

# (See the assignment handout for descriptions of the milestones)



#

# Which approved features have been implemented?

# (See the assignment handout for the list of features)

# Easy Features:

# 1. Gravity

# 2. Game Over Condition/Screen

# 3. Sound Effects for rotating, dropping, clear line and losing.

# 4. Each tetromino is a different colour

# Hard Features:

# 1. Implemented full set of Tetrominoes

# 2. Animation to lines when they are completed



# How to play:

# ASD are movement keys for left, down and right respectively

# Q is for quit game

# R is for rotate piece

# E restarts the game after losing

# P is for pause (not counting in my official featurelist though refer to ones above)


# Link to video demonstration for final submission:

# - https://www.youtube.com/watch?v=p6Ui7m8ddMo 

#

# Are you OK with us sharing the video with people outside course staff?

# - yes

#

# Any additional information that the TA needs to know:

# - N/A

#

#####################################################################



######################## Bitmap Display Configuration ########################
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 128
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
##############################################################################
    .data
ADDR_DSPL:
    .word 0x10008000

blockPos:
	.space 24

editStatus:
	.space 4

ADDR_KBRD:
    .word 0xffff0000
    
pastBlocks:
	.space 2048
	
nextBlock:
	.space 4

    .text
    .globl main
    
.eqv pos1 $s0


main:

la $t0, nextBlock
li $t1, 6
sw $t1, 0($t0)

lw $s2 ADDR_DSPL
la $s3 pastBlocks
li $s4, 0xFFFFFF        

la $s0, blockPos
la $s7, pastBlocks

### Initialize game

la $t0, pastBlocks
li $t1, 0            # Load zero into $t1
li $t2, 512          # Set counter for 512 words

initialize_displayArray:
    beq $t2, $zero, done_initializing  # Exit when counter reaches zero
    sw $t1, 0($t0)        # Store zero in the current word
    addi $t0, $t0, 4      # Move to the next word
    subi $t2, $t2, 1      # Decrement counter
    j initialize_displayArray  # Repeat for all words
    
    
done_initializing:



ini_logic:
    li $t2, 1
    li $t3, 33
    li $t1, 13         # $t1 = wall code
    la $t0, pastBlocks       # $t0 = base address for collision map

ini_walls:
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 60($t0)          # paint the corresponding unit on the right side gray
    addi $t0, $t0, 64        # increment to the unit below the one we are currently painting
    addi $t2, $t2, 1         # Update counter
    bne $t2, $t3, ini_walls  # loop condition i = 1, i < 33 (since 16 x 32 display)

li $t2, 2
li $t3, 16    
addi $t0, $t0, -60          # Resetting mem address for last row
    
ini_floor:
    sw $t1, 0($t0)
    addi $t0, $t0, 4        # iterate to adjacent unit
    addi $t2, $t2, 1
    bne $t2, $t3, ini_floor
    

la $t0,editStatus
li $t1, 0
sw $t1,0($t0)

j game_loop

####
draw_tetris_piece:

	
	
	
	la $t0 editStatus
	lw $t1, 0($t0)
	
	#see if we need to spawn new piece
	beq $t1,1,editing
	
	
	#Find out which piece to draw:
	
	la $t0, nextBlock
	lw $t1, 0($t0)

	
	beq $t1,1,I_piece
	beq $t1,2,O_piece
	beq $t1,3,L_piece
	beq $t1,4,J_piece
	beq $t1,5,S_piece
	beq $t1,6,Z_piece
	beq $t1,7,T_piece
	
	I_piece:
	
	#now change editing to true
	
	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0xFF0000        # $t1 = red color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 4
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    li $t4, 1
    sw $t4, 16($s0)
    sw $t4, 20($s0)
    
    la $s0, blockPos
    
    #put next piece to O
    la $t0, nextBlock
    li $t1, 2
    sw $t1, 0($t0)
    
    jr $ra
    
    editing:
    	jr $ra
    	
    O_piece:
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0x0000FF        # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 4
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, -4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1
    sw $t4, 20($s0)
    li $t4, 2
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to L
    la $t0, nextBlock
    li $t1, 3
    sw $t1, 0($t0)
    
    jr $ra
    
    L_piece:
    
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0x00FF00       # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 64
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1 #Orientation
    sw $t4, 20($s0)
    li $t4, 3   #Shape 
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to J
    la $t0, nextBlock
    li $t1, 4
    sw $t1, 0($t0)
    
    jr $ra
    
    J_piece:
    
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0xFFFF00      # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 64
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, -4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1 #Orientation
    sw $t4, 20($s0)
    li $t4, 4   #Shape 
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to I
    la $t0, nextBlock
    li $t1, 5
    sw $t1, 0($t0)
    
    jr $ra
    
    S_piece:
    
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0xFFA500       # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    addi $t0, $t0, 64
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 4
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, -64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1 #Orientation
    sw $t4, 20($s0)
    li $t4, 5   #Shape 
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to I
    la $t0, nextBlock
    li $t1, 6
    sw $t1, 0($t0)
    
    jr $ra
    
    Z_piece:
    
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0x800080       # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 4
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1 #Orientation
    sw $t4, 20($s0)
    li $t4, 6   #Shape 
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to T
    la $t0, nextBlock
    li $t1, 7
    sw $t1, 0($t0)
    
    jr $ra
    
    T_piece:
    
    	la $t0,editStatus
	li $t1, 1
	sw $t1,0($t0)
   
    li $t1, 0xFFC0CB       # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 24      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 4
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 4
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 60
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    #Setting block attributes
    li $t4, 1 #Orientation
    sw $t4, 20($s0)
    li $t4, 7   #Shape 
    sw $t4, 16($s0)
    
    la $s0, blockPos
    
    #put next piece to I
    la $t0, nextBlock
    li $t1, 1
    sw $t1, 0($t0)
    
    jr $ra
    	
    

####




    

game_loop:
	
	jal draw_tetris_piece
	jal pattern_1
	jal draw_cur_piece
	jal draw_past_blocks
	jal keyboard_input
	jal respond_to_S
	jal break_check
	
	
	yeah:
	
	li $v0, 32 
	li $a0, 100
	syscall
	j game_loop
	


    



### UPDATING BACKGROUND


pattern_1:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    li $t5, 1

j draw_background

logic_background:
    bgt $t5, 16, pattern_2
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_background:
    bgt $t2, $t3, logic_background
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t4, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_background
    
pattern_2:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    addi $t0, $t0, 64
    li $t5, 1

j draw_background2

logic_background2:
    bgt $t5, 16, wall_logic
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_background2:
    bgt $t2, $t3, logic_background2
    sw $t4, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_background2

wall_logic:
    li $t2, 1
    li $t3, 33
    li $t1, 0x808080         # $t1 = gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display

draw_walls:
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 60($t0)          # paint the corresponding unit on the right side gray
    addi $t0, $t0, 64        # increment to the unit below the one we are currently painting
    addi $t2, $t2, 1         # Update counter
    bne $t2, $t3, draw_walls # loop condition i = 1, i < 33 (since 16 x 32 display)

li $t2, 2
li $t3, 16    
addi $t0, $t0, -60          # Resetting mem address for last row
    
draw_floor:
    sw $t1, 0($t0)
    addi $t0, $t0, 4        # iterate to adjacent unit
    addi $t2, $t2, 1
    bne $t2, $t3, draw_floor

jr $ra




## DRAW PREV BLOCKS
draw_past_blocks:


	la $t0, pastBlocks
	lw $t1 ADDR_DSPL
	li $t2, 0            # Load zero into $t1
	li $t3, 512          # Set counter for 512 words

	draw_loop:
    		beq $t3, $zero, done_draw  # Exit when counter reaches zero
    		
    		
    		
    		lw $t5, 0($t0) #Store current colour at this index
    		
    		beq $t5,1,colour_red
    		beq $t5,2,colour_blue
    		beq $t5,3,colour_green
    		beq $t5,4,colour_yellow
    		beq $t5,5,colour_orange
    		beq $t5,6,colour_purple
    		beq $t5,7,colour_pink
    		
    		## goes here if there isn't a colour there
    		addi $t0, $t0, 4      # Move to the next word (pastblocks)
    		addi $t1, $t1, 4      # Move to the next word (display)
    		subi $t3, $t3, 1      # Decrement counter
    		j draw_loop  # Repeat for all words
    		
    		colour_red:
    			li $t4, 0xFF0000
    			sw $t4, 0($t1)
    			
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		colour_blue:
    		
    			li $t4, 0x0000FF
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		colour_green:
    		
    			li $t4, 0x00FF00
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		colour_yellow:
    			li $t4, 0xFFFF00
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    			
    			
    		colour_orange:
    			li $t4, 0xFFA500
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		
    		colour_purple:
    			li $t4, 0x800080
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		colour_pink:
    			li $t4, 0xFFC0CB
    			sw $t4, 0($t1)
    			addi $t0, $t0, 4      # Move to the next word (pastblocks)
    			addi $t1, $t1, 4      # Move to the next word (display)
    			subi $t3, $t3, 1      # Decrement counter
    			j draw_loop  # Repeat for all words
    		
    		
    		
    
    
	done_draw:
		jr $ra



## DRAW CURRENT PIECE

draw_cur_piece:
	la $t0, 16($s0)
	lw $t1, 0($t0)
	beq $t1,1,red
	beq $t1,2,blue
	beq $t1,3,green
	beq $t1,4,yellow
	beq $t1,5,orange
	beq $t1,6,purple
	beq $t1,7,pink
	
	red:
	li $t1, 0xFF0000
	j draw_rest_cur        # $t1 = red color for Tetris piece 0xFF0000
	
	blue:
	li $t1, 0x0000FF
	j draw_rest_cur
	
	
	green:
	li $t1, 0x00FF00
	j draw_rest_cur
	
	yellow:
	li $t1, 0xFFF000
	j draw_rest_cur
	
	orange:
	li $t1, 0xFFA500
	j draw_rest_cur
	
	purple:
	li $t1, 0x800080
	j draw_rest_cur
	
	pink:
	li $t1, 0xFFC0CB
	j draw_rest_cur
	
	
	draw_rest_cur:
	la $s0, blockPos
	
	
	##Check game over
	lw $t2, ADDR_DSPL
    			lw $t3, 0($s0)
    			lw $t4, 4($s0)
    			lw $t5, 8($s0)
    			lw $t6, 12($s0)
    
    			sub $t3, $t3, $t2
    			sub $t4, $t4, $t2
    			sub $t5, $t5, $t2
    			sub $t6, $t6, $t2
    
    			la $t7, pastBlocks
    
    			add $t3, $t3, $t7
    			add $t4, $t4, $t7
    			add $t5, $t5, $t7
    			add $t6, $t6, $t7
    			
    			lw $t3, 0($t3)
    			lw $t4, 0($t4)
    			lw $t5, 0($t5)
    			lw $t6, 0($t6)
    			
    			bnez $t3, game_over
    			bnez $t4, game_over
    			bnez $t5, game_over
    			bnez $t6, game_over
	
	
	
	
	###

	

    	lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    	sw $t1, 0($t2)
    	
    	lw $t2, 4($s0)          # Load the address from the first index of the struct into $t2
    	sw $t1, 0($t2) 
    	
    	  
    	lw $t2, 8($s0)          # Load the address from the first index of the struct into $t2
    	sw $t1, 0($t2)
    	
    	lw $t2, 12($s0)          # Load the address from the first index of the struct into $t2
    	sw $t1, 0($t2)    
    	jr $ra
####


# KEYBOARD INPUT ############


keyboard_input: # checks if there is actual keyboard input, if there is goes to the input handler function


    li 		$v0, 32
    li 		$a0, 1
    syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_handle      # If first word 1, key is pressed
    jr $ra
     
    
keyboard_handle:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x61, respond_to_A       # Check if 'A' was pressed
    beq $a0, 0x73, respond_to_S       # Check if 'S' was pressed
    beq $a0, 0x64, respond_to_D       # Check if 'D' was pressed
    beq $a0, 0x71, respond_to_Q 	      #Check if 'Q' was pressed
    beq $a0, 0x72, respond_to_R
    beq $a0, 0x70, respond_to_P
    jr $ra


respond_to_P: #pause




pattern_1b:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    li $t5, 1

j draw_backgroundb

logic_backgroundb:
    bgt $t5, 16, pattern_2b
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_backgroundb:
    bgt $t2, $t3, logic_backgroundb
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t4, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_backgroundb
    
pattern_2b:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    addi $t0, $t0, 64
    li $t5, 1

j draw_background2b

logic_background2b:
    bgt $t5, 16, wall_logicb
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_background2b:
    bgt $t2, $t3, logic_background2b
    sw $t4, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_background2b

wall_logicb:
    li $t2, 1
    li $t3, 33
    li $t1, 0x808080         # $t1 = gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display

draw_wallsb:
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 60($t0)          # paint the corresponding unit on the right side gray
    addi $t0, $t0, 64        # increment to the unit below the one we are currently painting
    addi $t2, $t2, 1         # Update counter
    bne $t2, $t3, draw_wallsb # loop condition i = 1, i < 33 (since 16 x 32 display)

li $t2, 2
li $t3, 16    
addi $t0, $t0, -60          # Resetting mem address for last row
    
draw_floorb:
    sw $t1, 0($t0)
    addi $t0, $t0, 4        # iterate to adjacent unit
    addi $t2, $t2, 1
    bne $t2, $t3, draw_floorb



    
pause_cycle:
    li 		$v0, 32
    li 		$a0, 1
    syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_handle2      # If first word 1, key is pressed
    li $v0, 32 
    li $a0, 1000
    syscall
    j pause_cycle
    
   keyboard_handle2:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x70, respond_to_P2
    li $v0, 32 
    li $a0, 1000
    syscall
    j pause_cycle
    
    
    respond_to_P2:
    	jr $ra
    
  

	
    
    

	

respond_to_A: #left
	
	lw $t0 ADDR_DSPL
	lw $t1, 0($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,-4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece left
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 4($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,-4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece left
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 8($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,-4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece left
	###
	lw $t0 ADDR_DSPL
	lw $t1, 12($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,-4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece left
	
	###
	
	j move_left #means that there is no piece to the left
	
	no_left:
		jr $ra
	

    move_left:
    
    	lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    	addi $t2, $t2,-4
    	sw $t2, 0($s0)
    
    
    	lw $t2, 4($s0)          # Load the address from the first index of the struct into $t2
    	addi $t2, $t2,-4
    	sw $t2, 4($s0)
    
    
    	lw $t2, 8($s0)          # Load the address from the first index of the struct into $t2
    	addi $t2, $t2,-4
    	sw $t2, 8($s0)
    
    
    	lw $t2, 12($s0)          # Load the address from the first index of the struct into $t2
    	addi $t2, $t2,-4
    	sw $t2, 12($s0)
    
    	jr $ra

respond_to_S: #down

	lw $t0 ADDR_DSPL
	lw $t1, 0($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,64
	lw $t5, 0($t4)
	
	bne $t5,$zero,save_block #there is a piece below
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 4($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,64
	lw $t5, 0($t4)
	
	bne $t5,$zero,save_block #there is a piece below
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 8($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,64
	lw $t5, 0($t4)
	
	bne $t5,$zero,save_block #there is a piece below
	
	##
	
	lw $t0 ADDR_DSPL
	lw $t1, 12($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,64
	lw $t5, 0($t4)
	
	bne $t5,$zero,save_block #there is a piece below
	
	#####
	

	move_down:
    
    		lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,64
    		sw $t2, 0($s0)
    
    
    		lw $t2, 4($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,64
    		sw $t2, 4($s0)
    
    
    		lw $t2, 8($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,64
    		sw $t2, 8($s0)
    
    
    		lw $t2, 12($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,64
    		sw $t2, 12($s0)
    
    		jr $ra

respond_to_D: #right

	lw $t0 ADDR_DSPL
	lw $t1, 0($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece right
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 4($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece right
	
	###
	
	lw $t0 ADDR_DSPL
	lw $t1, 8($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_left #there is a piece right
	###
	lw $t0 ADDR_DSPL
	lw $t1, 12($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	addi $t4,$t4,4
	lw $t5, 0($t4)
	
	bne $t5,$zero,no_right #there is a piece right
	
	###
	
	j move_right #means that there is no piece to the left
	
	no_right:
		jr $ra
    	move_right:
    

    		lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,4
    		sw $t2, 0($s0)
    
    
    		lw $t2, 4($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,4
    		sw $t2, 4($s0)
    
    
    		lw $t2, 8($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,4
    		sw $t2, 8($s0)
    
    
    		lw $t2, 12($s0)          # Load the address from the first index of the struct into $t2
    		addi $t2, $t2,4
    		sw $t2, 12($s0)
    		

    		jr $ra
respond_to_Q: #quit
	j exit

respond_to_R: #rotate first find shape
	lw $t4, 16($s0)
	
	beq $t4, 1, rotate_I# I shape
	beq $t4, 3, rotate_L
	beq $t4, 4, rotate_J
	beq $t4, 5, rotate_S
	beq $t4, 6, rotate_Z
	beq $t4, 7, rotate_T
	
	jr $ra
	
	
	rotate_I: #find rotation and rotate accordingly for I
		lw $t3, 20($s0)
		
		beq $t3, 1, rotate_I_1
		beq $t3, 2, rotate_I_2
		
		
		rotate_I_1:
		
			lw $t2, ADDR_DSPL
    			lw $t3, 0($s0)
    			lw $t4, 4($s0)
    			lw $t5, 8($s0)
    			lw $t6, 12($s0)
    
    			sub $t3, $t3, $t2
    			sub $t4, $t4, $t2
    			sub $t5, $t5, $t2
    			sub $t6, $t6, $t2
    
    			la $t7, pastBlocks
    
    			add $t3, $t3, $t7
    			add $t4, $t4, $t7
    			add $t5, $t5, $t7
    			add $t6, $t6, $t7
    
    			lw $t3, -120($t3)
    			lw $t4, -56($t4)
    			lw $t6, 60($t6)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate
    			
			yes_I_1:
			
			lw $t0, 8($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -128
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 12($s0)
			
			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
			
			
			no_rotate:
				jr $ra
			
			
		
		rotate_I_2:
			
			lw $t2, ADDR_DSPL
    			lw $t3, 0($s0)
    			lw $t4, 4($s0)
    			lw $t5, 8($s0)
    			lw $t6, 12($s0)
    
    			sub $t3, $t3, $t2
    			sub $t4, $t4, $t2
    			sub $t5, $t5, $t2
    			sub $t6, $t6, $t2
    
    			la $t7, pastBlocks
    
    			add $t3, $t3, $t7
    			add $t4, $t4, $t7
    			add $t5, $t5, $t7
    			add $t6, $t6, $t7
    
    			lw $t3, 120($t3)
    			lw $t4, 56($t4)
    			lw $t6, -60($t6)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

		
			yes_I_2:
			
			lw $t0, 8($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -8
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 12($s0)
			
			li $t5 1
			sw $t5, 20($s0) #set the current orientation to position 1
			
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
			
			
			jr $ra
		
	rotate_L:
		
		lw $t3, 20($s0)
		
		beq $t3, 1, rotate_L_1
		beq $t3, 2, rotate_L_2
		beq $t3, 3, rotate_L_3
		beq $t3, 4, rotate_L_4
		rotate_L_1:
		
		
			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, 4($t4)
    			lw $t4, -4($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			

			yes_L_1:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, 60
			sw $t1, 12($s0)

			
			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		
   		rotate_L_2:
   		
   			
   			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -64($t4)
    			lw $t4, 64($t4)
    			lw $t6, -68($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate
    			
   			yes_L_2:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, -68
			sw $t1, 12($s0)

			
			li $t5 3 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_L_3:
   		
   			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -4($t4)
    			lw $t4, 4($t4)
    			lw $t6, -60($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate
   		yes_L_3:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 12($s0)

			
			li $t5 4 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_L_4:
   		
   			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -64($t4)
    			lw $t4, 64($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate

   		yes_L_4:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, 68
			sw $t1, 12($s0)

			
			li $t5 1 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
	rotate_J:
		lw $t3, 20($s0)
		
		beq $t3, 1, rotate_J_1
		beq $t3, 2, rotate_J_2
		beq $t3, 3, rotate_J_3
		beq $t3, 4, rotate_J_4
		
		rotate_J_1:
		
			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, 4($t4)
    			lw $t4, -4($t4)
    			lw $t6, -68($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_J_1:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, -68
			sw $t1, 12($s0)

			
			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_J_2:
   			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, 64($t4)
    			lw $t4, -64($t4)
    			lw $t6, -60($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_J_2:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 12($s0)

			
			li $t5 3 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_J_3:
   		
   		lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, 4($t4)
    			lw $t4, -4($t4)
    		

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_J_3:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, 68
			sw $t1, 12($s0)

			
			li $t5 4 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_J_4:
   		
   			lw $t2, ADDR_DSPL
    			lw $t4, 4($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -64($t4)
    			lw $t4, 64($t4)


    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_J_4:
			
			lw $t0, 4($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, 60
			sw $t1, 12($s0)

			
			li $t5 1 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
	rotate_S:
		lw $t3, 20($s0)
		
		beq $t3, 1, rotate_S_1
		beq $t3, 2, rotate_S_2
		
		
		rotate_S_1:
			
			lw $t2, ADDR_DSPL
    			lw $t4, 0($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -64($t4)
    			lw $t4, 68($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			

			yes_S_1:
			
			lw $t0, 0($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, 68
			sw $t1, 12($s0)

			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_S_2:
   			lw $t2, ADDR_DSPL
    			lw $t4, 0($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -60($t4)
    			lw $t4, -56($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate

			yes_S_2:
			
			lw $t0, 0($s0)

			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 8($s0)
			
			move $t1, $t0
			addi $t1, $t1, -56
			sw $t1, 12($s0)
			
			li $t5 1 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		
	rotate_Z:
		lw $t3, 20($s0)
		
		beq $t3, 1, rotate_Z_1
		beq $t3, 2, rotate_Z_2
		
		
		rotate_Z_1:
		
			lw $t2, ADDR_DSPL
    			lw $t4, 8($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -60($t4)
    			lw $t4, 64($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate

			yes_Z_1:
			
			lw $t0, 8($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 4($s0)

			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_Z_2:
   			
   			lw $t2, ADDR_DSPL
    			lw $t4, 8($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -68($t4)
    			lw $t4, -64($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate

			yes_Z_2:
			
			lw $t0, 8($s0)

			move $t1, $t0
			addi $t1, $t1, -68
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 4($s0)
			
			li $t5 1 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
	rotate_T:
		lw $t3, 20($s0)
		beq $t3, 1, rotate_T_1
		beq $t3, 2, rotate_T_2
		beq $t3, 3, rotate_T_3
		beq $t3, 4, rotate_T_4
		
		rotate_T_1:
		
			lw $t2, ADDR_DSPL
    			lw $t4, 12($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -60($t4)
    			lw $t4, 4($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_T_1:
			
			lw $t0, 12($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 4
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, 68
			sw $t1, 8($s0)

			
			li $t5 2 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_T_2:
   		
   			lw $t2, ADDR_DSPL
    			lw $t4, 12($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, 60($t4)
    			lw $t4, 64($t4)
    			

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_T_2:
			
			lw $t0, 12($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, 60
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, 64
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, 68
			sw $t1, 8($s0)

			
			li $t5 3 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_T_3:
   		
   			lw $t2, ADDR_DSPL
    			lw $t4, 12($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -68($t4)
    			lw $t4, -4($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_T_3:
			
			lw $t0, 12($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -68
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -4
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, 60
			sw $t1, 8($s0)

			
			li $t5 4 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra
   		rotate_T_4:
   			
   			lw $t2, ADDR_DSPL
    			lw $t4, 12($s0)
    			sub $t4, $t4, $t2
    			
    
    			la $t7, pastBlocks
    			add $t4, $t4, $t7

    			lw $t3, -68($t4)
    			lw $t4, -64($t4)
    			lw $t6, -60($t4)

    			bnez $t3, no_rotate
    			bnez $t4, no_rotate
    			bnez $t6, no_rotate

			yes_T_4:
			
			lw $t0, 12($s0)
			
			
			move $t1, $t0
			addi $t1, $t1, -68
			sw $t1, 0($s0)
			
			move $t1, $t0
			addi $t1, $t1, -64
			sw $t1, 4($s0)
			
			move $t1, $t0
			addi $t1, $t1, -60
			sw $t1, 8($s0)

			
			li $t5 1 #set the current orientation to position 2
			sw $t5, 20($s0)
			
			li $v0, 31
   			li $a0, 50
   			li $a1, 400
   			li $a2, 10
   			li $a3, 70
   			syscall
   			
   			jr $ra

#############################################################

save_block:
	la $t0, pastBlocks
	lw $t1 ADDR_DSPL
	
	##
	lw $t0 ADDR_DSPL
	lw $t1, 0($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	
	lw $t5,16($s0)
	
	
	li $v0, 1          # Set syscall for printing an integer
    	move $a0, $t5      # Move the value to be printed into $a0
    	syscall            # Print the integer
    	
    	
	sw $t5, 0($t4)
	
	##
	lw $t0 ADDR_DSPL
	lw $t1, 4($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	
	lw $t5,16($s0)
	sw $t5, 0($t4)
	
	##
	
	lw $t0 ADDR_DSPL
	lw $t1, 8($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	
	lw $t5,16($s0)
	sw $t5, 0($t4)
	
	##
	lw $t0 ADDR_DSPL
	lw $t1, 12($s0)
	sub $t2, $t1,$t0
	
	la $t3, pastBlocks
	
	add $t4,$t3,$t2
	
	lw $t5,16($s0)
	sw $t5, 0($t4)
	
	##
	
	la $t0,editStatus
	li $t1, 0
	sw $t1,0($t0)
	
	# Save block sound
	li $v0, 31
   	li $a0, 80
   	li $a1, 400
   	li $a2, 10
   	li $a3, 70
   	syscall
	
	jr $ra

####

break_check:


	la $t0, pastBlocks      # Load the base address of the grid into $t0

	li $t1, 0         # Initialize i to 0
	
	outer_loop:
    		bge $t1, 31, end_outer_loop  # if i >= 31, exit the outer loop

    		move $t2, $t0     # temp = grid
    		li $t3, 0         # counter = 0

    		li $t4, 0         # Initialize j to 0
	inner_loop:
    		bge $t4, 16, end_inner_loop  # if j >= 16, exit the inner loop

    		lw $t5, 0($t0)    # load grid[j] into $t5
    		beqz $t5, skip    # if grid[j] == 0, skip incrementing counter

    		addi $t3, $t3, 1  # counter++

	skip:
    		addi $t0, $t0, 4  # grid += 4
    		addi $t4, $t4, 1  # j++

    		j inner_loop      # Repeat inner loop

	end_inner_loop:
    		li $t6, 16        # Assuming length is 16
    		bne $t3, $t6, skip_del_row  # if counter != length, skip deleting row

    		
    		j del_row       # Jump to del_row function

	skip_del_row:
    		addi $t0, $t2,64 # Move grid pointer to the next row (16 * 4 bytes per row)
    		addi $t1, $t1, 1  # i++

    		j outer_loop      # Repeat outer loop

	end_outer_loop:
    		j yeah
	del_row:
    		# Implement the row deletion logic here
    		# For simplicity, assume we zero out the row
    		li $t7, 14         # Set counter to 16
    		addi $t2,$t2, 4
    		
	del_row_loop:
    		beqz $t7, end_del_row 
     		
     		sub $t8, $t2, $s3
     		add $t9, $s2, $t8
     		sw $s4, 0($t9)

     		sw $zero, 0($t2)  
     		addi $t2, $t2, 4  
     		subi $t7, $t7, 1 
     		
     		
     		li $v0, 32 
		li $a0, 100
		syscall
     		
    		j del_row_loop    # Repeat del_row loop
    
    	end_del_row:
    		# Save block sound
		li $v0, 31
   		li $a0, 65
   		li $a1, 400
   		li $a2, 10
   		li $a3, 70
   		syscall
    		jal gravity_check
    		j skip_del_row

gravity_check:
    # Set up the starting address and the end address for the outer loop
    la $t3, pastBlocks  # Load the base address of pastBlocks
    addi $t0, $t3, 1984 # Starting address (address of pastBlocks[495])
    addi $t1, $t3, 0    # End address (address of pastBlocks[0])

outer_loop2:
    # Check if we've reached the end of the outer loop
    blt $t0, $t1, end_outer_loop2

    # Load the value at the current address
    lw $t5, 0($t0)      # Load pastBlocks[t0]

    # If the current block is zero, skip to the next iteration
    beqz $t5, next_iteration2

    # Calculate the address of the block below
    addi $t6, $t0, 64   # Address of the block below (16 units down, 16 * 4 bytes)

    # Load the value at the address of the block below
    lw $t9, 0($t6)      # Load pastBlocks[t6]

    # If the block below is non-zero, skip to the next iteration
    bnez $t9, next_iteration2

    # Move the current block down
    sw $t5, 0($t6)      # Store the current block value in the block below
    sw $zero, 0($t0)    # Set the current block value to zero

next_iteration2:
    addi $t0, $t0, -4   # Decrement the outer loop address (move up one row)
    j outer_loop2       # Repeat outer loop

end_outer_loop2:
    jr $ra
    
game_over:

pattern_1c:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    li $t5, 1

j draw_backgroundc

logic_backgroundc:
    bgt $t5, 16, pattern_2c
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_backgroundc:
    bgt $t2, $t3, logic_backgroundc
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t4, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_backgroundc
    
pattern_2c:
    li $t2, 1
    li $t3, 8
    li $t1, 0x1b1b1b         # $t1 = light gray
    li $t4, 0x17161A         # $t4 = dark gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display
    addi $t0, $t0, 64
    li $t5, 1

j draw_background2c

logic_background2c:
    bgt $t5, 16, wall_logicc
    addi $t0, $t0, -8
    li $t2, 1
    li $t3, 8
    addi $t5, $t5, 1
    addi $t0, $t0, 72
    
draw_background2c:
    bgt $t2, $t3, logic_background2c
    sw $t4, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 4($t0)           # paint the corresponding unit on the right side gray
    addi $t0, $t0, 8
    addi $t2, $t2, 1
    j draw_background2c

wall_logicc:
    li $t2, 1
    li $t3, 33
    li $t1, 0x808080         # $t1 = gray
    lw $t0, ADDR_DSPL        # $t0 = base address for display

draw_wallsc:
    sw $t1, 0($t0)           # paint the first unit (i.e., top-left) gray
    sw $t1, 60($t0)          # paint the corresponding unit on the right side gray
    addi $t0, $t0, 64        # increment to the unit below the one we are currently painting
    addi $t2, $t2, 1         # Update counter
    bne $t2, $t3, draw_wallsc # loop condition i = 1, i < 33 (since 16 x 32 display)

li $t2, 2
li $t3, 16    
addi $t0, $t0, -60          # Resetting mem address for last row
    
draw_floorc:
    sw $t1, 0($t0)
    addi $t0, $t0, 4        # iterate to adjacent unit
    addi $t2, $t2, 1
    bne $t2, $t3, draw_floorc

## Drawing LOSE
    li $t1, 0xFF0000       # $t1 = blue color for Tetris piece
    lw $t0, ADDR_DSPL       # $t0 = base address for display
    addi $t0, $t0, 536      # Move to the middle of the display and shift 4 units right (128/2 - 4 units * 8 pixels/unit / 2 + 4 units * 8 pixels)
    li $t2, 4               # length of the "I" piece (4 units)
    
    sw $t0, 0($s0)
    lw $t2, 0($s0)          # Load the address from the first index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    addi $t0, $t0, 64
    sw $t0, 4($s0)
    lw $t2, 4($s0)          # Load the address from the second index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)          # Store the red color value at the address in $t2
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)
    
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)
    
    addi $t0, $t0, 64
    sw $t0, 8($s0)
    lw $t2, 8($s0)          # Load the address from the third index of the struct into $t2
    sw $t1, 0($t2)
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)
    
    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)

    
    addi $t0, $t0, 4
    sw $t0, 12($s0)
    lw $t2, 12($s0)          # Load the address from the fourth index of the struct into $t2
    sw $t1, 0($t2)
    
    #Lose sound
    
    li $v0, 31
   li $a0, 20
   li $a1, 800
   li $a2, 10
   li $a3, 70
   syscall
   
   li $v0, 31
   li $a0, 10
   li $a1, 800
   li $a2, 10
   li $a3, 70
   syscall
    
lose_cycle:
    li 		$v0, 32
    li 		$a0, 1
    syscall

    lw $t0, ADDR_KBRD               # $t0 = base address for keyboard
    lw $t8, 0($t0)                  # Load first word from keyboard
    beq $t8, 1, keyboard_handle3      # If first word 1, key is pressed
    li $v0, 32 
    li $a0, 1000
    syscall
    j lose_cycle
    
   keyboard_handle3:
    lw $a0, 4($t0)                  # Load second word from keyboard
    beq $a0, 0x65, respond_to_e
    li $v0, 32 
    li $a0, 1000
    syscall
    j lose_cycle
    
    
    respond_to_e:
    	j main


    

    	

exit:
    li $v0, 10              # terminate the program gracefully
    syscall
