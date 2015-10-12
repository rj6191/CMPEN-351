###########################################################################################################################
.data								#says we will be putting data in
Stack_begin:		.word 0:40				#stack
Stack_Bottom:
stack:			.word 0:8
num1:			.word 0:4 				#creates a space in memory to store first input
num2:			.word 0:4				#creates a space in memory to store second input
remainder:		.word 0:4				#creates a space in memory to store remainder
result:			.word 0:4				#creates a space in memory to store result		
asciinum1:		.asciiz "00000000000000000000000000000000000000" #creates a space in memory to make a clear
asciinum2:		.asciiz "00000000000000000000000000000000000000" #creates a space in memory to make a clear
asciiresult:		.asciiz "00000000000000000000000000000000000000" #creates a space in memory to make a clear
asciisqrt:		.asciiz "00000000000000000000000000000000000000" #creates a space in memory to make a clear
asciiremainder:		.asciiz "00000000000000000000000000000000000000" #creates a space in memory to make a clear
buffer:			.asciiz "00000000000000000000000000000000000000" #creates a buffer that is 38 digits
Input1: 		.asciiz "\nPlease enter first number:"	#prompts the user to input something
Input2: 		.asciiz "\nPlease enter second number:" #prompts the user to input something
Input_operator: 	.asciiz "Please enter operator(+-*/%$):"	#prompts the user to input something
Your_answer:		.asciiz "\nYour answer is: "		#outputs equation to user		
Output_result: 		.asciiz " = "				#outputs the result to the user
Output_remainder: 	.asciiz "\nYour remainder is: "		#outputs the remainder to the user		
Operator_Error: 	.asciiz "\nNot valid operator\n"	#output that shows if there is not a valid operator shown
Div_Error: 		.asciiz "\nInvalid divisor\n"		#output that shows if there is a divide by 0 error
INVALID_NUM: 		.asciiz "\nNot a valid numerical input\n"
###########################################################################################################################
.text
Main:
	la $sp, Stack_Bottom			#puts stack pointer at the bottom of the stack
	la $sp, stack

	la  $a0, Input1				#loads address of first input string
	la  $a1, buffer				#loads the buffer
	la  $a2, num1				#stores the first input into memory
	la  $a3, asciinum1			#loads string that for invalid input
	jal GetInput 				#jumps to get input
	
	 				
	la  $a0, Input_operator			#loads address of operator input string
	jal GetOperator				#jumps to get operator

	jal chk_op_plus				#jumps to check if operator is valid
	
	
	la $ra, SQRT_OUT
	la $a0, num1
	beq $v1, '$', SquareRoot		#if user inputed operator is $ go to SquareRoot

	la  $a0, Input2				#loads address of second input number string
	la  $a1, buffer				#loads the buffer
	la  $a2, num2				#stores the second input into memory
	la  $a3, asciinum2			#loads string that for invalid input
	jal GetInput				#jumps to get second number


	la  $a0, num1				#loads 1st input into a0
	la  $a1, num2				#loads second input into a1
	la  $a2, result				#loads result into a2
	la  $a3, remainder			#loads remainder into a3
	
	la $ra, resume				#set return address so we can come back after our branch
	beq $v1, '+', AddNumb			#if user inputed operator is + go to AddNumb
	beq $v1, '-', SubNumb			#if user inputed operator is - go to SubNumb
	beq $v1, '*', MultNumb			#if user inputed operator is * go to MultNumb
	beq $v1, '/', DivNumb			#if user inputed operator is / go to DivNumb
	beq $v1, '%', DivNumb			#if user inputed operator is % go to DivNumb

resume:						#where we return after our arithmetic operation	
	la $a0, result				#loads stupid result
	la $a1, asciiresult			#loads place to put good result
	
	jal BinToDecAsc				#make stupid result into good result
	
	beq $v1, '%', MODULO_OUT		#if user inputed operator is % go to DivNumb

	la  $a0, Your_answer			
	la  $a1, asciiresult			#load true result
	jal DisplayNumb				#displays the equation that was entered on one line

			
	la $a1, remainder			#load remainder
	la  $ra,done				#set point to return to
	lw  $t7, 0($a1)				#load address of remainder
	bne $t7, $0, convert_remainder		#if remainder is not zero, branch
