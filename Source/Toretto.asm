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
				
				
; ------------------------------------------------------------------
;				Variables In RAM
; ------------------------------------------------------------------

				; Start Code here (Start of the ROM memory space)
				seg.u Variables
				org $80 ; (Start of RAM)
				
ROADTOP			byte ; Top of road
ROADBOT			byte ; Bottom of road
ROADCENTRE		byte ; Centre line of road
ROADWIDTHHALF	byte ; Half of RoadWidth
CURRENTROAD		byte ; Shadow of what a is holding when drawing the road
CURRENTPATTERN	byte ; Current Road Pattern
CURRENTBG		byte ; Current BG Colour
CURRENTCYCLE	byte ; Current cycle of road
CURRENTLINE		byte ; CurrentScanline
SPRITEY			byte ; Current YPos Of Sprite
SPRITEX			byte ; Current XPos Of Sprite
TEMPSPRITEY		byte ; TempStorage of YPos
NEXTNOTE		byte ; Current note to play
TIMETILLCHANGE	byte ; How long until we need to change the note again

; ------------------------------------------------------------------
;				Variables In ROM
; ------------------------------------------------------------------

				; Start Code here (Start of the ROM memory space)
				seg Code
				org $F000
				
BGOFFCOLOUR		= #$28 ; Dusty Desert
BGONCOLOUR		= #$04 ; Dark Grey
ROADCOLOUR		= #$0E ; White
ROADWIDTH		= #$50 ; Width of road
SCREENHEIGHT	= #$c0 ; Screen Height (Should be changed on PAL)
VBLANKLINES		= #$25 ; Number of lines of VBLANK (Change on PAL)
ROADCYCLE		= #$06 ; Frames before we cycle the road pattern
ROADPATTERN		= #%10101010 ; Markings on the road default pattern
PFSETTINGS		= #%00000000 ; Playfield settings for CTRLPF
PLAYERSIZE		= #$07 ; Sprite size for main player
STARTSPRITEY	= #$B0 ; Location of sprite on screen at start
STARTSPRITEX	= #$0F ; Location of sprite on screen at start
SONGLENGTH		= #$08 ; Number of notes in the song
SONGTEMPO		= #$0a ; How often we change notes in the song
SONGVOLUME		= #$8 ; Song Volume
;---Graphics Data for Player---

PlayerFrame0
        .byte #0 ; Padding
        .byte #%01100110;$02
        .byte #%01100110;$02
        .byte #%01111111;$00
        .byte #%01111111;$00
        .byte #%01111111;$0E
        .byte #%00111100;$00
        .byte #%00111100;$00
;---End Graphics Data---

;---Color Data for Player---

PlayerColourFrame0
        .byte #$FF; Black
        .byte #$02;
        .byte #$02;
        .byte #$00;
        .byte #$00;
        .byte #$0E;
        .byte #$00;
        .byte #$00;
;---End Color Data---

; SongControl Data

SongControlData
		.byte #15
		.byte #12
		.byte #14
		.byte #8
		.byte #15
		.byte #12
		.byte #14
		.byte #8
; End SongControl Data

; SongFrequency Data

SongFrequencyData
		.byte #15
		.byte #12
		.byte #14
		.byte #8
		.byte #15
		.byte #12
		.byte #2
		.byte #9
; End SongPitch Data


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
				
				; Calcuate where the boundries to the road should be drawn
				lda #SCREENHEIGHT
				lsr
				sta ROADCENTRE
				tay ; Can be used later! 
				
				; Work out max / 2
				lda #ROADWIDTH
				ldx #0
				jsr InitialiseRoad
				
				; Set music volume
				lda #SONGVOLUME
				sta AUDV0
				
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
				
				; Set new sprite position
				lda SPRITEX
				ldx #0
				jsr SetSpriteX
				
				; Reset sprite position
				sta WSYNC
				sta HMOVE
				
				lda SPRITEY
				sta TEMPSPRITEY
				
				; Update music
				jsr UpdateMusic
RotateRoad
				; Rotate road pattern if required (Gives illusion of movement)
				ldx CURRENTCYCLE
				dex
				bne PrepareLV
				
				; If Equal to zero it's time to rotate the road!
				lda CURRENTPATTERN
				BITWISE_NOT
				sta CURRENTPATTERN
				
				ldx #ROADCYCLE
PrepareLV		
				stx CURRENTCYCLE
				
				; Reset first bg change to consider
				ldx #SCREENHEIGHT
					
				lda ROADTOP
				sta CURRENTROAD
				
				TIMER_WAIT
				
				; Make sure kernal draw loop starts at the correct time
				sta WSYNC
				DISABLE_VBLANK
				SLEEP #31
				
; ------------------------------------------------------------------
;				Draw Playfield
; ------------------------------------------------------------------
						
