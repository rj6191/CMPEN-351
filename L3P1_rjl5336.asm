###########################################################################################################################
.data								#says we will be putting data in
save_word:
	.asciiz "   "						#creates blank space to store our value that gets wrote out to a file
Input1: 
	.asciiz "\Please enter a positive number:\n"		#prompts the user to input something
Input2: 
	.asciiz "\Please enter another positive number:\n"	#prompts the user to input something	
Output:
	.asciiz "\The result of the numbers you entered multiplied by each other is: \n"
	
fout:   .asciiz "Program1_out"      # filename for output

	

.text

main:
la $a0, Input1			#loads adress of first input array
li $v0, 4			#service 4 is print string
syscall

li $v0, 5			#retrieves value of Input
syscall 

add $t0, $zero, $v0		#moves value of input1 stored in $v0 to temp register $t0

la $a0, Input2			#loads adress of second input array
li $v0, 4			#service 4 is print string
syscall

li $v0, 5			#retrieves value of Input
syscall 

add $t1, $zero, $v0		#moves value of input2 stored in $v0 to temp register $t1
    
    
    jal Outloop
    j   print

Outloop:
    add $t3, $zero, $0        
    add $t4, $zero, $0        

    beq $t1, $0, done		#if second input is 0, branch to done loop
    beq $t0, $0, done		#if first input is 0, branch to done loop

    add $t2, $zero, $0        	# extend multiplicand to 64 bits

inloop:
    andi $t6, $t0, 1    	#This is the multiplier
    beq  $t6, $0, next 		# Will skip the loop if $t6 is equal to zero
    addu $t3, $t3, $t1  	#increment t3 by itself plus t1
    sltu $t6, $t3, $t1  	#check to see if t1 is greater than t3
    addu $t4, $t4, $t6  	#increment t4 by itself plus t6
    addu $t4, $t4, $t2  	#increment t4 by itself plus t2
next:
    # shift multiplicand left
    srl $t6, $t1, 31    	
    sll $t1, $t1, 1		#multiply by 2
    sll $t2, $t2, 1		#multiply by 2
    addu $t2, $t2, $t6

    srl $t0, $t0, 1     	# shift multiplier right
    bne $t0, $0, inloop		#if first input is 0, branch bck to inloop

done:
    jr $ra

print:
    # print output string
    li  $v0,4           
    la  $a0,Output      
    syscall             

    # print out the result       
   li      $v0,1       
   move    $a0,$t3      
   syscall     
   
 #this code was provided in the MARS help file.  I have modified it to fit our program
  ###############################################################
  # Open (for writing) a file that does not exist
  la $t7, save_word         
  sb $t3, ($t7)	      #	
  li   $v0, 13        # system call for open file
  la   $a0, fout      # output file name
  li   $a1, 1         # Open for writing (flags are 0: read, 1: write)
  li   $a2, 0         # mode is ignored
  syscall             # open a file (file descriptor returned in $v0)
  move $s6, $v0       # save the file descriptor 
  ###############################################################
  # Write to file just opened
  li   $v0, 15        # system call for write to file
  move $a0, $s6       # file descriptor 
  la   $a1, save_word # address of buffer from which to write
  li   $a2, 4         # hardcoded buffer length
  syscall             # write to file
  ###############################################################
  # Close the file 
  li   $v0, 16        # system call for close file
  move $a0, $s6       # file descriptor to close
  syscall             # close file
  ###############################################################    

li  $v0,10           # code for exit
syscall              # exit program
###########################################################################################################################
