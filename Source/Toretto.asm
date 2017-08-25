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

BGOFFCOLOUR		= #$18 ; Dusty Desert
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
				
				; Draw Playfield begin
				ldx #SCREENHEIGHT
				
				; Only Calculate road boundries if first time
				cmp #ROADCALC, #0
				bne PrepareLV
				
				; Calcuate where the boundries to the road should be drawn
				txa
				lsr
				sta ROADCENTRE
				tay ; Can be used later! 
				
				; Work out max / 2
				lda #ROADWIDTH
				lsr
				sta ROADWIDTHHALF
				
				; Now we know outside edge will be midpoint + (max / 2)
				tya
				adc #ROADWIDTHHALF
				sta ROADTOP
				
				tya
				sbc #ROADWIDTHHALF
				sta ROADBOT
				sta CURRENTROAD
				
				; Make sure we never do that again
				lda #1
				sta ROADCALC
				
PrepareLV		
				ldy #0 ; Using to say if we should draw the midpoint of the road
LVScan
				sta WSYNC
				
				cmp #DRAWINGPF,#1
				bne DrawLogic
				lda #0
				sta PF0
				sta PF1
				sta PF2
				sta DRAWINGPF
DrawLogic
				cmp	#CURRENTROAD,x
				bne NotRoad
				
				; Draw the piece of the road
				cpy #0
				bne CentreDraw 
				
				lda #ROADBOUNDRY
				sta PF0
				sta PF1
				sta PF2
				
				; if not the centre we change BG colour
				cmp #COLUBK,#BGOFFCOLOUR
				beq DrawOnRoad
				
				; Set to off road colour
				lda #BGOFFCOLOUR
				sta COLUBK
				jmp GetRoadCentre
DrawOnRoad
				; set to on-road colour
				lda #BGONCOLOUR
				sta COLUBK
				
GetRoadCentre
				
				lda #ROADCENTRE
				sta CURRENTROAD
				ldy #1 ; Now we're drawing the centre
				jmp NotRoad
CentreDraw		

				lda #ROADPATTERN
				sta PF0
				sta PF1
				sta PF2
				ldy #0 ; No Longer drawing the centre
				lda #ROADBOT
				sta CURRENTROAD
NotRoad
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