###########################################################################################################################
.data								#says we will be putting data in
Stack:			.word 0:99				#stack
Stack_Bottom:
num1:			.word 0:2 				#creates a space in memory to store first input
num2:			.word 0:2				#creates a space in memory to store second input
remainder:		.word 0:2				#creates a space in memory to store remainder
result:			.word 0:2				#creates a space in memory to store result		
buffer:			.asciiz "0000000000.00"			#creates a buffer that is 10 digits
Input1: 		.asciiz "\nPlease enter first number:"	#prompts the user to input something
Input2: 		.asciiz "\nPlease enter second number:" #prompts the user to input something
Input_operator: 	.asciiz "\Please enter operator(+-*/):"	#prompts the user to input something
Your_Equation:		.asciiz "Your Equation is: "		#outputs equation to user		
Output_result: 		.asciiz " = "				#outputs the result to the user
Output_remainder: 	.asciiz "\nYour remainder is:"		#outputs the remainder to the user		
Operator_Error: 	.asciiz "\nNot valid operator\n"	#output that shows if there is not a valid operator shown
Div_Error: 		.asciiz "\nInvalid divisor\n"		#output that shows if there is a divide by 0 error
INVALID_NUM: 		.asciiz "\nNot a valid numerical input\n"
Decimal: 		.asciiz "."
	
.text
Main:
	la $sp, Stack_Bottom				#puts stack pointer at the bottom of the stack
	
	
	la $ra, return_from_input1		#set place to return
	la  $a0, Input1				#loads address of first input string
	la  $a1, buffer				#jumps to get first number
	la  $a2, num1				#stores the first input into memory
	la  $a3, INVALID_NUM			#loads string that for invalid input
	jal GetInput 				#jumps to get input
	return_from_input1:			#place to return to
	
	 				
	la  $a0, Input_operator			#loads address of operator input string
	jal GetOperator				#jumps to get operator
	la  $t9, Decimal			#loads decimal into t9
	sb  $v1, 0($t9)				#stores the operator 
	
	jal chk_op_plus				#jumps to check if operator is valid
	
	la  $ra, return_from_input2		#set place to return to
	la  $a0, Input2				#loads address of second input number string
	la  $a1, buffer				#jumps to get second number
	la  $a2, num2				#stores the second input into memory
	la  $a3, INVALID_NUM			#loads string that for invalid input
	jal GetInput				#jumps to get second number
	return_from_input2:			#place to return to

	la  $a0, num1				#loads 1st input into a0
	la  $a1, num2				#loads second input into a1
	la  $a2, result				#loads result into a2
	la  $a3, remainder			#loads remainder into a3
	la  $t9, Decimal			#loads decimal into t9
	lb $t0, 0($t9)
	
	la $ra, resume				#set return address so we can come back after our branch
	beq $v1, '+', AddNumb			#if user inputed operator is + go to AddNumb
	beq $v1, '-', SubNumb			#if user inputed operator is - go to SubNumb
	beq $v1, '*', MultNumb			#if user inputed operator is * go to MultNumb
	beq $v1, '/', DivNumb			#if user inputed operator is / go to DivNumb

resume:						#where we return after our arithmetic operation	
	la $a0, Your_Equation			#loads a prompt
	li $v0, 4				#prints out		
	syscall

	la $a0, num1				#load num1
	la $a1, num2				#load num2
	la $a2, result				#load result
	add $a3, $0, $0				#zero out a3	
	lb $a3, Decimal				#load decimal point
	

	jal DisplayEquation			#display the equation the user entered on one line (BONUS)



done:						#point to return to
	la  $a0, num1				#loads 1st input into a0
	la  $a1, num2				#loads second input into a1
	la  $a2, result				#loads result into a2
	jal reset				#jump to reset procdedure
	j Main					#restart loop
	
#procedure to get user input for num1 and num2
GetInput:					
	li $v0, 4				#service 4 is print string
	syscall
	
	sw   $a0, 0($sp)			#store to the stack
	sw   $a1, 4($sp)			#store to the stack
	addi $sp, $sp, 8			#shift stack pointer
	
	add  $a0, $0, $a1			#a0 = buffer
	addi $a1, $0, 13			#max number of characters we can use is 13
	
	li $v0, 8				#retrieves value of Input string
	syscall 

	add  $a1, $0, $a2			#put num1 into a1
	sw   $ra, 0($sp)			#stores return address
	addi $sp, $sp, 4			#shift stack pointer
	
	jal Parse				#jump to procedure to parse our input string
	
	beqz $v0, Reset_Input			#if v0 = 0, branch to reset
	lw   $a0, 4($a2)			#if 0.1 mult by 10 so its 0.10
	bge  $a0, 10, End_Input			#if a0 is greater than 10, branch to End_Input
	
	jal Single_Double			#jump to a procedure that will make 0.1 into 0.10 
	sw  $v0, 4($a2)				#