done:
	
EXIT:						#exit loop
	li $v0, 10
	syscall
convert_remainder:
	la $a0, remainder			#loads stupid result
	la $a1, asciiremainder			#loads place to put good result
	jal BinToDecAsc
	la $a0, Output_remainder
	la $a1, asciiremainder			#load remainder
	jal DisplayNumb				#if remainder is not zero, branch
	j EXIT
#Procedure:SQRT_OUT Displays the result of square rooting num1	
SQRT_OUT:
	
	la $a0, num1
	la $a1, asciisqrt
	jal BinToDecAsc
	la $a0, Your_answer
	la $a1, asciisqrt		#load remainder
	jal DisplayNumb				#if remainder is not zero, branch
	j EXIT
#Procedure:MODULO_OUT Displays the result of modulo divison ( a0 % a1)		
MODULO_OUT:
	la $a0, remainder			#loads stupid result
	la $a1, asciiremainder			#loads place to put good result
	jal BinToDecAsc
	la $a0, Output_remainder
	la $a1, asciiremainder			#load remainder
	jal DisplayNumb				#if remainder is not zero, branch
	j EXIT
#Procedure:GetInput Displays a prompt to the user and then wait for a numerical input
#The user�s input will get stored to the (word) address pointed by $a1 
#Input: $a0 points to the text string that will get displayed to the user
#Input: $a1 points to a word address in .data memory, where to store the input number
GetInput:					
	li $v0, 4				#service 4 is print string
	syscall
	
	
	addi $sp, $sp, 8			#shift stack pointer			      
	add  $a0, $zero, $a1			#a0 = buffer
	addi $a1, $0, 39			#max number of characters we can use
	
	li $v0, 8				#retrieves value of Input string
	syscall 
	
	add  $a1, $zero, $a2			#loads 4 word num into a1
	addi $sp, $sp, -12    			#decrements stack
		
	sw   $a3, 0($sp)			#save dummy variable to stack
	sw   $a2, 4($sp)			#save num(1 or 2) to stack				
	sw   $ra, 8($sp)			# store our ra so we can jump back to main 
	
	jal DecAscToBin				
	
	lw   $a0, 4($sp)			#load actual num(1 or 2)
	lw   $a1, 0($sp)			#load dummy variable
	addi $sp, $sp, 8			#increment stack
	
	jal BinToDecAsc
	
	lw   $ra, 0($sp)			#restore ra
	addi $sp, $sp, 4 			#increment stack

	jr $ra 					#go home

#Procedure: GetOperator Displays a prompt to the user and then wait for a single character input
#Input: $a0 points to the text string that will get displayed to the user
#Returns the operator in $v1 (as an ascii character)
GetOperator:					
	li $v0, 4				#service 4 is print string
	syscall

	li  $v0,12				#retrieves value of GetOperator
	syscall 
	
	add $v1, $v0, $0			#store operator into v1
	
jr $ra

#Procedure: DisplayNumb Displays a message to the user followed by a numerical value 
#Input: $a0 points to the text string that will get displayed to the user
#Input: $a1 points to a word address in .data memory, where the input value is stored
DisplayNumb:
	li $v0, 4				#service 4 is print string
	syscall
	
	add $a0, $a1, $zero			#move our result that is stored in $a1 to $a0
	li  $v0, 4				#print integer syscall
	syscall	
jr $ra
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
	bne $v1, '*', chk_op_sqrt		#if not '*' branch to see if '$'
	jr $ra
#procedure to see if operator is '$'
chk_op_sqrt:					
	bne $v1, '$', chk_modulo		#if not '$' branch to see if '%'
	jr $ra
