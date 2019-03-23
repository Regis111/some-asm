stos1 segment stack
        dw 200 dup (?)
wstosu  dw ?
stos1 ends                            

data1 segment
    nazwa           	db  "FLAG.bmp",0
	handle          	dw  ?
	
	curr_y         		dw  ?
	
	real_x          	dw  ?
	real_y          	dw  ?
	
	omijane_wiersze 	dw  0
	
	omijane_kolumny 	dw  0
	
	poz_curr_1bajta		dd	?
	
	poz_curr_ostbajta	dd	?
	
	x0					dw	?
	y0					dw	?
	
	
	omijane_bajty		dw	0
	ominiete_wiersze	dw	0
	
	numer_koloru    	db  ?
	
	adres           	dw  ?
	
	buf             	db  200 dup(?)
	
	size_hd         	dw  ?
	
	size_x				dw  ?
	size_y				dw  ?
	
	real_x1				dw	?
	real_y1				dw	?
	
	bpp					db  ?
	            
	b               	db  ?
	g               	db  ?
	r               	db  ?
	
data1 ends

code1 segment
start:	
	mov sp, offset wstosu
	mov ax, seg wstosu
	mov ss, ax
	
	mov al, 13h
	xor ah, ah
	int 10h							;wlaczenie trybu graficznego
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	mov ax, seg nazwa
	mov ds, ax
	mov dx, offset nazwa
	mov ax, 3d00h 
	int 21h
	mov word ptr ds:[handle], ax      ;otwarcie pliku handle == file handle 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov dx, offset buf
	mov ax, seg buf
	mov ds, ax
	mov cx, 200
	mov bx, word ptr ds:[handle]
	xor al, al
	mov ah, 3fh
	int 21h							;przeczytanie wstepu do bufora
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	mov al, byte ptr ds:[buf+18]
	mov ah, byte ptr ds:[buf+19]
	mov word ptr ds:[size_x], ax
	
	mov al, byte ptr ds:[buf+22]
	mov ah, byte ptr ds:[buf+23]
	mov	word ptr ds:[size_y], ax
	
	mov al, byte ptr ds:[buf+28]
	mov byte ptr ds:[bpp], al       		;przeczytanie z bufora wielkosci i bpp           
	
	mov al, byte ptr ds:[buf+14]
	mov byte ptr ds:[size_hd], al
	mov byte ptr ds:[size_hd+1], 0
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	cmp word ptr ds:[size_y], 200
	ja skroc_ilosc_wierszy
	jbe nie_skracaj_wierszy

reszta1:	
	
	cmp word ptr ds:[size_x], 320
	ja skroc_ilosc_kolumn
	jbe nie_skracaj_kolumn
	
reszta2:
	
    mov bx, ds:[handle]
    mov ax, 13
    mov dx, word ptr ds:[size_hd]
    add dx, ax 
    xor cx, cx
    mov ax, 4200h
    int 21h
    
	;call wyznacz_poz_bajta
	;mov word ptr ds:[poz_1_bajta], dx
	;mov word ptr ds:[poz_1_bajta+2], ax
	
omin_wiersze:                                 
    
	mov bx, ds:[handle]
    mov dx, 3
    mov ax, word ptr ds:[omijane_wiersze]
	mul dx
    mov dx, word ptr ds:[size_x]
    mul dx
    mov cx, dx
    mov dx, ax
    mov ax, 4201h
    int 21h                            
	
omin_bajty:
	
	nop
	mov bx, ds:[handle]
	xor cx, cx
	mov dx, ds:[omijane_bajty]
	mov ax, 3
	mul dx
	mov dx, ax
	mov ax, 4201h
	int 21h
	nop
	
print:
    mov cx, 200 ;; wykonywac real_y razy
    petla0:
        mov word ptr ds:[curr_y], cx
        push cx
        mov cx, 320
        petla1:                  		;; wykonywac real_x razy
            
			mov ax, word ptr ds:[y0]
			mov bx, word ptr ds:[curr_y]
			dec bx
			cmp ax, bx
			jb na_czarno
			sub ax, word ptr ds:[real_y]
			inc ax
			cmp ax, bx
			ja na_czarno
			
			mov bx, 320
			sub bx, cx
			mov ax, 0
			cmp ax, bx
			ja na_czarno
			add ax, word ptr ds:[real_x]
			cmp ax, bx
			jbe na_czarno
			
            call przeczytaj_BGR
            call oblicz_bajt
			
			continue:
			call oblicz_adres    		;;oblicz adres bajtu i wstaw do si
            call zaswiec_punkt                          
        loop petla1
        
        xor cx, cx                                        
        mov bx, ds:[handle]
        mov ax, word ptr ds:[omijane_kolumny]
        mov dx, 3
		mul dx
		mov dx, ax
		mov ax, 4201h
        int 21h                                 ;przesun o [omijane_kolumny]
        pop cx
		
    loop petla0
	
	;call wyznacz_poz_bajta
    ;mov word ptr ds:[poz_curr_ostbajta], dx
	;mov word ptr ds:[poz_curr_ostbajta+2], ax
	
czekaj:
	
	xor ax, ax
	int 16h
	
	cmp al, 'w'
	je move_up
	cmp al, 's'
	je move_down
	cmp al, 'a'
	je move_left
	cmp al, 'd'
	je move_right
   
zamknij_plik:

    mov bx, word ptr ds:[handle]
    mov ah, 3eh
    int 21h

zamknij_program:
	mov al, 3h
	mov ah, 0
	int 10h
	
	mov ax, 4c00h
    int 21h 

