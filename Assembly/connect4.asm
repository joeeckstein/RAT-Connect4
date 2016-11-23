;RAT CONNECT 4
;CPE 233 Winter 2016 Cal Poly
;Joe Eckstein
;Brenan Balbido
;Michael Le

.EQU input 		= 0x20		;Switches

.EQU player 	= 0x81		;SSEG
.EQU column_out = 0x25		;Unused
.EQU somePort  	= 0x15
.EQU VGA_HADD  	= 0x90		;VGA High Address Out
.EQU VGA_LADD  	= 0x91		;VGA Low  Address Out
.EQU VGA_COLOR 	= 0x92		;VGA Color/Enable Out
.EQU X_CONVERT 	= 0x93		;Grid Xcoordinate Out
.EQU Y_CONVERT 	= 0x94		;Gird Ycoordiante Out
.EQU CONV_HADD 	= 0x95		;First Pixel High Out
.EQU CONV_LADD 	= 0x96		;First Pixel Low  Out

;r0	 Low Display Address
;r1	 High Display Address
;r2	 Color Data
;r3	 Draw Counter 1
;r4	 Draw Counter 2
;r5	 X coordinate of piece
;r6	 Y coordinate of piece
;r7	 RAM Location of piece
;r8	 RAM Location of piece scratch
;r9	 RAM Player	  of piece
;r10 Player Turn
;r11 Invalid Piece Counter

.CSEG
.ORG		0x10				; data starts here


;Draws Game Board and Background
init:		MOV r0, 0xFF		; Low  Address
			MOV r1, 0x00		; High Address
			MOV r2, 0xFF		; Background Color
			MOV r3, 0x00
bgdraw:		CALL draw			; Pushes to Frame Buffer
			ADD r0, 0x01		; Moves to next pixel
			CMP r0, 0xFF		; Checks if LADD needs to overflow
			BRNE bgdraw
			ADD r1, 0x01		; Increments the HADD
			CMP r1, 0x0F		; Not an efficient program, but only runs on boot
			BRNE bgdraw			; and does not take up much progrom
boarddraw:	MOV r2, 0x03		; Draws Game Board
			MOV r0, 0xFF
			MOV r1, 0x00
			MOV r3, 0x00
level1:		CALL drawgrid		; draw a gridline starting in row 0
			CMP r3, 0x08		; check if number of gridlines has been hit
			BRNE level1
			ADD r0, 0x18		; move on to next row
			MOV r3, 0x00		; init counter
			CMP r0, 0xFF		; check if row 3 is filled
			BRNE level1
			MOV r0, 0x03		; init location, must do manual rollover
			MOV r1, 0x01		; manual rollover
			CALL drawline1		; draw first horizontal line
			MOV r0, 0x3F
			MOV r3, 0x00
level2:		CALL drawgrid		; draw first set of gridlines
			CMP r3, 0x08
			BRNE level2
			ADD r0, 0x18
			MOV r3, 0x00
			CMP r0, 0xFF
			BRNE level2			; this check will not take us through the entire next set,
			MOV r1, 0x02		; but requires us to manually roll over the register.
			MOV r3, 0x00		; now we fill the last line with an increased msb
level2b:	CALL drawgrid		; this code was created without realizing that the use of
			CMP r3, 0x08		; the ADDC instruction would have greatly reduced the
			BRNE level2b		; complexity, however it works, so it stays
			MOV r0, 0x43
			CALL drawline1
			MOV r0, 0x7F
			MOV r3, 0x00
level3:		CALL drawgrid
			CMP r3, 0x08
			BRNE level3
			ADD r0, 0x18
			MOV r3, 0x00
			CMP r0, 0xFF
			BRNE level3
			MOV r0, 0xFF
			MOV r1, 0x03
			MOV r3, 0x00
level3b:	CALL drawgrid
			CMP r3, 0x08
			BRNE level3b
			MOV r3, 0x00
			ADD r0, 0x18
			CMP r0, 0x7F		; Code continues and is complex due to forgetting
			BRNE level3b		; that the ADDC instruction exists
			MOV r0, 0x83		; ADDC is utilized in later parts of the program
			CALL drawline1
			MOV r0, 0xBF
			MOV r3, 0x00
level4:		CALL drawgrid
			CMP r3, 0x08
			BRNE level4
			ADD r0, 0x18
			MOV r1, 0x04
			MOV r3, 0x00
level4b:	CALL drawgrid
			CMP r3, 0x08
			BRNE level4b
			MOV r3, 0x00
			ADD r0, 0x18
			CMP r0, 0xBF
			BRNE level4b
			ADD r0, 0x04
			CALL drawline1
			MOV r0, 0xFF
			MOV r3, 0x00
			MOV r1, 0x05
level5:		CALL drawgrid
			CMP r3, 0x08
			BRNE level5
			ADD r0, 0x18		; move on to next row
			MOV r3, 0x00		; init counter
			CMP r0, 0xFF
			BRNE level5
			MOV r1, 0x06
			MOV r0, 0x03
			CALL drawline1
			MOV r0, 0x3F
			MOV r3, 0x00
