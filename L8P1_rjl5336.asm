###########################################################################################################################
.data
	numStack: .word 0:5
	circleLineLengths:	# the draw cirlce function uses these as the radii for drawing (a circle)
		.word 4, 6, 8, 10, 11, 12, 13, 14, 14, 15, 15, 16, 16, 17, 17, 17, 17, 17
		.word 17, 17, 17, 17, 16, 16, 15, 15, 14, 14, 13, 12, 11, 10, 8, 6, 4
	
	youWin: .asciiz "\nYou Win!"
	wrong: .asciiz "\nYou Lose!"
	return: .asciiz "\n\n\n"
###########################################################################################################################
###########################################################################################################################	
.text
main:
	jal drawBoard
	
	li $t0, 5
	la $a2, numStack
	loop1:
		jal genRand
		sw $a0, 0($a2)
		addi $a2, $a2, 4
		addi $t0, $t0, -1
		bne $t0, 0, loop1
		
	la $a0, numStack
	la $s6, 1
	jal disp
	jal dispReturn
	la $a0, numStack
	li $a1, 1
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	la $a0, numStack
	la $s6, 2
	jal disp
	jal dispReturn
	la $a0, numStack
	li $a1, 2
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	la $a0, numStack
	la $s6, 3
	jal disp
	jal dispReturn
	la $a0, numStack
	li $a1, 3
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	la $a0, numStack
	la $s6, 4
	jal disp
	jal dispReturn
	la $a0, numStack
	li $a1, 4
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	la $a0, numStack
	la $s6, 5
	jal disp
	jal dispReturn
	la $a0, numStack
	li $a1, 5
	jal check
	jal dispReturn
	jal dispReturn
	jal dispReturn
	
	j win
###########################################################################################################################	
	
###########################################################################################################################	
dispReturn:	# takes no arguments, however uses a0 and v0 and outputs a return in the run i/o
	la $a0, return
	li $v0, 4
	syscall
	jr $ra
###########################################################################################################################	
###########################################################################################################################	
check:			# read in inputted ascii char and compare with first number on stack
			# args: a0 is pointer of stack begining, a1 is the number of inputs to check
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
	
	
disp:			# arguments: a0 is pointer at begining of stack, s6 is number of outputs to display
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
		
#		syscall
		flashEnd:
		add $t6, $t6, 4
		add $s6, $s6, -1
		bne $s6, 0, multNumbers
	
	jr $s4
	
genRand:		# returns random int between 1 and 4 (inclusive)
	li $v0, 30	# put 30 into v0 for get time syscall
	syscall		# call syscall to get time
	move $a0, $v0	# put the time into a0 to seed random number generator
	
	li $v0, 42	# put 42 into v0 for random number gen with upper bound
	li $a1, 4	# put 4 into a1 to set upper bound
	syscall		# create random num in a0
	
	add $a0, $a0, 1	# account for 0 in rand gen
	jr $ra
	
	
win:		# no args but uses a0 and v0 for output of string syscall
	la $a0, youWin
	li $v0, 4
	syscall
	j end
	
	
incorrect:		# no args but uses a0-a3 and v0 to output sound bursts and that player lost
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
	
drawBoard:		# no args, but uses a0-a2 to draw the "X" of the board
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
	
