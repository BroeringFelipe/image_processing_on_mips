.eqv lenght_max 1048576 #1048576 = 512*512*4
			#4194304 = 1024*1024*4  Doesn't work

.eqv speed_animations 39

.eqv without_color	0x00ffffff

.eqv offset_base_2x	0x00390000

.eqv offset_base_4x	0x00003900

.eqv offset_base_8x	0x00000039

#.eqv offset_base_16x	0x00000040

.data
display_bitmap:	.space lenght_max
buff: 		.space lenght_max
buff_tmp:	.space lenght_max

bmp_lenght: 	.word	0

width_lenght: 	.word	0
height_lenght:	.word	0

width_offset: 	.word	0
height_offset:	.word	0

keyboard:	.word	0

filename: 	.asciiz "lena.bmp"



.text

jal interrupcao

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

li $s4, 0#x80000000
li $s5, 0#x80000000
li $s6, 0
li $s7, 0

	main_loop:
	lw $s7, keyboard
	
	beq $s7,  43, option_zoom_1	# Zoom +
	beq $s7,  45, option_zoom_0	# Zoom -
	
	beq $s7,  49, option_se 	# Seta para Esquerda
	beq $s7,  53, option_sc		# Seta para Cima
	beq $s7,  51, option_sd 	# Seta para Direita
	beq $s7,  50, option_sb 	# Seta para Baixo
	
	beq $s7, 101, option_split_1 	# Dividir e
	beq $s7, 102, option_split_2 	# Dividir f
	
	beq $s7, 103, option_bar_1 	# Barras g
	beq $s7, 104, option_bar_2 	# Barras h
	beq $s7, 119, option_bar_3 	# Barras w
	beq $s7, 120, option_bar_4 	# Barras x
	
	beq $s7,  97, option_float_1 	# Flutuar a
	beq $s7,  98, option_float_2 	# Flutuar b
	beq $s7, 121, option_float_3 	# Flutuar y
	beq $s7, 122, option_float_4 	# Flutuar z
	
	beq $s7, 105, option_fade_in 	# Fade in i
	beq $s7, 111, option_fade_out 	# Fade out o
	
	beq $s7, 118, option_flip_vert	# Flip horizontal v 
	beq $s7, 117, option_flip_hrzt	# Flip vertical u
	
	beq $s7, 116, option_rotate_color	# Rotacao de cores t
	beq $s7, 115, option_invert_color	# Iverter cores s
	beq $s7,  99, option_grey_scale		# Escala de cinza c
	beq $s7, 109, option_average_pixel	# Media dos pixels m
	
	beq $s7, 108, option_save_on_buff 	# Save the actually image on buffer
	
	beq $s7, 114, option_reset 	# Reset r
	
	beq $s7, 113, option_quit 	# Quit
	
	j main_loop
	
	option_zoom_1:	# Zoom +
		li $s7, 0
		sw $s7, keyboard
		
		addi $s6, $s6, 1
		
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)

		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal zoom
	
		j main_loop
	
	
	option_zoom_0:	# Zoom -
		li $s7, 0
		sw $s7, keyboard
		
		addi $s6, $s6, -1
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		
		bgtz $s6, zoom_0
		
		li $s4, 0
		li $s5, 0
		jal move_image
		j main_loop
		
		
		zoom_0:
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)
		jal zoom
		j main_loop
		
		
	option_se: 	# Seta para Esquerda
		li $s7, 0
		sw $s7, keyboard
		
		beq $s6, 1, offset_zoom_2x_se
		beq $s6, 2, offset_zoom_4x_se
		beq $s6, 3, offset_zoom_8x_se
		#beq $s6, 4, offset_zoom_16x_se
		
		offset_zoom_2x_se:
			subi $s4, $s4, offset_base_2x
			j continue_option_se
		offset_zoom_4x_se:
			subi $s4, $s4, offset_base_4x
			j continue_option_se
		offset_zoom_8x_se:
			subi $s4, $s4, offset_base_8x
			j continue_option_se
		#offset_zoom_16x_se:
			#subi $s4, $s4, offset_base_16x
			#j continue_option_se
		
		continue_option_se:
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal zoom
			
		j main_loop
		
		
	option_sc:	# Seta para Cima
		li $s7, 0
		sw $s7, keyboard
		
		beq $s6, 1, offset_zoom_2x_sc
		beq $s6, 2, offset_zoom_4x_sc
		beq $s6, 3, offset_zoom_8x_sc
		#beq $s6, 4, offset_zoom_16x_sc
		
		offset_zoom_2x_sc:
			subi $s5, $s5, offset_base_2x
			j continue_option_sc
		offset_zoom_4x_sc:
			subi $s5, $s5, offset_base_4x
			j continue_option_sc
		offset_zoom_8x_sc:
			subi $s5, $s5, offset_base_8x
			j continue_option_sc
		#offset_zoom_16x_sc:
			#subi $s5, $s5, offset_base_16x
			#j continue_option_sc
		
		continue_option_sc:
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal zoom
			
		j main_loop
	
	
	option_sd: 	# Seta para Direita
		li $s7, 0
		sw $s7, keyboard
			
		beq $s6, 1, offset_zoom_2x_sd
		beq $s6, 2, offset_zoom_4x_sd
		beq $s6, 3, offset_zoom_8x_sd
		#beq $s6, 4, offset_zoom_16x_sd
		
		offset_zoom_2x_sd:
			addi $s4, $s4, offset_base_2x
			j continue_option_sd
		offset_zoom_4x_sd:
			addi $s4, $s4, offset_base_4x
			j continue_option_sd
		offset_zoom_8x_sd:
			addi $s4, $s4, offset_base_8x
			j continue_option_sd
		#offset_zoom_16x_sd:
			#addi $s4, $s4, offset_base_16x
			#j continue_option_sd
		
		continue_option_sd:
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal zoom
		
		j main_loop
	
	
	option_sb: 	# Seta para Baixo
		li $s7, 0
		sw $s7, keyboard
			
		beq $s6, 1, offset_zoom_2x_sb
		beq $s6, 2, offset_zoom_4x_sb
		beq $s6, 3, offset_zoom_8x_sb
		#beq $s6, 4, offset_zoom_16x_sd
		
		offset_zoom_2x_sb:
			addi $s5, $s5, offset_base_2x
			j continue_option_sb
		offset_zoom_4x_sb:
			addi $s5, $s5, offset_base_4x
			j continue_option_sb
		offset_zoom_8x_sb:
			addi $s5, $s5, offset_base_8x
			j continue_option_sb
		#offset_zoom_16x_sb:
			#addi $s5, $s5, offset_base_16x
			#j continue_option_sb
		
		continue_option_sb:
		addi $sp, $sp, -12
		sw $s4, 0($sp)
		sw $s5, 4($sp)
		sw $s6, 8($sp)
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal zoom
		
		j main_loop
		
		
	option_split_1:	# Dividir e
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal split_1
		
		j main_loop
		
	option_split_2:	# Dividir f
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal split_2
		
		j main_loop
	
	option_bar_1: 	# Barras g
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal bar_1
		
		j main_loop
	
	option_bar_2: 	# Barras h
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal bar_2
		
		j main_loop
	
	option_bar_3: 	# Barras w
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal bar_3
		
		j main_loop
	
	option_bar_4: 	# Barras x
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal bar_4
		
		j main_loop
		
	option_float_1:	# Flutuar a
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal float_1
		
		j main_loop
	
	option_float_2:	# Flutuar b
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal float_2
		
		j main_loop
	
	option_float_3:	# Flutuar y
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal float_3
		
		j main_loop
	
	option_float_4:	# Flutuar z
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal float_4
	
		j main_loop
		
	option_fade_in: # Fade in i
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, buff
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal fade_in
	
		j main_loop
		
	option_fade_out:# Fade out o
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal fade_out
		
		j main_loop
	
	option_flip_vert:	# Flip horizontal v 
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal flip_vert
		
		j main_loop
	
	option_flip_hrzt:	# Flip vertical u
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal flip_hrzt
		
		j main_loop
	
	
	option_rotate_color:	# Rotacao de cores t
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal rotate_color
		
		j main_loop
	
	option_invert_color:	# Iverter cores s
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal invert_color
		
		j main_loop
	
	option_grey_scale:	# Escala de cinza c
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal grey_scale
		
		j main_loop
	
	option_average_pixel:	# Media dos pixels m
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, display_bitmap
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal average_pixel
		
		j main_loop
	
	option_save_on_buff:
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap
		la $a1, buff
		lw $a2, width_lenght
		lw $a3, height_lenght
		jal average_pixel
		
		j main_loop
	
	option_reset: 	# Reset r
		li $s7, 0
		sw $s7, keyboard
		
		la $a0, display_bitmap	#Pass the adress of display
		la $a1, buff		#Pass the adress for de buffer
		la $a2, bmp_lenght
		la $a3, filename
		jal read_archive
		
		j main_loop
	
		
	option_quit:
		li $s7, 0
		li $v0 10
		syscall




