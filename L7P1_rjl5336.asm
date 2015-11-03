.data
Stack_Begin:
		.word	0:40
Stack_End:
Colors:	
		.word 0x000000 	#colors + 0 	black	color[0]
		.word 0x0000ff 	#colors + 4 	blue	color[1]
		.word 0x00ff00 	#colors + 8 	green	color[2]
		.word 0xff0000 	#colors + 12 	red	color[3]
		.word 0xff00ff 	#colors + 16 	purple	color[4]
		.word 0xffffff 	#colors + 20 	white	color[5]
		.word 0x00ffff	#colors + 24	cyan	color[6]
		.word 0xffff00	#colors + 28	yellow	color[7]
FlashColorTable:	#numbers to load into $a0, $a1, and $a2 respectively.
		.word  2,  2,  7	#1
		.word 19,  2,  6	#2
		.word  2, 19,  2	#3
		.word 19, 19,  3	#4
simons_colors:	.word 0:11
users_colors:	.word 0:11
SS_msg:		.asciiz "\nSimon Said: "
win_msg:	.asciiz "\nCongratulations, you've won!"
roundend:	.asciiz "\nYou won the round! Next round starts soon, get ready!"
diffSel_msg:	.asciiz "Please select your difficulty: easy(1), medium(2), hard(3): "


.text
#################################################################################################################################################
# Notes: RNG 4 (as an example) refers to a random number generator given the number 4. RNG 0 would be a RNG with number 0, etc.			#
#-----------------------------------------------------------------------------------------------------------------------------------------------#
# Procedure Name	- Input List		- Output List	- Description							   		#
#-----------------------------------------------------------------------------------------------------------------------------------------------#
# CheckAnswer		- $a0, $a1, $a2		- 		- Checks an answer given versus the correct answer. Exits if it was wrong.	#
# ChooseRNG		- 			- $a0		- Picks a random number from 0 to 3. Requires a RNG 4.				#
# ClearDisplay		- 			-		- Repaints the screen so it looks like it has been cleared.			#
# CoordConverter	- $a0, $a1		- $v0		- Takes in an (x, y) coord and returns where you should change in memory.	#
# DrawDot		- $a0, $a1, $a2		-		- draws a dot at whatever (x, y) coord in whatever color you specified.		#
# DrawHorizLine		- $a0, $a1, $a2, $a3	-		- draws a horizontal line in the color and position given.			#
# DrawSquare		- $a0, $a1, $a2, $a3	-		- draws a square, starting at (x, y) given and going for z lines.		#
# DrawVertLine		- $a0, $a1, $a2, $a3	-		- draws a vertical line in the color and position given.			#
# FlashColor		- $a0, $a1		-		- Flashes a color, input number determines color and location.			#
# FlashSequence		- $a0, $a1, $a2		-		- Flahses a sequence of colors, based on our array of colors.			#
# GetColor		- $a0			- $v0		- takes in a number (0-7) and returns its color from the table below		#
# GetDifficulty		- $a0			- $v0		- Used for determining the difficulty level a user wasnts.			#
# GetInputs		- $a0, $a1, $a2, $a3	-		- gets as many integer inputs are needed to copy simon.				#
# GetgenRand		- $a0			- $v0		- gets a random number from 0 - $a0. Returns it into $v0			#
# Make5RNG		- $a0			-		- Makes 5 RNG's. Starts numbering them at $a0. ($a0 = 0, RNG = 0, 1, 2, etc.)	#
# MakeRNG		- $a0			-		- Makes a random number generator (based on time) and numbers it $a0.		#
# PauseTime		- $a0 			- 		- time you want to pause in milliseconds.					#
# genRand		- $a0, $a1		- $v0		- gets a random number, up to whatever is in $a1.				#
#################################################################################################################################################

#################################################################################
# 				Color Table					#
#################################################################################
# 0x000000		Black		Colors[0]		Colors + 0	#
# 0x0000ff		Blue		Colors[1]		Colors + 4	#
# 0x00ff00		Green		Colors[2]		Colors + 8	#
# 0xff0000		Red		Colors[3]		Colors + 12	#
# 0xff00ff		Purple		Colors[4]		Colors + 16	#
# 0xffffff		White		Colors[5]		Colors + 20	#
# 0x00ffff		Cyan		Colors[6]		Colors + 24	#
# 0xffff00		Yellow		Colors[7]		Colors + 28	#
#################################################################################

