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

; HARDWARE FUNCTIONS

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

	EXTERN	EXTERR
	EXTERN	TELL
	EXTERN	PBCDL
	EXTERN	OUTCHR
	EXTERN	EXPRI
	EXTERN	COMMA
	EXTERN	XEQ

ESC	EQU	27

;CLRSCN	- Clear screen.
;	  (Alter characters to suit your VDU)
; 	  Destroys: A,D,E,H,L,F
CLRSCN:	PUSH	BC
	CALL	TELL
	DEFB	ESC,"[;H"	; home cursor
	DEFB	ESC,"[2J"	; clear screen
	DEFB	0
	LD	BC,0
	LD	(TEXTX),BC
	LD	(TEXTY),BC
	POP	BC
	RET

;PUTCSR	- Move cursor to specified position.
;	  Inputs: DE = horizontal position (LHS=0)
;		  HL = vertical position (TOP=0)
; 	  Destroys: A,D,E,H,L,F
PUTCSR:	LD	(TEXTX),DE		;SAVE X & Y FOR LATER
	LD	(TEXTY),HL
	LD	A,ESC
	CALL	OUTCHR
	LD	A,'['
	CALL	OUTCHR
	LD	DE,(TEXTX)
	CALL	PBCDL
	LD	A,';'
	CALL	OUTCHR
	LD	HL,(TEXTY)
	CALL	PBCDL
	LD	A,'H'
	CALL	OUTCHR
	RET

;GETCSR	- Return cursor coordinates.
;	  Outputs:  DE = X coordinate (POS)
;		    HL = Y coordinate (VPOS)
;  	  Destroys: A,D,E,H,L,F
GETCSR:	LD	DE,(TEXTX)
	LD	HL,(TEXTY)
	RET

;GETIME	- Read elapsed-time clock.
;  	  Outputs: DEHL = elapsed time (centiseconds)
; 	  Destroys: A,D,E,H,L,F
GETIME:	LD	DE,0
	LD	HL,0
	RET

;PUTIME	- Load elapsed-time clock.
;	  Inputs: DEHL = time to load (centiseconds)
; 	  Destroys: A,D,E,H,L,F
PUTIME:	RET
;
;COLOUR	- Set text color
COLOUR:	CALL	EXPRI
	EXX
	LD	A,L
	AND	7
	BIT	7,L
	JP	Z,FGCLR
	ADD	10
FGCLR:  ADD	30
	BIT	3,L
	JP	Z,OUTCLR
	ADD	60
OUTCLR:	LD	L,A
	LD	A,ESC
	CALL	OUTCHR
	LD	A,'['
	CALL	OUTCHR
	CALL	PBCDL
	LD	A,'m'
	CALL	OUTCHR
	JP	XEQ

; GCOL - Set graphics color
;	destroys HL, A
GCOL:	CALL	EXPRI
	EXX
	LD	A,L
	AND	0FH
	LD	E,A		; E contains new color in background nybble
	ADD	A,A
	ADD	A,A
	ADD	A,A
	ADD	A,A
	LD	D,A		; D contains new color in foreground nybble
	BIT	7,L		; bit 7 set indicates backdrop color
	JP	NZ,BDGCOL
	LD	A,(CGCOL)
	BIT	6,L		; bit 6 set indicates cell background color
	JP	NZ,BGGCOL
	AND	0FH		; clear existing foreground
	OR	D		; set new foreground
	LD	(CGCOL),A
	JP	XEQ
BGGCOL:	LD	A,(CGCOL)
	AND	0F0H		; clear existing background
	OR	E		; set new background
	LD	(CGCOL),A
	JP	XEQ
BDGCOL:	LD	A,(CCOLOR)	; get current backdrop colors
	AND	0F0H		; clear existing backdrop
	OR	E		; set new backdrop
	LD	(CCOLOR),A	; save backdrop colors
	LD	BC,(VDPADR)	; send to vdp
	INC	C
	LD	B,87H
	OUT	(C),A
	OUT	(C),B
	JP	XEQ

