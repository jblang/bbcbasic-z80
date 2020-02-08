; Copyright (c) 2020 J.B. Langston
; 
; This software is provided 'as-is', without any express or implied
; warranty. In no event will the authors be held liable for any damages
; arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
; 
; 1. The origin of this software must not be misrepresented; you must not
;    claim that you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation would be
;    appreciated but is not required.
; 2. Altered source versions must be plainly marked as such, and must not be
;    misrepresented as being the original software.
; 3. This notice may not be removed or altered from any source distribution.
;
; HARDWARE FUNCTIONS
;
	PUBLIC	CLG
	PUBLIC	COLOUR
	PUBLIC	DRAW
	PUBLIC	ENVEL
	PUBLIC	GCOL
	PUBLIC	MODE
	PUBLIC	MOVE
	PUBLIC	PLOT
	PUBLIC	SOUND
	PUBLIC	ADVAL
	PUBLIC	POINT
	PUBLIC	GETIMS
	PUBLIC	PUTIMS
	PUBLIC	CLRSCN
	PUBLIC	PUTCSR
	PUBLIC	GETCSR
	PUBLIC	PUTIME
	PUBLIC	GETIME
;
	EXTERN	EXTERR
	EXTERN	TELL
	EXTERN	PBCDL
	EXTERN	OUTCHR
	EXTERN	EXPRI
	EXTERN	XEQ
;
ESC	EQU	27
;
;CLRSCN	- Clear screen.
;	  (Alter characters to suit your VDU)
; 	  Destroys: A,D,E,H,L,F
;
CLRSCN:	PUSH	BC
	CALL	TELL
	DEFB	ESC,"[;H"	; home cursor
	DEFB	ESC,"[2J"	; clear screen
	DEFB	0
	POP	BC
	RET
;
;PUTCSR	- Move cursor to specified position.
;   	  Inputs: DE = horizontal position (LHS=0)
;                 HL = vertical position (TOP=0)
; 	  Destroys: A,D,E,H,L,F
;
PUTCSR:	PUSH	DE		;SAVE X & Y FOR LATER
	PUSH	HL
	LD	A,ESC
	CALL	OUTCHR
	LD	A,'['
	CALL	OUTCHR
	POP	DE
	CALL	PBCDL
	LD	A,';'
	CALL	OUTCHR
	POP	HL
	CALL	PBCDL
	LD	A,'H'
	CALL	OUTCHR
	RET
;
;GETCSR	- Return cursor coordinates.
;   	  Outputs:  DE = X coordinate (POS)
;                   HL = Y coordinate (VPOS)
;  	  Destroys: A,D,E,H,L,F
;
GETCSR:	LD	DE,0
	LD	HL,0
	RET
;
;GETIME	- Read elapsed-time clock.
;  	  Outputs: DEHL = elapsed time (centiseconds)
; 	  Destroys: A,D,E,H,L,F
;
GETIME:	LD	DE,0
	LD	HL,0
	RET
;
;PUTIME	- Load elapsed-time clock.
;   	  Inputs: DEHL = time to load (centiseconds)
; 	  Destroys: A,D,E,H,L,F
;
PUTIME:	RET
;
;COLOUR	- Set color
;
COLOUR:	CALL	EXPRI
	EXX
VTCLR:  LD	A,L
	AND	7
	BIT	7,L
	JR	Z,FGCLR
	ADD	10
FGCLR:  ADD	30
	BIT	3,L
	JR	Z,OUTCLR
	ADD	60
OUTCLR: LD	L,A
	LD	A,ESC
	CALL	OUTCHR
	LD	A,'['
	CALL	OUTCHR
	CALL	PBCDL
	LD	A,'m'
	CALL	OUTCHR
	JP	XEQ
;
CLG:
DRAW:
ENVEL:
GCOL:
MODE:
MOVE:
PLOT:
SOUND:
ADVAL:
POINT:
GETIMS:
PUTIMS:
	XOR	A
	CALL	EXTERR
	DEFM	"Sorry"
	DEFB	0