Stack_Init:
	la 	$sp, Stack_End
Main:
	la	$a0, diffSel_msg	#difficulty selection message
	jal GetDifficulty
	addiu	$s3, $v0, -48
	li 	$t9, 1500
	div	$s4, $t9, $s3
	mul	$s3, $s3, 3
	addi	$s3, $s3, 3		#need to complete difficulty * 3 + 2. Aka - 5 for easy, 8 for medium, 11 for hard. The extra +1 is because we're doing less than.
	
	addi	$s0, $0, 1		#set this equal to 1 initially. $s0 is used to count how many colors should display before asking for input.
	la	$s1, simons_colors	#load our correct answer array's address into $s1
	la	$s2, users_colors	#load our user's answer's array's address into $s2
	add 	$a0, $0, $0		#Zero this out
	
	jal ClearDisplay		#makes our graphic appear with its basic design
	jal Make5RNG			#makes our 5 random number generators
Main_Loop:

	addi 	$a0, $0, 3
	jal GetgenRand			#gets a random number 0 - 3
	
	addiu	$v0, $v0, 1		#turns it into  1-4
	
	subi	$t0, $s0, 1
	mul	$t0, $t0, 4
	add	$t9, $s1, $t0		#saves our random number into memory, the correct spot in memory based on which number it is.
	sw	$v0, 0($t9)
	
	la	$a0, simons_colors
	la 	$a1, FlashColorTable
	move	$a2, $s0
	jal FlashSequence		#flashes all the colors in their order
		
	move 	$a0, $s0
	move 	$a1, $s2
	la	$a2, SS_msg
	move	$a3, $s1
	jal GetInputs			#gets our inputs. one for each value printed.

	addi 	$s0, $s0, 1		#add 1 to our counter, so if we loop again we do another number	
			
	bge	$s0, $s3, Skip_Pause
	
	la 	$a0, roundend
	li	$v0, 4
	syscall				#pause between rounds
	move	$a0, $s4
	jal PauseTime

Skip_Pause:
	
	blt 	$s0, $s3, Main_Loop	#if we haven't done a 5 number sequence yet, run it again.
	
	la 	$a0, win_msg		
	li 	$v0, 4
	syscall				#print out our win message
	
	li 	$v0, 10
	syscall				#exit the program
	
#Procedure: CheckAnswer
#this procedure will check a specific answer versus the answer it's supposed to match.
#Input: $a0 - our specific answer
#Input: $a1 - which number it should be (I.E. 1 -> array[0])
#Input: $a2 - address of our answer array
.data
fail_msg:	.asciiz "\nSorry, but you didn't get the sequence quite right."		#error message specifically for this procedure
.text
CheckAnswer:
	addiu	$a1, $a1, -1	#turns our number into an array-scale number (0-(x-1)) instead of (1-x)
	sll	$a1, $a1, 2	#multiplies our number by 4
	add	$a2, $a2, $a1	#adds our number to the array address
	lw	$t9, 0($a2)	#loads the number at ^that address
	bne	$a0, $t9, CA_Fail	#if it is equal to the number we had as an answer, return to where we came from. otherwise, fail(below)
	jr	$ra
CA_Fail:
	la 	$a0, fail_msg		#print out a fail message
	li	$v0, 4
	syscall
	
	li	$v0, 10
	syscall				#exit program
	
#Procedure: ChooseRNG
#Output: $a0 - holds a value 0-3; to be used to choose which RNG to use to get an RNG (adds a level of randomness?)
ChooseRNG:
	addi 	$a1, $0, 4
	li 	$v0, 42
	syscall		#get a random number, 0 - 3
	jr 	$ra
		
