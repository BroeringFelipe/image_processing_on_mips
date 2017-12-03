.eqv lenght_max 1048576 #1048576 = 512*512*4
			#4194304 = 1024*1024*4  Doesn't work

.data
display_bitmap:	.space lenght_max
buff: 		.space lenght_max
buff_tmp:	.space lenght_max
bmp_lenght: 	.word
width_lenght: 	.word
height_lenght:	.word
filename: 	.asciiz "lena.bmp"

.text
#Call function read_archive
la $a0, display_bitmap	#Pass the adress of display
la $a1, buff	#Pass the adress for de buffer
la $a2, bmp_lenght
la $a3, filename
jal read_archive

la $t0, width_lenght
sw $v0, 0($t0)

la $t0, height_lenght
sw $v1, 0($t0)

#Call function rotate_image
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
la $a0, display_bitmap
la $a1, display_bitmap
lw $a2, width_lenght
lw $a3, height_lenght
jal flip_hrzt


li $v0, 10
syscall


#abre arquivo
########################################################################
load_file:

move $t0, $a0		# Save the arguments
move $t1, $a1
move $t2, $a2
move $t3, $a3

move $a0, $t3		# endere�o da string com o nome do arquivo
li $v0, 13		# parametro p chamada de abertura
li $a1, 0		# flags (0=read, 1=write)
li $a2, 0		# mode = desnecess�rio
syscall			# devolve o descritor (ponteiro) do arquivo em $v0

move $t9, $v0		# Save de file descriptor in $t9

move $a0, $v0		# mode o descritor para $a0
li $v0, 14		# parametro de chamada de leitura de arquivo
move $a1, $t1		# endere�o para armazenamento dos dados lidos
li $a2, lenght_max	# tamanho m�x de caracteres
syscall			# devolve o n�mero de caracteres lidos

move $t4, $v0		
add $t4, $t4, $t1	# aponta para o endere�o do ultimo caracter lido + 1
sb $zero, 0($t4)	# grava 0 (zero - caracter nulo)


# Close the file 
li   $v0, 16       	# system call for close file
move $a0, $t9      	# file descriptor to close
syscall            	# close file

move $a0, $t0		# Return the arguments
move $a1, $t1
move $a2, $t2
move $a3, $t3

jr $ra
########################################################################



#read_archive
########################################################################
# $a0 = display_bitmap
# $a1 = buff
# $a2 = bmp_lenght
# $a3 = filename
read_archive:	
	
	sw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jal load_file
	
	lw $ra, -4($sp)
	addi $sp, $sp, -4
	
	#Read the length of archive.bmp
	move   $t0, $a1
	lw   $t1, 0($t0)
	srl  $t1, $t1, 16

	lw   $t2, 4($t0)
	sll  $t2, $t2, 16

	add  $t1, $t1, $t2	#$t1 contains the length of buff
	
	#Read the width and height of image.bmp
	move   $t0, $a1
	lw   $t2, 16($t0)
	srl  $t2, $t2, 16

	lw   $t3, 20($t0)
	sll  $t3, $t3, 16

	add  $v0, $t2, $t3	#$v0 contains the length width
			
	move   $t0, $a1
	lw   $t2, 20($t0)
	srl  $t2, $t2, 16

	lw   $t3, 24($t0)
	sll  $t3, $t3, 16

	add  $v1, $t2, $t3	#$t1 contains the length height	
			
			
			
	#move $t0, $a1		#Move the initial adress of buff to $t0
	addi $t0, $t0, 54	#Skip the header
	
	li $t2, 0		#Control variable
	addi $t2, $t2, 54	#Skip the header on the count
	
	move $t3, $a0		#Move the initial adress of display to $t3
	
	print_to_disp_loop:
		sb $zero, 0($t3)
		
		lbu $t4, 0($t0)
		sb  $t4, 0($t3)
		
		lbu $t4, 1($t0)
		sb  $t4, 1($t3)
		
		lbu $t4, 2($t0)
		sb  $t4, 2($t3)
		
		lw $t4, 0($t3)
		sw $t4, 0($t3)
		
		addi $t3, $t3, 4
		addi $t0, $t0, 3
		addi $t2, $t2, 3
		
		blt $t2, $t1, print_to_disp_loop
	
		
	# update buff and flip image to be correct
	addi $sp, $sp, -20
	sw $a3, 16($sp)
	sw $a2, 12($sp)
	sw $a1, 8($sp)
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	
		
	move $a2, $v0
	move $a3, $v1
		
	
	jal flip_vert
	lw $a1, 4($sp)
	lw $a0, 8($sp)
	jal move_image
	
	
	lw $a3, 16($sp)
	lw $a2, 12($sp)
	lw $a1, 8($sp)
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 20
	##############################
	
	
	jr $ra
########################################################################


# flip vertical
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
flip_vert:
	# Copy the source image to buffer to be processed
	addi $sp, $sp, -8
	sw $a1, 4($sp)
	sw $ra, 0($sp)

	la $a1, buff_tmp
	jal move_image
	
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	##############################
	la $a0, buff_tmp

	move $t0, $a1
	move $t1, $a0
	
	mul $t7, $a2, 4
	
	mul $t2, $a2, $a3	
	mul $t6, $t2, 4
	
	add $t1, $t1, $t6
	li $t3 0
	loop_flip_vert_1:
		sub $t1, $t1, $t7
		li $t5 0
		
		loop_flip_vert_2:
			lw $t4 ($t1)
			sw $t4 ($t0)
		
			addi $t1 $t1 4
			addi $t0 $t0 4
			addi $t3 $t3 4
			addi $t5 $t5 1
		blt $t5, $a2, loop_flip_vert_2
		sub $t1, $t1, $t7		
		
	blt $t3, $t6, loop_flip_vert_1
	
	
	jr $ra
########################################################################


# flip horizontal
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
flip_hrzt:
	# Copy the source image to buffer to be processed
	addi $sp, $sp, -8
	sw $a1, 4($sp)
	sw $ra, 0($sp)

	la $a1, buff_tmp
	jal move_image
	
	lw $a1, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	##############################
	la $a0, buff_tmp	#Update the source address to buff_tmp

	move $t0, $a1
	move $t1, $a0
	
	mul $t7, $a2, 4
	
	mul $t2, $a2, $a3	
	mul $t6, $t2, 4

	
	li $t3 0
	loop_flip_hrzt_1:
		add $t1, $t1, $t7
		li $t5 0
		
		loop_flip_hrzt_2:
			lw $t4, 0($t1)
			sw $t4, 0($t0)
		
			sub  $t1, $t1, 4
			addi $t0, $t0, 4
			addi $t3, $t3, 4
			addi $t5, $t5, 1
		blt $t5, $a2, loop_flip_hrzt_2
		add $t1, $t1, $t7		
		
	blt $t3, $t6, loop_flip_hrzt_1
	
	
	jr $ra
########################################################################



#Move image
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
move_image:
	mul $t0, $a2, $a3
	li $t1, 0
	
	move $t2, $a0
	move $t3, $a1
	
	loop_move_image:
		lw $t4, 0($t2)
		sw $t4, 0($t3)
		
		addi $t2, $t2, 4
		addi $t3, $t3, 4
		addi $t1, $t1, 1
		
		blt $t1, $t0, loop_move_image
	
	jr $ra		
########################################################################