#Call functions
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght

li $t6, 32896
li $t7, 32896
li $t8, 1

la $t0, width_offset
la $t1, height_offset

sw $t6, width_offset
sw $t7, height_offset

lw $t6, width_offset
lw $t7, height_offset

addi $sp, $sp, -12
sw $t6, 0($sp)
sw $t7, 4($sp)
sw $t8, 8($sp)

la $a0, display_bitmap
la $a1, display_bitmap
lw $a2, width_lenght
lw $a3, height_lenght
jal zoom


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



# Fade out animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
fade_out:
	# Copy the source image to destination
	# If uncommented, the effect occurs on the source image
	#addi $sp, $sp, -4
	#sw $ra, 0($sp)
	#jal move_image
	#lw $ra, 0($sp)
	#addi $sp, $sp, 4

	move $t1, $a1
	
	mul $t2, $a2, $a3
	

	li $t3, 0
	li $t4, 47

	li $t9, 6
	li $t6, without_color
	
	loop_fade_out_1:
		loop_fade_out_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_fade_out
			sw   $t6, 0($t1)
			
			
			jump_fade_out:
			addi $t3, $t3, 1
			addi $t1, $t1, 4	
		
		blt $t3, $t2, loop_fade_out_2
		
		div $t4, $t4, 2
		move $t1, $a1
		li $t3, 0
		addi $t9, $t9, -1
		
	bgtz $t9, loop_fade_out_2
	
	jr $ra