#Procedure: ClearDisplay
#This procedure just repaints our whole display black.
ClearDisplay:
	addiu 	$sp, $sp, -4
	sw 	$ra, 0($sp)		#shift stack and preserve $ra
	
	li	$a0, 0
	li	$a1, 0
	li	$a2, 0
	li	$a3, 32
	jal DrawSquare			#draw a black square over the whole screen

	li	$a0, 0
	li	$a1, 16
	li	$a2, 5
	li	$a3, 32
	jal DrawHorizLine
	
	li	$a0, 0
	li	$a1, 15
	li	$a2, 5
	li	$a3, 32
	jal DrawHorizLine
	
	li	$a0, 16
	li	$a1, 0
	li	$a2, 5
	li	$a3, 32
	jal DrawVertLine
	
	li	$a0, 15
	li	$a1, 0
	li	$a2, 5
	li	$a3, 32
	jal DrawVertLine
	
	
	lw	$ra, 0($sp)
	addiu	$sp, $sp, 4		#restore $ra and stack, jump back to where we came from
	jr	$ra
	
#Procedure: CoordConverter
#this procedure takes coordinates in (x, y) and converts them into a memory address. Assumes certain settings for graphics display:
#Heap base (0x10040000); 8 x 8 dots, 256 x 256 dimensions.
#Input: $a0 - x coordinate
#Input: $a1 - y coordinate
#Output: $v0 - memory addresss
CoordConverter:
	li 	$v0, 0x10040000		#assumes our base address is 0x10040000 (the heap setting)
				
	sll 	$a1, $a1, 7		#calculates down rows (*128)
	
	sll 	$a0, $a0, 2		#calculates over spaces (*4)
	
	add 	$v0, $v0, $a0		
	add 	$v0, $v0, $a1		#adds our extra spaces to our address so we got the right spot, stores it in $v0.
	
	jr 	$ra
	
#Procedure: DrawDot
#this procedure will draw a single dot of the color specified at the location specified.
#Input: $a0 - x coordinate we want to draw the dot at
#Input: $a1 - y coordinate we want to draw the dot at
#Input: $a2 - number of the color we want to use (0-7), see table at top for more details
DrawDot:
	addiu 	$sp, $sp, -8
	sw 	$ra, 4($sp)
	sw 	$a2, 0($sp)		#save $ra and $a2, shift stack accordingly
	
	jal CoordConverter		#turn (x, y) into a memory address
	
	lw 	$a0, 0($sp)		#take $a2 out of stack and place it into $a0
	sw	$v0, 0($sp)		#save $v0 (output from CoordConverter) onto the stack
	
	jal GetColor
	
	lw 	$t9, 0($sp)		#load the recently saved $v0 into $t9
	sw	$v0, 0($t9)		#save our color into the memory slot specified there^. 
	
	lw 	$ra, 4($sp)
	addiu 	$sp, $sp, 8		#fix stack pointer, load $ra, go back to where we're from
	jr	$ra

#Procedure: DrawHorizLine
#this procedure will draw a horizontal line starting at the location given, and going as many spots specified in $a3.
#Input: $a0 - x coordinate to start drawing at
#Input: $a1 - y coordinate to start drawing at
#Input: $a2 - number of the color we want to use (0-7), see table at top for more details
#Input: $a3 - how long of a line we want
DrawHorizLine:
	addiu 	$sp, $sp, -20		#reserve space for $ra and all 4 $a registers
	sw 	$ra, 16($sp)
DHL_Loop:
	sw	$a0, 12($sp)		#save $a registers
	sw	$a1, 8($sp)
	sw 	$a2, 4($sp)
	sw	$a3, 0($sp)
	
	jal DrawDot			#draws a dot in the specific space we want
	
	lw 	$a0, 12($sp)		#Restore our $a registers
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	lw	$a3, 0($sp)
	
	addiu	$a0, $a0, 1		#move over one space and lower the amount of dots left to print
	addiu	$a3, $a3, -1		#decrement our counter
	
	bgtz	$a3, DHL_Loop		#loop again if our number of dots left is >0
	
	lw	$ra, 16($sp)
	addiu 	$sp, $sp, 20		#load $ra, fix our stack, and head back where we came from.
	jr	$ra


