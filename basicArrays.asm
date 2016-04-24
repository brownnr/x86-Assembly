TITLE Programming Assignment 5     (Prog5Brown.asm)

; Author:  				Nicholas Brown
; E-mail:  				brownn5@oregonstate.edu
; Class - Section:  	CS271 - 400
; Assignment Number:  	Program #5
; Assignment Due Date:	02/28/2016
; Description: 			Generate an array of random integers, sort them, 
;						calculate median and display array.


INCLUDE Irvine32.inc

;;;;;;;;;;;;;;;;;;;;;;;;;
; Constants & Shortcuts ;
;;;;;;;;;;;;;;;;;;;;;;;;;
	CLEAR		EQU		Call Clrscr
	PUT_STR		EQU		Call WriteString
	PUT_LINE	EQU		Call CrLf
	PUT_DEC		EQU		Call WriteDec
	GET_DEC		EQU		Call ReadDec
	
	MIN = 10
	MAX = 200
	LO = 100
	HI = 999
	
;;;;;;;;;;;;;
; Variables ;
;;;;;;;;;;;;;
.data
	intro		BYTE	"            Array of Random Numbers     by Nicholas Brown", 0dh, 0ah
				BYTE	"This program generates random numbers in the range [100 .. 999],", 0dh, 0ah
				BYTE	"displays the original list, sorts the list, and calculates the median", 0dh, 0ah
				BYTE	"value. Finally, it displays the list sorted in descending order.", 0dh, 0ah
				BYTE	0dh, 0ah, "**EC: Generate the numbers into a file; then read the file into the array.", 0
	getRequest	BYTE	0dh, 0ah, "How many numbers should be generated? [10 .. 200]: ", 0
	request		DWORD	?
	invalid		BYTE	"Invalid Input!", 0dh, 0ah, 0
	myArr		DWORD	MAX	DUP(?)
	unTitle		BYTE	"The unsorted random numbers:", 0dh, 0ah, 0
	sortTitle	BYTE	"The sorted list:", 0dh, 0ah, 0
	median		BYTE	0dh, 0ah, "The median is ", 0
	per			BYTE	".", 0dh, 0ah, 0
	unFile		BYTE	"unsorted.txt", 0
	sortedFile	BYTE	"sorted.txt", 0
	fileHandle	DWORD	?
	fileError	BYTE	0dh, 0ah, "THERE WAS AN ERROR CREATING OR OPENING THE FILE.", 0dh, 0ah, 0
	badExit		BYTE	0dh, 0ah, "THE PROGRAM IS EXITING AS A RESULT OF AN ERROR WITH A FILE.", 0dh, 0ah, 0
	buffer		BYTE	6 DUP(?)


.code
main PROC
	;seed random number generator
	call Randomize

	;show program introduction
		push OFFSET intro		;pass intro by reference
	call Introduction

	;get user's data
		push OFFSET invalid		;pass two strings by reference
		push OFFSET getRequest
		push OFFSET request		;pass by reference to get input
	call GetData

	;fill the array(written to file here) with random numbers
		push OFFSET myArr
		push OFFSET fileError
		push OFFSET fileHandle
		push OFFSET unFile
		push OFFSET buffer
		push request
	call FillArray

	mov ebx, OFFSET fileError	
	cmp edx, ebx				;if error message is NOT in edx
	jne display1				;keep running program
	mov edx, OFFSET badExit		;otherwise, alert user and quit
	PUT_STR
	call WaitMsg
	jmp quit

display1:
	;displays unsorted array
		push OFFSET fileHandle
		push request
		push OFFSET fileError
		push OFFSET unFile
		push OFFSET buffer
	call DisplayList

	mov ebx, OFFSET fileError	
	cmp edx, ebx				;if error message is NOT in edx
	jne sort1					;keep running program
	mov edx, OFFSET badExit		;otherwise, alert user and quit
	PUT_STR
	call WaitMsg
	jmp quit

