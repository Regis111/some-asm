assume cs:kod , ds:dane , ss:stos1
dane segment
	sukces			db 0ah,0dh,"Poprawne dane.","$"
	porazka			db 0ah,0dh,"Niepoprawne dane.","$"
	blad_spacji		db 0ah,0dh,"Zbyt duzo spacji.","$"
	jeden			db "one"
	dwa				db "two"
	trzy			db "three"
	cztery			db "four"
	piec			db "five"
	szesc			db "six"
	siedem			db "seven"
	osiem			db "eight"
	dziewiec		db "nine"
	zero			db "zero"
	
	plus			db "plus"
	minus			db "minus"
	razy			db "times"
	
	dzialanie		db 19
					db ?
					db 19 dup (0)
	liczba 			db 0
	spacje			db 3,3
	
	cyfra1          db 6 dup (1)
	operator		db 5 dup (3)
	cyfra2          db 6 dup (2)
	
	cyfra1a			db ?,"?"
	cyfra2a			db ?,"?"
	wynik			db ?
	
	
	cyfra1_dlugosc	db ?
	cyfra2_dlugosc	db ?
	oper_dlugosc	db ?
dane ends
kod segment
start:               
    
    mov sp, offset wstosu
	mov ax, seg wstosu
	mov ss, ax
    
	mov ax, seg dzialanie
	mov ds,ax
	
	mov ah, 0ah					;
	mov dx, offset dzialanie			;
	int 21h						;wprowadzenie wejścia do bufora
	
	mov cx,0
	mov cl, byte ptr ds:[dzialanie+1];wprowadzenie do cx liczby znaków
	mov si, offset dzialanie +2	;inicjalizacja bx na pierwszy znak wejścia
	mov bx, offset spacje
	petla1:
		cmp byte ptr ds:[si],' '			;porównanie obecnego znaku ze spacją
		je inkr					;skok do etykiety inkr
		inc si					;inkrementacja licznika
	loop petla1
	
	cmp byte ptr ds:[liczba],2	;sprawdzenie czy były 2 spacje
	je dobrze					
	jne zle
	
	inicjalizacja:
		mov si, offset dzialanie+2		;
		mov di, offset cyfra1			;
		mov cl, byte ptr ds:[spacje]
		mov byte ptr ds:[cyfra1_dlugosc], cl	;	
		rep movsb								;inicjalizacja liczby 1
		
		mov si, offset dzialanie+2		
		mov ax,0
		mov al, byte ptr ds:[spacje]
		add si, ax
		add si, 1
		mov di, offset operator
		mov al, byte ptr ds:[spacje+1]
		sub al, byte ptr ds:[spacje]
		sub al, 1
		mov cl,al
		mov byte ptr ds:[oper_dlugosc], cl
		rep movsb						;inicjalizacja operatora
		
		mov si, offset dzialanie+2+1
		add si, word ptr ds:[spacje+1]
		mov di, offset cyfra2
		mov al, byte ptr ds:[dzialanie+1]
		sub al, byte ptr ds:[spacje+1]
		sub al,1
		mov cl, al
		mov byte ptr ds:[cyfra2_dlugosc], cl
		rep movsb						;inicjalizacja liczby 2
		ret
	
	inkr:						;
		inc byte ptr ds:[liczba]		;zliczenie spacji
		mov ax, si						;
		sub ax, offset dzialanie+2 		;obliczenie indeksu znaku spacji
		cmp ax,0						;sprawdzenie możliwości bycia spacji na indeksie 0
		je zle							;
		add ax,1						;
		cmp al, byte ptr ds:[dzialanie+1]	;sprawdzenie możliwości bycia spacji na indeksie n-1, gdzie n liczba znaków bufora
		je zle							;
		sub ax,1						;
		mov ds:[bx], ax					;wstawienie wartości indeksu do spacje
		inc bx							;
		inc si
		dec cl
		cmp byte ptr ds:[si],' ';
		je zle_spacje
		jmp petla1						;inkrementacja zmiennej liczba, gdy została wykryta spacja
		
	dobrze:
		mov ah,9
		mov dx,offset sukces
		int 21h
		call inicjalizacja
		jmp wywolania_cyfra1
		;jmp wywolania_cyfra2
		jmp koniec
	zle:
		mov ah,9
		mov dx,offset porazka
		int 21h
		jmp koniec
	zle_spacje:
		mov ah,9
		mov dx,offset blad_spacji
		int 21h
		jmp koniec
	wywolania_cyfra1:
		sub bx,bx
		l1:
		    mov bx, init_cyfra1
			push bx								;ładowanie etykiety inicjowania_cyfry
			mov al, byte ptr cyfra1_dlugosc		
			cmp al,3							;porownywanie dlugosci stringów
			jne l2
			mov bx, offset cyfra1				
			push bx								;ładowanie offsetu inputu
			mov bx, offset jeden
			push bx								;ładowanie offsetu wzorca
			mov bx, 3
			push bx								;ładowanie długości stringa
			mov bx, 1	
			push bx								;ładowanie samej cyfry
			mov bx, l2
			push bx								;ładowanie adresu etykiety do której nastąpi skok, gdy znak się nie będzie zgadzał w czasie porównywania
			jmp porownanie_liczby				
		l2:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,3
			jne zle
			mov bx, offset cyfra1
			push bx
			mov bx, offset dwa
			push bx
			mov bx, 3
			push bx
			mov bx, 2
			push bx
			mov bx, zle
			push bx
			jmp porownanie_liczby
