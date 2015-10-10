# Write a MIPS code that asks the user for decimal number 
# Convert it to hex and print the result     
.data 
prompt: .asciiz "Enter the decimal number to convert: " 
ans: .asciiz "\nHexadecimal equivalent: "
result: .space 8 
 
.text     
main:     
	la $a0, prompt     
	li $v0, 4     
	syscall     

	li $v0, 5     
	syscall     
	add $t0, $zero, $v0
     
	la $a0, ans     
	li $v0, 4     
	syscall     
	li $t2, 8               
    
	la $t3, result      

Hex_Loop:     
	beqz $t2, Hex_Exit      
 	rol  $t0, $t0, 4     
	and  $t4, $t0, 0xf           
	ble  $t4, 9, Hex_Sum        
	addi $t4, $t4, 55              
b Hex_End 
    
Hex_Sum:         
	addi $t4, $t4, 48   

Hex_End:     
	sb   $t4, 0($t3)        
	addi $t3, $t3, 1           
	addi $t2, $t2, -1       
j Hex_Loop 

Hex_Exit:     
	la $a0, result     
	li $v0, 4     
	syscall 
	    
la $v0, 10     
syscall  

