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
	
Hex_Out1: .asciiz "\nThe result of the first number as 8 hex digits is: \n "
Hex_Out2: .asciiz "\nThe result of the second number as 8 hex digits is: \n "
result:  .space 8


.text

main:
 					# ask and store the first number
 	li $v0, 4
 	la $a0, Input1
 	syscall
 
 	li $v0, 5
 	syscall
 	add $t0, $zero, $v0		#moves value of input2 stored in $v0 to temp register $t0
 	
  					# ask and store the second number
 	li $v0, 4
 	la $a0, Input2
 	syscall
 
 	li $v0, 5
 	syscall
 	add $t1, $zero, $v0		#moves value of input2 stored in $v0 to temp register $t1	

la $a0, Output1     			#displays first output prompt
li $v0, 4     
syscall 	               
jal dec_to_binary1			#jumps and links to first decimal to binary conversion
	#creates a new line
 	li $v0, 11
 	li $a0, 10
 	syscall
la $a0, Output2     			#displays second output prompt
li $v0, 4     
syscall  	
jal dec_to_binary2			#jumps and links to second decimal to binary conversion
	#creates a new line
 	li $v0, 11
 	li $a0, 10
 	syscall
 	
li $t2, 8      				#creates the counter for the hex loop
la $t3, result				#loads the result to memory
la $a0, Hex_Out1     			#displays the first hex output line
li $v0, 4     
syscall 
	
jal Hex_Loop1	 			#jumps and links to first decimal to hex conversion	
	#creates a new line
 	li $v0, 11
 	li $a0, 10
 	syscall	
 	
li $t2, 8      				#creates the counter for the hex loop
la $t3, result				#loads the result to memory
la $a0, Hex_Out2     			#displays the second hex output line
li $v0, 4     
syscall  
	
jal Hex_Loop2				#jumps and links to second decimal to hex conversion	


dec_to_binary1:
	add  $t2, $zero, $t0 		# store $t0 into $t2
 	add  $t3, $zero, $zero 		#set $t3 to 0
 	addi $t4, $zero, 1 		#load 1 as a mask
 	sll  $t4, $t4, 31 		#move the mask to appropriate position
 	addi $t5, $zero, 32 		#set the loop counter
loop1:
	and $t3, $t2, $t4 		#and the input with the mask
 
	beq $t3, $zero, print_binary1 	# Branch to the first print_binary loop if its 0
	add $t3, $zero, $zero		# Zero out $t3
 	addi $t3, $zero, 1 		# Put a 1 in $t3
 	

j print_binary1				#jump and link to the first print_binary loop

dec_to_binary2:
	add  $t2, $zero, $t1 		# store $t1 into $t2
 	add  $t3, $zero, $zero 		# Zero out $t3
 	addi $t4, $zero, 1 		# load 1 as a mask
 	sll  $t4, $t4, 31 		# move the mask to appropriate position
 	addi $t5, $zero, 32 		# set the loop counter
loop2:
	and  $t3, $t2, $t4 		# and the input with the mask
 	beq  $t3, $zero, print_binary2 	# Branch to the second print_binary loop if its 0
	add  $t3, $zero, $zero		# Zero out $t3
 	addi $t3, $zero, 1 		# Put a 1 in $t3	


j print_binary2				#jump and link to the second print_binary loop



print_binary1:				#loop that will print out the first number in binary
 
        li      $v0,1           	# sys call to print an integer
        move    $a0,$t3       		# move the result into a0
        syscall                		# print
        
   	srl  $t4, $t4, 1		#move the mask
    	addi $t5, $t5, -1		#decrease the loop counter
    	bne  $t5, $zero, loop1		#if the loop counter is not 0, go back and run the loop again
 
        jr      $ra

print_binary2:				#loop that will print out the first number in binary
  
        li      $v0,1           	# sys call to print an integer
        move    $a0,$t3       		# move the result into a0
        syscall                		# print

   	srl  $t4, $t4, 1		#move the mask
    	addi $t5, $t5, -1		#decrease the loop counter
    	bne  $t5, $zero, loop2		#if the loop counter is not 0, go back and run the loop again	
  
        jr      $ra 
          
Hex_Loop1:     
	beqz $t2, Hex_Exit1    	#checks to see if the counter is eqaul to zero, if so, jump to the exit loop 
 	rol  $t0, $t0, 4     	#rotate input left by 4 bits
	and  $t4, $t0, 0xf      #masks input with 1111 and stores into t4    
	ble  $t4, 9, Hex_Sum1   #if result is less than or eqaul to 9, branch to Hex_Sum1     
	addi $t4, $t4, 55       #adds 55 to the result.  55 is ASCII 7, so if you add 7 to a number greater or equal to nine it will make it a letter
	  
b Hex_End1 			#branch to the end loop
    
Hex_Sum1:         
	addi $t4, $t4, 48   	#adds 48 to the result.  48 is ASCII 0

Hex_End1:     
	sb   $t4, 0($t3)        # stores the converted hex number into the result
	addi $t3, $t3, 1        # increment address counter  
	addi $t2, $t2, -1       # decrement loop counter       
j Hex_Loop1 			# Jumps back to the conversion loop of the first number

Hex_Exit1:     			#The loop to exit the hex conversion if the counter is equal to zero
	la $a0, result     
	li $v0, 4     
	syscall 
jr $ra	
Hex_Loop2:     
	beqz $t2, Hex_Exit2 	#checks to see if the counter is eqaul to zero, if so, jump to the exit loop   
 	rol  $t1, $t1, 4     	#rotate input left by 4 bits
	and  $t4, $t1, 0xf   	#masks input with 1111 and stores in t4       
	ble  $t4, 9, Hex_Sum2   #if result is less than or eqaul to 9, branch to Hex_Sum2      
	addi $t4, $t4, 55       #adds 55 to the result.  55 is ASCII for 7       
	
b Hex_End2 			#branch to the end loop
    
Hex_Sum2:         		#adds 48 to the result.  48 is ASCII for 0
	addi $t4, $t4, 48   

Hex_End2:     
	sb   $t4, 0($t3)        # stores the converted hex number into the result
	addi $t3, $t3, 1        # increment address counter  
	addi $t2, $t2, -1       # decrement loop counter

j Hex_Loop2 			# Jumps back to the conversion loop of the second number

Hex_Exit2:     			#The loop to exit the hex conversion if the counter is equal to zero	
	la $a0, result     
	li $v0, 4     
	syscall 
        
#ends program
	li  $v0,10           	#exit syscall
	syscall              	# exit program        
###########################################################################################################################
