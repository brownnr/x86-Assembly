TITLE Fibonacci Numbers     (prog2.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #2
; Assignment Due Date:	1/24/2016
; Description:  		Calculate Fibonacci numbers for the number
;				of terms given by user.


INCLUDE Irvine32.inc

U_LIMIT		EQU		40
DISPLAY_S	EQU		call WriteString
READ_S		EQU		call ReadString
DISPLAY_D	EQU		call WriteDec
READ_I		EQU		call ReadDec
LINE		EQU		call CrLf

.data
	intro			BYTE	"	Fibonacci Numbers	by Nicholas Brown", 0
	ec_1			BYTE	"**EC: Display numbers in aligned columns.", 0
	name_prompt		BYTE	"Please enter your name....  ", 0
	user_name		BYTE	50 DUP(0)
	greeting		BYTE	"Hello ", 0
	number_prompt	BYTE	", enter the number ", 0ah
					BYTE	" of Fibonacci terms(1-40): ", 0
	fib_num			DWORD	?		;get user's selection
	oldFib_num		DWORD	0		;use to hold old calculated Fib number
	try_again		BYTE	"Your number must be between 1 and 40, ", 0ah
					BYTE	" please try again: ", 0
	good_bye		BYTE	"Good bye ", 0


.code
main PROC
;introduction
	mov edx, OFFSET intro
	DISPLAY_S
	LINE
	mov edx, OFFSET ec_1
	DISPLAY_S
	LINE
	LINE
	mov edx, OFFSET name_prompt
	DISPLAY_S
	mov edx, OFFSET user_name
	mov ecx, 49
	READ_S

;userInstructions
	mov edx, OFFSET greeting
	DISPLAY_S
	mov edx, OFFSET user_name
	DISPLAY_S
	mov edx, OFFSET number_prompt
	DISPLAY_S
	
;getUserData
GETNUM:
	READ_I
	cmp eax, 0			;if user number is less than 0
	jle	IFZERO
	cmp eax, U_LIMIT	;or greater than 40
	jg IFZERO			;jump to get another number
	mov fib_num, eax	;else assign number to memory
	jmp SKIPZERO		;and jump to continue execution
	
IFZERO:
	LINE
	mov edx, OFFSET try_again
	DISPLAY_S
	jmp GETNUM

;displayFibs
SKIPZERO:
	mov eax, 1				;set up first number two numbers
	mov ebx, 1
	mov dh, 5				;used to set up row counter for printing
	mov dl, 0				;first column
	mov ecx, fib_num		;use the user's number for the loop counter
	dec ecx					;since the first number is outside the loop
	call gotoxy				;go to x/y to print formatted columns
	DISPLAY_D
	jmp FIB_LOOP

FIB_LOOP:	
	cmp dl, 40				;if it's the 6th number of that line
	jge INC_LOOP			;go to PRINT_LOOP
	jmp SKIP_INC

INC_LOOP:
	inc dh					;increment the row to print numbers on
	mov dl, -12

SKIP_INC:
	add dl, 12				;move to next formatted column
	add	eax, oldFib_num
	call gotoxy			
	DISPLAY_D
	mov oldFib_num, ebx
	mov ebx, eax
	loop FIB_LOOP

;farewell
	LINE
	LINE
	mov edx, OFFSET good_bye
	DISPLAY_S
	mov edx, OFFSET user_name
	DISPLAY_S
	LINE
	call WaitMsg

	exit	; exit to operating system
main ENDP

END main