########################################################################



# Fade in animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
fade_in:

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


	# Clear the destination
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################
	
	move $t1, $a1
	move $t0, $a0
	
	mul $t2, $a2, $a3
	
	li $t3, 0
	li $t4, 47
	li $t9, 6
	
	loop_fade_in_1:
		loop_fade_in_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_fade_in
			lw   $t8, 0($t0)
			sw   $t8, 0($t1)
			
			
			jump_fade_in:
			addi $t3, $t3, 1
			addi $t0, $t0, 4
			addi $t1, $t1, 4	
		
		blt $t3, $t2, loop_fade_in_2
		
		div $t4, $t4, 2
		
		move $t1, $a1
		move $t0, $a0
		
		li $t3, 0
		
		addi $t9, $t9, -1
		
	bgtz $t9, loop_fade_in_2
	
	jr $ra
########################################################################



# Float 1
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
float_1:
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


	# Clear the destination
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################
	
	mul $t2, $a2, $a3
	
	mul $t6, $a2, 2
	mul $t6, $t6, 4
	
	mul $t7, $t2, 4
	
	move $t0, $a0
	add $t1, $a1, $t7
	
	move $t7, $a2

	mul $t8, $a2, 4
	mul $t8, $a2, speed_animations
	
	loop_float_1_1:
		
		add $t7, $t7, $t8
		blt $t7, $t2, jump_lf_1
		move $t7, $t2
		
		
		
		jump_lf_1:
		li  $t3, 0

		mul $t6, $t7, 4
		
		sub $t1, $t1, $t6
		move $t0, $a0
	
		
	
		loop_float_1_2:
			lw $t4, 0($t0)
			sw $t4, 0($t1)
		
			addi $t3, $t3, 1
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			
			rem  $t5, $t3, $t7
			bnez $t5, loop_float_1_2
		
		#addi $sp, $sp, -4
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $ra, 0($sp)
		#addi $sp, $sp, 4
		
	blt $t7, $t2, loop_float_1_1
	
	jr $ra
