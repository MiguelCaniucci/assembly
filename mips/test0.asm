	.data
prompt:	.asciiz	"Enter a string: "
resmsg:	.asciiz "\nResult string is: "
lenmsg:	.asciiz	"\nString length is: "

buf:	.space	80

	.text
	.globl	main
main:
	la		$a0, prompt
	li		$v0, 4		# print string
	syscall
	
	# input a string
	la		$a0, buf
	li		$a1, 80
	li		$v0, 8	# read string
	syscall
	
	la		$t0, buf
	move	$t1, $t0

nextchar:
	lbu		$t2, ($t0)
	beq		$t2, '\0', finish	# end of string
	# check for space
	beq		$t2, ' ', skipwrite
	sb		$t2, ($t1)
	addiu	$t1, $t1, 1 		# move the write pointer
skipwrite:
	addiu	$t0, $t0, 1			# move the read pointer
	b		nextchar
	
finish:

	la		$a0, resmsg
	li		$v0, 4	# print string
	syscall

	# display the result string
	la		$a0, buf
	li		$v0, 4	# print string
	syscall
	
	la		$a0, lenmsg
	li		$v0, 4	# print string
	syscall
	
	# display string length
	la 		$t0, buf
	subu	$a0, $t1, $t0
	li		$v0, 1	# print int
	syscall

	li		$v0, 10	# exit
	syscall
	
