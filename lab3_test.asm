####################################################################################
.data								#says we will be putting data in
Input1: 
	.asciiz "\Please enter a positive number:\n"		#prompts the user to input something
Input2: 
	.asciiz "\Please enter another positive number:\n"	#prompts the user to input something	
Output:
	.asciiz "\The result of the numbers you entered multiplied by each other is: \n"

.text

main:
la $a0, Input1							#loads adress of first input array
li $v0, 4							#service 4 is print string
syscall

li $v0, 5							#retrieves value of Input
syscall 

add $t0, $zero, $v0						#moves value of input1 stored in $a0 to temp register $t0

la $a0, Input2							#loads adress of second input array
li $v0, 4							#service 4 is print string
syscall

li $v0, 5							#retrieves value of Input
syscall 

add $t1, $zero, $v0						#moves value of input2 stored in $a0 to temp register $t1
    
    
    jal MyMult
    j   print

MyMult:
    move $t3, $0        # lw product
    move $t4, $0        # hw product

    beq $t1, $0, done
    beq $t0, $0, done

    move $t2, $0        # extend multiplicand to 64 bits

loop:
    andi $t6, $t0, 1    # LSB(multiplier)
    beq $t6, $0, next   # skip if zero
    addu $t3, $t3, $t1  # lw(product) += lw(multiplicand)
    sltu $t6, $t3, $t1  # catch carry-out(0 or 1)
    addu $t4, $t4, $t6  # hw(product) += carry
    addu $t4, $t4, $t2  # hw(product) += hw(multiplicand)
next:
    # shift multiplicand left
    srl $t6, $t1, 31    # copy bit from lw to hw
    sll $t1, $t1, 1
    sll $t2, $t2, 1
    addu $t2, $t2, $t6

    srl $t0, $t0, 1     # shift multiplier right
    bne $t0, $0, loop

done:
    jr $ra

print:
    # print output string
    li  $v0,4           
    la  $a0,Output      
    syscall             

    # print out the result
    li      $v0,1       
    move    $a0,$t4    
    syscall             

    li      $v0,1       
    move    $a0,$t3     
    syscall             

li  $v0,10          # code for exit
syscall             # exit program