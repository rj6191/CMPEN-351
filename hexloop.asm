###########################################################################################################################
.data
Input1: 
	 .asciiz "\Please enter a positive number:\n"		#prompts the user to input something
Input2: 
	 .asciiz "\Please enter another positive number:\n"	#prompts the user to input something
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
 	add $t0, $zero, $v0	
 	
 	 # ask and store the second number
 	li $v0, 4
 	la $a0, Input2
 	syscall
 
 	li $v0, 5
 	syscall
 	add $t1, $zero, $v0		#moves value of input2 stored in $a0 to temp register $t1	
	 	
li $t2, 8      
la $t3, result
la $a0, Hex_Out1     
li $v0, 4     
syscall 
	
jal Hex_Loop1	 
 	li $v0, 11
 	li $a0, 10
 	syscall	
 	
li $t2, 8      
la $t3, result
la $a0, Hex_Out2     
li $v0, 4     
syscall  
	
jal Hex_Loop2

Hex_Loop1:     
	beqz $t2, Hex_Exit1    
 	rol  $t0, $t0, 4     
	and  $t4, $t0, 0xf           
	ble  $t4, 9, Hex_Sum1        
	addi $t4, $t4, 55              
b Hex_End1 
    
Hex_Sum1:         
	addi $t4, $t4, 48   

Hex_End1:     
	sb   $t4, 0($t3)        
	addi $t3, $t3, 1           
	addi $t2, $t2, -1       
j Hex_Loop1 

Hex_Exit1:     
	la $a0, result     
	li $v0, 4     
	syscall 
jr $ra	
Hex_Loop2:     
	beqz $t2, Hex_Exit2    
 	rol  $t1, $t1, 4     
	and  $t4, $t1, 0xf           
	ble  $t4, 9, Hex_Sum2        
	addi $t4, $t4, 55              
b Hex_End2 
    
Hex_Sum2:         
	addi $t4, $t4, 48   

Hex_End2:     
	sb   $t4, 0($t3)        
	addi $t3, $t3, 1           
	addi $t2, $t2, -1       
j Hex_Loop2 

Hex_Exit2:     
	la $a0, result     
	li $v0, 4     
	syscall 
	
	

li  $v0,10           # code for exit
syscall              # exit program