flashBox:		# takes in $a0 as the x coord
			# takes in a1 as the y coord
			# takes in a2 as the color
			# takes in t7 as the id of the circle outputted
	la $t9, ($ra)
	add $s0, $a0, $zero		# s0 is now the x coord
	add $s2, $a1, $zero		# s2 is now the y coord
	la $t4, circleLineLengths
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
	
	li $a2, 0
	add $a1, $s2, $zero
	add $a0, $s0, $zero	
	
	beq $t7, 1, outOne
	beq $t7, 2, outTwo
	beq $t7, 3, outThree
	
	outFour:	# outputs the "4" on the green circle
		addi $a0, $a0, 3
		addi $a1, $a1, 10
		li $a3, 15
		jal vertLine
		addi $a0, $s0, -2
		addi $a1, $s2, 15
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -2
		addi $a1, $s2, 10
		li $a3, 5
		jal vertLine
		li $v0, 31
		li $a0, 75
		li $a1, 700
		li $a2, 16
		li $a3, 127
		syscall
		j endOutNumb
	
	outOne:		# outputs the "1" on the yellow circle
		addi $a1, $a1, 5
		li $a3, 15
		jal vertLine
		addi $a0, $s0, -1
		addi $a1, $s2, 5
		li $a3, 15
		jal vertLine
		addi $a0, $s0, 1
		addi $a1, $s2, 5
		li $a3, 15
		jal vertLine
		li $v0, 31
		li $a0, 60
		li $a1, 700
		li $a2, 16
		li $a3, 127
		syscall
		j endOutNumb
		
	outTwo:		# outputs the "t" on the blue circle
		addi $a0, $a0, -3
		addi $a1, $a1, 4
		li $a3, 5
		jal horizLine
		addi $a0, $a0, -3
		addi $a1, $a1, 5
		li $a3, 5
		jal horizLine
		addi $a0, $s0, 2
		addi $a1, $s2, 4
		li $a3, 5
		jal vertLine
		addi $a0, $s0, 3
		addi $a1, $s2, 4
		li $a3, 5
		jal vertLine
		addi $a0, $s0, -3
		addi $a1, $s2, 9
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -3
		addi $a1, $s2, 10
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -3
		addi $a1, $s2, 9
		li $a3, 5
		jal vertLine
		addi $a0, $s0, -2
		addi $a1, $s2, 9
		li $a3, 5
		jal vertLine
		addi $a0, $s0, -3
		addi $a1, $s2, 14
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -3
		addi $a1, $s2, 15
		li $a3, 5
		jal horizLine
		li $v0, 31
		li $a0, 67
		li $a1, 700
		li $a2, 16
		li $a3, 127
		syscall
		j endOutNumb
		
	outThree:		# outputs the "3" on the red circle
		addi $a0, $s0, -2
		addi $a1, $s2, 10
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -2
		addi $a1, $s2, 11
		li $a3, 5
		jal horizLine
		addi $a0, $s0, 3
		addi $a1, $s2, 10
		li $a3, 15
		jal vertLine
		addi $a0, $s0, 3
		addi $a1, $s2, 11
		li $a3, 15
		jal vertLine
		addi $a0, $s0, -2
		addi $a1, $s2, 17
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -2
		addi $a1, $s2, 18
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -2
		addi $a1, $s2, 25
		li $a3, 5
		jal horizLine
		addi $a0, $s0, -2
		addi $a1, $s2, 24
		li $a3, 5
		li $v0, 31
		li $a0, 70
		li $a1, 700
		li $a2, 16
		li $a3, 127
		syscall
		jal horizLine
		
	
endOutNumb:		# where to jump to after the number has been placed on the circle
			# this pauses the other functions for the sound burst
	li $v0, 32
	li $a0, 700
	syscall
	
	la $t4, circleLineLengths
	li $s1, 35
	li $a2, 0
	add $a1, $s2, $zero
	add $a0, $s0, $zero
	deleteCircle:
		lw $t5, 0($t4)
		sub $a0, $s0, $t5
		sll $a3, $t5, 1
		addi $a3, $a3, 1
		jal horizLine
		addi $a1, $a1, 1
		addi $t4, $t4, 4
		addi $s1, $s1, -1
		bgtz $s1, deleteCircle
		jr $t9

vertLine:		# takes in a0 as x coord, a1 as x coord, a3 as length
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
	
horizLine:		# takes in a0 as x coord, a1 as x coord, a3 as length
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


drawDot:		# takes in a0 as x coord, a1 as x coord
	addiu $sp, $sp, -24
	sw $ra, 20($sp)
	jal calcAddress
	jal getColor
	sw $v1, 0($v0)
	lw $ra, 20($sp)
	addiu $sp, $sp, 24
	jr $ra
	
calcAddress:		# calculates the address on the bitmap
	sll $s7, $a0, 2
	sll $s3, $a1, 10
	add $s7, $s7, $s3
	addi $v0, $s7, 0x10040000
	jr $ra
	
getColor:		# puts the color into v1, accepts a2 as the number id of the color
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
	
end:		# ends the program, prettily
	li $v0, 10
	syscall
