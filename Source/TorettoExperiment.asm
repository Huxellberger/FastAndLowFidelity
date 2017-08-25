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

ROADTOP			= $80 ; Top of road
ROADBOT			= $81 ; Bottom of road
ROADCENTRE		= $82 ; Centre line of road
ROADCALC		= $83 ; Have we calculated the road?
ROADWIDTHHALF	= $84 ; Half of RoadWidth
DRAWINGPF		= $85 ; Currently Drawing the playfield
CURRENTROAD		= $86 ; Shadow of what a is holding when drawing the road

; ------------------------------------------------------------------
;				Variables In ROM
; ------------------------------------------------------------------

BGOFFCOLOUR		= #$28 ; Dusty Desert
BGONCOLOUR		= #$06 ; Dark Grey
FGCOLOUR		= #$0E ; White
ROADWIDTH		= #$80 ; Width of road
SCREENHEIGHT	= #192 ; Screen Height (Should be changed on PAL)
ROADPATTERN		= #%00110011 ; Markings on the road default pattern
ROADBOUNDRY		= #%11111111 ; Road Boundry

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
				lda #BGOFFCOLOUR
				sta COLUBK
				lda #FGCOLOUR
				sta COLUPF
				
				ldy #0
				
LVScan
				sta WSYNC
				
				cpy #5
				bne DrawBlank
				lda #ROADPATTERN
				sta PF0
				sta PF1
				sta PF2
				ldy #0
				jmp EndDraw
DrawBlank
				lda #0
				sta PF0
				sta PF1
				sta PF2
				
EndDraw
				iny
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