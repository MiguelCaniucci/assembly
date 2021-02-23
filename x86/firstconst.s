; ECOAR 20L 
; x86 Project 18
; Michał Kaniuk 295815

	section .text
	global firstconst
	
firstconst:

; ####### PROLOGUE ######

	push	ebp		; save caller's frame pointer
	mov	ebp, esp	; set own frame pointer
	push	ebx		; save "saved" registers that are being used
	push	esi
	
; ######## BODY #######

	mov	eax, [ebp+8]	; agument - pointer to string
	
; ##### Find digits ######

find_first_digit:
	mov	dl, [eax]	; read char from string
	test	dl, dl		; check if byte == 0 
	jz	number_not_found	; if == 0 -> no int found
	
	inc 	eax		; increment pointer

; Check if digit (if > '9' or < '0' check next char)
	cmp	dl, '9'	
	ja	find_first_digit	
	cmp	dl, '0'
	jb	find_first_digit
	
first_digit:
	mov	ebx, eax	; set pointer
	dec	eax		; decrement to point on the digit
	
find_last_digit:
	mov	dl, [ebx]	; store char
	inc	ebx		; increment
	
	cmp	dl, '9'	; if > '9' check suffix
	ja	check_suffix	
	cmp	dl, '0'	; if >= '0' look for last digit
	jae	find_last_digit
	
; ###### Check suffix #####

check_suffix:		
	dec	ebx		; decrement pointer (points on the last digit)
	mov	dh, dl		; dh -> suffix
				
; Hexadecimal
	cmp	dh, 'h'	; if suffix == h its hexadecimal
	je	start_convert_hex
	
; If not hex check other suffixes
	cmp	dh, 'f'	
	ja	check_if_octal

; Hex digit
	cmp	dh, 'a'	; if >= a its part of the number in hex
	jae	continue_finding_const	
	
; Hex uppercase digit 
	cmp	dh, 'F'	; if > F or < A check if octal
	ja	check_if_octal	; otherwise its part of hex
	cmp 	dh, 'A'	
	jb	check_if_octal

continue_finding_const:
	mov	ecx, ebx	
	inc	ecx		; increment
	
find_next_hex_digit:
	mov	dl, [ecx]	; store char
	inc	ecx
	
	test 	dl, dl		; if end of string check other suffixes 
	jz	check_if_octal
	cmp	dl, 'f'	; if > f check hex
	ja	check_if_hex
	cmp	dl, 'a'	; if >= a find next hex digit
	jae	find_next_hex_digit

	cmp	dl, 'F'	; if > F check octal
	ja	check_if_octal
	cmp	dl, 'A'	; if >= A find next hex digit
	jae	find_next_hex_digit
	
	cmp	dl, '9'	; if > 9 check octal
	ja	check_if_octal
	cmp	dl, '0'	; if >= 0 find next hex digit
	jae	find_next_hex_digit
	
check_if_hex:
	cmp	dl, 'h'	; if == h its hexadecimal
	je	set_hex	

check_if_octal:
	cmp	dh, 'q'	; if == q or == o its octal
	je	set_octal
	cmp	dh, 'o'
	je	set_octal
	
; Check if binary
	cmp	dh, 'b'	; if == b its binary
	je	set_binary
	
; no suffix, convert to decimal
	jmp	set_decimal
	
; ###### Convert string to integer ######

set_hex:
	dec	ecx		; decrement pointer
	mov	ebx, ecx	; ebx -> end adress

start_convert_hex:		; prepare registers
	mov	ecx, eax	; ecx -> beginning
	xor	eax, eax
	xor	edx, edx

convert_hex:
	mov	dl, [ecx]	; store char

; Check if a character
	cmp	dl, '9'	
	ja	uppercase_char
	
; Digit -> convert to int 
	sub	dl, '0'	
	jmp	continue_hex_convertion

uppercase_char:		; if upper character convert to integer
	cmp	dl, 'F'
	ja	lowercase_char
	sub	dl, 'A'	
	add 	dl, 10
	jmp	continue_hex_convertion

lowercase_char:		; if lower character convert to integer
	sub	dl, 'a'
	add	dl, 10
	
continue_hex_convertion:
	add	eax, edx	; add to the number 
	inc	ecx		
	
	cmp	ebx, ecx	; if end of number finish
	je	epilogue
	
	shl	eax, 4		; eax*16
	jmp	convert_hex
	
set_octal:
	mov	ecx, eax	; store beginning in ecx 
	mov	esi, eax	; esi used to restart if necessary 
	xor	eax, eax	
	xor	edx, edx
	
convert_oct:
	mov	dl, [ecx]	; store char
	cmp	dl, '7'	; if > 7 restart, because its not octal
	ja	reset_conversion	
	
	sub	dl, '0'	; convert into integer
	add	eax, edx	; add to the number
	
	inc	ecx			
	cmp	ebx, ecx	; if end of number finish 
	je	epilogue			
	
	shl	eax, 3		; eax*8
	jmp	convert_oct	; continue 	

set_binary:
	mov	ecx, eax	; store beginning in ecx 
	mov	esi, eax	; esi used to restart if necessary
	xor	eax, eax
	xor	edx, edx
	
convert_bin:
	mov	dl, [ecx]	; store char
	cmp	dl, '1'	; if digit not 0 or 1 restart, because its not binary 	
	ja	reset_conversion	
	
	sub	dl, '0'	; convert to integer
	add	eax, edx	; add to the number 
	
	inc	ecx			
	cmp	ebx, ecx	; if end of number finish
	je	epilogue				
	
	shl	eax, 1		; eax*2
	jmp	convert_bin	

reset_conversion:
	mov	eax, esi	; beginning of the number in eax 

set_decimal:
	mov	ecx, eax	; set pointer
	mov	esi, 10	; store 10 
	xor	eax, eax
	xor	edx, edx
	
convert_dec:
	mov	dl, [ecx]	; store char
	sub	dl, '0'	; convert from string to int
	add	eax, edx	; add to the number 
	
	inc	ecx
	cmp	ebx, ecx	; if end of number finish
	je	epilogue
	
	mul	esi		; eax*10
	jmp	convert_dec		
	
number_not_found:
	mov	eax, 0		; return 0 
	
; ####### EPILOGUE #######

epilogue:
	pop	esi		; restore saved registers
	pop	ebx		
	pop	ebp		; restore caller's frame pointer
	ret			; return to caller
		
		
