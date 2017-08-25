; ThreeteeSML.h
; Macro Library for all the typical Macros you might want to use in a program
; Threetee Gang (C) 2017

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
				ldx #37
				lda #2
				sta VBLANK
.VBLANTSC		
				; Wait it out
				sta WSYNC
				dex
				bne .VBLANTSC
				
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
				ldx #37
				lda #2
				sta VBLANK
				
.VOVERSC		
				; Wait it out
				sta WSYNC
				dex
				bne .VOVERSC
				
				; Shift right and use new value to disable
				lsr
				sta VBLANK
			ENDM
			
; ------------------------------------------------------------------
