; 	Simple ZX Next Tile Map Example
;	em00k20 / David Saphier 

tilemapFF	EQU $f 
tileimages	EQU $10

	device zxspectrumnext 

	include "macros.asm"
	
	org 8000h

;====================================================

start:
		ei
		
		call initSetup					; setup
		call InitTileMap				; initalise tilemap 
		call loadmapdata				; load the tilemap + bitmap
		call drawfullmap				; draw entire screen 
		
gameloop:
		
		halt
		call scrolltilemapright			; scroll 1px to right 
		
		jp gameloop


;====================================================

initSetup:
		nextreg_nn $15,%01000011		; sets SLU
		nextreg_nn $7,3					; 28mhz
		nextreg_nn $8,%11011010			; contention etc 
		ret 
		
InitTileMap:

		call SetPalette
		;loadfile tilebitmap, $6000 , 4096 
		nextreg $57,tileimages 
		ld hl,$e000 : ld de,$6000 : ld bc,2048 : ldir 
		
		nextreg_nn $6b,%10100001 : nextreg_nn $6c,0
		nextreg_nn $6e,$40 : nextreg_nn $6f,$60 	; tileadd + bitmap 
		nextreg_nn $68,%10000000 : nextreg_nn $43,%00110000 
		xor a : nextreg_a $14 : nextreg_a $4c :  nextreg_a $30 :  nextreg_nn $31,240
		call ClearTilemap
		ClipTile 4,154,0,255
		ret 
		
ClearTilemap:
		ld hl,$4000 : ld de,$4001 : ld (hl),0 : ld bc,80*40 : ldir 
		ret 

SetPalette: 							; set tilemap palette 
		ld hl,tilepalette : nextreg_nn $43,%00110000
		ld bc,0
Uploadpal:
		ld a,b : nextreg_a $40 : inc b 
		ld a,(hl) : nextreg_a $41 : inc hl : ld a,(hl) : nextreg_a $41
		inc hl : ld a,b : or a : jp nz,Uploadpal
		ret 

loadmapdata:
		;loadfile tilemap, $e000 , 6144
		nextreg $57,tilemapFF
		ret 

drawfullmap:		
		ld hl,$e000 					; this is the map data 
		ld de,$4000						; start of screen tilemap 
		ld c,25 						; height 
		
foryloop:		
		ld b,40							; width 
		
forxloop:		
			ld a,(hl) : ld (de),a 		; copy tile 
			inc hl : inc de 
		djnz forxloop
			inc h
offset:			
			ld l,0
			dec c : ld a,c : or a
		jr nz,foryloop
		ret 

mapright:
		ld hl,$4001 : ld de,$4000 : ld bc,968 : ldir 
		ld de,$4028 : ld hl,$e000 : ld a,(offset+1) : add $28 : ld l,a
		
		ld b,25
.mrlp:	ld a,(hl) : ld (de),a :	inc h : add de,40
		djnz .mrlp
		
		ld hl,offset+1 : inc (hl) : ld a,(hl) : cp 255-40 : jp z,resetoffset	
		ret 
		
resetoffset:
		xor a : ld (offset+1),a 
		ret

scrolltilemapright:
		ld b,8
scrolloop:
		dec b : jp z,resetscrolloffest	
		ld a,8 : sub b : nextreg_a $30
		ld a,b : ld (scrolltilemapright+1),a 
		ret 
		
resetscrolloffest
		xor a : nextreg_a $30
		call mapright
		ld a,8 : ld (scrolltilemapright+1),a 
		ret 
		
RasterWait:
		push bc 
		ld e,190 : ld a,$1f : ld bc,$243b : out (c),a : inc b
		
.waitforlinea:	
		in a,(c) : cp e : jr nz,.waitforlinea		
		pop bc 
		ret 

;====================================================


	include "esxdos.asm" 

;====================================================

tilepalette	
	incbin 		"./assets/MM.pal",0					; palette 
	
	slot 7 												; slot 7 is mmu 7 @ 0xe000..0xffff
	page tilemapFF : org $e000	
tilemap		
	incbin 		"./assets/lev1part1.map",0			; 6144 tilemap 
	
	page tileimages : org $e000	
tilebitmap	
	incbin 		"./assets/mm.til",0					; tile bitmap 4bit 

;====================================================

	savenex open "tilemap.nex", start , $bffe
    savenex core 3, 0, 0      
    savenex cfg  0, 0            
    savenex auto
    savenex close    