sort1:
	;sorts the array
		push OFFSET fileError
		push OFFSET fileHandle
		push OFFSET sortedFile
		push OFFSET buffer
		push request
		push OFFSET myArr
	call SortList

	mov ebx, OFFSET fileError	
	cmp edx, ebx				;if error message is NOT in edx
	jne med1					;keep running program
	mov edx, OFFSET badExit		;otherwise, alert user and quit
	PUT_STR
	call WaitMsg
	jmp quit

med1:
	;displays the median
		push request
		push OFFSET myArr
		push OFFSET median
		push OFFSET per
	call GetMed

	;displays the sorted array
		push OFFSET fileHandle
		push request
		push OFFSET fileError
		push OFFSET sortedFile
		push OFFSET buffer
	call DisplayList

	mov ebx, OFFSET fileError	
	cmp edx, ebx				;if error message is NOT in edx
	jne quit					;keep running program
	mov edx, OFFSET badExit		;otherwise, alert user and quit
	PUT_STR
	call WaitMsg

quit:
	exit	; exit to operating system
main ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to introduce the program.
;receives: Address of introduction string.
;returns: nothing
;preconditions: none
;registers changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Introduction PROC
	enter 0,0				;push ebp and move esp into ebp

	mov edx, [ebp + 8]		;the OFFSET of intro
	PUT_STR					;write the string
	PUT_LINE				;print two carriage returns
	PUT_LINE

	leave					;restore the ebp
	ret 4					;pop the pushed argument from caller
Introduction ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to get user data.
;receives: Address of request parameter, address of invalid input
;			string, and input prompt.
;returns: User's number.
;preconditions: none
;registers changed: edx, edi, eax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetData PROC
	enter 0,0				;push ebp and move esp into ebp

	mov edi, [ebp + 8]		;the OFFSET of request
putRequest:
	mov edx, [ebp + 12]		;the OFFSET of getRequest
	PUT_STR					;write the string
	GET_DEC					;read the dec
	cmp eax, MIN			;check input against min
	jl err					
	cmp eax, MAX			;check input against max
	jg err					;show input was invalid
	stosd					;otherwise store input to edi register
	jmp getOut				;leave procedure

err:
	mov edx, [ebp + 16]		;the OFFSET of invalid
	PUT_STR					;write the string
	jmp putRequest			;prompt user to re-enter input

getOut:						
	leave					;restore ebp
	ret 12					;pop the arguments pushed from caller
GetData ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Procedure to fill array with random integers.
;receives: Address of the array, address of file error message, 
;			address of fileHandle, address of unsorted file's 
;			filename, address of the buffer, and value of request.
;returns: A file and array filled with random integers.
;preconditions: none
;registers changed: edi, ecx, edx, eax, esi, ebx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FillArray PROC 
	enter 0,0						;push ebp

	mov edx, [ebp + 16]				;the offset of the filename
	call CreateOutputFile			;create output file
	mov esi, [ebp + 20]
	mov [esi], eax					;save the file handle

	cmp eax, INVALID_HANDLE_VALUE	;error creating file
	je fileErr

	mov edi, [ebp + 28]				;offset of the array
	mov ecx, [ebp + 8]				;the user's request for the counter
	mov edx, HI
	sub edx, LO						;edx = real range for random number generator
	mov ebx, 0						;counter for numbers per row
	cld								;clear direction flag so edi is incremented each time stosd is called
	
arrayLoop:
	mov eax, edx					;set up range for RandomRange
	call RandomRange
	add eax, LO						;offset number returned
	stosd

	push ebx
	push [ebp + 12]					;push OFFSET of buffer for convert procedure
	call Convert					;converts decimal integer to ASCII representation

	push ecx						;save ecx and edx registers
	push edx
	push ebx
	mov eax, [esi]					;file handle
	mov edx, [ebp + 12]				;OFFSET of buffer containing random integer
	mov ecx, 6						;number of bytes to write(3 for number, 3 for padding)
	call WriteToFile				;write number to file
	pop ebx
	inc ebx
	pop edx							;restore edx and ecx registers for loop
	pop ecx
	cmp ebx, 10
	je nextRow
	jmp nextLoop