#Procedure: DrawSquare
#this procedure will draw a square, starting at the ($a0, $a1) coordinates, in color $a2, and it will be $a3 x $a3.
#Input: $a0 - x coordinate to start the square at
#Input: $a1 - y coordinate to start the square at
#Input: $a2 - color to draw the box in
#Input: $a3 - how big to make the square (I.E. 5x5)
DrawSquare:
	addiu	$sp, $sp, -24		#allocate space for $ra, $a0-$a3, and $s0.
	sw 	$ra, 20($sp)
	sw	$s0, 16($sp)		#save $ra and $s0
	move 	$s0, $a3		#use $s0 as a counter
DS_Loop:
	sw	$a0, 12($sp)		#save $a registers
	sw	$a1, 8($sp)
	sw 	$a2, 4($sp)
	sw	$a3, 0($sp)
	
	jal DrawHorizLine		#draw a horizontal line
	
	lw 	$a0, 12($sp)		#Restore our $a registers
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	lw	$a3, 0($sp)
	
	addiu 	$s0, $s0, -1		#mark one line as done on our counter
	addiu 	$a1, $a1, 1		#move our coordinates so we start on the next line
	bgtz	$s0, DS_Loop		#keep looping until our counter is zero
	
	lw	$s0, 16($sp)
	lw	$ra, 20($sp)
	addiu 	$sp, $sp, 24		#load $ra & $s0, fix our stack, and head back where we came from.
	jr	$ra
	
#Procedure: DrawVertLine
#this procedure will draw a vertical line starting at the location given, and going as many spots specified in $a3.
#Input: $a0 - x coordinate to start drawing at
#Input: $a1 - y coordinate to start drawing at
#Input: $a2 - number of the color we want to use (0-7), see table at top for more details
#Input: $a3 - how long of a line we want
DrawVertLine:
	addiu 	$sp, $sp, -20		#reserve space for $ra and all 4 $a registers
	sw 	$ra, 16($sp)
DVL_Loop:
	sw	$a0, 12($sp)		#save $a registers
	sw	$a1, 8($sp)
	sw 	$a2, 4($sp)
	sw	$a3, 0($sp)
	
	jal DrawDot			#draws a dot in the specific space we want
	
	lw 	$a0, 12($sp)		#Restore our $a registers
	lw	$a1, 8($sp)
	lw	$a2, 4($sp)
	lw	$a3, 0($sp)
	
	addiu	$a1, $a1, 1		#move over one space and lower the amount of dots left to print
	addiu	$a3, $a3, -1		#decrement our counter
	
	bgtz	$a3, DVL_Loop		#loop again if our number of dots left is >0
	
	lw	$ra, 16($sp)
	addiu 	$sp, $sp, 20		#load $ra, fix our stack, and head back where we came from.
	jr	$ra

#Procedure: FlashColor
#This procedure takes a number 1-4 and based on that determines which square to flash on our display.
#Input: $a0 - our input number.
#Input: $a1 - memory address for our lookup table
FlashColor:
	addiu 	$sp, $sp -4		#shift stack pointer and save $ra
	sw	$ra, 0($sp)
	
	subi	$a0, $a0, 1		#convert our number to a 0 scale
	mul	$a0, $a0, 12		#turn $a0 into the amount we need to add to our base table address to find the right number
	add	$t9, $a1, $a0		#add ^ that to our base address
	
	lw	$a0, 0($t9)
	lw	$a1, 4($t9)
	lw	$a2, 8($t9)		#load the correct values into $a0 - $a2
	li	$a3, 11			#initialize the size of square to draw.
	jal DrawSquare			#draws the square that we will need to remember
	
	li	$a0, 750
	jal PauseTime			#waits for .75s
	
	jal ClearDisplay		#clears the display
	li	$a0, 500
	jal PauseTime			#wait another half a second
	
	lw	$ra, 0($sp)		#restore $ra and stack pointer, return to where we came from
	addiu 	$sp, $sp 4
	jr	$ra
	