move_up:
	mov ax, word ptr ds:[omijane_wiersze]
	add ax, 5
	cmp ax, word ptr ds:[ominiete_wiersze]
	ja czekaj
	add word ptr ds:[omijane_wiersze], 5
	jmp reszta2
	
	;cmp ds:[y0], 199
	;jae mama
	;mov 
	;cmp ds:[y0], 0
	;jbe mama1
	;add ds:[y0], 5
	;jmp reszta2
	;mama:
	;add ds:[omijane_wiersze], 5
	;sub ds:[real_y], 5
	;jmp reszta2
	;mama1:
	;add ds:[y0], 5
move_down:
	
	cmp word ptr ds:[y0], 199
	jnz czekaj
	mov bx, word ptr ds:[omijane_wiersze]
	sub bx, 5
	js czekaj
	sub word ptr ds:[omijane_wiersze], 5
	jmp reszta2
	;mov ax, word ptr ds:[real_y1]
	;cmp word ptr ds:[real_y], ax
	;jnz aa
	;sub ds:[y0], 5
	;aa:
	;cmp ds:[y0], 199
	;jb bb
	;sub ds:[omijane_wiersze], 5
	;add ds:[real_y], 5
	;bb:
	;mov ax, word ptr ds:[y0]
	;sub ax, word ptr ds:[real_y]
	
	;cmp ax, 0
	;ja reszta2
	;sub word ptr ds:[real_y], 5
	;jmp reszta2
	
move_left:
	
	mov ax, word ptr ds:[omijane_bajty]
	sub ax, 5
	js czekaj
	sub ds:[omijane_bajty], 5
	;cmp word ptr ds:[real_x], 320
	;ja reszta2
	;add ds:[real_x], 5
	;sub ds:[omijane_kolumny], 5
	jmp reszta2

move_right:
	
	mov ax, word ptr ds:[omijane_bajty]
	mov dx, 320
	add ax, dx
	cmp ax, word ptr ds:[size_x]
	jae czekaj
	
	add ds:[omijane_bajty], 5
	;cmp ds:[real_x], 320
	;ja reszta2
	;sub ds:[real_x], 5
	;;add ds:[omijane_kolumny], 5
	jmp reszta2

wyznacz_poz_obecna:
	
	mov ax, 4201h
	mov bx, word ptr ds:[handle]
	xor cx, cx
	xor dx, dx
	int 21h
	ret
	
skroc_ilosc_wierszy:

    mov word ptr ds:[real_y], 200
    mov word ptr ds:[real_y1], 200
	mov word ptr ds:[y0], 199
	mov ax, word ptr ds:[size_y]                  
    sub ax, 200               
    mov word ptr ds:[omijane_wiersze], ax
	mov word ptr ds:[ominiete_wiersze], ax
    jmp reszta1
                   
skroc_ilosc_kolumn:
    mov word ptr ds:[real_x], 320               
    mov word ptr ds:[real_x1], 320
	mov ax, word ptr ds:[size_x]
    sub ax, 320               
    mov word ptr ds:[omijane_kolumny], ax
    mov word ptr ds:[x0], 0
	jmp reszta2

nie_skracaj_wierszy:
	mov ax, word ptr ds:[size_y]
	
	mov word ptr ds:[y0], ax
	
	mov word ptr ds:[real_y], ax 
	mov word ptr ds:[real_y1], ax
	
	jmp reszta1

nie_skracaj_kolumn:
	mov ax, word ptr ds:[size_x]
	
	mov word ptr ds:[real_x], ax
	mov word ptr ds:[real_x1], ax
	mov word ptr ds:[x0], 0
	
	jmp reszta2
	
oblicz_adres: ;;cl - x (size_x -> 0)
    
    mov bx, word ptr ds:[curr_y]
    dec bx
	mov ax, 320
    mul bx
    
    mov bx, 320
    sub bx, cx
	
    add ax, bx
    mov si, ax
    ret 

przeczytaj_BGR:         ;wczytuje 3 bajty do handle
    
    mov dx, offset buf
    mov ax, seg buf
    mov ds, ax
    
    mov bx, word ptr ds:[handle]
    push cx
    
    mov cx, 3
    mov ah, 3fh
    int 21h
    
    pop cx
    ret           

zaswiec_punkt:  ;na bajcie si wyswietl bl
    
    mov ax, 0A000h
    mov es, ax
    
    mov al, byte ptr ds:[numer_koloru]
    ;mov al, 4
	mov es:[si], al
    ret
    
oblicz_bajt: ; wyznacza wartosc bajta do wyswietlenia na podstawie buf i zapisuje do zmiennej
    mov al, byte ptr ds:[buf]
    mov ds:[b], al
    mov al, byte ptr ds:[b]
    mov bl, 64
    call podziel_al_przez_bl
    mov ds:[b], al               ;B
    
    mov al, byte ptr ds:[buf+1]
    mov bl, 32
    call podziel_al_przez_bl
    mov bl, 4 
    call pomnoz_al_przez_bl 
    mov ds:[g], al                 ;G
    
    mov al, byte ptr ds:[buf+2]
    mov bl, 32
    call podziel_al_przez_bl
    mov bl, 32
    call pomnoz_al_przez_bl
    mov ds:[r], al                   ;R
    
    mov bl, byte ptr ds:[b]
    mov bh, byte ptr ds:[g]
    add bl, bh
    mov bh, byte ptr ds:[g]
    add bl, bh
    
    mov byte ptr ds:[numer_koloru], bl
    ret
    
podziel_al_przez_bl:
    div bl
    xor ah, ah
    ret
    
pomnoz_al_przez_bl:    
    mul bl    
    ret

na_czarno:
	mov byte ptr ds:[numer_koloru], 0
	jmp continue
	
code1 ends
end start