; set backdrop color

; MODE - Set graphics mode
;	destroys all registers
MODE:	CALL	EXPRI		; get mode
	EXX
	LD	A,L
	CALL	VDPINI
	JP	XEQ

; PLOT - Plot graphics
;
PLOT:	CALL	GETXY		;DE <- X, HL <- Y
	LD	B,L
	LD	C,E
	CALL	BMPLOT
XEQ1:	JP	XEQ

GETXY:	CALL	EXPRI		;"X"
	EXX
	PUSH	HL
	CALL	COMMA
	CALL	EXPRI		;"Y"
	EXX
	POP	DE
	RET

; unimplemented functions
CLG:
DRAW:
MOVE:
POINT:
ENVEL:
SOUND:
ADVAL:
GETIMS:
PUTIMS:
	XOR	A
	CALL	EXTERR
	DEFM	"Not implemented"
	DEFB	0
	
; VDP state
VDPADR:	DEFB	0BEH		; VDP base port
VDPINT:	DEFB	0		; 0 = NMI, 1 = INT
CMODE:	DEFB	2		; Current graphics mode
CGCOL:	DEFB	0F0H		; Current graphics color
CCOLOR:	DEFB	0F0H		; Current text color
GRAPHX:	DEFW	0		; Current graphics X coordinate
GRAPHY:	DEFW	0		; Current graphics Y coordinate
TEXTX:	DEFW	0		; Current text X coordinate
TEXTY:	DEFW	0		; Current text Y coordinate

; VDP table addresses
NAMTAB	EQU	3800H		; name table
COLTAB	EQU	2000H		; color table
PATTAB	EQU	0H		; pattern table
SPATAB	EQU	3BC0H		; sprite attribute table
SPPTAB	EQU	1800H		; sprite pattern table

; default register values
DEFREG:	DEFB	0, 80H		; blank, 16KB enabled
	DEFB	NAMTAB/400H
	DEFB	COLTAB/40H	; calculate register values from
	DEFB	PATTAB/800H	; addresses defined above
	DEFB	SPATAB/80H
	DEFB	SPPTAB/800H

; mode-specific register values
MODREG:	DEFB	0, 0D0H		; MODE 0: text
	DEFB	0, 0C0H		; MODE 1: tile graphics
	DEFB	2, 0C0H		; MODE 2: bitmap graphics
	DEFB	0, 0C8H		; MODE 3: multicolor graphics
	
; initialize vdp registers to default values
;	A = mode to set
VDPINI:	AND	3		; limit to modes 0-3
	LD	(CMODE),A	; save mode for later
	LD	BC,(VDPADR)
	INC	C		; select vdp register port
	LD	HL,DEFREG	; look up default register values
	LD	B,7		; register counter
	LD	D,80H		; register address
REGLP:	LD	E,(HL)
	OUT	(C),E
	OUT	(C),D
	INC	HL
	INC	D
	DJNZ	REGLP
	LD	A,(CCOLOR)	; restore saved colors
	OUT	(C),A
	OUT	(C),D

; clear vram
	LD	DE,4000H	; 16KB of memory
	OUT	(C),E		; write at start of memory
	OUT	(C),D
	DEC	C		; select vram port
CLRLP:	OUT	(C),B
	DEC	DE
	LD	A,D
	OR	E
	JP	NZ,CLRLP

; mode-specific initialization
	LD	A,(CMODE)
	CP	3
	JP	Z,MODE3
	CP	2
	JP	NZ,SETREG