nextRow:
	mov ebx, 0

nextLoop:
	loop arrayLoop
	
	mov eax, [esi]					;file handle
	call CloseFile					;close file
	jmp gone

fileErr:
	mov edx, [ebp + 24]
	PUT_STR

gone:	
	leave							;restore ebp
	ret 24							;pop 6 arguments
FillArray ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Converts 3 digit decimal to ASCII representation.
;receives: Number to be converted in eax, count of number in ebx,
;			and address of the buffer to save ASCII number.
;returns: ASCII integer value of a number.
;preconditions: none
;registers changed: edx, ecx, ebx, esi, edi, eax but
;					all are restored.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Convert PROC USES edx ecx ebx esi edi eax
	enter 0,0					;push ebp

	mov ecx, 3					;loop 3 times, 1 for each digit
	mov edi, [ebp + 32]			;OFFSET of the buffer

loopStart:
	mov ebx, 10					;divide by 10 to isolate last digit
	cdq
	div ebx
	add edx, 48					;add 48 for ASCII representation
	mov [edi + ecx - 1], dl		;store number in offset from beginning of buffer
	loop loopStart

	mov eax, 32					;for space
	mov [edi + 3], eax			;append a space to end of number
	
	mov eax, [ebp + 36]
	cmp eax, 9
	je lineFeed
	jmp spaces

lineFeed:						;makes a new row of numbers after the 10th
	mov eax, 13
	mov [edi + 4], eax
	mov eax, 10
	mov [edi + 5], eax
	jmp doneConv

spaces:							;makes for a total of 3 spaces between each number
	mov eax, 32
	mov [edi + 4], eax		
	mov [edi + 5], eax

doneConv:
	leave						;restore ebp
	ret 8						;pop 2 argument
Convert ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Displays the unsorted array of random integers.
;receives: Address of fileHandle, value of request, address of file
;			error message, address of filename to read from, and
;			address of buffer.
;returns: Displays list of numbers, read from file.
;preconditions: none
;registers changed: esi, ecx, edx, eax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DisplayList PROC
	enter 0,0

	PUT_LINE
	
	mov edx, [ebp + 12]				;offset of filename
	call OpenInputFile
	mov esi, [ebp + 24]
	mov [esi], eax
	
	cmp eax, INVALID_HANDLE_VALUE	;error opening file
	je fErr

	mov ecx, [ebp + 20]				;user's request for loop

readLoop:
	push ecx
	mov eax, [esi]					;offset of the file handle
	mov edx, [ebp + 8]				;offset of the buffer
	mov ecx, 6
	call ReadFromFile
	pop ecx
	jc fErr							;if carry flag is set, there was an error
	
	mov edx, [ebp + 8]
	PUT_STR
	loop readLoop

	mov eax, [esi]					;file handle
	call CloseFile					;close file
	jmp gone

fErr:
	mov edx, [ebp + 16]				;offset of file read error message
	PUT_STR

gone:	
	leave							;restore ebp
	ret 20							;pop 5 arguments
DisplayList ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Sorts the array of random integers.
;receives: Address of file error message, address of fileHandle,
;			address of sorted file's filename, address of buffer,
;			value of request, and address of myArr.
;returns: The array sorted in descending order.
;preconditions: none
;registers changed: ecx, esi, eax (and edx & ebx through sub procedure)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SortList PROC
	enter 0,0
	
	mov ecx, [ebp + 12]				;value of request
	dec ecx

