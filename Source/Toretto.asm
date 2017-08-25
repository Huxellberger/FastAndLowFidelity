; Toretto V0.1
; Threetee Gang (C) 2017
; NTSC Version

				processor 6502
	
				#include "vcs.h"
				#include "macro.h"
				#include "ThreeteeSML.h"
				
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
				CLEAN_START
				
; ------------------------------------------------------------------
; 				Handle VBLANK and VSYNC (NTSC)
; ------------------------------------------------------------------

NextFrame		
				VSYNC_NTSC
				VBLANK_NTSC
				
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
				
				OVERSCAN_NTSC
				
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