jr $ra

#procedure to reset the stack and return to our main function
End_Input:
	subi $sp, $sp, 4			#shifts stack pointer back to before ra
	lw   $ra, 0($sp)			#puts ra back on stack
	subi $sp, $sp, 8			#shifts stack pointer back
	jr $ra					#starts program over again
	
#procedure to reset input
Reset_Input:
	subi $sp, $sp, 4			#shifts stack pointer back to before ra
	lw   $ra, 0($sp)			#puts ra back on stack
	subi $sp, $sp, 8			#shifts stack pointer back
	j Main					#starts program over again
	
#procedure to change single deicmal values into double decimal values	
Single_Double:
	sll $t0, $a0, 1				#shift a0 by 1, multiply a0 by 2
	sll $v0, $a0, 3				#shift a0 by 3, multiply a0 by 8
	add $v0, $v0, $t0			#adds the resultants togehter and now we have multiplied by 10
	jr $ra					#return back to get input
#procedure to parse our input string
Parse:
	lw   $t9, 0($a1)			#running value
	add  $t7, $0, $0			#counts iterations 
	add  $t6, $0, $0			#counts number of decimal places. 
	addi $t5, $0, 1				#This counts the amount of decimals used	
	
	#sub procedure of Parse
	Parse_Loop:				
		lb    $t0, 0($a0)		#reads next byte in string
		addiu $a0, $a0, 1		#move byte we read over by 1
		addi  $t7, $t7, 1		#increase iteration counter
		addi  $t6, $t6, -1		#decreases decimal places counter
		
		beq   $t0, 10, Parse_End	#if newline jump to the end
		beq   $t0, 45, Parse_Negative_Number	#if negative 
		beqz  $t6, Parse_End		#if $t6 is zero, end 
		beq   $t0, 46, Parse_Decimal	#If decimal, jump to decimal.
		addi  $t1, $t0, -57		#if input isnt a number , throw an error
		bgtz  $t1, Parse_Error		#if $t1 is 0, throw an error
		addi  $t2, $t0, -48		#if the byte we read was a number then run calculations.
		bgez  $t2, Parse_Calculator	#if t2 > 0 branch
		bltz  $t2, Parse_Error		#if t2 < 0, throw an error
		
	#sub procedure of parse, used if we have negative numbers	
	Parse_Negative_Number:			
		la   $a0, INVALID_NUM		#loads invalid number error message	
		li   $v0, 4			#prints out invalid number message
		syscall				
		add  $v0, $zero, $0		#zeros out v0
		jr $ra				#returns to GetInput
		
	#sub procedure of Parse
	Parse_Calculator:	
		sll $t8, $t9, 1			#shift t8 by 1, multiply t8 by 2
		sll $t9, $t9, 3			#shift t9 by 3, multiply t9 by 8
		add $t9, $t9, $t8		#add resultants from sll's together and store into t9
		add $t9, $t9, $t2		#add t9 and t2
		j Parse_Loop			#jumps to parse_loop
		
	#sub procedure of parse, used if there is an error
	Parse_Error:
		add $a0, $a3, 0			#loads in error message
		li $v0, 4			#prints out error message
		syscall	
		
		lw $a0, 0($sp)			#sets $a0 to what is stored on the bottom of the stack 
		lw $a1, 4($sp)			#sets $a1 to what is stored 4 bits higher on the stack
		add $v0, $zero, $0		#zero out $v0
		
		jr $ra				#jumps back to return address
	
	#sub procedure of parse, runs if there is a decimal point
	Parse_Decimal:
		beq  $t7, 1, Parse_Error	#jumps to error if numer entered is like .1 instead of 0.1
		addi $t5, $t5, -1		#subtracts one from the decimal counter
		bltz $t5, Parse_Error		#will error if $t5 < 0
		j Parse_Decimal_Final
		
	#sub procedure of parse, runs if there was a deciaml point
	Parse_Decimal_Final:
		sw   $t9, 0($a1)		#Save XXX.00 part of number
		addi $a1, $a1, 4		#
		lw   $t9, 0($a1)		#go to 000.XX part of number
		addi $t6, $0, 3			#sets t6 = 3
		j Parse_Loop
	
	#sub procedure of parse, runs when we are done parsing
	Parse_End:
		beq $t7, 1, Parse_Error		#if the itteration counter is equal to one, branch to error
		
	Parse_Final:
		sw  $t9, 0($a1)		 	#save our number
		jr  $ra
		
