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
;				VBLANK_NTSC
; ------------------------------------------------------------------

			; Account for 37 lines of VBLANK
			MAC VBLANK_NTSC
				; Enable VBLANK
				lda #2
				sta VBLANK

				WSYNC_FOR 37
				
				; Shift right and use new value to disable
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
;				CLEAR_PLAYER_0
; ------------------------------------------------------------------

			; Stop drawing a sprite for player zero
			MAC CLEAR_PLAYER_0
				lda #0
				sta GRP0
				sta	COLUP0
			ENDM
			
; ------------------------------------------------------------------
