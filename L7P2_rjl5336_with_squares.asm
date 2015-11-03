###########################################################################################################################
.data															  #
	Stack: .word 0:5												  #
	squares:													  #		
		.word 17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17	  #
		.word 17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17,17	  #
															  #
	youWin: .asciiz "\nYou win the game!!"										  #
	wrong: .asciiz "\nYou loose......"										  #
	return: .asciiz "\n\n\n"											  #
###########################################################################################################################
.text
###########################################################################################################################
main:
	jal drawBoard
	
	li $t0, 5
	la $a2, Stack
	loop1:
		jal genRand
		sw $a0, 0($a2)
		addi $a2, $a2, 4
		addi $t0, $t0, -1
		bne $t0, 0, loop1
	
	#this block is to check if the user got the first number right, if so move to check the next one 	
	la $a0, Stack
	la $s6, 1
	jal disp
	jal dispReturn
	la $a0, Stack
	li $a1, 1
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	#this block is to check if the user got the second number right, if so move to check the next one 	
	la $a0, Stack
	la $s6, 2
	jal disp
	jal dispReturn
	la $a0, Stack
	li $a1, 2
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	#this block is to check if the user got the third number right, if so move to check the next one 
	la $a0, Stack
	la $s6, 3
	jal disp
	jal dispReturn
	la $a0, Stack
	li $a1, 3
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	#this block is to check if the user got the fourth number right, if so move to check the next one 
	la $a0, Stack
	la $s6, 4
	jal disp
	jal dispReturn
	la $a0, Stack
	li $a1, 4
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	#this block is to check if the user got the last number right, if so they win	
	la $a0, Stack
	la $s6, 5
	jal disp
	jal dispReturn
	la $a0, Stack
	li $a1, 5
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	j win
###########################################################################################################################	
###########################################################################################################################	
#Procedure: dispReturn
#creates a new line after number is put in	
dispReturn:	
	la $a0, return
	li $v0, 4
	syscall
	jr $ra
###########################################################################################################################
###########################################################################################################################	
#Procedure check: will compare what the user inputs to what the random num is
#a0 is pointer of stack begining 
#a1 is the number of inputs to check	
check:			
			
	lw $t1, 0($a0)
	checkLoop:
		li $v0 12
		syscall
		addi $t0, $v0, -48
		bne $t0, $t1, incorrect
		add $a0, $a0, 4
		lw $t1, 0($a0)
		add $a1, $a1, -1
		bne $a1, 0, checkLoop
	
	jr $ra
###########################################################################################################################
###########################################################################################################################	
#Procedure disp: this displays the random number on the stack	
#a0 is pointer at begining of stack
#s6 is number of outputs to display	
disp:			
	la $s4, ($ra)
	la $t6, ($a0)
	multNumbers:
		li $v0, 1
		lw $t7, 0($t6)
		beq $t7, 1, block1
		beq $t7, 2, block2
		beq $t7, 4, block3
		block4:
			li $a0, 215
			li $a1, 115
			li $a2, 4
			li $a3, 11
			jal flashBox
			j flashEnd
		block1:
			li $a0, 128
			li $a1, 41
			li $a2, 1
			li $a3, 11
			jal flashBox
			j flashEnd
		block2:
			li $a0, 41
			li $a1, 115
			li $a2, 2
			li $a3, 11
			jal flashBox
			j flashEnd
		block3:
			li $a0, 128
			li $a1, 185
			li $a2, 3
			li $a3, 11
			jal flashBox
			j flashEnd
		

		flashEnd:
		add $t6, $t6, 4
		add $s6, $s6, -1
		bne $s6, 0, multNumbers
	
	jr $s4
###########################################################################################################################
###########################################################################################################################	
#Procedure genRand: returns random int between 1 and 4 	
#Register a0 will hold the random number			
genRand:		
	li $v0, 30		#time syscall
	syscall		
	
	move $a0, $v0		# put the time into a0 to seed random number generator
	
	li $v0, 42		# syscall 42 for random number gen with upper bound
	li $a1, 4		#to set upper bound
	syscall			# create random num in a0
	
	add $a0, $a0, 1		# account for 0 in rand gen
	jr $ra
###########################################################################################################################
###########################################################################################################################	
#Procedure win:  Outputs a string that says you win	
win:		
	la $a0, youWin
	li $v0, 4
	syscall
	j end
