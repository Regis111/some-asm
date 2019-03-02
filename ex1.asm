dane segment
	sukces			db 0ah,0dh,"Poprawne dane.","$"
	porazka			db 0ah,0dh,"Niepoprawne dane.","$"
	dzialanie		db 19
					db ?
					db 19 dup (0)
	liczba 			db 0
	spacje			db 0,0
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
	petla:
		cmp byte ptr ds:[si],' '			;porównanie obecnego znaku ze spacją
		je inkr					;skok do etykiety inkr
		inc si					;inkrementacja licznika
	loop petla
	
	cmp byte ptr ds:[liczba],2	;sprawdzenie czy były 2 spacje
	je dobrze					
	jne zle
	
	koniec:
		mov ah,4ch
		int 21h
	
	inkr:						;
		inc byte ptr ds:[liczba]
		inc si
		jmp petla						;inkrementacja zmiennej liczba, gdy została wykryta spacja
		
	dobrze:
		mov ah,9
		mov dx,offset sukces
		int 21h
		jmp koniec
		
	zle:
		mov ah,9
		mov dx,offset porazka
		int 21h
		jmp koniec
kod ends
end start