TITLE Programming Assignment 3     (Prog3Brown.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #3
; Assignment Due Date:	2/8/2016
; Description: 			Calculate sum and average of negative numbers
;						entered by the user.

INCLUDE Irvine32.inc

	UBOUND		EQU		-1
	LBOUND		EQU		-100
	DISPLAY_S	EQU		call WriteString
	READ_S		EQU		call ReadString
	DISPLAY_D	EQU		call WriteDec
	DISPLAY_I	EQU		call WriteInt
	READ_I		EQU		call ReadInt
	LINE		EQU		call CrLf

.data
	intro			BYTE	"    Sum and Average of Negative Numbers     by Nicholas Brown", 0
	ec_1			BYTE	"**EC: Number the lines during user input.", 0
	ec_2			BYTE	"**EC: Calculate and display the average as a floating-point number,", 0dh, 0ah
					BYTE	"      rounded to the nearest .001.", 0
	name_prompt		BYTE	"What is your name? ", 0
	user_name		BYTE	50 DUP(0)
	greeting		BYTE	"Hello, ", 0
	instructions	BYTE	"Please enter numbers between -100 and -1", 0ah
					BYTE	"Enter a non-negative number when you are finished to see the results.", 0
	get_num			BYTE	" - Enter number: ", 0
	line_num		DWORD	1
	divisor			DWORD	2
	sum				SDWORD	?
	nums_entered	BYTE	"Number of valid entries: ", 0
	nums_sum		BYTE	"The sum of your valid numbers is ", 0
	nums_avg		BYTE	"The average rounded to the nearest .001 is ", 0
	rounded_avg		BYTE	"The rounded integer average is ", 0
	rounded_num		SDWORD	?
	quotient		DWORD	?
	remainder		DWORD	?
	decimal			BYTE	".", 0
	no_nums			BYTE	"You did not enter any valid numbers.", 0
	try_again		BYTE	"Your number must be between -100 and -1, or a non-negative number", 0dh, 0ah
					BYTE	"to quit. Please try again.", 0
	good_bye		BYTE	"Good bye ", 0


.code
main PROC
;Introduction
	mov edx, OFFSET intro					;display title and programmer's name
	DISPLAY_S
	LINE
	mov edx, OFFSET ec_1					;extra credit option 1
	DISPLAY_S
	LINE
	mov edx, OFFSET ec_2					;extra credit option 2
	DISPLAY_S
	LINE
	LINE

;Get user name
	mov edx, OFFSET name_prompt				;ask for user's name
	DISPLAY_S
	mov edx, OFFSET user_name		
	mov ecx, 49
	READ_S

;Greet user
	mov edx, OFFSET greeting				;greet user
	DISPLAY_S
	mov edx, OFFSET user_name
	DISPLAY_S
	LINE
	LINE

;Instructions
	mov edx, OFFSET instructions			;display instructions
	DISPLAY_S
	LINE

;Get numbers
top:
	mov eax, line_num
	mov edx, OFFSET get_num
	DISPLAY_D
	DISPLAY_S
	READ_I
	jns calc								;jump to calc label if non-neg number
	cmp eax, LBOUND							;validate number is >= -100
	jl retry								;jump to retry label if < -100
	add sum, eax							;accumulate valid entries
	inc line_num							;for line numbers and counting entries
	jmp top

retry:
	mov edx, OFFSET try_again				;give chance to try again
	DISPLAY_S
	LINE
	jmp top

;Calculate and display results
calc:
	dec line_num
	cmp line_num, 0							;jump to bye label if no valid number entered
	je no_negs
	mov edx, OFFSET nums_entered			;show number of valid entries
	DISPLAY_S
	mov eax, line_num
	DISPLAY_D
	LINE
	mov edx, OFFSET nums_sum				;show sum of valid entries
	DISPLAY_S
	mov eax, sum
	DISPLAY_I
	LINE
	
	;calculate rounded average
	mov eax, sum
	cdq										;sign extend register
	mov ebx, line_num
	idiv ebx
	mov quotient, eax						;save quotient for rounding to nearest .001
	mov rounded_num, eax					;save quotient for integer rounding
	mov remainder, edx
	neg edx
	imul edx, 10
	mov eax, edx
	cdq
	idiv ebx
	cmp eax, 5								;if decimal is <= 5
	jle show_rounded_avg					;just show the rounded integer
	dec	rounded_num							;otherwise increment it before showing
show_rounded_avg:
	mov edx, OFFSET rounded_avg
	mov eax, rounded_num
	DISPLAY_S
	DISPLAY_I
	LINE

	mov edx, OFFSET nums_avg				;show rounded average
	mov eax, quotient
	DISPLAY_S
	DISPLAY_I								;display non-rounded quotient
	mov edx, OFFSET decimal					;display decimal point
	DISPLAY_S
	mov edx, remainder						;replace original remainder for div_loop
	neg edx									;convert remainder to it's compliment to make rounding easier
	mov ecx, 3								;loop counter
div_loop:
	imul edx, 10							;multiply remainder by 10
	mov eax, edx
	cdq
	idiv ebx								;divide again
	cmp ecx, 1								;on third loop check for rounding up or down
	jz round_it
skip_round:
	DISPLAY_D
	loop div_loop							;calculate remainder as floating point
	LINE
	jmp bye

round_it:
	mov quotient, eax						;save last decimal position in quotient
	cmp edx, 0								;if there's no additional dividing to do
	jz skip_round							;display the zero
	imul edx, 10							;otherwise divide one more time
	mov eax, edx
	cdq
	idiv ebx
	cmp eax, 5								;if 4th decimal position is <= 5
	jle show_last							;jump to show_last
	inc quotient							;otherwise round third decimal up
show_last:
	mov eax, quotient						;display third decimal
	DISPLAY_D
	LINE
	jmp bye

no_negs:
	mov edx, OFFSET no_nums					;no valid numbers were entered
	DISPLAY_S
	LINE

;Leave
bye:
	mov edx, OFFSET good_bye
	DISPLAY_S
	mov edx, OFFSET user_name
	DISPLAY_S
	LINE

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
