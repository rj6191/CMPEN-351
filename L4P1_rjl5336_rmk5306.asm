###########################################################################################################################
.data						#says we will be putting data in
Stack:						#stack
	.word 0:99
Stack_Bottom:

num1:						#creates a space in memory to store first input
	.word 0
num2:						#creates a space in memory to store second input
	.word 0		
remainder:					#creates a space in memory to store remainder
	.word 0	
result:						#creates a space in memory to store result
	.word 0		
Input1: 
	.asciiz "\nPlease enter first number:"	#prompts the user to input something
Input2: 
	.asciiz "\nPlease enter second number:" #prompts the user to input something
Input_operator: 
	.asciiz "\Please enter operator(+-*/):"	#prompts the user to input something
Your_Equation:
	.asciiz "Your Equation is: "		#prompts the user to input something		
Output_result:
	.asciiz " = "				#outputs the result to the user
Output_remainder: 
	.asciiz "\nYour remainder is:"		#outputs the remainder to the user		
Operator_Error:
	.asciiz "\nNot valid operator\n"	#output that shows if there is not a valid operator shown
Div_Error:
	.asciiz "\nInvalid divisor\n"		#output that shows if there is a divide by 0 error
	
.text
la $sp, Stack_Bottom				#puts stack pointer at the bottom of the stack

Main:
add $a2, $zero, $0				#zero out $a2
sw $zero, result				#zero out result	
sw $zero, remainder				#zero out remainder

	la  $a0, Input1				#loads address of first input array
	la  $a1, num1				#stores the first input into memory
	
jal GetInput 
	la  $a0, Input_operator			#loads address of second input array

jal GetOperator
	
	la  $a0, Input2				#loads address of second input array
		
jal chk_op_plus	

	la  $a1, num2				#stores the second input into memory	
jal GetInput

	la  $a0, Your_Equation			#loads address of second input array	
jal DisplayEquation				#display the equation the user entered on one line (BONUS)

la $ra,donesub					#set return address so we can come back after our branch

beq $v1, '+', AddNumb				#if user inputed operator is + go to AddNumb
beq $v1, '-', SubNumb				#if user inputed operator is - go to SubNumb
beq $v1, '*', MultNumb				#if user inputed operator is * go to MultNumb
beq $v1, '/', DivNumb				#if user inputed operator is / go to DivNumb

donesub:					#where we return after our arithmetic operation
	
la $a0, Output_result				#loads address of result output array
la $a1, result
jal DisplayNumb					#displays the equation that was entered on one line


la $a0, Output_remainder			#load " = " string
la $a1, remainder				#load remainder

la $ra,done					#set point to return to
lw $t7, 0($a1)					#load address of remainder
bne $t7, $0, DisplayNumb			#if remainder is not zero, branch
done:						#point to return to

j Main						#restart loop

GetInput:
	li $v0, 4				#service 4 is print string
	syscall
	
	li $v0, 5				#retrieves value of Input
	syscall 

	sw $v0, ($a1)				#moves value of input1 stored in $v0 to temp register $a1 
jr $ra

GetOperator:
	li $v0, 4				#service 4 is print string
	syscall

	li $v0,12				#retrieves value of GetOperator
	syscall 
	add $v1, $0, $v0			#moves value of the operator stored in $v0 to $v1
	
jr $ra

DisplayEquation:				#this is code for the bonus
	li $v0, 4				#service 4 is print string
	syscall
	
	lw $a1, num1				#pulls the first input from memory 
	li $v0, 1				#print integer syscall
	move $a0, $a1				#move our first input that is stored in memory to $a0
	syscall
	
	li $v0, 11				#print character syscall
	move $a0, $v1				#moves character from where it was stored int $a0
	syscall
	
	lw $a1, num2				#pulls the second input from memory 
	li $v0, 1				#print integer syscall
	move $a0, $a1				#move our second input that is stored in memory to $a0
	syscall		
