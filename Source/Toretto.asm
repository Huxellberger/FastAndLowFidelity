; Toretto V0.1
; Threetee Gang (C) 2017
; NTSC Version
; Graphics Data Generated via PlayerPal v2.1 (AlienBill.com/2600/PlayerPalNext.html)

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
CURRENTPATTERN	= $87 ; Current Road Pattern
CURRENTBG		= $89 ; Current BG Colour
CURRENTCYCLE	= $90 ; Current cycle of road
CURRENTLINE		= $91 ; CurrentScanline
SPRITEY			= $92 ; Current YPos Of Sprite
SPRITEX			= $93 ; Current XPos Of Sprite
CURRENTDRAW		= $94 ; Current Sprite being drawn

; ------------------------------------------------------------------
;				Variables In ROM
; ------------------------------------------------------------------

BGOFFCOLOUR		= #$28 ; Dusty Desert
BGONCOLOUR		= #$04 ; Dark Grey
ROADCOLOUR		= #$0E ; White
ROADWIDTH		= #$50 ; Width of road
SCREENHEIGHT	= #$c0 ; Screen Height (Should be changed on PAL)
VBLANKLINES		= #$25 ; Number of lines of VBLANK (Change on PAL)
ROADCYCLE		= #$06 ; Frames before we cycle the road pattern
ROADPATTERN		= #%10101010 ; Markings on the road default pattern
PFSETTINGS		= #%00000000 ; Playfield settings for CTRLPF
PLAYERSIZE		= #$08 ; Sprite size for main player
STARTSPRITEY	= #$70 ; Location of sprite on screen at start
STARTSPRITEX	= #$0F ; Location of sprite on screen at start

;---Graphics Data for Player---

PlayerFrame0
        .byte #%01100110;$0C
        .byte #%01100110;$0C
        .byte #%11111111;$00
        .byte #%01111111;$0E
        .byte #%01111111;$00
        .byte #%01111000;$00
        .byte #%00000000;$00
        .byte #%00000000;$00
;---End Graphics Data---


;---Colour Data for Player---

PlayerColourFrame0
        .byte #$0C;
        .byte #$0C;
        .byte #$00;
        .byte #$0E;
        .byte #$00;
        .byte #$00;
        .byte #$00;
        .byte #$00;
;---End Colour Data---


; ------------------------------------------------------------------
;				System Reset
; ------------------------------------------------------------------

Start			
				CLEAN_START
				
; ------------------------------------------------------------------
;				Initialising The Game
; ------------------------------------------------------------------
				
				; Setup initial road pattern
				lda #ROADPATTERN
				sta CURRENTPATTERN
				
				; load Playfield settings
				lda #PFSETTINGS
				sta CTRLPF
				
				; Set Initial sprite position
				ldy #STARTSPRITEY
				sty SPRITEY
				
				ldx #STARTSPRITEX
				stx SPRITEX
				
; ------------------------------------------------------------------
; 				Handle VBLANK and VSYNC (NTSC)
; ------------------------------------------------------------------

NextFrame		
				VSYNC_NTSC
				
				ENABLE_VBLANK
				TIMER_SET_SCANLINE_DELAY_NTSC_VBLANK
				
				; Set Background Colour
				lda #BGOFFCOLOUR
				sta COLUBK
				sta CURRENTBG
				lda #ROADCOLOUR
				sta COLUPF
				
				; Reset sprite position
				;sta RESP0
				sta HMOVE
				
				; HANDLE INPUT BEGIN
CheckDown
				ldy SPRITEY
				lda SWCHA
				tax
				eor #%11011111
				bne CheckUp
				dey
				jmp YPosWriteback
CheckUp
				txa
				eor #%11101111
				bne CheckRight
				iny
				
YPosWriteback
				
				sty SPRITEY
				
CheckRight		
				ldx SPRITEX
				bit SWCHA
				bvs CheckLeft
				dex
				
CheckLeft
				bit SWCHA
				bmi XPosWriteback
				inx
				
XPosWriteback
				stx SPRITEX
				; HANDLE INPUT END
				
RotateRoad
				; Rotate road pattern if required (Gives illusion of movement)
				ldx CURRENTCYCLE
				dex
				bne SetupRoadside
				
				; If Equal to zero it's time to rotate the road!
				lda CURRENTPATTERN
				BITWISE_NOT
				sta CURRENTPATTERN
				
				ldx #ROADCYCLE
				
