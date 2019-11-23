%include "includes/io.inc"

extern getAST
extern freeAST

section .data
	charP dd 0

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1
    left: resd 1
    right: resd 1
    op1: resd 1
    op2: resd 1
section .text
global main

main:
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    ; Implementati rezolvarea aici:

    mov ebx,[root]
	push ebx
	call eval
	PRINT_DEC 4,eax
	add esp,4

final_end:
	; NU MODIFICATI
	; Se elibereaza memoria alocata pentru arbore
	push dword [root]
	call freeAST

	xor eax, eax
	leave
	ret


eval:
	push ebp
	mov ebp,esp

	xor eax,eax 			; This part of the code is
	xor ecx,ecx 			; cleaning all the registers
	xor edx,edx 			; before doing any operation

	mov ebx,[ebp+8] 		; This part of the code is
	mov edx,[ebx] 			; getting the data out of the
	mov dword[charP],edx 	; structure
	mov ecx,[edx] 			;
	
	mov edx,[ebx+4] 		; This part of the code is
	mov dword[left],edx 	; getting the adreesses of the sons
	mov edx,[ebx+8] 		;
	mov dword[right],edx 	;

	test dword[left],0xff	; Test if is a number (has no sons)
	jz number				; or an operator (has sons)

	push dword[charP]		; This variables will be modified
	push dword[right]		; by the recursive calls

	push dword[left]		; This code does the left child
	call eval				; of the root and saves in op1
	mov [op1],eax			; the result and saves
	add esp,4				; it on the stack cause
	push dword[op1]			; the other call will change it

	mov eax,[esp+4]			; Get back the right
	mov dword[right],eax	; 
	push dword[right]		; Do the right child
	call eval				; 
	mov [op2],eax			; 
	add esp,4				;

	mov ecx,[esp+8]			; Get back the char
	mov edx,[ecx]			;
	mov ecx,edx				;

	mov eax,[esp]			; Get back the op1
	mov [op1],eax			;

	push dword[op2]			;
	push dword[op1]			;
	push ecx				; Do the Operation
	call operation			; The result is in EAX
	jmp last				;

number:
	push dword[charP]		; call the atoi function
	call atoi				; ATOI function
	add esp,4				;
last:
	leave
	ret

atoi:
	push ebp
	mov ebp,esp

	xor edx,edx

	mov ecx,[ebp+8]			; the char*
	
	xor eax,eax 			; Clear all
	xor edx,edx 			; the registers
	xor ebx,ebx 			; 
	xor edx,edx 			; 

string_loop:
	xor eax,eax 			; Get the char
	mov al,[ecx] 			;	

	cmp eax,0
	jz end_string
	cmp eax,'-'
	jz neg_case

	sub eax,'0'

	add ebx,eax

	push edx 				; Multiply the previsous result
	push ecx 				; with 10
	push 10 				; 
	push ebx 				; 
	call op_mul 			; 
	mov ecx,[esp+8] 		; 
	mov edx,[esp+12] 		; 
	add esp,16 				; 
	add ebx,eax 			; 
		
continue_loop:
	inc ecx
	jmp string_loop

neg_case:
	mov edx,1
	jmp continue_loop

end_string:

	push edx
	push 10
	push ebx
	call op_div
	mov edx,[esp+8]
	add esp,12

	cmp edx,0
	jz not_neg	
	neg eax

not_neg:
	
	leave
	ret


operation:					; The operation function
	push ebp
	mov ebp,esp

	mov eax,[ebp+8]
	mov ebx,[ebp+12]
	mov ecx,[ebp+16]

	cmp eax,'+'
	jnz skip_add
	push ecx
	push ebx
	call op_add
	add esp,8
	jmp skip_div
skip_add:

	cmp eax,'-'
	jnz skip_sub
	push ecx
	push ebx
	call op_sub
	add esp,8
	jmp skip_div
skip_sub:

	cmp eax,'*'
	jnz skip_mul
	push ecx
	push ebx
	call op_mul
	add esp,8
	jmp skip_div
skip_mul:

	cmp eax,'/'
	jnz skip_div
	push ecx
	push ebx
	call op_div
	add esp,8
skip_div:

	leave
	ret


op_add:
	push ebp
	mov ebp,esp

	mov eax,dword[ebp+8]
	mov ebx,dword[ebp+12]
	add eax,ebx
	leave
    ret

op_sub:
	push ebp
	mov ebp,esp

	mov eax,[ebp+8]
	sub eax,[ebp+12]

	leave
    ret

op_mul:					; mul operation
	push ebp
	mov ebp,esp

	mov eax,[ebp+8]
	mov ebx,[ebp+12]

	xor edx,edx

	test eax,eax 			;TEST IF EAX IS NEGATIVE
	jns unsigned_eax_mul

	mov edx,1

;	PRINT_DEC 4,eax
;	PRINT_STRING '->'

	dec eax 				; changing the eax

;	PRINT_DEC 4,eax
;	PRINT_STRING '->'

	not eax 				;

;	PRINT_DEC 4,eax
;	NEWLINE


unsigned_eax_mul:

	test ebx,ebx 			;TEST IF EBX IS NEGATIVE
	jns unsigned_ebx_mul

;	PRINT_DEC 4,ebx
;	PRINT_STRING '->'
	
	cmp edx,0
	je not_set_mul
	mov edx,0
	jmp edx_set_mul

not_set_mul:
	mov edx,1
edx_set_mul:

	dec ebx 				; changing the ebx
	not ebx 				; 

;	PRINT_DEC 4,ebx
;	NEWLINE

unsigned_ebx_mul:


	xor ecx,ecx

do_mul:						; Multiplication is done
	cmp ebx,0				; just by adding
	jz end_mul				; the first number with itseft
	dec ebx 				;
	add ecx,eax 			;
	jmp do_mul 				;
end_mul:					;

	mov eax,ecx
	cmp edx,0
	jz exit_mul
	neg eax
exit_mul:

	leave
    ret




op_div:						; div operation
	push ebp
	mov ebp,esp

	mov eax,[ebp+8]
	mov ebx,[ebp+12]

	xor edx,edx

	test eax,eax 			;TEST IF EAX IS NEGATIVE
	jns unsigned_eax_div

	mov edx,1
	dec eax 				; changing the eax
	not eax 				;

unsigned_eax_div:

	test ebx,ebx 			;TEST IF EBX IS NEGATIVE
	jns unsigned_ebx_div

	
	cmp edx,0
	je not_set_div
	mov edx,0
	jmp edx_set_div

not_set_div:
	mov edx,1
edx_set_div:

	dec ebx 				; changing the ebx
	not ebx 				; 

unsigned_ebx_div:

	xor ecx,ecx
do_div:						; The divisoin is done by
	cmp eax,ebx 			; substracting the divisor from 
	jl end_div 				; the divident until the 
	inc ecx 				; divident becomes equal with 
	sub eax,ebx 			; the quotient
	jmp do_div				; 
end_div:					; 

	mov eax,ecx
	cmp edx,0
	jz exit_div
	neg eax
exit_div:

	leave
    ret