###########################################################################################################################
###########################################################################################################################	
#Procedure Incorrect:  Outputs a string that says you loose
incorrect:		
	li $v0, 31
	li $a0, 62
	li $a1, 900
	li $a2, 56
	li $a3, 127
	syscall
	li $a0, 60
	li $a1, 880
	syscall
	li $a0, 61
	li $a1, 880
	syscall
	
	la $a0, wrong
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
###########################################################################################################################
###########################################################################################################################	
#Procedure: draw board
#uses a0-a2 to draw the "X" of the board
drawBoard:		
	la $s5, ($ra)

	li $a0, 0
	li $a1, 0
	li $a2, 5
	jal drawDot
	
	drawLoop1:
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		li $a2, 5
		jal drawDot
		ble $a0, 265, drawLoop1
	
	li $a0, 256
	li $a1, 0
	li $a2, 5
	jal drawDot
	
	drawLoop2:
		addi $a0, $a0, -1
		addi $a1, $a1, 1
		li $a2, 5
		jal drawDot
		bgtz $a0, drawLoop2
	
	jr $s5
###########################################################################################################################
###########################################################################################################################	
#Procedure: flashbox
#Input:a0 as the x coord
#Input:a1 as the y coord
#Input:a2 as the color
#Input: t7 as the id of the square outputted	
flashBox:		
	la $t9, ($ra)
	add $s0, $a0, $zero		# s0 is now the x coord
	add $s2, $a1, $zero		# s2 is now the y coord
	la $t4, squares
	li $s1, 35
	drawCircle:
		lw $t5, 0($t4)
		sub $a0, $s0, $t5
		mul $a3, $t5, 2
		addi $a3, $a3, 1
		jal horizLine
		addi $a1, $a1, 1
		addi $t4, $t4, 4
		addi $s1, $s1, -1
		bgtz $s1, drawCircle
###########################################################################################################################
###########################################################################################################################	
#Procedure:endOutNumb
# where to jump to after the number has been placed on the square
# this pauses the other functions for the sound burst	
endOutNumb:		
	li $v0, 32
	li $a0, 700
	syscall
	
	la $t4, squares
	li $s1, 35
	li $a2, 0
	add $a1, $s2, $zero
	add $a0, $s0, $zero
	
	#Procedure: deleteSquare
	#clears screen 
	deleteSquare:
		lw $t5, 0($t4)
		sub $a0, $s0, $t5
		sll $a3, $t5, 1
		addi $a3, $a3, 1
		jal horizLine
		addi $a1, $a1, 1
		addi $t4, $t4, 4
		addi $s1, $s1, -1
		bgtz $s1, deleteSquare
		jr $t9
###########################################################################################################################
###########################################################################################################################		
#Procedure: vertLine
#Input: a0 as x coord, a1 as y coord, a3 as length
vertLine:		
	la $t0, ($ra)
	li $t3, 1
	move $t1, $a1
	move $t2, $a0
	vertLineLoop:
		jal drawDot
		add $a1, $t1, $t3
		addi $a3, $a3, -1
		add $a0, $t2, $zero
		addi $t3, $t3, 1
		bnez $a3, vertLineLoop
	jr $t0
###########################################################################################################################
###########################################################################################################################
#Procedure: horizLine
#Input: a0 as x coord, a1 as y coord, a3 as length	
horizLine:		
	la $t0, ($ra)
	li $t3, 1
	move $t1, $a1
	move $t2, $a0
	horizLineLoop:
		jal drawDot
		add $a0, $t2, $t3
		addi $a3, $a3, -1
		add $a1, $t1, $zero
		addi $t3, $t3, 1
		bnez $a3, horizLineLoop
	jr $t0
###########################################################################################################################
###########################################################################################################################
#Procedure: drawdot
#Input: a0 as x coord, a1 as y coord
drawDot:		
	addiu $sp, $sp, -24
	sw $ra, 20($sp)
	jal calcAddress
	jal getColor
	sw $v1, 0($v0)
	lw $ra, 20($sp)
	addiu $sp, $sp, 24
	jr $ra
###########################################################################################################################
###########################################################################################################################	
#Procedure: calcAddress
#calculates the address on the bitmap	
calcAddress:		
	sll $s7, $a0, 2
	sll $s3, $a1, 10
	add $s7, $s7, $s3
	addi $v0, $s7, 0x10040000
	jr $ra
###########################################################################################################################
###########################################################################################################################	
#Proceudre: getcolor
#Input:  a2 as the number id of the color
#Output: color into v1
getColor:		
	beq $a2, 1, yellow
	beq $a2, 2, blue
	beq $a2, 3, green
	beq $a2, 4, red
	beq $a2, 5, white
	add $v1, $zero, $zero
	jr $ra
		
	yellow:
		addi $v1, $zero, 0xffff00
		jr $ra
	blue:
		addi $v1, $zero, 0xff
		jr $ra
	green:
		addi $v1, $zero, 0xff00
		jr $ra
	red:
		addi $v1, $zero, 0xff0000
		jr $ra
	white:
		addi $v1, $zero, 0xffffff
		jr $ra
###########################################################################################################################
###########################################################################################################################		
#Procedure end:  end simon		
end:		
	li $v0, 10
	syscall
