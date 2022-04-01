.data

weight1: .float 0.0
weight2: .float 0.0
momentum: .float 0.0
threshold: .float 0.0
learningRate: .float 0.0
error : .word 0
epochs: .word 0
txt: .asciiz "enter data: "
txt1: .asciiz "   weight1: "
txt2: .asciiz "   weight2: "
txt3: .asciiz "   momentum: "
txt4: .asciiz "   learning rate: "
txt5: .asciiz "   threshold: "
txt6: .asciiz "   number of epochs: "
txt7: .asciiz "new epoch:\n"
txt8: .asciiz "input1: " 
txt9: .asciiz "   input2: " 
txt10: .asciiz "   desired output: " 
txt11: .asciiz "   actual output: " 
txt12: .asciiz "   error: "
txtfile: .asciiz "enter training file name: "
name: .space	32
fin: .asciiz "testarc.csv"
byteErrorMessage: .asciiz "There were less than or equal to zero bytes read. Now exiting."
Barray:	.asciiz	"The array from data is: "
space:	.asciiz	" "
newline: .asciiz "\n"
buffer:	.space	80
length:	.word	80
numBytes: .word	0
array:	.word	4
inputno: .word 0

.text
.globl main
.ent main
main:

	li $v0, 4
	la $a0, txtfile
	syscall 
	li $v0,8 #take in input
        la $a0, name #load byte space into address
        li $a1, 12 # allot the byte space for string
        move $t0,$a0 #save string to t0
        syscall
        
   	li $v0, 4
	la $a0, newline
	syscall
         
	# Set $a0 equal to the address of the filename
	# and $a1 to the address of the buffer where data is stored
	move $a0,$t0
	la	$a1, buffer
	
	# Call numBytesRead
	jal numBytesRead
	# If numBytes<=0, error message and exit, else set equal to numBytes
	blez $v0, byteError  
	sw $v0, numBytes
	
	# Call string to int after setting a0 and a1
	la $a0, array
	li $a1, 4
	la $a2, buffer
	jal stringToInt
	move $s0, $a0
	
	#call array size
	la $a0, array
	#move $a0, $s0
	jal lenArray
        move    $t7,$v0
	
        
	#call get data from user	
	jal getdata
	
	#start training
	lw $t9,epochs
	xor	$s2, $s2, $s2	# i = 0
	loop:
	li $v0, 4
	la $a0, txt7
	syscall 
	jal training
	li $v0, 4 
	la $a0, newline
	syscall
	addiu	$s2, $s2, 1	# i = i+1
	bne	$t9, $s2, loop
	
	li $v0,10
	syscall 
##############################################################################	
numBytesRead:

	# Move a registers to s registers 
	move $s0, $a0
	move $s1, $a1
	
	# Open file with no flags for reading, move file descriptor to s2
	li $v0, 13
	move $a0, $s0
	li $a1, 0
	li $a2, 0
	syscall
	move $s2, $v0
	
	# Make a0 the file descriptor, read 80 char from file and put in buffer
	move $a0, $s2
	li $v0, 14
	move $a1, $s1
	li $a2, 80
	syscall
	
	# Close file
	li $v0, 16
	syscall
	
	# return to main
	move $v0, $s2
	jr $ra
##############################################################################
byteError:

	# Print error message and exit
	li	$v0, 4
	la	$a0, byteErrorMessage
	syscall
	
	j exit
##############################################################################
stringToInt:

	move $s0, $a0	# s0= array
	move $s1, $a1	# s1 = 4
	move $s2, $a2	# s2 = buffer
	
	lb $t2, ($s2)
    	move $t3,$t2
    	sub $t3, $t3, 48
    	sb $t3, inputno
    	
    	addi $s2, $s2, 1
	addi $s2, $s2, 1
	
	li $s3, 0	# sum = s3 = 0
	xor $t9,$t9,$t9
loop1:	lb $t1, ($s2)
	beq $t1, 0, end		# if it's 0, end of data reached
	j loop2
		
loop2:	beq $t1, 59, save	# if equal ";", save 
	beq $t1, 10, save       # if equal new line, save
	blt $t1, 48, ignore	# if less than 48, ignore
	sub $t1, $t1, 48	# subtract 48
	mul $s3, $s3, 10	# multiply sum by 10
	add $s3, $s3, $t1	# add converted ascii to sum
	addi $s2, $s2, 1	# add one to the buffer
	j loop1			# get next byte

ignore: addi $s2, $s2, 1	# add one to the buffer
	j loop1			# jump to loop 1 to get next byte
	
save:  
	sw $s3, ($s0)		# store int in array 
	addi $s0, $s0, 4	# add 4 to array to get to next word
	addi $s2, $s2, 1	# add one to the buffer
	li $s3, 0		# set sum back to zero
	j loop1			# get next byte from loop 1
	
end: jr $ra			# go back to main