jr $ra

DisplayNumb:
	li $v0, 4				#service 4 is print string
	syscall
	
	li   $v0, 1				#print integer syscall
	lw   $a0, 0($a1)			#move our result that is stored in $a1 to $a0
	syscall	
jr $ra

AddNumb:
	lw $a0, num1				#loads the first input from memory
	lw $a1, num2				#loads the second input from memory
	
	add $a2, $a1, $a0			#adds the two inputs together
	sw  $a2, 0($sp)				#stores the result to the stack
	sw $a2, result				#stores result
jr $ra

SubNumb:
	lw $a0, num1				#loads the first input from memory
	lw $a1, num2				#loads the second input from memory
	
	sub $a2, $a0, $a1			#subtracts the second input from the first
	sw  $a2, 0($sp)				#stores the result to the stack
	sw $a2, result				#stores result
jr $ra

MultNumb:
	lw $a0, num1				#loads the first input from memory
	lw $a1, num2				#loads the second input from memory
	
	loopMulti:
	andi $t2, $a1, 1			#set t2 equal to the second input
	beq  $t2, $zero, otherMulti		#if t2 is zero branch
	addu $a2, $a2, $a0			#add a0 to the result and stor it into the result
	
	otherMulti:
	sll $a0,$a0,1				#multiply a0 by 2
	srl $a1,$a1,1				#divide a1 by 2
	bne $a1,$zero,loopMulti			#if a1 is zero, branch
	
	sw $a2, result				#stores result
jr $ra

DivNumb:
	lw $a0, num1				#loads the first input from memory
	lw $a1, num2				#loads the second input from memory
	beq $a1, $0, divid_error		#if second input is 0 branch since you cannot divide by 0
	la $a3, remainder			#set were to store the remainder
 	add $a2, $0, $0				#zero out a2
 	add $t1, $a1, $0			#store the second input into a temp register
 	j chko
 
	oloopDiv:
 	add  $t1, $a1, $0			#store the second input into a temp register
	addi $t2, $0, 1				#initialize temp quotient to 1
 	j noqmul
 
	iloopDiv:
 	sll $t2, $t2, 1				#multiply temp quotient by 2
 	
	noqmul:
 	sll  $t1, $t1, 1			#multiply divisor by 2
 	sltu $t0, $a0, $t1			#if remaining dividend is less than div multiple
 	beq  $t0, $zero, iloopDiv		#branch back to iloopDiv
 
 	addu $a2, $a2, $t2			#add temp quotient to running
 	srl  $t1, $t1, 1			#undo last divisor multiply
 	sub  $a0, $a0, $t1			#subtract biggest multiple from dividend

	chko:
 	sltu $t0, $a0, $a1			#set $t0 if a0 < a1
 	beq  $t0, $0, oloopDiv			#repeat until div is calculated
 	
 	sw $a2, result				#stores result
 	sw $a0, 0($a3)				#stores remainder
 	
jr $ra
divid_error:					#loop if there is a divide by zero error
	la $a0, Div_Error			#loads string that says there was an error
	li $v0, 4				#print string
	syscall
	
	j Main					#start main function over again
chk_op_plus:					#loop to see if operator is '+'
	bne $v1, '+', chk_op_minus		#if not '+' branch to see if '-'
	jr $ra
chk_op_minus:					#loop to see if operator is '-'
	bne $v1, '-', chk_op_mlt		#if not '-' branch to see if '*'
	jr $ra
chk_op_mlt:					#loop to see if operator is '*'
	bne $v1, '*', chk_op_div		#if not '*' branch to see if '/'
	jr $ra
chk_op_div:					#loop to see if operator is '/'
	bne $v1, '/', op_error			#if not '/' branch to error loop
	jr $ra
op_error:					#loop to output a operator error
	la $a0, Operator_Error			#load operator string
	li $v0, 4				#print string
	syscall
	
	j Main					#start main function over again