########################################################################



# Float 3
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
float_3:
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


	# Clear the destination
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################
	
	mul $t2, $a2, $a3
	
	mul $t6, $a2, 2
	mul $t6, $t6, 4
	
	mul $t7, $t2, 4
	
	move $t1, $a1
	add $t0, $a0, $t7
	
	move $t7, $a2

	mul $t8, $a2, 4
	mul $t8, $a2, speed_animations
	
	loop_float_3_1:
		
		add $t7, $t7, $t8
		blt $t7, $t2, jump_lf_3
		move $t7, $t2
		
		
		
		jump_lf_3:
		li  $t3, 0

		mul $t6, $t7, 4
		
		sub $t0, $t0, $t6
		move $t1, $a1
	
		
	
		loop_float_3_2:
			lw $t4, 0($t0)
			sw $t4, 0($t1)
		
			addi $t3, $t3, 1
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			
			rem  $t5, $t3, $t7
			bnez $t5, loop_float_3_2
		
		#addi $sp, $sp, -4
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $ra, 0($sp)
		#addi $sp, $sp, 4
		
	blt $t7, $t2, loop_float_3_1
	
	jr $ra
########################################################################



# Float 2
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
float_2:
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
	
	mul $t2, $a2, $a3

	move $t0, $a0
	move $t1, $a1

	
	mul $t8, $a2, 4 # 4 is the lenght of a word
	mul $t8, $a2, speed_animations
	
	mul $t9, $t2, 4
	add $t9, $t9, $t1
	
	li $t7, 0
	li $t6, 0
	
	li $t3, without_color
	
	loop_float_2_1:
		
		add $t7, $t7, $t8
		
		blt $t7, $t2, jump_lf_2
			move $t7, $t2			
		jump_lf_2:
		
		add $t1, $a1, $t6
		
		mul $t6, $t7, 4
		add $t4, $t6, $a1 
		
		loop_clean_float_2:
			sw   $t3, 0($t1)
			addi $t1, $t1, 4
		blt $t1, $t4, loop_clean_float_2
		
		move $t0, $a0
	
		loop_float_2_2:
			lw $t4, 0($t0)
			sw $t4, 0($t1)
		
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			
			blt $t1, $t9, loop_float_2_2
			
		
		#addi $sp, $sp, -4
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $ra, 0($sp)
		#addi $sp, $sp, 4
		
	blt $t7, $t2, loop_float_2_1
	
	jr $ra
########################################################################



# Float 4
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
float_4:
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
	
	mul $t2, $a2, $a3

	move $t0, $a0
	move $t1, $a1

	
	mul $t8, $a2, 4 # 4 is the lenght of a word
	mul $t8, $a2, speed_animations
	
	mul $t9, $t2, 4
	add $t9, $t9, $t0
	
	li $t7, 0
	li $t6, 0
	
	li $t3, without_color
	
	loop_float_4_1:
		
		add $t7, $t7, $t8
		
		blt $t7, $t2, jump_lf_4
			move $t7, $t2			
		jump_lf_4:
		
		
		
		mul $t6, $t7, 4
		
		add $t0, $a0, $t6
		
		move $t1, $a1
	
		loop_float_4_2:
			lw $t4, 0($t0)
			sw $t4, 0($t1)
		
			addi $t0, $t0, 4
			addi $t1, $t1, 4
			
			blt $t0, $t9, loop_float_4_2
	
		add $t4, $t6, $t1
		
		loop_clean_float_4:
			sw   $t3, 0($t1)
			addi $t1, $t1, 4
		blt $t1, $t4, loop_clean_float_4
		
		#addi $sp, $sp, -4
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $ra, 0($sp)
		#addi $sp, $sp, 4
		
	blt $t7, $t2, loop_float_4_1
	
	jr $ra
