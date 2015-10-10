###########################################################################################################################
.data
Input1: 
	.asciiz "\Please enter a positive number:\n"		#prompts the user to input something
Input2: 
	.asciiz "\Please enter another positive number:\n"	#prompts the user to input something	
Output1:
	.asciiz "\The result of the first number as a 32 bit binary number is: \n"
Output2:
	.asciiz "\The result of the second number as a 32 bit binary number is: \n"	
	



.text

main:
 	# ask and store the first number
 	li $v0, 4
 	la $a0, Input1
 	syscall
 
 	li $v0, 5
 	syscall
 	add $t0, $zero, $v0		#moves value of input2 stored in $a0 to temp register $t1
  	# ask and store the second number
 	li $v0, 4
 	la $a0, Input2
 	syscall
 
 	li $v0, 5
 	syscall
 	add $t1, $zero, $v0		#moves value of input2 stored in $a0 to temp register $t1	
	               
la $a0, Output1     
li $v0, 4     
syscall 
jal dec_to_binary1
	#creates a new line so the thirty two bit numbers dont end up on same line
 	li $v0, 11
 	li $a0, 10
 	syscall
la $a0, Output2     
li $v0, 4     
syscall  	
jal dec_to_binary2
	#creates a new line so the thirty two bit numbers dont end up on same line
 	li $v0, 11
 	li $a0, 10
 	syscall

#ends program
	li  $v0,10           # code for exit
	syscall              # exit program


dec_to_binary1:
	add  $t2, $zero, $t0 		# put our input ($a0) into $t0
 	add  $t3, $zero, $zero 		# Zero out $t1
 	addi $t4, $zero, 1 		# load 1 as a mask
 	sll  $t4, $t4, 31 		# move the mask to appropriate position
 	addi $t5, $zero, 32 		# loop counter
loop1:
	and $t3, $t2, $t4 		# and the input with the mask
 
	beq $t3, $zero, print_binary1 	# Branch to print if its 0
	add $t3, $zero, $zero		# Zero out $t1
 	addi $t3, $zero, 1 		# Put a 1 in $t1
 	

j print_binary1

dec_to_binary2:
	add  $t2, $zero, $t1 		# put our input ($a0) into $t0
 	add  $t3, $zero, $zero 		# Zero out $t1
 	addi $t4, $zero, 1 		# load 1 as a mask
 	sll  $t4, $t4, 31 		# move the mask to appropriate position
 	addi $t5, $zero, 32 		# loop counter
loop2:
	and $t3, $t2, $t4 		# and the input with the mask
 	beq $t3, $zero, print_binary2 	# Branch to print if its 0
	add  $t3, $zero, $zero		# Zero out $t1
 	addi $t3, $zero, 1 		# Put a 1 in $t1	


j print_binary2



print_binary1:
    # print output string
 
        li      $v0,1           	# system call code for print_int
        move    $a0,$t3       		# prepare to print the integer answer
        syscall                		# print the first sum
        
   	srl  $t4, $t4, 1
    	addi $t5, $t5, -1
    	bne  $t5, $zero, loop1
 
        jr      $ra

print_binary2:
    # print output string
  
        li      $v0,1           	# system call code for print_int
        move    $a0,$t3       		# prepare to print the integer answer
        syscall                		# print the first sum

   	srl  $t4, $t4, 1
    	addi $t5, $t5, -1
    	bne  $t5, $zero, loop2
  
        jr      $ra   
 
###########################################################################################################################
