TITLE Basic Mathematics     (prog1.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #1
; Assignment Due Date:	1/17/2016
; Description: 			Calculate the sum, difference, product and
;			quotient and remainder of two numbers from user.

INCLUDE Irvine32.inc

LINE		EQU		call CrLf			;new line shortcut
DISPLAY_S	EQU		call WriteString	;WriteString shortcut
DISPLAY_D	EQU		call WriteDec		;WriteDec shortcut
DISPLAY_I	EQU		call WriteInt		;WriteInt shortcut
READ_I		EQU		call ReadInt		;ReadInt shortcut

.data
progHeader	BYTE	"	Basic Mathematics	by Nicholas Brown", 0
extraC_1	BYTE	"**EC1: Repeat until the user chooses to quit.", 0
extraC_2	BYTE	"**EC2: Validate the second number to be less than the first.", 0	
instruct	BYTE	"After you enter two numbers, I will give you the sum, difference,", 0ah
			BYTE	" product, quotient and remainder of your two numbers.", 0
prompt_1	BYTE	"Please enter your two numbers: ", 0
num_1		DWORD	?		;to be entered by user
num_2		DWORD	?		;to be entered by user
large_2		BYTE	"Your second number is larger than the first number, but that's ok.", 0
showSum		BYTE	"The sum of your numbers is ", 0
sum			DWORD	?		;to be calculated
showDiff	BYTE	"The difference of your numbers is ", 0
difference	DWORD	?		;to be calculated
negFlag		BYTE	?		;set if difference is negative
showProd	BYTE	"The product of your numbers is ", 0
product		DWORD	?		;to be calculated
showQuot	BYTE	"The quotient of your numbers is ", 0
quotient	DWORD	?		;to be calculated
showRem		BYTE	"The remainder of your numbers is ", 0
remainder	DWORD	?		;to be calculated
prompt_2	BYTE	"Would you like to play again? 'y' to continue, 'n' to quit   ", 0
good_bye	BYTE	"Thanks, have a good day. ", 0

.code
main PROC

;introduction
L1:
	call Clrscr 
	mov edx, OFFSET progHeader	;program title/author
	DISPLAY_S
	LINE
	mov edx, OFFSET extraC_1	;extra credit option 1
	DISPLAY_S
	LINE
	mov edx, OFFSET extraC_2	;extra credit option 2
	DISPLAY_S
	LINE
	LINE
	mov edx, OFFSET instruct	;program instructions
	DISPLAY_S
	LINE

;get data
	LINE
	mov edx, OFFSET prompt_1	;prompt for first number
	DISPLAY_S
	LINE
	READ_I
	mov num_1, eax				;move user's number to memory
	READ_I
	cmp eax, num_1				;if second number is greater than first
	jg L2						;tell user second number is larger
	jmp L3						;otherwise jump to L3

L2:
	mov edx, OFFSET large_2		
	DISPLAY_S
	LINE
	
L3:
	mov num_2, eax				;move second number to memory


;calculate values
;sum
	mov eax, num_1				
	add eax, num_2				;add user's numbers
	mov sum, eax				;move result to memory
;difference
	mov eax, num_1
	sub eax, num_2				;subtract user's numbers
	mov difference, eax			;move result to memory
	js L4						;jump if Sign flag is set
	mov negFlag, 0
	jmp L5						;else jump to L5

L4:
	mov negFlag, 1				;remember Sign flag

;product
L5:
	mov eax, num_1
	mov ebx, num_2
	mul ebx						;multiply user's numbers
	mov product, eax			;move result to memory
;quotient/remainder
	mov eax, num_1
	cdq							;extend register for division
	mov ebx, num_2
	div ebx						;divide user's numbers
	mov quotient, eax			;move quotient and remainder to memory
	mov remainder, edx
	
;display results
;sum
	LINE
	mov edx, OFFSET showSum		;display the sum
	DISPLAY_S
	mov eax, sum
	DISPLAY_D
	LINE
;difference
	mov al, 1
	cmp al, negFlag				;if negFlag is 1(negative)
	je L6						;jump to L6
	mov eax, difference
	mov edx, OFFSET showDiff	;else display difference
	DISPLAY_S
	DISPLAY_D
	LINE
	jmp L7						

L6:
	mov eax, difference
	mov edx, OFFSET showDiff	;display negative result
	DISPLAY_S
	DISPLAY_I
	LINE

;product
L7:
	mov edx, OFFSET showProd
	DISPLAY_S
	mov eax, product			;display product
	DISPLAY_D
	LINE
;quotient
	mov edx, OFFSET showQuot
	mov eax, quotient			;display quotient
	DISPLAY_S
	DISPLAY_D
	LINE
;remainder
	mov edx, OFFSET showRem
	mov eax, remainder			;display remainder
	DISPLAY_S
	DISPLAY_D
	LINE

;prompt to continue
	LINE
	mov edx, OFFSET prompt_2	;prompt user to continue or quit
	DISPLAY_S
	call ReadChar
	cmp al, 121					;if user says 'y' or 'Y'
	je L1						
	cmp al, 89
	je L1						;jump to L1
	call Clrscr					;clear screen
	
;say goodbye
	LINE
	mov edx, OFFSET good_bye	;say goodbye
	DISPLAY_S
	LINE
	call WaitMsg

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