#procedure to see if operator is '%'
chk_modulo:					
	bne $v1, '%', chk_op_div		#if not '$' branch to see if '/'
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

		
########################################
#                                      #
#   Start of the big number routines   #
#   -- all variables are 4 words --    #
#   ---- needs a stack pointer ----    #
#                                      #
########################################

# Arithmetic Routines:
#
#   AddNumb      0($a2)  =  0($a0)  +  0($a1)
#   SubNumb      0($a2)  =  0($a0)  -  0($a1)
#   MultNumb     0($a2)  =  0($a0)  *  0($a1)
#   DivNumb      0($a2)  =  0($a0)  /  0($a1)
#                0($a3)  =  0($a0)  %  0($a1)
#   SquareRoot   0($a0)  =  sqrt( 0($a0) )
#
# Logical Routines:
#
#   ShiftLeft1   0($a0)  =  ( 0($a0) << 1 )  + $a1 (carry)
#                           $a1 = 0/1 will be inserted at the LSB
#   ShiftRight1  0($a0)  =  ( 0($a0) >> 1 )
#
# Data Conversions:
#
#   DecAscToBin  0($a1)  =  convert dec-asciiz input ($a0)
#                           if leading "0x" assumes input text is hex
#                           if leading "-" negates the decimal result
#   HexAscToBin  0($a1)  =  convert hex-asciiz input ($a0)
#   BinToDecAsc  ($a1)   =  convert 0($a0) into dec-asciiz (includes -)
#   BinToHexAsc  ($a1)   =  convert 0($a0) into hex-asciiz
#
# Miscellaneous Routines:
#
#   VarCpy       0($a1) = 0($a0)
#   VarClr       0($a0) = 0
#   CmpNumb      Compares 0($a1) to 0($a0)
#                $v0 =  1 if ($a1) > ($a0)
#                $v0 = -1 if ($a1) < ($a0)
#                $v0 =  0 if ($a1) == ($a0)

        .data

        .align  2               # forces the data segment to a word boundary
_Zero:  .word   0,0,0,0         # dedicated variables (zero and one)
_One:   .word   1,0,0,0

_temp:  .word   0,0,0,0         # temp working variables
_data:  .word   0,0,0,0

        .text

# copy from one (four word) variable to another
# $a0 = points to the source
# $a1 = points to the destination
VarCpy:
        li      $t5, 4          # move 4 words of data
_copy:
        lw      $t0, 0($a0)     # read from source
        sw      $t0, 0($a1)     # write to destination
        addiu   $a0, $a0, 4
        addiu   $a1, $a1, 4

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _copy
        jr      $ra


# initialize a (four word) variable to zero
# $a0 = points to the variable to clear
VarClr:
        li      $t5, 4          # write 4 words
_clear:
        sw      $zero, ($a0)   # store zero at the destination
        addiu   $a0, $a0, 4

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _clear
        jr      $ra


# Shift Left 1 bit (also multiply by 2) with carry input
# $a0 = pointer to the data to shift left
# $a1 = initial carry input (0 = none, 1 = carry) (this is not a pointer)
ShiftLeft1:
        lui     $t2, 0x8000
        li      $t5, 4          # loop through 4 words of data
_left1:
        lw      $t0, 0($a0)     # get the word
        and     $t3, $t0, $t2   # save the ms bit
        sll     $t0, $t0, 1     # shift left 1 bit
        sw      $t0, 0($a0)

        beq     $a1, $zero, _left2
        ori     $t0, 1          # insert the carry from before
        sw      $t0, 0($a0)
_left2:
        move    $a1, $t3        # get the new carry
        addiu   $a0, $a0, 4

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _left1
        jr      $ra


# Shift Right 1 bit (also divide by 2)
# $a0 = pointer to the data to shift right
ShiftRight1:
        li      $a1, 0          # set initial carry
        lui     $t2, 0x8000
        li      $t5, 4          # write 4 words