; initialize bitmap graphics (MODE 2)
	INC	C		; select vdp register port
	LD	B,83H		; color table register
	LD	A,0FFH		; color table at 2000H
	OUT	(C),A
	OUT	(C),B
	LD	B,84H		; pattern table register
	LD	A,3		; pattern table at 0H
	OUT	(C),A
	OUT	(C),B
	LD	DE,NAMTAB	; write to name table
	SET	6,D
	OUT	(C),E
	OUT	(C),D
	DEC	C		; select vram port
	LD	B,3		; initialize name table with 3 sets
	XOR	A		; of 256 bytes ranging from 00-FF
M2LOOP:	OUT	(C),A
	NOP			; extra time to finish vram write
	INC	A
	JP	NZ,M2LOOP
	DJNZ	M2LOOP
	JP	SETREG

; initialize multicolor graphics (MODE 3)
MODE3:	INC	C		; select vdp register port
	LD	DE,NAMTAB	; write to name table
	SET	6,D
	OUT	(C),E
	OUT	(C),D
	DEC	C		; select vram port
	XOR	A		; first section starts at 0
	LD      D,6		; nametable has 6 different sections
M3LP1:	LD      E,4		; each section has 4 identical lines
M3LP2:	PUSH	AF		; save line starting value
	LD      B,32		; each line is 32 bytes long
M3LP3:	OUT     (C),A
	NOP			; extra time to finish vram write
	INC     A
	DJNZ    M3LP3
	POP	AF		; recover line starting value
	DEC     E		; line counter
	JP      NZ,M3LP2
	ADD     A,32		; increase line's starting value
	DEC     D		; section counter
	JP      NZ,M3LP1

; set mode specific registers
SETREG:	LD	A,(CMODE)
	LD	D,0
	LD	E,A
	LD	HL,MODREG	; look up mode register values
	ADD	HL,DE
	ADD	HL,DE
	INC	C		; select vdp register port
	LD	A,(HL)		; send mode register 1
	LD	B,80H
	OUT	(C),A
	OUT	(C),B
	INC	HL		; send mode register 2
	LD	A,(HL)
	INC	B
	OUT	(C),A
	OUT	(C),B
	RET	

; Bit mask values for X coordinates 0 through 7
MASK:	DEFB 80H, 40H, 20H, 10H, 8H, 4H, 2H, 1H

; plot the pixel at X/Y coordinates
;       B = Y position
;       C = X position
BMPLOT:	LD	A,(CMODE)	; only plot in mode 2
	CP	2
	RET	NZ
	LD	A,B		; don't plot Y coord > 191
	CP	192
	RET	NC

; calculate address offset to X,Y coord in DE
	RRCA
	RRCA
	RRCA
	AND	1FH		; D = (Y / 8)
	LD	D,A
	LD	A,C		; E = (X & F8)
	AND	0F8H
	LD	E,A
	LD	A,B		; E |= (Y & 7)
	AND	7
	OR	E
	LD	E,A

; set bit in pattern table
	LD	HL,MASK		; look up bit mask in table
	LD	A,C		; from lower 3 bits of X coord
	AND	7
	LD	B,0
	LD	C,A
	ADD	HL,BC
	LD	A,(HL)		; get mask in A
	LD	BC,(VDPADR)
	INC	C		; select vdp register port
	LD	HL,PATTAB
	ADD	HL,DE
	OUT	(C),L		; set read address in pattern table
	OUT	(C),H
	DEC	C		; select vram port
	IN	B,(C)		; read previous pattern
MASKOP:	OR      B		; combine mask with previous pattern
	SET	6,H		; set write address in pattern table
	INC	C		; vdp register port
	OUT	(C),L
	OUT	(C),H
	DEC	C		; select vram port
	OUT     (C),A

; set byte in color table
	INC	C		; select vdp register port
	LD	HL,COLTAB	; add the color table base address
	ADD	HL,DE
	SET	6,H		; set write address in color table
	OUT	(C),L
	OUT	(C),H
	LD	A,(CGCOL)	; get current color
	DEC	C		; select vram port
	OUT	(C),A		; set color in color table
	RET