########################################################################



# bar_1 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
bar_1:
	# Copy the source image to destination
	# If uncommented, the effect occurs on the source image
	#addi $sp, $sp, -4
	#sw $ra, 0($sp)
	#jal move_image
	#lw $ra, 0($sp)
	#addi $sp, $sp, 4

	move $t1, $a1
	
	mul $t2, $a2, $a3
	

	li $t3, 0
	li $t4, 16

	li $t9, 5
	li $t6, without_color
	
	loop_bar_1_1:
		loop_bar_1_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_bar_1
			sw   $t6, 0($t1)
			
			
			jump_bar_1:
			addi $t3, $t3, 1
			addi $t1, $t1, 4	
		
		blt $t3, $t2, loop_bar_1_2
		
		div $t4, $t4, 2
		move $t1, $a1
		li $t3, 0
		addi $t9, $t9, -1
		
	bgtz $t9, loop_bar_1_1
	
	jr $ra
########################################################################



# bar_2 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
bar_2:

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


	# Clear the destination
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################
	
	move $t1, $a1
	move $t0, $a0
	
	mul $t2, $a2, $a3
	
	li $t3, 0
	li $t4, 16
	li $t9, 5
	
	loop_bar_2_1:
		loop_bar_2_2:			
			rem  $t5, $t3, $t4
			bnez $t5, jump_bar_2
			lw   $t8, 0($t0)
			sw   $t8, 0($t1)
			
			
			jump_bar_2:
			addi $t3, $t3, 1
			addi $t0, $t0, 4
			addi $t1, $t1, 4	
		
		blt $t3, $t2, loop_bar_2_2
		
		div $t4, $t4, 2
		
		move $t1, $a1
		move $t0, $a0
		
		li $t3, 0
		
		addi $t9, $t9, -1
		
	bgtz $t9, loop_bar_2_1
	
	jr $ra
########################################################################



# bar_3 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
bar_3:
	# Copy the source image to destination
	# If uncommented, the effect occurs on the source image
	#addi $sp, $sp, -4
	#sw $ra, 0($sp)
	#jal move_image
	#lw $ra, 0($sp)
	#addi $sp, $sp, 4

	move $t1, $a1
	
	mul $t2, $a2, $a3
	mul $t4, $a2, 64
	
	mul $t8, $t2, 4
	add $t8, $t8, $a1
	
	li $t9, 5
	li $t6, without_color
	mul $t7, $a2, 4
	
	loop_bar_3_1:
		
	
		loop_bar_3_2:
			add $t1, $t1, $t4
			sub $t1, $t1, $t7
			li $t3, 0	
			
			bgt $t1, $t8, jump_loop_bar_3_2
			
			#Activate the delay for the animation to slow down 
			#addi $sp, $sp, -8
			#sw $t9, 4($sp)
			#sw $ra, 0($sp)
			#jal delay_1
			#lw $t9, 4($sp)
			#lw $ra, 0($sp)
			#addi $sp, $sp, 8
					
			loop_bar_3_3:
				sw   $t6, 0($t1)
				addi $t3, $t3, 1
				addi $t1, $t1, 4
			blt $t3, $a2, loop_bar_3_3
			j loop_bar_3_2

		
		jump_loop_bar_3_2:
		div $t4, $t4, 2
		move $t1, $a1	
	

	bge $t4, $t7, loop_bar_3_1
	
	jr $ra
########################################################################