_right1:
        addiu   $a0, $a0, -4

        lw      $t0, 16($a0)    # get the word
        andi    $t3, $t0, 1     # save the ls bit
        srl     $t0, $t0, 1     # shift right 1 bit
        sw      $t0, 16($a0)

        beq     $a1, $zero, _right2
        or      $t0, $t0, $t2   # insert the carry from before
        sw      $t0, 16($a0)
_right2:
        move    $a1, $t3        # get the new carry

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _right1
        jr      $ra


# Addition
# $a0 = points to src 1 (to add)
# $a1 = points to src 2 (to add)
# $a2 = points to destination  ($a0) + ($a1)
AddNumb:
        li      $t1, 0          # set carry = 0
        li      $t5, 4          # add 4 words
_add1:
        lw      $t0, 0($a0)     # result = (a0) + (a1) + carry
        lw      $t3, 0($a1)
        addu    $t2, $t3, $t0
        addu    $t2, $t2, $t1
        sw      $t2, 0($a2)     # (a2) = result

        li      $t1, 0          # assume no carry
        bgeu    $t2, $t0, _add2 # if result < src...
        li      $t1, 1          # then there is a carry
        j       _add3
_add2:
        bgeu    $t2, $t3, _add3 # if result < src...
        li      $t1, 1          # then there is a carry
_add3:
        addiu   $a0, $a0, 4
        addiu   $a1, $a1, 4
        addiu   $a2, $a2, 4

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _add1
        jr      $ra


# Subtraction
# $a0 = points to src 1 (to sub)
# $a1 = points to src 2 (to sub)
# $a2 = points to destination  ($a0) - ($a1)
SubNumb:
        li      $t1, 0          # set borrow = 0
        li      $t5, 4          # subtract 4 words
_sub1:
        lw      $t0, 0($a0)     # result = (a0) - (a1) - borrow
        lw      $t2, 0($a1)
        subu    $t3, $t0, $t2
        subu    $t2, $t3, $t1
        sw      $t2, 0($a2)     # (a2) = result

        li      $t1, 0          # assume no borrow
        bleu    $t2, $t0, _sub2 # if result > src...
        li      $t1, 1          # then there is a borrow
_sub2:
        bleu    $t3, $t0, _sub3
        li      $t1, 1
_sub3:
        addiu   $a0, $a0, 4
        addiu   $a1, $a1, 4
        addiu   $a2, $a2, 4

        addiu   $t5, $t5, -1    # loop 4 times
        bne     $t5, $zero, _sub1
        jr      $ra


# Compare
# $a0 = points to src 1
# $a1 = points to src 2
# compares the two (four word) variables for greater, less or the same
# returns $v0
#    $v0 =  1 if ($a1) > ($a0)
#    $v0 = -1 if ($a1) < ($a0)
#    $v0 =  0 if ($a1) == ($a0)
CmpNumb:
        li      $t5, 4          # compare 4 words
_cmp1:
        addiu   $a0, $a0, -4
        addiu   $a1, $a1, -4

        lw      $t0, 16($a0)    # get the two data words (start at the msb)
        lw      $t1, 16($a1)    # and check for greater or less than

        bgtu    $t1, $t0, _more
        bltu    $t1, $t0, _less

        addiu   $t5, $t5, -1    # else both are the same for now
        bne     $t5, $zero, _cmp1

        li      $v0, 0          # v0 = 0 : both are the same
        jr      $ra
_more:
        li      $v0, 1          # v0 = 1 : (a1) > (a0)
        jr      $ra
_less:
        li      $v0, -1         # v0 = -1 : (a1) < (a0)
        jr      $ra


# Multiply
# $a0 = points to src 1
# $a1 = points to src 2
# $a2 = points to the destination  ($a0) * ($a1)
# if the result overflows the destination, that portion of the data is lost
MultNumb:
        addiu   $sp, $sp, -32   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s5, 16($sp)
        sw      $s6, 20($sp)
        sw      $ra, 24($sp)

        move    $s0, $a0
        move    $s1, $a1
        move    $s2, $a2

        la      $a0, _temp      # clear out the temp variable
        jal     VarClr

        li      $s3, 0          # flag to speed up the multiply
        li      $s5, 4          # multiply all 4 words
