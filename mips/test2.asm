	.data
prompt:	.asciiz	"Enter a string: "
lenmsg:	.asciiz	"\nString length is "

buf:	.space	80

	.text
	.globl	main
main:
	
	la		$a0, prompt
	li		$v0, 4			# print string
	syscall
	
	# input a string
	la		$a0, buf
	li		$a1, 80
	li		$v0, 8		# read string
	syscall
	
	la		$t0, buf
	move	$t1, $t0

nextchar:

	lbu		$t2, ($t0)
	bltu	$t2, ' ', finish		# end of string
	# check for lowercase letter
	bltu	$t2, 'a', nochange
	bgtu	$t2, 'z', nochange
	subiu	$t2, $t2, 0x20			# convert to uppercase
	sb		$t2, ($t0)

nochange:

	addiu	$t0, $t0, 1	# move the pointer
	b		nextchar
	
finish:
	# display the result string
	la		$a0, buf
	li		$v0, 4		# print string
	syscall
	
	la		$a0, lenmsg
	li		$v0, 4		# print string
	syscall
	
	# display string length
	subu	$a0, $t0, $t1
	li		$v0, 1	# print int
	syscall

	li		$v0, 10	# exit
	syscall
	
	