outerLoop:
	push ecx						;save outerLoop's count
	mov esi, [ebp + 8]				;address of array

	innerLoop:
		mov eax, [esi]				;value stored in current position of array
		cmp [esi + 4], eax			;if next value is less
		jl noSwap					;don't swap
		xchg eax, [esi + 4]			;otherwise exchange values
		mov [esi], eax				

	noSwap:
		add esi, 4					;increment esi
		loop innerLoop				;continue innerLoop

	pop ecx							;restore outerLoop count
	loop outerLoop					;continue outerLoop

	push [ebp + 28]					;file read error message
	push [ebp + 24]					;fileHandle
	push [ebp + 20]					;sorted filename
	push [ebp + 16]					;buffer
	push [ebp + 12]					;request
	push [ebp + 8]					;myArr
	call WriteSorted				;write sorted array to file

	leave							;restore ebp
	ret 24							;pop 6 arguments
SortList ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Writes sorted array to file.
;receives: Address of file error message, address of fileHandle,
;			address of sorted file's filename, address of buffer,
;			value of request, and address of myArr.
;returns: Nothing, array is written to a file.
;preconditions: none
;registers changed: edx, edi, eax, ecx, esi, ebx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
WriteSorted PROC
	enter 0,0

	mov edx, [ebp + 20]				;file name to write to
	call CreateOutputFile			;create file
	mov edi, [ebp + 24]				;store fileHandle
	mov [edi], eax

	cmp eax, INVALID_HANDLE_VALUE	;check for file error
	je error

	mov ecx, [ebp + 12]				;request for loop
	mov esi, [ebp + 8]				;offset of myArr
	mov ebx, 0						;to keep track of 10 numbers per line
	cld

beginLoop:
	mov eax, [esi]					;get number from array
	add esi, 4						;increment esi
	push ebx						;count of numbers written so far
	push [ebp + 16]					;offset of buffer
	call Convert 					;convert number to ASCII representation

	push ecx						;save registers
	push edx
	push ebx
	mov eax, [edi]					;file handle
	mov edx, [ebp + 16]				;offset of buffer
	mov ecx, 6						;number of bytes to write to file
	call WriteToFile
	pop ebx							;restore registers
	inc ebx							;and increment ebx
	pop edx
	pop ecx
	cmp ebx, 10						;if 10 numbers have been written
	je newRow						;jump to make new row
	jmp loopAgain					;otherwise continue loop

newRow:
	mov ebx, 0						;reset ebx for new row

loopAgain:
	loop beginLoop					;continue loop

	mov eax, [edi]					;fileHandle
	call CloseFile
	jmp stop

error:
	mov edx, [ebp + 28]				;offset of file error message
	PUT_STR

stop:
	leave							;restore ebp
	ret 24							;pop 6 arguments
WriteSorted ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Get the median of the array of random integers.
;receives: Value of request, address of myArr, address of median
;			and address of string containing a period.
;returns: The median is printed to the console.
;preconditions: none
;registers changed: edx, eax, ebx, esi, ecx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
GetMed PROC
	enter 0,0

	PUT_LINE
	mov edx, [ebp + 12]				;offset of median string
	PUT_STR

	mov eax, [ebp + 20]				;request
	mov ebx, 2						;divide by 2 to get middle position of array
	cdq
	div ebx

	mov esi, [ebp + 16]				;offset of myArr
	mov ecx, eax					;ecx holds median's index
	mov eax, [esi + ecx * 4]		;eax holds the value at median's index

	cmp edx, 0						;if there is no remainder
	je average						;jump to get average of 2 middle indexes
	jmp doneHere					;otherwise show average

average:
	dec ecx							;decrement ecx
	add eax, [esi + ecx * 4]		;add next index in myArr to middle index
	cdq
	div ebx							;divide by 2 to get average

doneHere:
	PUT_DEC							;display median
	mov edx, [ebp + 8]				;display period
	PUT_STR
	PUT_LINE

	leave							;restore ebp
	ret 16							;pop 4 arguments
GetMed ENDP


END main