_Mult1:
        addiu   $s1, $s1, -4

        lui     $s6, 0x8000     # mask out 1 bit at a time
_Mult2:
        beq     $s3, $zero, _Mult3
        li      $a1, 0
        la      $a0, _temp
        jal     ShiftLeft1      # combination of shifting and adding
_Mult3:
        lw      $t0, 16($s1)
        and     $t0, $t0, $s6   # do the add if the bit is set
        beq     $t0, $zero, _Mult4

        move    $a0, $s0
        la      $a1, _temp
        la      $a2, _temp
        jal     AddNumb
        li      $s3, 1          # shows that we have a non-zero value
_Mult4:
        srl     $s6, $s6, 1
        bne     $s6, $zero, _Mult2

        addiu   $s5, $s5, -1
        bne     $s5, $zero, _Mult1

        la      $a0, _temp
        move    $a1, $s2
        jal     VarCpy          # copy back to the user

        lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s5, 16($sp)
        lw      $s6, 20($sp)
        lw      $ra, 24($sp)
        addiu   $sp, $sp, 32
        jr      $ra


# Divide
# $a0 = points to src 1  dividend
# $a1 = points to src 2  divisor
# $a2 = points to the destination  ($a0) / ($a1)  quotient
# $a3 = points to the destination  ($a0) % ($a1)  remainder
DivNumb:
        addiu   $sp, $sp, -40   # create a stack frame
        sw      $s0,  0($sp)
        sw      $s1,  4($sp)
        sw      $s2,  8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $s5, 20($sp)
        sw      $s6, 24($sp)
        sw      $s7, 28($sp)
        sw      $ra, 32($sp)
        sw      $a3, 36($sp)

        move    $s0, $a0
        move    $s1, $a1
        move    $s2, $a2

        la      $a0, _temp      # clear out some temp variables
        jal     VarClr
        la      $a0, _data
        jal     VarClr

        la      $a0, _Zero
        move    $a1, $s1
        jal     CmpNumb         # check for divide by zero
        beq     $v0, $zero, _Div7

        li      $s3, 0          # use a flag to speed up the divide
        li      $s5, 4          # divide over all 4 words
_Div1:
        addiu   $s0, $s0, -4
        lw      $s7, 16($s0)    # combination of zhift and subtract
        or      $t0, $s3, $s7   # first check to see if quotient is zero
        beq     $t0, $zero, _Div6

        lui     $s6, 0x8000     # then mask out each bit
_Div2:
        and     $s4, $s7, $s6   # if it is set, then we have a non-zero result
        beq     $s4, $zero, _Div3
        li      $s3, 1
        j       _Div4
_Div3:
        beq     $s3, $zero, _Div5
_Div4:
        move    $a1, $s4        # shift the carry into the data
        la      $a0, _data
        jal     ShiftLeft1
        li      $a1, 0          # shift the remainder
        la      $a0, _temp
        jal     ShiftLeft1

        move    $a0, $s1        # then do compare and subtract
        la      $a1, _data
        jal     CmpNumb
        li      $t0, -1
        beq     $v0, $t0, _Div5

        move    $a1, $s1        # data is the remainder
        la      $a0, _data
        la      $a2, _data
        jal     SubNumb
        la      $a0, _One       # temp is the quotient
        la      $a1, _temp
        la      $a2, _temp
        jal     AddNumb
_Div5:
        srl     $s6, $s6, 1
        bne     $s6, $zero, _Div2
_Div6:
        addiu   $s5, $s5, -1
        bne     $s5, $zero, _Div1
_Div7:
        la      $a0, _data
        lw      $a1, 36($sp)
        jal     VarCpy          # copy data to the remainder ptr
        la      $a0, _temp
        move    $a1, $s2
        jal     VarCpy          # copy temp to the quotient ptr

        lw      $s0,  0($sp)
        lw      $s1,  4($sp)
        lw      $s2,  8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)
        addiu   $sp, $sp, 40
        jr      $ra


