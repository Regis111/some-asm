dane segment
	sukces			db 0ah,0dh,"Poprawne dane.","$"
	porazka			db 0ah,0dh,"Niepoprawne dane.","$"
	dzialanie		db 19
					db ?
					db 19 dup (0)
	liczba 			db 0
	spacje			db 3,3
	cyfra1          db 6 dup (?)
	operator		db 5 dup (?)
	cyfra2          db 6 dup (?)
	cyfra1a			db ?
	cyfra2a			db ?
dane ends
kod segment
start:
	mov ax, seg dzialanie
	mov ds,ax
	
	mov ah, 0ah					;
	mov dx, offset dzialanie			;
	int 21h						;wprowadzenie wejścia do bufora
	
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
		mov cl, byte ptr ds:[spacje]	;
		rep movsb						;inicjalizacja liczby 1
		
		mov si, offset dzialanie+2		
		mov ax,0
		mov al, byte ptr [spacje]
		add si, ax
		add si, 1
		mov di, offset operator
		mov al, byte ptr [spacje+1]
		sub al, byte ptr [spacje]
		sub al, 1
		mov cl,al
		rep movsb						;inicjalizacja operatora
		
		mov si, offset dzialanie+2+1
		add si, word ptr [spacje+1]
		mov di, offset cyfra2
		mov al, byte ptr ds:[dzialanie+1]
		sub al, byte ptr ds:[spacje+1]
		sub al,1
		mov cl, al
		rep movsb						;inicjalizacja liczby 2
	koniec:
		mov ah,4ch
		int 21h
	
	inkr:						;
		inc byte ptr ds:[liczba]		;zliczenie spacji
		mov ax, si						;
		sub ax, offset dzialanie+2 		;obliczenie indeksu znaku spacji
		mov ds:[bx], ax					;wstawienie wartości indeksu do spacje
		inc bx							;
		inc si							;
		jmp petla1						;inkrementacja zmiennej liczba, gdy została wykryta spacja
		
	dobrze:
		mov ah,9
		mov dx,offset sukces
		int 21h
		call inicjalizacja
		jmp koniec
	zle:
		mov ah,9
		mov dx,offset porazka
		int 21h
		jmp koniec
kod ends
end start