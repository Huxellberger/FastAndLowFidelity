; ThreeteeSML.h
; Macro Library for all the typical Macros you might want to use in a program
; Threetee Gang (C) 2017

; Some notes about macros: . Signifies not to duplicate tag (e.g generates a new one for each use of the macros
; Look at WSYNC_FOR to see how to handle errors

; ------------------------------------------------------------------
;				WSYNC_FOR
; ------------------------------------------------------------------

			;WSYNC for a number of cycles
			MAC WSYNC_FOR
.WSYNC_IT		SET {0}

				IF .WSYNC_IT < 2
					ECHO "MACRO ERROR: 'Should Be using for values > 1"
					ERR
				ENDIF
				
				ldx #.WSYNC_IT

.WSYNC_DEL
				sta WSYNC
				dex
				bne .WSYNC_DEL
			ENDM

; ------------------------------------------------------------------
;				VSYNC_NTSC
; ------------------------------------------------------------------

			; Account for 3 scanlines of VSYNC
			MAC VSYNC_NTSC
				; Enable VSYNC
				lda #2
				sta VSYNC 
				
				; Wait it out
				sta WSYNC
				sta WSYNC
				sta WSYNC
				
				; Shift right and use new value to disable
				lsr
				sta VSYNC
			ENDM
			
; ------------------------------------------------------------------
;				ENABLE_VBLANK
; ------------------------------------------------------------------

			; Enable VBLANK
			MAC ENABLE_VBLANK
				lda #2
				sta VBLANK
			ENDM
			
; ------------------------------------------------------------------
;				DISABLE_VBLANK
; ------------------------------------------------------------------

			; Disable VBLANK
			MAC DISABLE_VBLANK
				lda #1
				sta VBLANK
			ENDM
			
; ------------------------------------------------------------------
;				VBLANK_NTSC
; ------------------------------------------------------------------

			; Account for 37 lines of VBLANK
			MAC VBLANK_NTSC
				ENABLE_VBLANK

				WSYNC_FOR 37
				
				; Shift right and use new value to disable
				; know a is 2 from enable
				lsr
				sta VBLANK
			ENDM
			
; ------------------------------------------------------------------
;				OVERSCAN_NTSC
; ------------------------------------------------------------------

			; Account for 30 lines of VBLANK (Overscan)
			MAC OVERSCAN_NTSC
				; Enable VBLANK
				lda #2
				sta VBLANK
				
				WSYNC_FOR 30
				
				; Shift right and use new value to disable
				lsr
				sta VBLANK
			ENDM
			
; ------------------------------------------------------------------
;				BITWISE_NOT
; ------------------------------------------------------------------

			; Use EOR for a bitwise not operation
			; Sets value in acc to bitwise not of prior value
			MAC BITWISE_NOT
				eor #$FF
			ENDM
			
; ------------------------------------------------------------------
;				MUL
; ------------------------------------------------------------------

			; Function to multiply two numbers
			; buggers a bunch of register values so be prepared for that
			; XInput is current acc value
			; ouput is in acc
			; if overflows that's stored in x
			MAC MUL
.YMULVAL		SET {1}
				
				ldx #0
				ldy #.YMULVAL
				sta .YMULVAL
.MULBRA
				clc
				adc #.YMULVAL
				bvc .MULNOOVER
				inx
.MULNOOVER
				dey
				bne .MULBRA
			ENDM
			
; ------------------------------------------------------------------
;				DIV_INT
; ------------------------------------------------------------------

			; Function to divide two numbers
			; buggers a bunch of register values so be prepared for that
			; X Input is current acc value
			; ouput is in acc
			; X is used as overflow count
			MAC DIV_INT
.YDIVVAL		SET {1}

				ldy #0
.DIVBRA
				iny
				sec
				sbc #.YDIVVAL
				bpl .DIVBRA
				cpx #0
				beq .DIVEND
				dex
				jmp .DIVBRA
.DIVEND
				tya
			ENDM
			
; ------------------------------------------------------------------
;				CLEAR_PLAYER_0
; ------------------------------------------------------------------

			; Stop drawing a sprite for player zero
			MAC CLEAR_PLAYER_0
				lda #0
				sta GRP0
				sta	COLUP0
			ENDM
			
; ------------------------------------------------------------------
;				TIMER_SET_SCANLINE_DELAY_NTSC
; ------------------------------------------------------------------

			; Macro to delay for a certain number of Scanlines
			; Can be used to execute logic in VBLANK and overscan before we need to drawing
			; Needs pairing with TIMER_WAIT at the end
			; Formula used is (N*76 + 13)/64 (64 cycle timer, 13 cycles to use timer and N is number of scanlines)
			; 76 is the cycles for a normal scanline to complete
			; should be 44 for NTSC VBLANK
			MAC TIMER_SET_SCANLINE_DELAY_NTSC
.NUM_SCANLINES	SET {0}

				IF .NUM_SCANLINES < 2
					ECHO "MACRO ERROR: 'Just use WSYNC for values less than 2!"
					ERR
				ENDIF
				
				lda #.NUM_SCANLINES
				MUL #76
				adc #13
				DIV_INT #64
				
				sta TIM64T
			ENDM
			
; ------------------------------------------------------------------
;				TIMER_WAIT
; ------------------------------------------------------------------

			; Macro to wait for timer delay to run down
			MAC TIMER_WAIT
.TIMERWAITCONT
				lda INTIM
				bne .TIMERWAITCONT
			ENDM
			
; ------------------------------------------------------------------