# Integer Square Root
# $a0 = points to input (four word) data variable
# response written back to $a0  (same variable)
SquareRoot:
        addiu   $sp, $sp, -24   # stack frame
        sw      $s0, 16($sp)
        sw      $ra, 20($sp)
        move    $s0, $a0

        la      $a1, _data      # init some variables
        jal     VarCpy
        move    $a0, $s0
        jal     VarClr
        move    $a0, $sp
        jal     VarClr

        lui     $t0, 0x4000     # more bit initialization
        sw      $t0, 12($sp)
_Sqrt1:
        la      $a0, _data      # this speeds up the next part
        move    $a1, $sp
        jal     CmpNumb
        li      $t0, 1
        bne     $v0, $t0, _Sqrt2

        move    $a0, $sp
        jal     ShiftRight1
        move    $a0, $sp
        jal     ShiftRight1
        j       _Sqrt1
_Sqrt2:
        la      $a0, _Zero      # the square root, is just compare and shift
        move    $a1, $sp
        jal     CmpNumb
        beq     $v0, $zero, _Sqrt5

        move    $a0, $s0
        move    $a1, $sp
        la      $a2, _temp
        jal     AddNumb

        move    $a0, $s0
        jal     ShiftRight1

        la      $a0, _temp
        la      $a1, _data
        jal     CmpNumb
        li      $t0, -1
        beq     $v0, $t0, _Sqrt4

        la      $a0, _data
        la      $a1, _temp
        la      $a2, _data
        jal     SubNumb

        li      $t5, 16         # loop over 4 words
_Sqrt3:
        addiu   $t5, $t5, -4
        addu    $t4, $t5, $sp
        lw      $t0, 0($t4)
        addu    $t4, $t5, $s0
        lw      $t1, 0($t4)
        or      $t0, $t0, $t1
        sw      $t0, 0($t4)
        bne     $t5, $zero, _Sqrt3
_Sqrt4:
        move    $a0, $sp
        jal     ShiftRight1
        move    $a0, $sp
        jal     ShiftRight1
        j       _Sqrt2
_Sqrt5:
        lw      $s0, 16($sp)
        lw      $ra, 20($sp)
        addiu   $sp, $sp, 24
        jr      $ra


# HexAscii to Binary
# $a0 = pointer to an input asciiz digit string
# $a1 = pointer to the (four word) destination variable
# converts asciiz string containing 0-9,A-F,a-f into binary
# input string is terminated by 0x00 or 0x0a
HexAscToBin:
        addiu   $sp, $sp, -24   # stack frame
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $ra, 12($sp)

        move    $s0, $a0
        move    $s1, $a1

        move    $a0, $a1        # clear the destination
        jal     VarClr

_HexAsc1:
        lb      $s2, 0($s0)     # get the next digit
        addiu   $s0, $s0, 1     # allow null or <cr> to terminate
        beq     $s2, 0x0a, _HexAsc3
        beq     $s2, $zero, _HexAsc3

        move    $a0, $s1        # shift left 4 bits
        li      $a1, 0
        jal     ShiftLeft1
        move    $a0, $s1
        li      $a1, 0
        jal     ShiftLeft1
        move    $a0, $s1
        li      $a1, 0
        jal     ShiftLeft1
        move    $a0, $s1
        li      $a1, 0
        jal     ShiftLeft1

        addiu   $t1, $s2, -48   # convert ascii to binary
        li      $t0, 0x39
        bleu    $s2, $t0, _HexAsc2
        addiu   $t1, $s2, -55
        li      $t0, 0x46
        bleu    $s2, $t0, _HexAsc2
        addiu   $t1, $s2, -87
_HexAsc2:
        lb      $s2, 0($s1)     # or in the binary data value
        or      $s2, $s2, $t1
        sb      $s2, 0($s1)
        j       _HexAsc1
_HexAsc3:
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 24
        jr      $ra


