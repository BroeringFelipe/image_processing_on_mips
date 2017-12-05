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
jal fade_out


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
		lbu $t4, 0($t0)
		sb  $t4, 0($t3)
		
		lbu $t4, 1($t0)
		sb  $t4, 1($t3)
		
		lbu $t4, 2($t0)
		sb  $t4, 2($t3)
		
		sb $zero, 3($t3)
		
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



# Rotate color
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
rotate_color:
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

	move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	
	li $t3 0
	
	loop_rotate_color:
		lbu $t4, 0($t0)
		lbu $t5, 1($t0)
		lbu $t6, 2($t0)
		
		sb  $t5, 0($t1)
		sb  $t6, 1($t1)
		sb  $t4, 2($t1)
				
		lw $t4, 0($t1)
		sw $t4, 0($t1)
		
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		addi $t1, $t1, 4	
		
	blt $t3, $t2, loop_rotate_color
	
	jr $ra
########################################################################



# invert color
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
invert_color:
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

	move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	
	li $t3, 0
	li $t7, 255
	
	loop_invert_color:
		lbu $t4, 0($t0)
		lbu $t5, 1($t0)
		lbu $t6, 2($t0)
		
		sub $t4, $t7, $t4
		sub $t5, $t7, $t5
		sub $t6, $t7, $t6
		
		sb  $t4, 0($t1)
		sb  $t5, 1($t1)
		sb  $t6, 2($t1)
				
		lw $t4, 0($t1)
		sw $t4, 0($t1)
		
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		addi $t1, $t1, 4	
		
	blt $t3, $t2, loop_invert_color
	
	jr $ra
########################################################################



# grey scale
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
grey_scale:
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

	move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	
	li $t3, 0
	
	li $t7, 2989	#R
	mtc1 $t7, $f0
	cvt.s.w $f0, $f0
	
	li $t7, 5870	#G
	mtc1 $t7, $f1
	cvt.s.w $f1, $f1
	
	li $t7, 1140	#B
	mtc1 $t7, $f2
	cvt.s.w $f2, $f2
	
	li $t7, 10000	#Factor to divide
	mtc1 $t7, $f3
	cvt.s.w $f3, $f3
	
	div.s $f0, $f0, $f3	#R factor
	div.s $f1, $f1, $f3	#G factor
	div.s $f2, $f2, $f3	#B factor
	
	loop_grey_scale:
		lbu $t4, 0($t0)	#Blue
		mtc1 $t4, $f4
		cvt.s.w $f4, $f4
		mul.s $f4, $f4, $f2
		
		lbu $t5, 1($t0)	#Green
		mtc1 $t5, $f5
		cvt.s.w $f5, $f5
		mul.s $f5, $f5, $f1
		
		lbu $t6, 2($t0)	#Red
		mtc1 $t6, $f6
		cvt.s.w $f6, $f6
		mul.s $f6, $f6, $f0
		
		add.s $f4, $f4, $f5
		add.s $f4, $f4, $f6
		
		cvt.w.s $f4, $f4
		
		mfc1 $t4, $f4
		
		sb  $t4, 0($t1)
		sb  $t4, 1($t1)
		sb  $t4, 2($t1)
				
		lw $t4, 0($t1)
		sw $t4, 0($t1)
		
		addi $t3, $t3, 1
		addi $t0, $t0, 4
		addi $t1, $t1, 4	
		
	blt $t3, $t2, loop_grey_scale
	
	jr $ra
########################################################################


# average pixel
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
average_pixel:
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

	move $t0, $a0
	move $t1, $a1
	
	mul  $t9, $a2, 4
	
	add  $t0, $t0, $t9
	addi $t0, $t0, 4
	
	add  $t1, $t1, $t9
	addi $t1, $t1, 4
	
	mul  $t3, $a2, $a3
	sub  $t3, $t3, $a2
	mul  $t3, $t3, 4
	addi $t3, $t3, -4
	add  $t3, $t3, $t0
	
	
	li $t6, 1
	
	loop_average_pixel:
		li $t5, 0
		li $t6, 0
		li $t7, 0
		
		sub  $t2, $t0, $t9
		addi $t2, $t2, -4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4	
			
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		#
		
		addi $t2, $t0, -4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		#
		
		add  $t2, $t0, $t9
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		
		
		
		addi $t2, $t2, 4
		
		lbu  $t4, 0($t2)
		add  $t5, $t5, $t4
		lbu  $t4, 1($t2)
		add  $t6, $t6, $t4
		lbu  $t4, 2($t2)
		add  $t7, $t7, $t4
		#
			
					
		div $t5, $t5, 9
		div $t6, $t6, 9
		div $t7, $t7, 9
		sb  $t5, 0($t1)
		sb  $t6, 1($t1)
		sb  $t7, 2($t1)
		
		lw  $t4, 0($t1)
		sw  $t4, 0($t1)
		
		addi $t6, $t6, 1
		blt  $t6, $a2, ts_line
			addi $t0, $t0, 8
			addi $t1, $t1, 8
			li   $t6, 1
		
		ts_line:
		addi $t0, $t0, 4
		addi $t1, $t1, 4
		
	blt $t0, $t3, loop_average_pixel
	
	jr $ra