LVScan
				sta WSYNC
				
				; Reset Drawing of playfield
				lda #0
				sta PF0
				sta PF1
				sta PF2
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
NotRoad
				jsr DrawSprite
EndScan
				dex
				bne LVScan
				
; ------------------------------------------------------------------
;				Handle Overscan (NTSC)
; ------------------------------------------------------------------
				
				ENABLE_VBLANK
				TIMER_SET_SCANLINE_DELAY_NTSC_OVERSCAN
				
				; Handle Input
				jsr HandleInput
				
				DISABLE_VBLANK
				
; ------------------------------------------------------------------
;				Loop Back around!				
; ------------------------------------------------------------------

				jmp NextFrame
				
; ------------------------------------------------------------------
;				Subroutines				
; ------------------------------------------------------------------

; ------------------------------------------------------------------
;				DrawSprite				
; ------------------------------------------------------------------

				; Draw a sprite at a given offset.
				; A is Y position of sprite, x is current Scanline
				; y is the line offset
DrawSprite		subroutine
				
				; Are we within sprite bounds?
				lda #PLAYERSIZE ; height in 2xlines
				sec
				isb TEMPSPRITEY	; INCs TEMP and then subtracts it from a (so we only draw it when we're at the right pos)
				bcs .SpriteDrawVal ; inside bounds?
				lda #0	; Use padding value so we draw nothing when we don't want to show the sprite
				; Sync and store sprite values
.SpriteDrawVal	
				tay
				lda PlayerFrame0,y
				sta GRP0
				lda PlayerColourFrame0,y
				sta COLUP0
				rts				

; ------------------------------------------------------------------
;				SetSpriteX				
; ------------------------------------------------------------------

				; Set Horizontal position subroutine, use to set sprite's x pos to correct value
				; INPUT: A is desired X coordinate of object, x is current sprite by offset
				; e.g DRAW = 0 is Player0, DRAW = 1 is player 2, using offset addressing.
SetSpriteX 		subroutine
				sta WSYNC ; Start a new line for right offset
				bit 0 ; waste 3 cycles of HBLANK
				sec
.DivideLoop
				sbc #15 ; number of tv cycles during instruction
				bcs .DivideLoop
				eor #7 ; fine offset, (so we can move in smaller than 15 pixel increments)
				asl
				asl
				asl
				asl
				sta HMP0,x ; Course position
				sta RESP0,x ; Fine offset
				rts
				
; ------------------------------------------------------------------
;				InitialiseRoad			
; ------------------------------------------------------------------

				; SetInitialRoad position
				; Calculate where all the road boundries should be based on Initial height
				; First bit will be repeated for multiple roads but it's not a big deal right now
				; A is road width, x is the offset to store to and y is the midpoint
InitialiseRoad	subroutine
				
				lsr
				sta ROADWIDTHHALF,x
				
				; Now we know outside edge will be midpoint + (max / 2)
				tya
				clc
				adc ROADWIDTHHALF,x
				sta ROADTOP,x
				
				tya
				sec
				sbc ROADWIDTHHALF,x
				sta ROADBOT,x
				rts
				
; ------------------------------------------------------------------
;				HandleInput			
; ------------------------------------------------------------------

				; Function to handle all the inputs in a standard Toretto Game
HandleInput		subroutine

				; Up and down are reversed
CheckDown
				ldy SPRITEY
				lda SWCHA
				tax
				eor #%11101111
				bne CheckUp
				cpy #254 ; Stop wrapping
				bcs CheckUp
				iny
				jmp YPosWriteback
CheckUp
				txa
				eor #%11011111
				bne CheckRight
				cpy #73 ; Stop wrapping
				bcc CheckRight
				dey
				
YPosWriteback
				sty SPRITEY
CheckRight		
				ldx SPRITEX
				bit SWCHA ; right and left stored in the top two bits so can be cheeky like this
				bmi CheckLeft
				cpx #130 ;Stop wrapping
				bcs CheckLeft
				inx
CheckLeft
				bit SWCHA
				bvs XPosWriteback
				cpx #1 ;Stop wrapping
				bcc XPosWriteback
				dex
XPosWriteback
				stx SPRITEX
				rts
				
; ------------------------------------------------------------------
;				Update Music			
; ------------------------------------------------------------------

				; Function to update the music
UpdateMusic		subroutine

				; Only change note when the tempo allows
				ldx TIMETILLCHANGE
				dex
				bne .WrTempoChange
				ldx #SONGTEMPO
				
				; Check which note to play
				ldy NEXTNOTE
				; Finally, write new song values
				lda SongControlData,y
				sta AUDC0
				lda SongFrequencyData,y
				sta AUDF0
.WrNoteChange
				; Make sure we're not going out of bounds
				iny
				cpy #SONGLENGTH
				bne .NotSongEnd
				ldy #0
.NotSongEnd
				sty NEXTNOTE
.WrTempoChange	
				stx TIMETILLCHANGE
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