#procedure to get user input for operator
GetOperator:					
	li $v0, 4				#service 4 is print string
	syscall

	li  $v0,12				#retrieves value of GetOperator
	syscall 
	
	add $v1, $v0, $0			#store operator into v1
jr $ra

#procedure to display the answer or the remainder
DisplayNumb:					
	beq $a0, ' ', Display_numb		#if the first character is a space, skip it and the space after it
	li $v0,  11				#prints a space
	syscall					
	
	add $a0, $0, ' '			#loads a space to be printed
	li $v0,  11				#prints a space
	syscall
	
Display_numb:
	lw $a0, 0($a1)				#loads num1
	li $v0, 1				#prints num1
	syscall		
	
	add $a0, $0, '.'			#loads a decimal point to be printed out
	li $v0, 11				#prints a decimal point
	syscall		
	
	lw $a0, 0($a2)				#loads num2
	li $v0, 1				#prints num2
	syscall
			
	add $a0, $0, ' '			#loads a space to be printed
	li $v0, 11				#prints a space
	syscall		
	jr $ra

#procedure to display equation
DisplayEquation:				#this is code for the bonus
	add  $t0, $a0, $0			#loads $a0 into $t0 temporarily
	sw   $ra, 4($sp)			#saves our return address into memory.
	sw   $a0, 8($sp)			#saves first number into memory
	sw   $a1, 12($sp)			#saves second number into memory
	sw   $a2, 16,($sp)			#saves result into memory
	add  $a0, $0,  ' '			#loads a space into a0
	add  $a1, $0, $t0			#loads a0 into a1
	addi $a2, $t0, 4			#next 4 bits of a0 into a2
	
	jal DisplayNumb				
	
	add  $a0, $0, $a3			#put a3 into a0
	lw   $a1, 12($sp)			#loads second num
	addi $a2, $a1, 4
	
	jal DisplayNumb				#calls DisplayNumb to display num2
	
	add  $a0, $0, '='			#loads =
	lw   $a1, 16($sp)			#loads result
	lw   $t9, 8($a1)			
	beqz $t9, Display_Equation		#checks to see if our negative value is active
	li   $v0, 11				#print a "="
	syscall					
	
	add $a0, $0, ' '
	syscall					#print a space
	
Display_Equation:
	addi $a2, $a1, 4			
	jal DisplayNumb		
	lw $ra, 4($sp)				#returns to where we came from
	jr $ra
	

#procedure that adds the two inputs
AddNumb:
	#sub procedure of AddNumb that adds the numbers after the decimal place
	Add_numb_after:	
		add $t9, $0, $0			#zero out t9				
		lw  $t0, 4($a0)			#loads the first input's decimal value from memory
		lw  $t1, 4($a1)			#loads the second input's decimal value from memory
		add $t2, $t1, $t0		#adds the two decimal values togehter
		blt $t2, 100, Add_numb_before	#if a2 < 100, branch to procedure to add the numbers before the deciaml

	
	#sub procedure of AddNumb to check for overflow in deciaml addition
	Add_numb_overflow:
		add $t9, $t9, 1			#holds overflow from decimal addition
		sub $t2, $t2, 100		#subtract 100 from a2
		bge $t2, 100, Add_numb_overflow	#will continue to loop until a2 <100
	
	#sub procedure of AddNumb that adds the numbers before the decimal place
	Add_numb_before:
		sw  $t2, 4($a2)			#saves the after decimal number to memory
		lw $t0, 0($a0)			#loads the first input's integer value
		lw $t1, 0($a1)			#loads the first input's integer value
		add $t2, $t0, $t9		#adds num1 with the overflow
		add $t2, $t2, $t1		#adds previous result and num2
		sw $t2, 0($a2)			#saves the integer 
	AddNumb_end:
	jr $ra

