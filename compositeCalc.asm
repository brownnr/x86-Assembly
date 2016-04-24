TITLE Programming Assignment 4 (Prog4Brown.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #4
; Assignment Due Date:	2/14/2016
; Description: 			Calculate composite numbers up to and including the nth
;						composite, which is entered by the user.

INCLUDE Irvine32.inc

	LOWER_LIMIT	EQU		1
	UPPER_LIMIT	EQU		400
	PUT_STR		EQU		call WriteString
	PUT_DEC		EQU		call WriteDec
	PUT_LINE	EQU		call CrLf
	CLEAR		EQU		call Clrscr
	GET_DEC		EQU		call ReadDec

.data 

	intro		BYTE	"            Composite Numbers     by Nicholas Brown", 0dh, 0ah
				BYTE	"**EC: Align output columns.(Console Window should be at least 80 columns wide", 0dh, 0ah
				BYTE	"        to ensure readability.)", 0dh, 0ah
				BYTE	"**EC: Display more composites, one page at a time.", 0dh, 0ah, 0
	instruct	BYTE	"Enter the number of composites you would like to see (between 1 and 400): ", 0
	userNum		DWORD	?
	isValid		DWORD	?
	isComp		DWORD	?
	inputErr	BYTE	"Invalid input, the number must be between 1 and 400. Try again: ", 0
	composites	BYTE	"Here are your composite numbers, max 200 per page: ", 0dh, 0ah, 0
	getMore		BYTE	"Press 1 to view the first 2,000 composite numbers, 0 to quit: ", 0
	choice		DWORD	?
	looper		DWORD	?
	good_bye	BYTE	0dh, 0ah, 0dh, 0ah, "                        Thank you for playing.", 0dh, 0ah
				BYTE	"                           Have a nice day!   ", 0
	

.code


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to introduce the program.
;receives: nothing
;returns: nothing
;preconditions: none
;registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
introduction PROC
	mov edx, OFFSET intro		;display introductions
	PUT_STR
	PUT_LINE

	ret

introduction ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to get user data.
;receives: address of userNum parameter
;returns: user input for number of composites to show
;preconditions: none
;registers changed: eax, ebx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getUserData PROC
	push ebp
	mov ebp, esp

	mov edx, OFFSET instruct
	PUT_STR
try_again:
	mov ebx, [ebp + 8]			;move @ userNum into register
	GET_DEC
	mov [ebx], eax				;store user input in memory location

	push LOWER_LIMIT			;set up stack frame for call to validate
	push UPPER_LIMIT
	push eax
	push OFFSET isValid
	call validate

	cmp isValid, 0			;check if input was validated
	je try_again				;loop if not validated

	pop ebp						;restore ebp
	ret 4						;clear local variable from stack

getUserData ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to validate user data.
;receives: address of validated parameter, LOWER_LIMIT, 
;			UPPER_LIMIT	and user input
;returns: 1 if valid, 0 if not valid
;preconditions: none
;registers changed: eax, ebx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
validate PROC
	push ebp
	mov ebp, esp

	mov ebx, [ebp + 8]			;move @ validated into register
	mov eax, [ebp + 12]
	cmp eax, [ebp + 16]			;check input against upper_limit
	jg notValid
	cmp eax, [ebp + 20]			;check input against lower_limit
	jl notValid
	mov eax, 1
	mov [ebx], eax				;input is valid
	jmp jumpOut					;exit function

notValid:
	mov eax, 0
	mov [ebx], eax				;input is not valid
	mov edx, OFFSET inputErr
	PUT_STR

jumpOut:
	pop ebp						;restore ebp
	ret 16						;clear local variables from stack

validate ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to show composite numbers.
;receives: user's number of composites to show
;returns: prints the composite numbers to the console, 10 numbers
;			per line, then gives option to view multiple pages
;preconditions: none
;registers changed: eax, ebx, ecx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
showComposites PROC
	push ebp
	mov ebp, esp

	mov eax, 3					;set up loops for isComposite, eax will start at 4
	mov ecx, [ebp + 8]
	
newPageLoop:
	mov looper, 1				;set looper to view only 200 numbers per page
	CLEAR						;clear console
	call introduction			;show program information
	mov edx, OFFSET composites	;introduce composites
	PUT_STR

	mov dh, 7					;set up x and y coordinates for aligning output
	mov dl, 0

showNum:
	cmp looper, 200				;if 200 numbers have been printed
	jg showMsg					;jump to showMsg
	inc eax						;otherwise increment eax
	push OFFSET isComp			;set up stack frame
	call isComposite

	cmp isComp, 1				;if number is a composite
	je printNum					;print the number
	jmp showNum					;otherwise loop back without decrementing ecx

	jmp endComp					;jump to end after printing last composite

printNum:
	inc looper
	call gotoxy					;output aligned in columns
	PUT_DEC
	cmp dl, 65					;if output number is 10th number for that row
	jge nextRow					;jump to increment to next row
	jmp nextCol					;otherwise go to next column

nextRow:
	inc dh						;increments to next row
	mov dl, -8					;set up for nextCol

nextCol:
	add dl, 8					;add 8 to get to next column
	loop showNum				;loop back for next number
	jmp endComp

showMsg:
	PUT_LINE
	PUT_LINE
	call WaitMsg				;prompt user to press any key to continue
	jmp newPageLoop

endComp:
	pop ebp						;restore ebp
	ret 4						;clear local variable from stack

showComposites ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to check if number is composite.
;receives: address of isComp
;returns: 1 if composite, 0 if not composite
;preconditions: none
;registers changed: eax, ebx, ecx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
isComposite PROC
	push edx					;push changed registers
	push eax
	push ecx
	push ebp
	mov ebp, esp

	mov eax, [ebp + 8]			;move number to check into eax
	cdq							;extend register
	mov ebx, 2
	div ebx
	cmp edx, 0					;is it an even number?
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 3
	div ebx
	cmp edx, 0					;is it divisible by 3?
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 5
	cmp eax, ebx
	je notComp					;5 is prime
	div ebx
	cmp edx, 0					;but if it's > 5 and divisible by 5, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 7
	cmp eax, ebx
	je notComp					;7 is prime
	div ebx
	cmp edx, 0					;but if it's > 7 and divisible by 7, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 11
	cmp eax, ebx
	je notComp					;11 is prime
	div ebx
	cmp edx, 0					;but if it's > 11 and divisible by 11, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 13
	cmp eax, ebx
	je notComp					;13 is prime
	div ebx
	cmp edx, 0					;but if it's > 13 and divisible by 13, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 17
	cmp eax, ebx					
	je notComp					;17 is prime
	div ebx
	cmp edx, 0					;but if it's > 17 and divisible by 17, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 19
	cmp eax, ebx
	je notComp					;19 is prime
	div ebx
	cmp edx, 0					;but if it's > 19 and divisible by 19, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 23
	cmp eax, ebx
	je notComp					;23 is prime
	div ebx
	cmp edx, 0					;but if it's > 23 and divisible by 23, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 29
	cmp eax, ebx
	je notComp					;29 is prime
	div ebx
	cmp edx, 0					;but if it's > 29 and divisible by 29, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 31
	cmp eax, ebx
	je notComp					;31 is prime
	div ebx
	cmp edx, 0					;but if it's > 31 and divisible by 31, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 37
	cmp eax, ebx
	je notComp					;37 is prime
	div ebx
	cmp edx, 0					;but if it's > 37 and divisible by 37, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 41
	cmp eax, ebx
	je notComp					;41 is prime
	div ebx
	cmp edx, 0					;but if it's > 41 and divisible by 41, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 43
	cmp eax, ebx
	je notComp					;43 is prime
	div ebx
	cmp edx, 0					;but if it's > 43 and divisible by 43, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 47
	cmp eax, ebx
	je notComp					;47 is prime
	div ebx
	cmp edx, 0					;but if it's > 47 and divisible by 47, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 53
	cmp eax, ebx
	je notComp					;53 is prime
	div ebx
	cmp edx, 0					;but if it's > 53 and divisible by 53, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 59
	cmp eax, ebx
	je notComp					;59 is prime
	div ebx
	cmp edx, 0					;but if it's > 59 and divisible by 59, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 61
	cmp eax, ebx
	je notComp					;61 is prime
	div ebx
	cmp edx, 0					;but if it's > 61 and divisible by 61, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 67
	cmp eax, ebx
	je notComp					;67 is prime
	div ebx
	cmp edx, 0					;but if it's > 67 and divisible by 67, it's composite
	je yesComp
	mov eax, [ebp + 8]
	cdq
	mov ebx, 71
	cmp eax, ebx
	je notComp					;71 is prime
	div ebx
	cmp edx, 0					;but if it's > 71 and divisible by 71, it's composite
	je yesComp
	
notComp:
	mov eax, 0					;set isComp to 0(number is prime)
	mov ecx, [ebp + 20]
	mov [ecx], eax
	jmp leaveHere

yesComp:
	mov eax, 1					;set isComp to 1(number is a composite)
	mov ecx, [ebp + 20]
	mov [ecx], eax
	
leaveHere:
	pop ebp						;restore changed registers
	pop ecx
	pop eax
	pop edx
	ret 4						;remove local variables from stack

isComposite ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to prompt user to view more composites.
;receives: none
;returns: none
;preconditions: none
;registers changed: eax, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moreComp PROC
	push ebp
	mov ebp, esp

	PUT_LINE
	PUT_LINE 
	mov edx, OFFSET getMore		;ask user if they want to see more composites, or quit
	PUT_STR
	GET_DEC
	cmp eax, 1					;if the user entered 0
	jne noMore					;jump to end of procedure

	push 2000					;otherwise call showComposites with 2000 as parameter
	call showComposites

	PUT_LINE
	PUT_LINE
	call WaitMsg
	
noMore:
	pop ebp						;restore ebp
	ret 4						;remove local variables from stack

moreComp ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to display the farewell message.
;receives: nothing
;returns: nothing
;preconditions: none
;registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
farewell PROC
	CLEAR
	mov edx, OFFSET good_bye	;display farewell message
	PUT_STR
	PUT_LINE
	PUT_LINE
	PUT_LINE
	PUT_LINE
	PUT_LINE
	PUT_LINE
	call WaitMsg

	ret

farewell ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                        Main procedure                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
main		PROC

	call introduction			;show introduction
	
	push OFFSET userNum			;set up stack frame for call to getUserData
	call getUserData

	push userNum				;set up stack frame for call to showComposites
	call showComposites			

	call moreComp				;ask user if they want to see more composites

	call farewell				;say goodbye

	exit
main		ENDP

END main
