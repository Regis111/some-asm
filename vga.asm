stos1 segment stack
        dw 200 dup (?)
wstosu  dw ?
stos1 ends                            

data1 segment
    nazwa           db  "tim.bmp",0
	handle          dw  ?
	
	curr_y          db  ?
	
	real_x          dw  ?
	real_y          dw  ?
	
	omijane_wiersze dw  0
	
	omijane_kolumny dw  0
	
	numer_koloru    db  ?
	
	adres           dw  ?
	
	buf             db  200 dup(?)
	
	size_hd         dw  ?
	
	size_x          dw  ?
	size_y          dw  ?
	
	bpp             db  ?
	            
	b               db  ?
	g               db  ?
	r               db  ?
	
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
    mov al, 0h
    mov ah, 42h
    int 21h
    
przejdz:                                  ;;;;poczatek fragmentu z bledem
    
	nop
	mov bx, ds:[handle]
    mov dx, 3
    mov ax, word ptr ds:[omijane_wiersze]
    mul dx
    mov dx, word ptr ds:[size_x]
    mul dx
    mov cx, dx
    mov dx, ax
    mov ax, 4201h
    int 21h                             ;;;;;;koniec fragmentu z bledem
	nop
	
print:
    mov cx, word ptr ds:[real_y] ;; wykonywac real_y razy
    petla0:
        mov byte ptr ds:[curr_y], cl
        push cx
        mov cx, word ptr ds:[real_x]
        petla1:                  		;; wykonywac real_x razy
            
            call przeczytaj_BGR
            
            call oblicz_bajt
            
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
    
zamknij_plik:

    mov bx, word ptr ds:[handle]
    mov ah, 3eh
    int 21h

koniec:
	
	xor ax, ax
	int 16h
	
	;cmp al, 'w'
	;je move_up
	cmp al, 's'
	je move_down
	;cmp al, 'a'
	;je move_left
	;cmp al, 'd'
	;je move_right
    mov ax, 4c00h
    int 21h                   

move_up:
	

move_down:


move_left:


move_right:


		  
skroc_ilosc_wierszy:
    mov word ptr ds:[real_y], 200
    mov ax, word ptr ds:[size_y]                  
    sub ax, 200               
    mov word ptr ds:[omijane_wiersze], ax
    jmp reszta1
                   
skroc_ilosc_kolumn:
    mov word ptr ds:[real_x], 320               
    mov ax, word ptr ds:[size_x]
    sub ax, 320               
    mov word ptr ds:[omijane_kolumny], ax
    jmp reszta2

nie_skracaj_wierszy:
	mov ax, word ptr ds:[size_y]
	mov word ptr ds:[real_y], ax 
	jmp reszta1

nie_skracaj_kolumn:
	mov ax, word ptr ds:[size_x]
	mov word ptr ds:[real_x], ax
	jmp reszta2
	
oblicz_adres: ;;cl - x (size_x -> 0)
    
    xor bh, bh
    mov bl, byte ptr ds:[curr_y]
    mov ax, 320
    mul bx
    
    mov bx, word ptr ds:[real_x]
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
	
code1 ends
end start