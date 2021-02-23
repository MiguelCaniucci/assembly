			.data
buf:			.space 512 # space for file contents
directives:		.space 256 # space for names of directives
numbers:		.space 256 # space for numbers of occurence
path:			.space 128 # space for file path
enter_msg:		.asciiz "Enter file path:\n"
syscall_msg:		.asciiz "\nNumber of syscalls: "
error_msg:		.asciiz "################\nWrong file path\n"
reset_msg:		.asciiz "\nPress:\n1 - to select new file path\n0 - to terminate the program\n"
directives_msg1:  	.asciiz "\n###STATISTICS###\n"
directives_msg2: 	.asciiz "################\n"
	
	.text
	.globl main

	# DEFINED CONSTANTS
	.eqv SYS_PRINT_INT        1
	.eqv SYS_PRINT_STRING     4
	.eqv SYS_READ_INT         5
	.eqv SYS_READ_STRING      8
	.eqv SYS_EXIT             10
	.eqv SYS_PRINT_CHAR       11
	.eqv SYS_READ_CHAR        12
	.eqv SYS_OPEN_FILE	  13
	.eqv SYS_READ_FILE        14
	.eqv SYS_WRITE_FILE       15
	.eqv SYS_CLOSE_FILE       16

# USE OF REGISTERS
# $s0 - points at file path
# $s1 - points at buffor array
# $s2 - directives end address
# $t0 - points at buffor array
# $t1 - points at directives array
# $t2 - beginning of directives array
# $t3 - points at the end of last directive
# $t4 - checking if end 
# $t5 - used to iterate in directives and numbers
# $t6 - used to iterate in directives
# $t7 - numbers array pointer
# $t8 - directives array pointer used for checking repetitions
# $t9 - number of apperances couter

main:
	
	li	$v0, SYS_PRINT_STRING	# Print enter_msg
	la	$a0, enter_msg		
	syscall
	
	li	$v0, SYS_READ_STRING	# read file path
	la	$a0, path		# store file path
	li	$a1, 512		# space for file
	syscall
	
	li	$t0, 0				
	move 	$t0, $a0		# put path in $t0
	
deleteNewLine:				
	# Delete \n at the end of the path 
	li	$t1, 0
	lbu	$t1, ($t0)				# load byte
	addiu	$t0, $t0, 1				# incrementation
	bne	$t1, '\n', deleteNewLine		# if not \n go to the next byte
	subiu	$t0, $t0, 1				# back 1 byte
	sb	$zero, ($t0)				# change \n into zero

openFile:
	# open file
	li 	$v0, SYS_OPEN_FILE	# open file
	la	$a0, path		# load file from
	li	$a1, 0			# 0 flag 
	li 	$a2, 0			# 0 mode
	syscall	
	# move data
	li	$t2, 0
	li	$t3, 0
	li	$s0, 0
	move 	$s0, $v0		# copy path adress to $s0
	blt	$v0, 0, error		# handle wrong path 
	la	$t2, directives		# $t2 - points to the begining of directives array	
	move	$t3, $t2		# $t3 - points to adress after last directive
	li	$t0, 0			# $t0 - 0
	li	$s1, 0

	
readFile:	
	# read file
	li 	$v0, SYS_READ_FILE	# read file
	move	$a0, $s0		# take file path to $a0
	la	$a1, buf		# input buffer
	li 	$a2, 512		# set max number of char as 512
	syscall
	
	beqz	$v0, closeFile		# if empty file, finish program
	
	la	$t0, buf		# $t0 - buf beginning adress
	move	$s1, $v0		# $s1 - file content
	addu	$s1, $s1, $t0		# $s1 - adress after last element in buf

	j	beforeDirective
	
inDirective:
	# directive has been found
	beq	$t0, $s1, readFile			# if end -> readFile
	sb	$t1, ($t2)				# store byte from directives array
	addiu	$t2, $t2, 1				# next byte in directives array

	lbu	$t1, ($t0)				# load byte from buffor
	beq 	$t1, '#', beforeCheckingRepetition	# check if not a comment
	ble	$t1, ' ', beforeCheckingRepetition	# check if sign <= ' ', if so check if new directive
	addiu	$t0, $t0, 1				# next byte in buf
	bne	$t1, ':', inDirective			# check if not label and delete if so (overwrite)
	move	$t2, $t3				# adress after last directive
		
