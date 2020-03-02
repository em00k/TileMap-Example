	
load:
	
	push de  
	push bc 
	ld a, '*' 				; use current drive
	ld b, FA_READ 			; set mode
	;ld ix, fname 			; filename in ix

	ESXDOS F_OPEN
	ret c 					; return if failed
	
	ld (handle), a 			; store handle
	ld l, 0 				; seek from start of file
	ld bc, 0
	ld de,0
	ESXDOS F_SEEK
	
	ld a, (handle) 			; restore handle

	pop bc 
	pop ix 
	;ld ix,16384 				; memory dest
	;ld bc,6912					; read length 
	ESXDOS F_READ

	ld a, (handle)
	ESXDOS F_CLOSE 			; close file
	
	ret

handle: db 0
	
	