;		l3:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l4:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;;			mov bx, zle
	;		push bx
	;		jmp porownanie_liczby
;		l5:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;;			mov bx, offset cyfra1
	;		push bx
	;		mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l6:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l7:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l8:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l9:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
;		l0:
;			mov al, byte ptr cyfra1_dlugosc
;			cmp al,3
;			jne zle
;			mov bx, offset cyfra1
;			push bx
;			mov bx, offset dwa
;			push bx
;			mov bx, 3
;			push bx
;			mov bx, 2
;			push bx
;			mov bx, zle
;			push bx
;			jmp porownanie_liczby
	wywolania_cyfra2:
		sub bx,bx
		m1:
		    mov bx, init_cyfra2
			push bx
			mov al, byte ptr cyfra2_dlugosc
			cmp al,3
			jne m2
			mov bx, offset cyfra2
			push bx
			mov bx, offset jeden
			push bx
			mov bx, 3
			push bx
			mov bx, 1
			push bx
			mov bx, m2
			push bx
			jmp porownanie_liczby
		m2:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,3
			jne zle
			mov bx, offset cyfra2
			push bx
			mov bx, offset dwa
			push bx
			mov bx, 3
			push bx
			mov bx, 2
			push bx
			mov bx, l2
			push bx
			jmp porownanie_liczby
	porownanie_liczby:
		pop bp							;adres etykiety
		pop dx							;cyfra
		pop cx							;liczba znaków w stringu
		pop bx							;offset wzorca
		pop si							;offset input-u
		petla2:
			mov al, byte ptr ds:[bx]
			cmp al, byte ptr es:[si]
			jne return1
			inc si
			inc bx
		loop petla2						;petla poruwnująca znaki wzorca i input-u
		pop bp 
		jmp bp							;skok do etykiety wywolania_cyfra2 lub porownanie_operatora
	return1:
		jmp bp
	
	init_cyfra1:
		mov byte ptr ds:[cyfra1a], dl
		jmp wywolania_cyfra2
	init_cyfra2:
		mov byte ptr ds:[cyfra2a], dl
		jmp wywolania_operatora
	
	
	wywolania_operatora:
		sub bx,bx
		plus1:	
			mov al, byte ptr oper_dlugosc
			cmp al, 4
			jne minus1
			
			mov bx, dodawanie
			push bx
			mov bx, offset operator
			push bx
			mov bx, offset plus
			push bx
			mov bx, 4
			push bx
			mov bx, minus1
			push bx
			jmp porownanie_operatora
		minus1:
			mov al, byte ptr oper_dlugosc
			cmp al, 5
			jne razy1
			
			mov bx, odejmowanie
			push bx
			mov bx, offset operator
			push bx
			mov bx, offset minus
			push bx
			mov bx, 5
			push bx
			mov bx, razy1
			push bx
			jmp porownanie_operatora
		razy1:
			mov al, byte ptr oper_dlugosc
			cmp al, 4
			jne zle
			
			mov bx, mnozenie
			push bx
			mov bx, offset operator
			push bx
			mov bx, offset razy
			push bx
			mov bx, 4
			push bx
			mov bx, zle
			push bx
			jmp porownanie_operatora
		
	porownanie_operatora:
		pop bp
		pop cx
		pop bx
		pop si
		pop di
		petla3:
			mov al, byte ptr ds:[bx]
			cmp al, byte ptr es:[si]
			jne return2
			inc si
			inc bx
		loop petla3
		jmp di
	return2:
		jmp bp

	dodawanie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		add al,bl
		mov byte ptr ds:[wynik], al
		jmp koniec
	odejmowanie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		sub al,bl
		mov byte ptr ds:[wynik], al
		jmp koniec
	mnozenie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		mul bl
		mov byte ptr ds:[wynik], al
		jmp koniec
	koniec:
		mov ah,4ch
		int 21h

kod ends	
	
stos1 segment stack
		dw 200 dup (?)
wstosu	dw ?
stos1 ends


end start