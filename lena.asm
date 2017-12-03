.data
display_bitmap:	.space 1000000
buff: .space 800000
filename: .asciiz "/home/fbroering/Dropbox/2017-2/MCP/lena/lena"

.text
#abre arquivo
la $a0, filename	# endere�o da string com o nome do arquivo
li $v0, 13		# parametro p chamada de abertura
li $a1, 0		# flags (0=read, 1=write)
li $a2, 0		# mode = desnecess�rio
syscall			# devolve o descritor (ponteiro) do arquivo em $v0

move $a0, $v0		# mode o descritor para $a0
li $v0, 14		# parametro de chamada de leitura de arquivo
la $a1, buff		# endere�o para armazenamento dos dados lidos
li $a2, 800000		# tamanho m�x de caracteres
syscall			# devolve o n�mero de caracteres lidos

move $t0, $v0		
la $t1, buff		# carrega endere�o do buffer novamente
add $t0, $t0, $t1	# aponta para o endere�o do ultimo caracter lido + 1
sb $zero, 0($t0)	# grava 0 (zero - caracter nulo)

move $a0, $t1		
li $v0, 4
syscall			# imprime caracteres lidos na 

# Close the file 
li   $v0, 16       	# system call for close file
move $a0, $s6      	# file descriptor to close
syscall            	# close file

#Save all temp registers before the call funcion
addi $sp, $sp, -56
sw $v0, 52($sp)
sw $v1, 48($sp)
sw $a0, 44($sp)
sw $a1, 40($sp)
sw $a2, 36($sp)
sw $a3, 32($sp)
sw $t0, 28($sp)
sw $t1, 24($sp)
sw $t2, 20($sp)
sw $t3, 16($sp)
sw $t4, 12($sp)
sw $t5,  8($sp)
sw $t6,  4($sp)
sw $t7,  0($sp)

#Call funcion print_bmp
la $a0, display_bitmap	#Pass the adress of display
la $a1, buff	#Pass the adress for de buffer
jal print_bmp

#Load all temp registers before the call funcion
lw $v0, 52($sp)
lw $v1, 48($sp)
lw $a0, 44($sp)
lw $a1, 40($sp)
lw $a2, 36($sp)
lw $a3, 32($sp)
lw $t0, 28($sp)
lw $t1, 24($sp)
lw $t2, 20($sp)
lw $t3, 16($sp)
lw $t4, 12($sp)
lw $t5,  8($sp)
lw $t6,  4($sp)
lw $t7,  0($sp)
addi $sp, $sp, 56

li $v0, 16
syscall

print_bmp:
	#Save all saved registers ($s0 to $s7)
	addi $sp, $sp, -32
	sw $s0, 28($sp)
	sw $s1, 24($sp)
	sw $s2, 20($sp)
	sw $s3, 16($sp)
	sw $s4, 12($sp)
	sw $s5,  8($sp)
	sw $s6,  4($sp)
	sw $s7,  0($sp)
	
	
	#Read the length of archive.bmp
	la   $t0, buff
	lw   $s0, 0($t0)
	srl  $s0, $s0, 16

	lw   $t1, 4($t0)
	sll  $t1, $t1, 16

	add  $s0, $s0, $t1	#$s0 contains the length of buff
			
	move $t0, $a1		#Move the initial adress of buff to $t0
	addi $t0, $t0, 54	#Skip the header
	
	li $t1, 0		#Control variable
	addi $t1, $t1, 54	#Skip the header
	
	move $t2, $a0		#Move the initial adress of display to $t2
	
	print_to_disp_loop:
		sb $zero, 0($t2)
		
		lbu $s1, 0($t0)
		sb  $s1, 1($t2)
		
		lbu $s1, 1($t0)
		sb  $s1, 2($t2)
		
		lbu $s1, 2($t0)
		sb  $s1, 3($t2)
		
		addi $t2, $t2, 4
		addi $t0, $t0, 3
		addi $t1, $t1, 3
		
		blt $t1, $s0, print_to_disp_loop
	
	
	#Load all saved registers ($s0 to $s7)
	lw $s0, 28($sp)
	lw $s1, 24($sp)
	lw $s2, 20($sp)
	lw $s3, 16($sp)
	lw $s4, 12($sp)
	lw $s5,  8($sp)
	lw $s6,  4($sp)
	lw $s7,  0($sp)
	addi $sp, $sp, 32
	
	jr $ra
	