SetupRoadside
				
				stx CURRENTCYCLE
				
				; Draw Playfield begin
				ldx #SCREENHEIGHT
				
				; Only Calculate road boundries if first time
				lda ROADCALC
				cmp #0
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
				clc
				adc ROADWIDTHHALF
				sta ROADTOP
				
				tya
				sec
				sbc ROADWIDTHHALF
				sta ROADBOT
				
				; Make sure we never do that again
				lda #1
				sta ROADCALC
PrepareLV		
				lda ROADTOP
				sta CURRENTROAD
				ldy #PLAYERSIZE
				
				TIMER_WAIT
				DISABLE_VBLANK
				
; ------------------------------------------------------------------
;				Draw Playfield
; ------------------------------------------------------------------
				
				
LVScan
				sta WSYNC
				
				; Stop drawing playfield if were previously
				lda DRAWINGPF
				cmp #1
				bne DrawLogic
				lda #0
				sta PF0
				sta PF1
				sta PF2
				sta DRAWINGPF
DrawLogic
				txa
				cmp	CURRENTROAD
				bne NotRoad
				
				; Draw the piece of the road
				cmp ROADCENTRE
				beq CentreDraw 
				
				; if not the centre we change BG colour
				lda CURRENTBG
				cmp #BGOFFCOLOUR
				beq DrawOnRoad
				
				; Set to off road colour
				lda #BGOFFCOLOUR
				sta COLUBK
				sta CURRENTBG
				jmp GetRoadCentre
DrawOnRoad
				; set to on-road colour
				lda #BGONCOLOUR
				sta COLUBK
				sta CURRENTBG
				
GetRoadCentre
				
				lda ROADCENTRE
				sta CURRENTROAD
				
				jmp NotRoad
CentreDraw		
				
				lda CURRENTPATTERN ; Because load/store affects flags lots of duping done here...
				sta PF1
				BITWISE_NOT ; PF2 is reverse ordered to PF1 (as is PF0)
				sta PF0
				sta PF2
				
				lda ROADBOT
				sta CURRENTROAD
				
				lda #1
				sta DRAWINGPF
NotRoad
				
				; BEGIN DRAWING SPRITES 
				; Are we within sprite bounds?
				stx CURRENTLINE
				lda SPRITEY
				sec
				sbc CURRENTLINE
				sec
				sbc #PLAYERSIZE
				bcs EndScan
				
				; Draw a line of the sprite, after getting to correct XPos
				dey 
				beq ResetSpriteSize
				
				lda SPRITEX
				jsr SetSpriteX
				lda PlayerFrame0,y
				sta GRP0
				lda PlayerColourFrame0,y
				sta COLUP0
				jmp EndScan
				
ResetSpriteSize
				
				ldy #PLAYERSIZE
				
				CLEAR_PLAYER_0
				; END DRAWING SPRITES
				
EndScan
				
				dex
				bne LVScan
				
; ------------------------------------------------------------------
;				Handle Overscan (NTSC)
; ------------------------------------------------------------------
				
				ENABLE_VBLANK
				TIMER_SET_SCANLINE_DELAY_NTSC_OVERSCAN
				; Overscan logic
				DISABLE_VBLANK
				
; ------------------------------------------------------------------
;				Loop Back around!				
; ------------------------------------------------------------------

				jmp NextFrame
				
; ------------------------------------------------------------------
;				Subroutines				
; ------------------------------------------------------------------

				; Set Horizontal position subroutine, use to set sprite's x pos to correct value
				; INPUT: A is desired X coordinate of object, CURRENTDRAW
				; e.g DRAW = 0 is Player0, DRAW = 1 is player 2, using offset addressing.
SetSpriteX 		subroutine
				sec
.DivideLoop
				sbc #15 ; number of tv cycles during instruction
				bcs .DivideLoop
				eor #7 ; fine offset, (so we can move in smaller than 15 pixel increments
				asl
				asl
				asl
				asl
				sta HMP0, #CURRENTDRAW
				sta RESP0, #CURRENTDRAW
				rts
				
; ------------------------------------------------------------------
;				Interrupt Vector Definitions
; ------------------------------------------------------------------

				; Set start of program
				org $fffa
				.word Start ; NMI
				.word Start ; Start Vector
				.word Start ; Interrupt vector (not used)
	
; ------------------------------------------------------------------