; Toretto V0.1
; Threetee Gang (C) 2017
; NTSC Version

				processor 6502
	
				#include "vcs.h"
				#include "macro.h"
				
; ------------------------------------------------------------------
;				START ROM
; ------------------------------------------------------------------
				
				; Start Code here (Start of the ROM memory space)
				seg Code
				org $F000

; ------------------------------------------------------------------
;				Variables In RAM
; ------------------------------------------------------------------

BGCOLOUR		= #$18 ; Dusty Desert
FGCOLOUR		= #$0E ; White
ROADWIDTH		= #$80 ; Width of road

; ------------------------------------------------------------------
;				System Reset
; ------------------------------------------------------------------

Start			
				sei ; Disable interrupts (don't exist for VCS)
				cld ; Disable BCD maths mode
		
				; Load stack pointer to $FF
				ldx #$FF
				txs
		
				; Reset system to known zero state (Inluding TIA)
				lda #0
				ldy #0
ResetRAM		sta $0,x ; X is already at top of RAM space
				dex
				bne ResetRAM ; branch if not at end of memory
				
; ------------------------------------------------------------------
; 				Handle VBLANK and VSYNC (NTSC)
; ------------------------------------------------------------------

NextFrame		
				lda #2
				sta VSYNC ; Enable VSYNC
				sta VBLANK ; Enable VBLANK
				
				; Hold for first 3 scanlines (VSYNC)
				sta WSYNC ; Wait for scanline to complete (Doesn't matter what you store)
				sta WSYNC
				sta WSYNC
				lda #0
				sta VSYNC ; Now disable VSYNC
				
				; Now need to wait for recommended 37 lines (VBLANK)
				ldx #37
LVBlank
				sta WSYNC
				dex
				bne LVBlank
				
				; Can now disable VBLANK and start drawing the frame!
				lda #0
				sta VBLANK
				
; ------------------------------------------------------------------
;				Draw Playfield
; ------------------------------------------------------------------

				; 192 visible scanlines make up our frame on NTSC
				; Set Background Colour
				lda BGCOLOUR
				sta COLUBK
				
				; Draw Playfield begin
				ldx #192
LVScan
				sta WSYNC
				dex
				bne LVScan
				
				
; ------------------------------------------------------------------
;				Handle Overscan (NTSC)
; ------------------------------------------------------------------
				
				; 30 lines of VBLANK (Overscan) to complete the frame
				lda #2
				sta VBLANK
				ldx #30
LVOver
				sta WSYNC
				dex
				bne LVOver
				
; ------------------------------------------------------------------
;				Loop Back around!				
; ------------------------------------------------------------------

				jmp NextFrame
				
; ------------------------------------------------------------------
;				Interrupt Vector Definitions
; ------------------------------------------------------------------

				; Set start of program
				org $fffa
				.word Start ; NMI
				.word Start ; Start Vector
				.word Start ; Interrupt vector (not used)
	
; ------------------------------------------------------------------