########################################################################



# Fade in animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
fade_out:
	# Copy the source image to destination
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal move_image
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	
	li $t0, 0
	li $t3, 0
	li $t4, 29
	li $t8, 0
	li $t9, 5
	li $t6, 0x00ffffff
	
	loop_fade_out_1:
		loop_fade_out_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_fade
			sw   $t6, 0($t1)
			
			
			jump_fade:
			addi $t3, $t3, 1
			addi $t0, $t0, 4
			addi $t1, $t1, 4	
		
		blt $t3, $t2, loop_fade_out_2
		
		div $t4, $t4, 2
		move $t1, $a1
		li $t3, 0
		addi $t8, $t8, 1
		
	blt $t8, $t9, loop_fade_out_2
	
	jr $ra
########################################################################


# Fade in animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
fade_in:
	# Clear the destination
	addi $sp, $sp, -8
	sw $a0, 4($sp)
	sw $ra, 0($sp)
	move $a0, $a1
	jal clear_screen
	lw $a0, 4($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 8
	
	move $t1, $a1
	move $t6, $a0
	
	mul $t2, $a2, $a3
	
	
	li $t3, 0
	li $t4, 32
	li $t9, 7
	
	
	mul $t0, $a2, 64
	div $s0, $t0, 4
	
	loop_fade_in_1:
		loop_fade_in_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_fade_in_1
				sw   $t6, 0($t1)
			
				rem  $t5, $t3, 1024
				bnez $t5, jump_fade_in_1
					add $t1, $t1, $t0
					sub $t2, $t2, $s0
			
			
			jump_fade_in_1:
			addi $t2, $t2, -1
			addi $t1, $t1, 4	
		
		bgtz $t2, loop_fade_in_2
		
		
		mul $t2, $a2, $a3

		ble $s0, $a2, jump_fade_in_2
		div $t0, $t0, 2
		div $s0, $t0, 4
		j end_jump_fade_in_2
		jump_fade_in_2:
		li $t0, 4
		li $s0, 1
		end_jump_fade_in_2:
		
		beq $t4, 2, jump_fade_in_3
		div $t4, $t4, 2
		jump_fade_in_3:
		
		bgt $t9, 2, jump_fade_in_4
		li $t4, 1
		jump_fade_in_4:
		
		move $t1, $a1
		li $t3, 0
		addi $t9, $t9, -1
		
	bgtz $t9, loop_fade_in_2
	
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



#Clear Screen
########################################################################
# $a0 = Screen to clear
# $a2 = width_lenght
# $a3 = height_lenght
clear_screen:
	mul $t0, $a2, $a3
	li $t1, 0
	
	move $t2, $a0
	li $t4, 0x00ffffff
	
	loop_clear_screen:
		sw $t4, 0($t2)
		
		addi $t2, $t2, 4
		
		addi $t1, $t1, 1
		
		blt $t1, $t0, loop_clear_screen
	
	jr $ra		
########################################################################



#Get pixel
########################################################################
# $a0 = source address
# $a1 = x
# $a2 = y
# $a3 = widht_lenght
# $v0 returns the value of the pixel
get_pixel:
	mul $t0, $a2, $a3
	add $t0, $t0, $a1
	add $t0, $t0, $a0
	
	li $t1, 0
	
	lw $v0, 0($t0)
		
	jr $ra		
########################################################################



#Save pixel
########################################################################
# $a0 = source address
# $a1 = x
# $a2 = y
# $a3 = widht_lenght
# 0($sp) = value
# $v0 returns the value of the pixel
save_pixel:
	mul $t0, $a2, $a3
	add $t0, $t0, $a1
	add $t0, $t0, $a0
	
	lw $t1, 0($sp)	
	
	sw $t1, 0($t0)
		
	jr $ra		
########################################################################