#Procedure: FlashSequence
#this procedure is meant to flash all the colors displayed thusfar.
#Input: $a0 - memory address for the array where we store the values
#Input: $a1 - memory address for our lookup table
#Input: $a2 - amount of times we should loop
FlashSequence:
	addiu	$sp, $sp, -16
	sw	$ra, 12($sp)		#shift our stack and save $ra and $s0-$s2
	sw	$s0, 8($sp)
	sw	$s1, 4($sp)
	sw	$s2, 0($sp)
	
	move 	$s0, $a0		#use $s0-$s2 to hold our $a register values
	move	$s1, $a1
	move	$s2, $a2
FS_Loop:
	addiu	$s2, $s2, -1		#decrement our loop counter
	
	lw	$a0, 0($s0)		
	move	$a1, $s1
	jal FlashColor			#flash the next color in our array
	
	addiu 	$s0, $s0, 4		#shift our array address pointer so we can flash colors correctly.
	bgtz	$s2, FS_Loop		#loop until our counter is zero
	
	lw	$ra, 12($sp)		#restore $ra and $s registers, shift stack pointer back, jump back to where we came from
	lw	$s0, 8($sp)
	lw	$s1, 4($sp)
	lw	$s2, 0($sp)
	addiu 	$sp, $sp, 16
	jr	$ra
	
#Procedure: GetColor
#Takes an input number (0-7) and returns us with the hex representation of the correct color.
#Input: $a0 - the color we want. See the table at the top for details.
#Output: $v0 - returns the color's hex representation.
GetColor:
	la 	$t0, Colors
	sll 	$a0, $a0, 2	#converts our number into the number of spaces we add to the address
	addu 	$a0, $a0, $t0
	lw 	$v0, 0($a0)	#loads from the address for the correct color.
	jr 	$ra

#Procedure: GetDifficulty
#used to determine what difficulty the user wants simon says to be on.
#Input: $a0 - location of our output message
#Output: $v0 - 1, 2, or 3 as an ascii character. Represents difficulty.
.data
GD_Errormsg:	.asciiz	"\nYou didn't enter in a difficulty option. Easy(1), Medium(2), or Hard(3)?: "
.text
GetDifficulty:
	li	$v0, 4			#print out our prompt/message
	syscall
	
	li	$v0, 12
	syscall				#read in a character
	
	beq	$v0, '1', GD_End	#make sure it is one of the characters we accept
	beq	$v0, '2', GD_End
	beq	$v0, '3', GD_End
	
	la	$a0, GD_Errormsg
	j GetDifficulty
GD_End:
	jr	$ra
#Procedure: GetInputs
#This procedure prompts the user for input X amount of times. X is specified in $a2.
#Input: $a0 - this represents a number for looping. it will loop to get input to compare later.
#Input: $a1 - this is the address of the location to store the values into.
#Input: $a2 - this is the address of our prompt
#Input: $a3 - this is the address of our answers
GetInputs:
	addiu 	$sp, $sp, -20
	sw	$ra, 16($sp)		#save our return addresses and S registers
	sw	$s0, 12($sp)
	sw	$s1, 8($sp)
	sw	$s2, 4($sp)
	sw	$a3, 0($sp)
	
	move 	$s0, $a1		#holds the location where we will be storing our values
	add	$s1, $0, $0		#this counts up when we loop
	move	$s2, $a0		#this is our looping counter - counts down
	
	move	$a0, $a2		#load our prompt to be printed
	li 	$v0, 4
	syscall				#print our prompt
GI_Loop:
	subi 	$s2, $s2, 1		#decrement our counter by one
	addi	$s1, $s1, 1		#increment our other counter by one
	
	li 	$v0, 12
	syscall				#read an integer in (As a character) and save it into memory
	addiu	$v0, $v0, -48
	sw 	$v0, 0($s0)
	
	move 	$a0, $v0
	move	$a1, $s1
	lw	$a2, 0($sp)
	jal CheckAnswer			#compares the recent answer with what it should be (saved in an array in memory)
	
	addiu 	$s0, $s0, 4		#shift our memory location over by a word
	bnez 	$s2, GI_Loop		#if our counter is 0 we have done enough, time to end.
	
	lw	$s2, 4($sp)
	lw	$s1, 8($sp)
	lw	$s0, 12($sp)
	lw 	$ra, 16($sp)		#restore our $s registers and $ra, fix our stack pointer, and go back to where we came from
	addiu 	$sp, $sp, 12
	jr 	$ra				