beforeDirective:
	# before finding a directive
	beq	$t0, $s1, readFile		# check if not end of file
	
	lbu	$t1, ($t0) 			# load byte from buffor
	addiu	$t0, $t0, 1			# iterate 
	beq	$t1, ':', beforeDirective	# check if not colon, skip if so
	ble	$t1, ' ', beforeDirective	# check if not a sign, skip if so
	bne	$t1, '#', inDirective		# check if not a comment, look for directive if not

nextLine:
	# skip to the next line in buf
	beq	$t0, $s1, readFile			# check if not the end of file
	
	lbu	$t1, ($t0)			# load byte from buffor
	addiu	$t0, $t0, 1			# iterate
	beq	$t1, '\n', beforeDirective	# check if nextline, if so look for directive
	j	nextLine
		
beforeCheckingRepetition:
	# setting registers before checking if directive is not being repeated
	la	$t6, directives		# directives array beginning adress
	move	$t5, $t3		# buf beginning adress
	move 	$s2, $t2		# directives end adress
	li	$t1, '\n'		# $t1 = nextline to store new directive in new line
	sb	$t1, ($t2)		# store byte at the end of directives
	li	$t7, 0			# used to iterate

checkRepetition:
	# checking if directive not repeated
	lbu	$t8, ($t5)		# $t8 - points at the current directive
	lbu	$t9, ($t6)		# $t9 - points at the beginning of directives array
	bne	$t8, $t9, moveForward	# if bytes not equal (not repeated) move forward to the next directive
	beq 	$t6, $s2, notExist	# if searched the whole array add new directive
	beq	$t8, '\n', addNum	# if nextline in buf add repetition
	addiu	$t5, $t5, 1		# iterate
	addiu	$t6, $t6, 1		# iterate
	j	checkRepetition		
	
moveForward:
	# move to the next index
	addiu 	$t7, $t7, 4		# iterate to another number
	move	$t5, $t3		# set $t5 at the beginning of new directive
	
moveToNextDirective:
	# move to the next directive
	lbu	$t9, ($t6)			# $t9 - points at the current directive
	addiu	$t6, $t6, 1			# increment
	bgt	$t9, ' ', moveToNextDirective	# if blank space go forward looking for directive
	j	checkRepetition			
	
notExist:
	# find a place for new directive
	sb	$t1, ($t2)			# store byte at $t2
	li	$t9, 1				# set counter to 1
	sb	$t9, numbers($t7)		# store number of apperances in numbers array 
	addiu	$t2, $t2, 1			# increment 
	move	$t3, $t2			# move adress after last directive
	j	nextLine

addNum:
	# add 1 to existing or new apperance
	lbu	$t9, numbers($t7)		# load number
	addiu	$t9, $t9, 1			# increment counter
	sb	$t9, numbers($t7)		# store number of apperances in numbers array
	move	$t2, $t3			# move address after last directive
	j	nextLine

closeFile:
	# close file before terminating the program
	li	$v0, SYS_CLOSE_FILE		# close file
	move	$a0, $s0
	syscall

beforePrint:
	# set values before printing
	li	$t5, 0				# set $t5 = 0 to iterate numbers
	la	$s1, directives			# set $s1 to the bef
	
	li	$v0, SYS_PRINT_STRING		
	la	$a0, directives_msg1	
	syscall

printNames:
	# print names of directives
	beq	$s1, $t2, exit			# if end of string directives array exit program
	li	$v0, SYS_PRINT_CHAR		# print char
	lbu	$a0, ($s1)			# load char 
	addiu	$s1, $s1, 1			# increment
	ble	$a0, ' ', printNumbers		# if end on directive name print its numbe of apperances
	syscall
	j printNames
	
printNumbers:
	# print numbers of apperences
	li	$v0, SYS_PRINT_CHAR		# print equal sign
	li	$a0, '='
	syscall
	li	$v0, SYS_PRINT_INT		# print number of occurances
	lbu	$a0, numbers($t5)		# load number 
	syscall
	li	$v0, SYS_PRINT_CHAR		# print nextline
	li	$a0, '\n'
	syscall
	addiu	$t5, $t5, 4			# increment to next number
	j	printNames			
	
error:
	# print error message
	li	$v0, SYS_PRINT_STRING		
	la	$a0, error_msg
	syscall
	
exit:
	# exit program
	li	$v0, SYS_PRINT_STRING
	la	$a0, directives_msg2
	syscall
	
	li	$v0, SYS_PRINT_STRING	# print reset message
	la	$a0, reset_msg
	syscall
	
	li	$v0, SYS_READ_INT	# read decision int 
	syscall
	
	move	$t0, $v0		
	beq	$t0, 1, main		# if int = 1, go to the beginning
	
	li	$v0, SYS_EXIT		# exit execution
	syscall