level6:		CALL drawgrid
			CMP r3, 0x08
			BRNE level6
			ADD r0, 0x18
			MOV r3, 0x00
			CMP r0, 0xFF
			BRNE level6
			MOV r1, 0x07
			MOV r3, 0x00
level6b:	CALL drawgrid
			CMP r3, 0x08
			BRNE level6b
			MOV r0, 0x43
			CALL drawline1

			MOV r10, 0x01		; sets initial player turn
			OUT r10, player		; displas initial player
			SEI

main:		SEI					; check input
			BRN main

render:		OUT r10, player		; displayers which player is active
			OUT r5,  X_CONVERT	; passes x coordinate of grid to decoder
			OUT r6,  Y_CONVERT	; passes y coordinate of grid to decoder
			IN  r0,  CONV_HADD	; receives VGA address-HIGH from decoder
			IN  r1,  CONV_LADD	; receives VGA address-LOW  from decoder
			CMP r10, 0x01		; checks which player is active
			BRNE play2draw		; changes color of the piece to reflect player
			MOV r2,  0x0F
			BRN play1draw
play2draw: 	MOV r2,  0xF0
play1draw: 	CALL squaredraw
			RET

isr:		CALL placePiece		; places a piece into memory
			CALL render
			CMP r11, 0x01
			BRCS turn			; changes turn after every interrupt
			RETID

; ---------- change turn methods ----------
turn:		CMP r10, 0x02		; no carry -> player 1
								; carry -> player 2
			BRCC p2p1			; player 2 to player 1
			BRCS p1p2			; player 1 to player 2
			RET
			
p2p1:		MOV r10, 0x01		; active player placed in r10
			RET

p1p2:		MOV r10, 0x02		; active player placed in r10
			RET
; -----------------------------------------

; ---------- place piece methods ---------
placePiece:	MOV r5, 0x00		; "Do not assume anything Obi-wan.
			MOV r6, 0x00		; Clear your mind must be
			MOV r7, 0x00		; if you are to discover
			MOV r8, 0x00		; the real villains behind this plot."
			MOV r9, 0x00		; - Yoda
			
			MOV r11, 0x00		; if 0x01, then you placed an invalid piece

			IN r5, input		; x coordinate of next piece
			CALL validX			; checks if value in r5 <= 7
			OUT r5, column_out
			
			CALL getRAMLoc		; returns r7 as RAM loc of valid slot
			
			CMP r11, 0x01
			BRCS loadPiece
			
			RET

loadPiece:	ST r10, (r7)		; loads the piece into loc given by r7
								; piece given by the identity of player, r10
			RET
			
getRAMLoc:	MOV r7, 0x00		; r7 will change based on x-coord, y-coord
								; 0x(x-coord)(y-coord)
			SUB r7, 0x10		; so that things start at 0
			MOV r8, 0xFF
			CALL convertX		; places x-coord into r7
			SUB r7, 0x01		; so that things start at 0 
			CALL convertY		; places y-coord into r7
			RET

convertX:	ADD r8, 0x01
			ADD r7, 0x10
			CMP r8, r5
			BRCS convertX
			RET

convertY:	ADD r6, 0x01
			ADD r7, 0x01
			LD  r9, (r7)		; checking RAM at loc given by r7, placed into r9
								; r9 given by 0x(x-coord)(y-coord)
			CMP r9, 0x01
			BRCC convertY
			CALL validY
			RET

validX:		CMP r5, 0x08
			BRCC invalidXY		; returns to main if input x > 7
			RET

validY:		CMP r6, 0x07
			BRCC invalidXY		; return to main if y > 6
			RET

invalidXY:	MOV r11, 0x01
			RET
			
drawgrid:	ADD r0, 0x05
			CALL draw
			ADD R3, 0x01		; increment the counter
			RET

drawline1:	MOV r3, 0x00
drawlineb:	ADD r0, 0x01		; draws starting at the pixel+1 
			CALL draw			; and draws 35 pixels horizontally
			ADD r3, 0x01
			CMP r3, 0x24
			BRNE drawlineb
			RET

; draws a square starting with pixel given
; feed it the upper left coordinate and it will draw the game piece
; feed the color of segment in first before calling this function

squaredraw: MOV	 R3, 0x00
			MOV	 R4, 0x00
squared2:	CALL draw
			ADD	 R0, 0x01
			ADD	 R3, 0x01
			CMP	 R3, 0x04
			BRNE squared2
			ADD	 R0, 0x3C
			ADDC R1, 0x00
			ADD	 R4, 0x01
			MOV	 R3, 0x00
			CMP	 R4, 0x04
			BRNE squared2
			RET

; Outputs the VGA Data to the display
draw:		OUT r0, VGA_LADD
			OUT r1, VGA_HADD
			OUT r2, VGA_COLOR
			RET
; -----------------------------------------

.ORG 0x3FF
			BRN isr