# bar_4 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
bar_4:
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


	# Clear the destination
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################

	move $t1, $a1
	move $t0, $a0
	
	mul $t2, $a2, $a3
	mul $t4, $a2, 64
	
	mul $t8, $t2, 4
	add $t8, $t8, $a1
	
	mul $t7, $a2, 4
	
	loop_bar_4_1:
		loop_bar_4_2:
			add $t0, $t0, $t4
			add $t1, $t1, $t4
			sub $t0, $t0, $t7
			sub $t1, $t1, $t7
			
			li $t3, 0	
			
			bgt $t1, $t8, jump_loop_bar_4_2
			
			loop_bar_4_3:
				lw   $t6, 0($t0)
				sw   $t6, 0($t1)
				
				addi $t0, $t0, 4
				addi $t1, $t1, 4
				
				addi $t3, $t3, 1
			blt $t3, $a2, loop_bar_4_3
			j loop_bar_4_2

		
		jump_loop_bar_4_2:
		div $t4, $t4, 2
		move $t0, $a0
		move $t1, $a1	
	
	bge $t4, $t7, loop_bar_4_1
	
	jr $ra
########################################################################



# split_1 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
split_1:
	# Copy the source image to destination
	# If uncommented, the effect occurs on the source image
	#addi $sp, $sp, -4
	#sw $ra, 0($sp)
	#jal move_image
	#lw $ra, 0($sp)
	#addi $sp, $sp, 4

	move $t1, $a1
	
	mul $t2, $a2, $a3
	

	li  $t3, 4	#word_length
	mul $t4, $a2, 4
	sub $t5, $t4, $t3

	mul  $t9, $t3, 2
	addi $t9, $t9, -4

	mul $t8, $t2, 4
	add $t8, $t8, $t1
	
	li $t6, without_color
	
	loop_split_1_1:
		loop_split_1_2:	
			
			sw   $t6, 0($t1)
			add  $t1, $t1, $t5
			sw   $t6, 0($t1)
			add  $t1, $t1, $t9	
		
		blt $t1, $t8, loop_split_1_2
		
		move $t1, $a1
		add  $t1, $t1, $t3
			
		addi $t3, $t3, 4
		addi $t5, $t5, -8
		
		mul  $t9, $t3, 2
		subi $t9, $t9, 4		
		
		#Activate the delay for the animation to slow down 
		#addi $sp, $sp, -8
		#sw $t9, 4($sp)
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $t9, 4($sp)
		#lw $ra, 0($sp)
		#addi $sp, $sp, 8
		
		
	bgtz $t5, loop_split_1_1
	
	jr $ra
########################################################################



# split_2 animation
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
split_2:
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


	# Clear the destination 
	# If uncommented, the screen is cleaned before the effect
	#addi $sp, $sp, -8
	#sw $a0, 4($sp)
	#sw $ra, 0($sp)
	#move $a0, $a1
	#jal clear_screen
	#lw $a0, 4($sp)
	#lw $ra, 0($sp)
	#addi $sp, $sp, 8
	##############################
	
	move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	

	li  $t3, 4	#word_length
	mul $t4, $a2, 4
	sub $t5, $t4, $t3

	mul  $t9, $t3, 2
	addi $t9, $t9, -4

	mul $t8, $t2, 4
	add $t8, $t8, $t1
	
	#li $t6, without_color
	
	loop_split_2_1:
		loop_split_2_2:	
			lw   $t6, 0($t0)
			sw   $t6, 0($t1)
			
			add  $t0, $t0, $t5
			add  $t1, $t1, $t5
			
			lw   $t6, 0($t0)
			sw   $t6, 0($t1)
			
			add  $t0, $t0, $t9
			add  $t1, $t1, $t9	
		
		blt $t1, $t8, loop_split_2_2
		
		move $t0, $a0
		move $t1, $a1
		
		add  $t0, $t0, $t3
		add  $t1, $t1, $t3
			
		addi $t3, $t3, 4
		addi $t5, $t5, -8
		
		mul  $t9, $t3, 2
		subi $t9, $t9, 4		
		
		#Activate the delay for the animation to slow down 
		#addi $sp, $sp, -8
		#sw $t9, 4($sp)
		#sw $ra, 0($sp)
		#jal delay_1
		#lw $t9, 4($sp)
		#lw $ra, 0($sp)
		#addi $sp, $sp, 8
		
		
	bgtz $t5, loop_split_2_1
	
	jr $ra