#Procedure: GetgenRand
#Gets a random number, from 0 to the maximum value you're looking for. Requires 5 RNG's to work (0 - 4)
#Input: $a0 is the maximum value you want.
#Output: $v0 is a random number from 0 - 3
GetgenRand:
	addiu 	$sp, $sp, -8
	sw 	$ra, 4($sp)		#store our return address and $a0
	sw 	$a0, 0($sp)		
	jal ChooseRNG		#returns the $a0 we use as an argument for genRand - will be 0-3
	lw 	$a1, 0($sp)		#load $a0 into $a1
	jal genRand		#outputs $v0 as a number 0-($a1)
	lw 	$ra, 4($sp)		#fix our stack and return
	addiu 	$sp, $sp, 8
	jr 	$ra
	
#Procedure: Make5RNG
#Does what its name implies. It will creates 5 RNG's, starting at the number you specify, and using that and the 4 numbers up.
#Input: $a0 - the number you want to start making them at.
Make5RNG:
	addiu	$sp, $sp -8
	sw	$ra, 4($sp)	#save our return address and $a0 (for further RNG usage)
	sw 	$a0, 0($sp)
	jal MakeRNG		#make RNG $a0 + 0
	addi 	$a0, $0, 997
	jal PauseTime		#Pauses to ensure a completely different time.
	lw	$t0, 0($sp)
	addi 	$a0, $t0, 1
	jal MakeRNG		#make RNG $a0 + 1
	addi 	$a0, $0, 873
	jal PauseTime		#Pauses to ensure a completely different time.
	lw	$t0, 0($sp)
	addi 	$a0, $t0, 2
	jal MakeRNG		#make RNG $a0 + 2
	addi 	$a0, $0, 336
	jal PauseTime		#Pauses to ensure a completely different time.
	lw	$t0, 0($sp)
	addi 	$a0, $t0, 3
	jal MakeRNG		#make RNG $a0 + 3
	addi 	$a0, $0, 13
	jal PauseTime		#Pauses to ensure a completely different time.
	lw	$t0, 0($sp)
	addi 	$a0, $t0, 4
	jal MakeRNG		#make RNG $a0 + 4
	addi 	$a0, $0, 742
	jal PauseTime		#Pauses to ensure a completely different time.
	lw 	$ra, 4($sp)		#fix our stack and load our return address
	addiu 	$sp, $sp, 8
	jr 	$ra	

#Procedure: MakeRNG
#Input: $a0 - the number you want to give the RNG.
MakeRNG:
	move 	$t9, $a0
	li 	$v0, 30
	syscall		#get time to use for seed
	move 	$a1, $a0
	move 	$a0, $t9
	li 	$v0, 40
	syscall		#initialize random number generator X.
	jr 	$ra
	
#Procedure: PauseTime
#Input: $a0 - time you want to pause in milliseconds. I.E. 1000 = 1 second. Procedure will pause for one second.
PauseTime:
	move 	$t9, $a0
	li 	$v0, 30
	syscall			#pulls the current system time
	move 	$t0, $a0
PT_Loop:
	syscall
	subu 	$t1, $a0, $t0	#compares time at start to current time
	bltu 	$t1, $t9, PT_Loop	#if it's been as many milliseconds as you wanted to wait, exits the procedure. Otherwise keeps looping.
	
	jr 	$ra	
	

genRand:		# returns random int between 1 and 4 (inclusive)
	li $v0, 30	# put 30 into v0 for get time syscall
	syscall		# call syscall to get time
	move $a0, $v0	# put the time into a0 to seed random number generator
	
	li $v0, 42	# put 42 into v0 for random number gen with upper bound
	li $a1, 4	# put 4 into a1 to set upper bound
	syscall		# create random num in a0
	
	add $a0, $a0, 1	# account for 0 in rand gen
	jr $ra
	