#procedure that subtracts the two inputs
SubNumb:
	Sub_After:
		add $t9, $0, $0			#zero out t9
		lw $t0, 4($a0)			#loads the decimal portion of our first number
		lw $t1, 4($a1)			#loads the decimal portion of our second number
		sub $t2, $t0, $t1		#subtracts second decimal from first decimal.
		bgez $t2, Sub_before		#if $t2 >0, branch to subtracting the integer
	Sub_Overflow:
		add $t9, $t9, 1			#add one to overflow 
		addi $t2, $t2, 100		#add 100 to subtracted 
		bltz $t2, Sub_Overflow		#if t2 < 0
	Sub_before:
		lw $t0, 0($a0)			#load integer portion of num1
		lw $t1, 0($a1)			#load integer portion of num2
		sub $t3, $t0, $t1		#subtract the second number from first 
		sub $t3, $t3, $t9		#subtract the overflow from result
		bgez $t3, SubNumb_End		#if t3 > 0, branch to end
	SubNumb_End:
		sw $t2, 4($a2)			#save the decimal into memory.
		sw $t3 0($a2)			#save the integer into memory.
		jr $ra	
#procedure that multiplies the two inputs
MultNumb:
	Mult_decimal:					
	lw $t0, 0($a0)				#loads the first input from memory
	lw $t1, 0($a1)				#loads the second input from memory
	
	loopMulti:
	andi $t2, $t1, 1			#set t2 equal to the second input
	beq  $t2, $zero, otherMulti		#if t2 is zero branch
	addu $t3, $t3, $t0			#add a0 to the result and stor it into the result
	
	otherMulti:
	sll $t0,$t0,1				#multiply a0 by 2
	srl $t1,$t1,1				#divide a1 by 2
	bne $t1,$zero,loopMulti			#if a1 is zero, branch
	sw  $t3, 4($a2)				#stores result
	
			#stores result
jr $ra

#procedure that divides the two inputs
DivNumb:					
	lw  $a0, 0($a0)				#loads the first input from memory
	lw  $a1, 0($a1)				#loads the second input from memory
	beq $a1, $0, divid_error		#if second input is 0 branch since you cannot divide by 0
	la  $a3, remainder			#set were to store the remainder
 	add $t3, $0, $0				#zero out a2
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
 
 	addu $t3, $t3, $t2			#add temp quotient to running
 	srl  $t1, $t1, 1			#undo last divisor multiply
 	sub  $a0, $a0, $t1			#subtract biggest multiple from dividend

	chko:
 	sltu $t0, $a0, $a1			#set $t0 if a0 < a1
 	beq  $t0, $0, oloopDiv			#repeat until div is calculated
 	sw   $t3, 0($a2)			#stores result
 	sw   $a0, 0($a3)			#stores remainder
 	
jr $ra

#procedure to reset all registers to 0
reset:
	sw $0, 0($a0)				#sets num1 to 0
	sw $0, 4($a0)
	sw $0, 0($a1)				#sets num2 to 0
	sw $0, 4($a1)
	sw $0, 0($a2)				#sets result to 0
	sw $0, 4($a2)		
	sw $0, 8($a2)							

	la $sp, Stack				#sets stack to 0
	sw $0, 0($sp)
	sw $0, 4($sp)
	sw $0, 8($sp)
	sw $0, 12($sp)
	sw $0, 16($sp)		
	sw $0, 20($sp)
	sw $0, 24($sp)
	sw $0, 28($sp)
	
	add $a0, $0, $0				#empties our a registers
	add $a1, $0, $0
	add $a2, $0, $0
	add $a3, $0, $0
	add $t9, $0, $0
	jr $ra
jr $ra

#procedure if there is a divide by zero error
divid_error:					
	la $a0, Div_Error			#loads string that says there was an error
	li $v0, 4				#print string
	syscall
	
	j Main					#start main function over again
	
#procedure to see if operator is '+'	
chk_op_plus:					
	bne $v1, '+', chk_op_minus		#if not '+' branch to see if '-'
	jr $ra

#procedure to see if operator is '-'	
chk_op_minus:					
	bne $v1, '-', chk_op_mlt		#if not '-' branch to see if '*'
	jr $ra

#procedure to see if operator is '*'
chk_op_mlt:					
	bne $v1, '*', chk_op_div		#if not '*' branch to see if '/'
	jr $ra

#procedure to see if operator is '/'
chk_op_div:					
	bne $v1, '/', op_error			#if not '/' branch to error loop
	jr $ra

#procedure to output a operator error
op_error:					
	la $a0, Operator_Error			#load operator string
	li $v0, 4				#print string
	syscall
	
	j Main					#start main function over again
