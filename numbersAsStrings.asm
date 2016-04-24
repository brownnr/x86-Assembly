TITLE Programming Assignment 6     (Prog6Brown.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #6
; Assignment Due Date:	3/14/2016
; Description: 			Takes 10 numbers from the user as strings and stores
;						the values in a array as decimals, then finds the sum
;						and average and displays as strings.

INCLUDE Irvine32.inc
;;;;;;;;;;
; MACROS ;
;;;;;;;;;;
displayString MACRO displayAddress
	push 	edx							;save edx register
	mov 	edx, displayAddress			;move string address into edx
	call 	WriteString			
	pop 	edx							;restore edx
ENDM


getString MACRO prompt1, stringAddress, errStr
	push	edx							;save registers
	push 	ecx
	push	eax


	mov		edx, prompt1				;move address of prompt into edx
	call	WriteString

tryAgain:
	mov 	edx, stringAddress			;move string address into edx
	mov 	ecx, MAX					;move MAX into ecx
	call 	ReadString				

	cmp eax, 0
	je showErr
	jmp doneGetting

showErr:
	displayString errStr
	jmp tryAgain

doneGetting:
	pop		eax							;restore registers
	pop 	ecx
	pop		edx
ENDM

;;;;;;;;;;;;;
; Constants ;
;;;;;;;;;;;;;
MAX = 100	;max size of string to be entered
NUMS = 10	;number of integers input
HI = 10000000000000000000000000000000b	;used to test for negative input

.data
;;;;;;;;;;;;;
; Variables ;
;;;;;;;;;;;;;
	intro		BYTE	"PROGRAMMING ASSIGNMENT 6: Designing low-level I/O procedures", 0dh, 0ah,
						"Written by: Nicholas Brown", 0dh, 0ah,
						"**EC: Number each line of user input and display a running subtotal.", 0dh, 0ah,
						"**EC: Handle signed integers.", 0dh, 0ah,
						"**EC: Make your ReadVal and WriteVal procedures recursive.", 0dh, 0ah, 0
	instruct	BYTE	"Please provide 10 integers.", 0dh, 0ah,
						"Each number needs to be small enough to fit inside a 32 bit register.", 0dh, 0ah,
						"After you have finished inputting the raw numbers I will display a list", 0dh, 0ah,
						"of the integers, their sum, and their average value.", 0dh, 0ah, 0
	prompt		BYTE	": Please enter an integer: ", 0
	err			BYTE	"   ERROR: You did not enter an integer or your number was too big.", 0dh, 0ah,
						"   Please try again: ", 0
	comma		BYTE	", ", 0
	input		BYTE	MAX DUP(?)
	num_array	SDWORD	NUMS DUP(0)
	sum			SDWORD	0
	avg			SDWORD	0
	subtotal	BYTE	"        The subtotal so far: ", 0
	sum_str		BYTE	0dh, 0ah, "The sum of these numbers is: ", 0
	avg_str		BYTE	0dh, 0ah, "The average is: ", 0
		arr_str		BYTE	0dh, 0ah, "You entered the following numbers:", 0dh, 0ah, 0
	buffer		BYTE	MAX DUP(?)

.code
;;;;;;;;;;;;;;;;;;
; main procedure ;
;;;;;;;;;;;;;;;;;;
main PROC
	;program intro
		push OFFSET intro
	call Introduction

	;program instructions
		push OFFSET instruct
	call Instructions

	;get user's numbers
		mov eax, 0					;clears eax to be used in ReadVal

		push NUMS
		push OFFSET subtotal
		push OFFSET sum
		push OFFSET num_array
		push OFFSET prompt
		push OFFSET err
		push OFFSET input
	call ReadVal

	;show array
	displayString OFFSET arr_str	;display the string announcing array
		mov ecx, 0					;clear ecx to be used in WriteVal

		push OFFSET comma
		push NUMS
		push OFFSET buffer
		push OFFSET num_array
	call WriteVal

	;show sum
	displayString OFFSET sum_str	;display the string announcing sum
		mov ecx, 0					;clear ecx to be used in WriteVal

		push 0						;don't need commas here, push is to avoid error
		push 1						;push 1 to print only one number(sum)
		push OFFSET buffer
		push OFFSET sum
	call WriteVal

	;show average
		push OFFSET buffer			;used for call to WriteVal in procedure
		push OFFSET avg_str
		push OFFSET avg
		push sum
		push NUMS
	call ShowAvg

	exit	; exit to operating system
main ENDP

;;;;;;;;;;;;;;;;;;;;
; other procedures ;
;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to introduce the program.
;receives: Address of introduction string.
;returns: nothing
;preconditions: none
;registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Introduction PROC USES edx
	enter 0,0						;push ebp and move esp into ebp

	displayString [ebp + 12]		;the OFFSET of intro
	call CrLf

	leave							;restore ebp
	ret 4							;pop the pushed argument from caller
Introduction ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to instructions for the program.
;receives: Address of instructions string.
;returns: nothing
;preconditions: none
;registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Instructions PROC USES edx
	enter 0,0						;push ebp and move esp into ebp

	displayString [ebp + 12]		;the OFFSET of instruct
	call CrLf

	leave							;restore ebp
	ret 4							;pop the pushed argument from caller
Instructions ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to recursively read user's input as string and convert
;	to int with call to sub procedure
;receives: NUMS, and addresses of subtotal string, sum, num_array,
;			prompt string, err string and input
;returns: User's numbers as integers in num_array
;preconditions: none
;registers changed: eax, ebx, ecx, edi, esi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadVal PROC
	enter 0,0							;push ebp and move esp into ebp
	pushad								;save all registers

	mov ecx, [ebp + 32]					;loop counter
	cmp ecx, 0
	je doneReading

	mov ebx, 0							;running total
	inc eax								;number for each line of input
	mov esi, [ebp + 20]					;num_array starting address
	mov edi, [ebp + 24]					;address of sum
	cld									;so lodsd increments forward
	
readLoop:
	call WriteDec
	getString [ebp + 16], [ebp + 8], [ebp + 12]		;get user's number

	push [ebp + 12]						;error message
	push [ebp + 8]						;input starting address
	push esi							;address of index in num_array
	call StrToInt						;converts string input to decimal number

	push eax							;save eax for the following
	lodsd								;load new decimal number into eax
	add [edi], eax						;add to sum
	displayString [ebp + 28]			;display current subtotal
	mov eax, [edi]
	call WriteInt
	call CrLf
	pop eax								;restore eax
	dec ecx								;decrement ecx

	push ecx							;push parameters and call recursively
	push [ebp + 28]
	push [ebp + 24]
	push esi
	push [ebp + 16]
	push [ebp + 12]
	push [ebp + 8]
	call ReadVal

doneReading:
	popad								;restore all registers
	leave								;restore ebp
	ret 28								;pop the pushed argument from caller
ReadVal ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure that converts string to decimal representation.
;receives: address of err message, starting address of input string,
;			address of index in array to store number.
;returns: Decimal representation of a number in string format.
;preconditions: none
;registers changed: eax, ebx, ecx, edx, edi, esi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
StrToInt PROC
	LOCAL temp:DWORD					

	pushad								;save all registers

begin:	
	mov ecx, 0							;clear ecx for calculations
	
	mov ebx, 0							;ebx used as flag for signed integers
	mov esi, [ebp + 12]					;offset of input
	mov edi, [ebp + 8]					;offset of num_array
	cld									;increment esi forward

toIntLoop:
	mov eax, 0							;clear eax for loading byte
	lodsb								;load byte into eax
	cmp eax, 45							;if number is negative
	je negFlag							

	cmp eax, 0							;else if end of input
	je fini

	cmp eax, 48							;else if eax is greater than the decimal 0
	jge upper

	jmp errMsg							;else error

upper:
	cmp eax, 57							;if eax is between decimals 0 and 9
	jle subtract48						;subtract 48 to get decimal number
	jmp errMsg							;otherwise error

subtract48:
	sub eax, 48							;get's decimal number
	mov temp, eax						;temporarily save new number
	mov eax, ecx						;get old decimal number
	mov edx, 10							;multiply it by 10
	mul edx
	jo errMsg
	add eax, temp						;add the new number
	jo errMsg
	mov ecx, eax						;save in ecx for now
	jmp toIntLoop						;check next byte

negFlag:
	mov ebx, 1							;use ebx as flag for signed integers
	jmp toIntLoop						;check next byte

fini:
	cmp ebx, 1							;if the flag was set
	je negate
	jmp store							;otherwise store number

negate:
	neg ecx								;number was negative, so negate decimal

store:
	mov eax, ecx						;move number from ecx
	stosd								;store in num_array
	jmp toIntDone						;exit procedure
		
errMsg:
	getString [ebp + 16], [ebp + 12], [ebp + 16]	;error, try again
	jmp begin

toIntDone:
	popad								;restore all registers
	ret 12								;pop the pushed argument from caller
StrToInt ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure writes decimal number as string.
;receives: address of comma, NUMS, address of buffer and address
;			of num_array
;returns: String representation of decimal number to console.
;preconditions: none.
;registers changed: eax, ecx, edx, edi, esi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteVal PROC
	enter 0,0 

	cmp ecx, [ebp + 16]					;if we've written enough numbers
	je doneWriting						;go to the end
	cmp ecx, 0							;if ecx > 0
	jg writeComma						;print a comma between numbers
	jmp noComma							;otherwise skip the comma

writeComma:
	displayString[ebp + 20]				;prints comma if one was passed

noComma:
	push ecx							;save current count of numbers written

	mov edi, [ebp + 12]					;buffer
	mov ecx, MAX - 1					;size of buffer
	mov eax, 0							
	cld									;esi and edi increment forward
	rep stosb							;overwrite old buffer with 0

	mov esi, [ebp + 8]					;starting address of numerical argument
	lodsd								;load number and increment esi

	mov ecx, 0							;clear ecx and edx for use in IntToStr
	mov edx, 0
	push [ebp + 12]						;push buffer and current number to stack
	push eax
	call IntToStr						;converts current number to string
	pop ecx								;restore ecx that was pushed above

	displayString [ebp + 12]			;display string in buffer

	inc ecx								;increment count of written numbers
recursion:
	push [ebp + 20]						;push parameters again for recursive call
	push [ebp + 16]						
	push [ebp + 12]
	push esi
	call WriteVal						;recursive call

doneWriting:
	leave								;restore ebp
	ret 16								;pop the pushed argument from caller
WriteVal ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure converts decimal number to string
;receives: address of buffer and number to convert.
;returns: String representation of a decimal number.
;preconditions: ecx and edx are clear.
;registers changed: eax, ecx, edx, edi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
IntToStr PROC
	LOCAL divisor:DWORD					;local variable to hold divisor

	push edx							;save edx
	cmp ecx, 0							;in case user inputs a 0, ecx and eax will equal 0, this
	je notEnd							;check makes sure it's converted to ASCII and not '\n'
	cmp eax, 0							;otherwise the end of the number is reached
	je doneHere
notEnd:
	mov divisor, 10						;divide number by 10 to isolate last digit

	mov eax, [ebp + 8]					;eax = decimal representation
	mov edi, [ebp + 12]					;buffer
	cld									;increment edi forward
	
	test eax, HI						;check eax's highest bit, 
	jnz negative						;if it's set it's a negative number
	jmp skipNeg							;otherwise the number is positive

negative:
	mov eax, 45							;eax = '-'
	stosb								;save to first index in buffer
	mov eax, [ebp + 8]					;eax = decimal representation of number
	neg eax								;get positive representation
	jmp recurse							;recursively call IntToStr on positive number

skipNeg:
	cdq									
	div divisor							;divide by 10 to get last digit in edx
	add edx, 48							;convert to ASCII

recurse:	
	inc ecx								;increase ecx for check 
	push edi							;push parameters for recursive call
	push eax
	call IntToStr

doneHere:
	pop edx								;recursion makes the popping of edx and stosb
	mov eax, edx						;store the number in correct order inside buffer argument
	stosb

	ret 8								;pop the pushed argument from caller
IntToStr ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure shows average of array.
;receives: address of buffer for a call to WriteVal, address of
;			avg_str and avg, values of sum and NUMS
;returns: Average of values in array.
;preconditions: none.
;registers changed: eax, ebx, ecx, edi
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ShowAvg PROC
	enter 0,0
	push eax						;save used registers
	push ebx
	push edi

	mov eax, [ebp + 12]				;eax = sum
	cdq
	mov ebx, [ebp + 8]				;ebx = NUMS
	idiv ebx						;signed division
	mov edi, [ebp + 16]				
	mov [edi], eax					;save result in avg variable

	displayString [ebp + 20]		;display avg_str
	mov ecx, 0						;clear ecx to be used in WriteVal

	push 0							;push 0 to avoid errors
	push 1							;push 1 to print only one number(avg)
	push [ebp + 20]					;address of buffer
	push [ebp + 16]					;address of avg
	call WriteVal					;display result of signed division

	pop edi							;restore used registers
	pop ebx
	pop eax
	leave							;restore ebp
	ret 20							;clean up stack
ShowAvg ENDP


END main