# DecimalAscii to Binary
# $a0 = pointer to an input asciiz digit string
# $a1 = pointer to the (four word) destination variable
# converts asciiz string containing 0-9 into binary
# input string is terminated by 0x00 or 0x0a
# checks for leading "0x" and if present assumes text is actually hex
# checks for leading "-" and if present will negate the decimal result
DecAscToBin:
        lb      $t0, 0($a0)     # check for leading spaces (to be ignored)
        bne     $t0, 0x20, _Space0
        addiu   $a0, $a0, 1
        j       DecAscToBin
_Space0:
        lb      $t0, 0($a0)     # check for leading 0x indicator
        bne     $t0, 0x30, _DecAsc0
        lb      $t0, 1($a0)
        beq     $t0, 0x58, _HexAsc0
        lb      $t0, 1($a0)
        bne     $t0, 0x78, _DecAsc0
_HexAsc0:
        addiu   $a0, $a0, 2
        j       HexAscToBin
_DecAsc0:
        addiu   $sp, $sp, -24   # stack frame
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $ra, 16($sp)

        move    $s0, $a0
        move    $s1, $a1

        sw      $zero, 20($sp)  # assume positive
        lb      $t0, 0($s0)     # check for negative
        bne     $t0, 0x2d, _DecAsc9
        sw      $t0, 20($sp)
        addiu   $s0, $s0, 1
        move    $a0, $s0
_DecAsc9:
        jal     HexAscToBin     # first convert ascii to binary
        la      $a0, _temp      # and then prepare to convert bcd to binary
        jal     VarClr

        li      $s2, 128        # loop through 128 bits
_DecAsc1:
        lw      $s3, 0($s1)     # mask out the data 1 bit at a time
        andi    $s3, $s3, 1

        move    $a0, $s1
        jal     ShiftRight1
        la      $a0, _temp
        jal     ShiftRight1

        beq     $s3, $zero, _DecAsc2
        la      $t0, _temp
        lw      $t1, 12($t0)
        lui     $t2, 0x8000
        or      $t1, $t1, $t2
        sw      $t1, 12($t0)

_DecAsc2:
        li      $t5, 4          # mask, compare and subtract all 4 words
_DecAsc3:
        lui     $t2, 0xf000     # set up the bit masks
        lui     $t3, 0x7000
        lui     $t4, 0x3000
_DecAsc4:
        lw      $t0, 0($s1)
        and     $t0, $t0, $t2
        bleu    $t0, $t3, _DecAsc5
        lw      $t0, 0($s1)
        subu    $t0, $t0, $t4
        sw      $t0, 0($s1)
_DecAsc5:
        srl     $t2, $t2, 4
        srl     $t3, $t3, 4
        srl     $t4, $t4, 4
        bne     $t2, $zero, _DecAsc4

        addiu   $s1, $s1, 4

        addiu   $t5, $t5, -1
        bne     $t5, $zero, _DecAsc3

        addiu   $s1, $s1, -16

        addiu   $s2, $s2, -1
        bne     $s2, $zero, _DecAsc1

        lw      $t0, 20($sp)     # check for negative
        beq     $t0, $zero, _DecAsc6
        la      $a0, _Zero
        la      $a1, _temp
        la      $a2, _temp
        jal     SubNumb
_DecAsc6:
        la      $a0, _temp       # copy the result back
        move    $a1, $s1
        jal     VarCpy

        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $ra, 16($sp)
        addiu   $sp, $sp, 24
        jr      $ra


# Binary to HexAscii
# $a0 = pointer to the input (four word) source variable
# $a1 = pointer to the destination text array (to build asciiz string)
# converts the binary variable to (hex) asciiz
# assumes that $a1 is pointing to a buffer large enough to store the text
BinToHexAsc:
        li      $t3, 0          # flag to indicate result is non zero
        li      $t5, 4          # loop through 4 words
_BinHex1:
        addiu   $a0, $a0, -4
        li      $t4, 32         # number of bits to shift right