##############################################################################
getdata:
	li $v0, 4
	la $a0, txt
	syscall 
	li $v0, 4 
	la $a0, newline
	syscall
	
	# getting weight 1
	li $v0, 4
	la $a0, txt1
	syscall 
	li  $v0,6 
	syscall
	mov.s   $f4,$f0
	s.s   $f4,weight1
	
	# getting weight2
	li $v0, 4
	la $a0, txt2
	syscall 
	li  $v0,6 
	syscall
	mov.s   $f4,$f0
	s.s   $f4,weight2
	
	# getting momentum
	li $v0, 4
	la $a0, txt3
	syscall 
	li  $v0,6 
	syscall
	mov.s   $f4,$f0
	s.s   $f4,momentum
	
	# getting learning rate
	li $v0, 4
	la $a0, txt4
	syscall 
	li  $v0,6 
	syscall
	mov.s   $f4,$f0
	s.s   $f4,learningRate
	
	# getting threshold
	li $v0, 4
	la $a0, txt5
	syscall 
	li  $v0,6 
	syscall
	mov.s   $f4,$f0
	s.s   $f4,threshold
	
	# getting number of epochs
	li $v0, 4
	la $a0, txt6
	syscall 
	li  $v0,5
	syscall
	move   $t0,$v0
	sw   $t0,epochs
	
	jr $ra
##############################################################################
training:

	move	$t0, $s0
	la $s1, 12
	xor	$t1, $t1, $t1	# $t1 = i = 0
	L1:
	
	lw $t2, 0($t0)	# $t2 = input[i] 
	
	li $v0, 4
	la $a0, txt8
	syscall 
	move $a0,$t2
	li $v0, 1
	syscall  
	   
	mtc1 $t2, $f1
	cvt.s.w $f1, $f1     # $f1 = input1
	l.s   $f0,weight1
	
	li $v0, 4
	la $a0, txt1
	syscall
	mov.s   $f4,$f0
        mov.d   $f12,$f4
	li  $v0,2
	syscall
	
	mul.s $f0, $f0, $f1  #input1 * weight1
	
	addiu	$t0, $t0, 4	# point to next A[i]  input2
	addiu	$t1, $t1, 1	# i++
	lw $t2, 0($t0)
	
	li $v0, 4
	la $a0, txt9
	syscall 
	move $a0,$t2
	li $v0, 1
	syscall
	
	mtc1 $t2, $f5 
	cvt.s.w $f5, $f5      # $f5 = input2
	l.s   $f2,weight2
	
	li $v0, 4
	la $a0, txt2
	syscall
	
	mov.s   $f4,$f2
        mov.d   $f12,$f4
	li  $v0,2
	syscall
	
	mul.s $f2, $f2, $f5  #input2 * weight2
	
	add.s $f0, $f0, $f2 # (in1*w1 + in2*w2)-threshold
	l.s   $f3,threshold
	sub.s $f0, $f0, $f3  
	
	la $t2,0
	mtc1 $t2, $f4
	cvt.s.w $f4, $f4
	c.le.s $f0, $f4  # step function
	bc1f here
	la $t3,0  # $t3 = actual output
	j next 
	here:
	la $t3,1
	next:
	
	li $v0, 4 
	la $a0, txt11
	syscall
	move $a0, $t3
	li  $v0,1
	syscall
	
	addiu	$t0, $t0, 4	# point to next A[i]  output
	addiu	$t1, $t1, 1	# i++
	lw $t4, 0($t0) # desired output
	
	li $v0, 4 
	la $a0, txt10
	syscall
	move $a0, $t4
	li  $v0,1
	syscall
	
	lw $t6,error
	sub $t6, $t4, $t3  # error = desired output - actual output
	
	li $v0, 4 
	la $a0, txt12
	syscall
	move $a0, $t6
	li  $v0,1
	syscall
	
	la $t7,0
	beq $t6,$t7,continue #compare error with zero
	
	# if error != 0 then update Weights else jump to continue
	l.s   $f6,learningRate
	l.s   $f2,momentum
	mtc1 $t6, $f7
	cvt.s.w $f7, $f7 # convert error to float
	
	# update weight 1
	l.s   $f3,weight1
	mul.s $f3,$f3,$f2 # x = weight1 * momentum
	mul.s $f6,$f6,$f1 #input1 * learning rate
	mul.s $f6,$f6,$f7 # y = input1 * learning rate * error
	add.s $f6,$f6,$f3 # new weight1 = x + y
	s.s $f6, weight1
	
	# update weight 2
	l.s   $f6,learningRate
	l.s   $f8,weight2
	mul.s $f8,$f8,$f2 # x = weight2 * momentum
	mul.s $f6,$f6,$f5 #input2 * learning rate
	mul.s $f6,$f6,$f7 # y = input2 * learning rate * error
	add.s $f6,$f6,$f8 # new weight2 = x + y
	s.s $f6, weight2

continue:
	li $v0, 4 
	la $a0, newline
	syscall
	addiu	$t0, $t0, 4	# point to next A[i]  input2
	addiu	$t1, $t1, 1	# i++
	bne	$t1, $s1, L1	# loop if (i != n)

	jr  $ra
	
###############################################################################
#Fn returns the number of elements in an array
lenArray:       
        addi    $sp,$sp,-8
        sw  $ra,0($sp)
        sw  $a0,4($sp)
        li  $t1,0

laWhile:
        lw  $t2,0($a0)
        beq $t2,$0,endLaWh
        addi    $t1,$t1,1
        addi    $a0,$a0,4
        j   laWhile

endLaWh:    
        move    $v0,$t1
        lw  $ra,0($sp)
        lw  $a0,4($sp)
        addi    $sp,$sp,8
        jr  $ra
###########################################################################################

exit:	
	 li $v0, 10
	 syscall		