########################################################################



# zoom
########################################################################
# $a0 = source address
# $a1 = destination address
# $a2 = width_lenght
# $a3 = height_lenght
# 8($sp) = n zoom
# 4($sp) = width_offset
# 0($sp) = height_offset
zoom:
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
	la   $a0, buff_tmp	#Update the source address to buff_tmp
	
	lw $t6, 0($sp)
	lw $t7, 4($sp)
	lw $t8, 8($sp)
	addi $sp, $sp, 12
	
	
	# Save all $sx registers
	addi $sp, $sp, -32
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s4, 16($sp)
	sw $s5, 20($sp)
	sw $s6, 24($sp)
	sw $s7, 28($sp)
	########################
	
	
	move $s0, $t8
	move $s1, $t7
	move $s2, $t6
	
	div  $s3, $a2, 2
	div  $s4, $a3, 2
	
	li $s5, 0
	
	loop_zoom_1:
	
	move $t0, $a0
	move $t1, $a1
	
	mul $t2, $a2, $a3
	
	addi $s5, $s5, 1
	beq $s5, 1, offset_zoom_2x
	beq $s5, 2, offset_zoom_4x
	beq $s5, 3, offset_zoom_8x
	#beq $s5, 4, offset_zoom_16x
	
	offset_zoom_2x:
		srl $t6, $s2, 16
		srl $t7, $s1, 16
		andi $t6, $t6, 0x000000ff
		andi $t7, $t7, 0x000000ff
		j continue_zoom
	
	offset_zoom_4x:
		srl  $t6, $s2, 8
		srl  $t7, $s1, 8
		andi $t6, $t6, 0x000000ff
		andi $t7, $t7, 0x000000ff
		j continue_zoom
	
	offset_zoom_8x:
		srl  $t6, $s2, 0
		srl  $t7, $s1, 0
		andi $t6, $t6, 0x000000ff
		andi $t7, $t7, 0x000000ff
		j continue_zoom
		
	#offset_zoom_16x:
		#srl  $t6, $s2, 0
		#srl  $t7, $s1, 0
	#	andi $t6, $t6, 0x000000ff
	#	andi $t7, $t7, 0x000000ff
	#	j continue_zoom
	
	
	continue_zoom:
	
	#rem $t6, $s2, $s3
	rem $t6, $t6, $s3
	mul $t6, $t6, 4
	add $t0, $t0, $t6
	
	#rem $t7, $s1, $s4
	rem $t7, $t7, $s4
	mul $t7, $t7, $a3
	mul $t7, $t7, 4
	add $t0, $t0, $t7
	
	li  $t3, 0
	
	mul $t8, $t2, 4
	add $t8, $t8, $t1

		
		loop_zoom_2:
		
			lw $t9, 0($t0)
			sw $t9, 0($t1)
			sw $t9, 4($t1)
			sw $t9, 2048($t1)
			sw $t9, 2052($t1)
		
			addi $t0, $t0, 4
			addi $t1, $t1, 8
			addi $t3, $t3, 1
		
			div  $t4, $a2, 2
			rem  $t4, $t3, $t4
			bnez $t4, loop_zoom_2
		
			mul $t4, $a2, 2
			add $t0, $t0, $t4
		
			addi $t1, $t1, 2048
				
		blt $t1, $t8, loop_zoom_2
		
		
		
		addi $s0, $s0,  -1  ########
		#div  $s2, $s2, $s3  ########
		#div  $s1, $s1, $s4  ########
		
		# Copy the source image to buffer to be processed
		addi $sp, $sp, -12
		sw   $a0, 8($sp)
		sw   $a1, 4($sp)
		sw   $ra, 0($sp)
		
		move $a0, $a1
		la   $a1, buff_tmp
		jal  move_image
		
		lw   $a0, 8($sp)
		lw   $a1, 4($sp)
		lw   $ra, 0($sp)
		addi $sp, $sp, 12
		##############################
		la   $a0, buff_tmp####	#Update the source address to buff_tmp
		
	bgtz $s0, loop_zoom_1
	
	# Load all saved $sx registers
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $s6, 24($sp)
	lw $s7, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra
########################################################################



# Move image
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



# Clear Screen
########################################################################
# $a0 = Screen to clear
# $a2 = width_lenght
# $a3 = height_lenght
clear_screen:
	mul $t0, $a2, $a3
	li $t1, 0
	
	move $t2, $a0
	li $t4, without_color
	
	loop_clear_screen:
		sw $t4, 0($t2)
		
		addi $t2, $t2, 4
		
		addi $t1, $t1, 1
		
		blt $t1, $t0, loop_clear_screen
	
	jr $ra		
########################################################################



# Get pixel
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



# Save pixel
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



# Delay
########################################################################
delay_1:
    li      $t9, 10000
    
    loop_delay_1:
    	addi    $t9, $t9, -1
    	bgez    $t9, loop_delay_1    

    jr      $ra
########################################################################



# Interrupcao
########################################################################
interrupcao:

	mfc0	$t0, $12		# Le o Status de interrupcao
	andi	$t0, $t0, 0xFFFE	# Remove ultimo bit
	mtc0    $t0, $12		# Desabilita as interrupcoes	
	
	lui     $t0,0xffff		# Carrega endereco do controle do teclado
	lw	$t1,0($t0)	        # Le informacao do controle
	ori	$t1,$t1,0x0002		# Adiciona bit para habilitar interrupcoes pelo teclado
	sw	$t1,0($t0)	        # Habilita interrupcoes do teclado
	
	mfc0	$t0, $12		# Le Status de interrupcao
	ori	$t0, $t0, 0x0001	# Adiciona bit de interrupcao
	mtc0    $t0, $12		# Habilita interrupcoes
	
	jr	$ra
########################################################################



.ktext 0x80000180
interrupt:
	addiu	$sp,$sp,-48
	sw	$at,44($sp)
	sw	$ra,40($sp)
	sw	$a1,36($sp)
	sw	$a0,32($sp)
	sw	$v0,28($sp)
	sw	$s0,24($sp)
	sw	$t5,20($sp)
	sw	$t4,16($sp)
	sw	$t3,12($sp)
	sw	$t2,8($sp)
	sw	$t1,4($sp)
	sw	$t0,0($sp)	
	
	# Leitura do caracter no endereco de memoria reservado para o teclado
	lui     $t0,0xffff		# get address of control regs
	lw	$t1,0($t0)	        # read rcv ctrl
	andi	$t1,$t1,0x0001		# extract ready bit
	beq	$t1,$0,intDone		#

	lw	$t5,4($t0)
	sw	$t5,keyboard
	
	# Tratamente do proximo endereco para retorno
	mfc0  $k0, $14  		# $k0 = EPC 
	addiu  $k0, $k0, 4  		# Increment $k0 by 4 
	mtc0  $k0, $14  		# EPC = point to next instruction 
	
intDone:
	# Clear Cause register
	mfc0	$t0,$13				# get Cause register, then clear it
	mtc0	$0, $13

	## restore registers
	lw	$t0,0($sp)
	lw	$t1,4($sp)
	lw	$t2,8($sp) 
	lw	$t3,12($sp) 
	lw	$t4,16($sp)
	lw	$t5,20($sp)
	lw	$s0,24($sp) 
	lw	$v0,28($sp)
	lw	$a0,32($sp)
	lw 	$a1,36($sp) 
	lw 	$ra,40($sp) 
	lw 	$at,44($sp) 
	addiu	$sp,$sp,48
	eret	