_BinHex2:
        addiu   $t4, $t4, -4

        lw      $t0, 16($a0)    # get the next nibble to test
        srlv    $t0, $t0, $t4
        andi    $t0, $t0, 0x0f

        or      $t1, $t0, $t3   # check for all zeroes
        beq     $t1, $zero, _BinHex4

        li      $t3, 1          # show that the result is no longer zero
        addiu   $t1, $t0, 0x30  # convert binary to ascii
        sb      $t1, 0($a1)
        bleu    $t1, 0x39, _BinHex3
        addiu   $t1, $t0, 55    # or ascii letter
        sb      $t1, 0($a1)
_BinHex3:
        addiu   $a1, $a1, 1
_BinHex4:
        bne     $t4, $zero, _BinHex2
        addiu   $t5, $t5, -1
        bne     $t5, $zero, _BinHex1

        bne     $t3, $zero, _BinHex5
        li      $t1, 0x30       # input only has zeroes
        sb      $t1, 0($a1)
        addiu   $a1, $a1, 1
_BinHex5:
        li      $t1, 0x0a       # append <cr> to the end
        sb      $t1, 0($a1)
        addiu   $a1, $a1, 1
        sb      $zero, 0($a1)   # and a null
        jr      $ra


# Binary to DecimalAscii
# $a0 = pointer to the input (four word) source variable
# $a1 = pointer to the destination text array (to build asciiz string)
# converts the binary variable to (decimal) asciiz
# will also store leading "-" if the data is negative
# assumes that $a1 is pointing to a buffer large enough to store the text
BinToDecAsc:
        addiu   $sp, $sp, -24   # stack frame
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $ra, 12($sp)

        move    $s0, $a0
        move    $s1, $a1

        la      $a1, _temp      # initialize some variables
        jal     VarCpy
        la      $a0, _data
        jal     VarClr

        lw      $t0, 12($s0)
        srl     $t0, $t0, 31    # get the sign flag
        andi    $t0, $t0, 1
        beq     $t0, $zero, _BinDec0

        la      $a0, _Zero
        la      $a1, _temp
        la      $a2, _temp
        jal     SubNumb

        li      $t0, 0x2d
        sb      $t0, 0($s1)
        addiu   $s1, $s1, 1
_BinDec0:

        li      $s2, 127        # go through 127 bits (1 less than max)
_BinDec1:
        li      $t5, 0          # loop over all 4 words
_BinDec2:
        lui     $t2, 0xf000     # set up the bit masks
        lui     $t3, 0x4000
        lui     $t4, 0x3000
_BinDec3:
        la      $t0, _data      # loop is mask, compare and add
        add     $t0, $t0, $t5
        lw      $t1, 0($t0)
        and     $t1, $t1, $t2
        bleu    $t1, $t3, _BinDec4

        lw      $t1, 0($t0)
        addu    $t1, $t1, $t4
        sw      $t1, 0($t0)
_BinDec4:
        srl     $t2, $t2, 4
        srl     $t3, $t3, 4
        srl     $t4, $t4, 4
        bne     $t4, $zero, _BinDec3

        addiu   $t5, $t5, 4
        bltu    $t5, 16, _BinDec2

        li      $a1, 0
        la      $a0, _temp
        jal     ShiftLeft1
        li      $a1, 0
        la      $a0, _data
        jal     ShiftLeft1

        la      $t0, _temp
        lw      $t0, 12($t0)
        lui     $t1, 0x8000
        and     $t0, $t0, $t1
        beq     $t0, $zero, _BinDec5
        la      $t0, _data
        lw      $t1, 0($t0)
        ori     $t1, $t1, 1
        sw      $t1, 0($t0)
_BinDec5:
        addiu   $s2, $s2, -1
        bne     $s2, $zero, _BinDec1

        la      $a0, _data
        move    $a1, $s1
        jal     BinToHexAsc     # data is now in hex

        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $ra, 12($sp)
        addiu   $sp, $sp, 24
        jr      $ra
