assume cs:kod , ds:dane , ss:stos1

stos1 segment stack
		dw 50 dup (?)
wstosu	dw ?
stos1 ends

dane segment
	powitanie		db "Enter the expression: $"
	porazka			db 0ah,0dh,"Invalid input data.","$"
	blad_spacji		db 0ah,0dh,"Too much spaces or not wrong schema of input",13,10,"Should be: 'digit operator digit'$"
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
					db 19 dup (?)
	liczba 			db 0
	spacje			db ?,?
	
	cyfra1          db 6 dup (?)
	operator		db 5 dup (?)
	cyfra2          db 6 dup (?)
	
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
    
	mov ax, seg powitanie
	mov ds, ax
	mov ah, 9
	mov dx, offset powitanie
	int 21h
	
	mov ah, 0ah					;
	mov dx, offset dzialanie			;
	int 21h						;wprowadzenie wejścia do bufora
	
	mov cx,0
	mov cl, byte ptr ds:[dzialanie+1]			;wprowadzenie do cx liczby znaków
	mov si, offset dzialanie +2					;inicjalizacja si jako iteratora w petla1
	mov bx, offset spacje						;inicjalizacja bx na pierwszy znak wejścia
	petla1:
		cmp byte ptr ds:[si],' '				;porównanie obecnego znaku ze spacją
		je inkr									;skok do etykiety inkr
		inc si									;inkrementacja licznika
	loop petla1
	
	cmp byte ptr ds:[liczba],2					;sprawdzenie czy były 2 spacje
	je dobrze					
	jne zle
	
	inkr:						;
		inc byte ptr ds:[liczba]		;zliczenie spacji
		mov ax, si						;
		sub ax, offset dzialanie+2 		;obliczenie indeksu znaku spacji
		cmp ax,0						;sprawdzenie możliwości bycia spacji na indeksie 0
		je zle_spacje							;
		add ax,1							;
		cmp al, byte ptr ds:[dzialanie+1]	;sprawdzenie możliwości bycia spacji na indeksie n-1, gdzie n liczba znaków bufora
		je zle_spacje							;
		sub ax,1						;
		mov ds:[bx], ax					;wstawienie wartości indeksu do spacje
		inc bx							;
		inc si
		dec cl
		cmp byte ptr ds:[si],' ';
		je zle_spacje
		jmp petla1						;inkrementacja zmiennej liczba, gdy została wykryta spacja
	
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
		
	dobrze:
		call inicjalizacja
		call wywolania_cyfra1
		call wywolania_cyfra2
		call wywolania_operatora
		jmp print
	zle:
		mov ah,9
		mov dx,offset porazka			;wejscie wyglada 'cyfra operator cyfra' ale, ktoras z czesci jest zla
		int 21h
		jmp koniec
	zle_spacje:
		mov ah,9
		mov dx,offset blad_spacji		;wejscie nie wyglada 'cyfra operator cyfra'
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
			mov si, offset cyfra1				;ładowanie offsetu inputu
			mov bx, offset jeden				;ładowanie offsetu wzorca
			mov cx, 3							;ładowanie długości tekstu
			mov dx, 1							;ładowanie samej cyfry	
			mov bp, l2							;ładowanie adresu etykiety do której nastąpi skok, gdy znak się nie będzie zgadzał w czasie porównywania
			call porownanie_liczby
			ret
		l2:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,3
			jne l3
			mov si, offset cyfra1
			mov bx, offset dwa
			mov cx, 3
			mov dx, 2
			mov bp, l3
			call porownanie_liczby
			ret
		l3:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,5
			jne l4
			mov si, offset cyfra1
			mov bx, offset trzy
			mov cx, 5
			mov dx, 3
			mov bp, l4
			call porownanie_liczby
			ret
		l4:
			mov al, byte ptr cyfra1_dlugosc
			cmp al, 4
			jne l5
			mov si, offset cyfra1
			mov bx, offset cztery
			mov cx, 4
			mov dx, 4
			mov bp, l5
			call porownanie_liczby
			ret
		l5:
			mov al, byte ptr cyfra1_dlugosc
			cmp al, 4
			jne l6
			mov si, offset cyfra1
			mov bx, offset piec
			mov cx, 4
			mov dx, 5
			mov bp, l6
			call porownanie_liczby
			ret
		l6:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,3
			jne l7
			mov si, offset cyfra1
			mov bx, offset szesc
			mov cx, 3
			mov dx, 6
			mov bp, l7
			call porownanie_liczby
			ret
		l7:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,5
			jne l8
			mov si, offset cyfra1
			mov bx, offset siedem
			mov cx, 5
			mov dx, 7
			mov bp, l8
			call porownanie_liczby
			ret
		l8:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,5
			jne l9
			mov si, offset cyfra1
			mov bx, offset osiem
			mov cx, 5
			mov dx, 8
			mov bp, l9
			call porownanie_liczby
			ret
		l9:
			mov al, byte ptr cyfra1_dlugosc
			cmp al,4
			jne l0
			mov si, offset cyfra1
			mov bx, offset dziewiec
			mov cx, 4
			mov dx, 9
			mov bp, l0
			call porownanie_liczby
			ret
		l0:
			mov al, byte ptr cyfra1_dlugosc
			cmp al, 4
			jne zle
			mov si, offset cyfra1
			mov bx, offset zero
			mov cx, 4
			mov dx, 0
			mov bp, zle
			call porownanie_liczby
			ret
	wywolania_cyfra2:
		sub bx,bx
		m1:
		    mov bx, init_cyfra2
			push bx
			mov al, byte ptr cyfra2_dlugosc
			cmp al,3
			jne m2
			mov si, offset cyfra2
			mov bx, offset jeden
			mov cx, 3
			mov dx, 1
			mov bp, m2
			call porownanie_liczby
			ret
		m2:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,3
			jne m3
			mov si, offset cyfra2
			mov bx, offset dwa
			mov cx, 3
			mov dx, 2
			mov bp, m3
			call porownanie_liczby
			ret
		m3:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,5
			jne m4
			mov si, offset cyfra2
			mov bx, offset trzy
			mov cx, 5
			mov dx, 3
			mov bp, m4
			call porownanie_liczby
			ret
		m4:
			mov al, byte ptr cyfra2_dlugosc
			cmp al, 4
			jne m5
			mov si, offset cyfra2
			mov bx, offset cztery
			mov cx, 4
			mov dx, 4
			mov bp, m5
			call porownanie_liczby
			ret
		m5:
			mov al, byte ptr cyfra2_dlugosc
			cmp al, 4
			jne m6
			mov si, offset cyfra2
			mov bx, offset piec
			mov cx, 4
			mov dx, 5
			mov bp, m6
			call porownanie_liczby
			ret
		m6:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,3
			jne m7
			mov si, offset cyfra2
			mov bx, offset szesc
			mov cx, 3
			mov dx, 6
			mov bp, m7
			call porownanie_liczby
			ret
		m7:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,5
			jne m8
			mov si, offset cyfra2
			mov bx, offset siedem
			mov cx, 5
			mov dx, 7
			mov bp, m8
			call porownanie_liczby
			ret
		m8:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,5
			jne m9
			mov si, offset cyfra2
			mov bx, offset osiem
			mov cx, 5
			mov dx, 8
			mov bp, m9
			call porownanie_liczby
			ret
		m9:
			mov al, byte ptr cyfra2_dlugosc
			cmp al,4
			jne m0
			mov si, offset cyfra2
			mov bx, offset dziewiec
			mov cx, 4
			mov dx, 9
			mov bp, m0
			call porownanie_liczby
			ret
		m0:
			mov al, byte ptr cyfra2_dlugosc
			cmp al, 4
			jne zle
			mov si, offset cyfra2
			mov bx, offset zero
			mov cx, 4
			mov dx, 0
			mov bp, zle
			call porownanie_liczby
			ret
	porownanie_liczby:
		petla2:
			mov al, byte ptr ds:[bx]
			cmp al, byte ptr es:[si]
			jne return1
			inc si
			inc bx
		loop petla2						;petla poruwnująca znaki wzorca i input-u
		pop bp 
		call bp							;wywolanie init_cyfra1 lub init_cyfra2
		ret								
	return1:
		jmp bp
		
	init_cyfra1:
		mov byte ptr ds:[cyfra1a], dl
		ret
	init_cyfra2:
		mov byte ptr ds:[cyfra2a], dl
		ret	
		
	wywolania_operatora:
		sub bx,bx
		plus1:	
			mov al, byte ptr oper_dlugosc
			cmp al, 4
			jne minus1
			mov di, dodawanie						;adres etykiety dzialania
			mov si, offset operator					;adres operatora z wejscia
			mov bx, offset plus						;adres operatora wzorca
			mov cx, 4								;dlugosc tekstu operatora
			mov bp, minus1							;adres nastepnej etykiety w razie porazki przy porownywaniu
			call porownanie_operatora
			ret
		minus1:
			mov al, byte ptr oper_dlugosc
			cmp al, 5
			jne razy1
			mov di, odejmowanie
			mov si, offset operator
			mov bx, offset minus
			mov cx, 5
			mov bp, razy1
			call porownanie_operatora
			ret
		razy1:
			mov al, byte ptr oper_dlugosc
			cmp al, 5
			jne zle
			mov di, mnozenie
			mov si, offset operator
			mov bx, offset razy
			mov cx, 5
			mov bp, zle
			call porownanie_operatora
			ret
	porownanie_operatora:
		petla3:
			mov al, byte ptr ds:[bx]
			cmp al, byte ptr es:[si]
			jne return2
			inc si
			inc bx
		loop petla3
		call di
		ret
	return2:
		jmp bp

	dodawanie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		add al,bl
		mov byte ptr ds:[wynik], al
		ret
	odejmowanie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		sub al,bl
		mov byte ptr ds:[wynik], al
		ret
	mnozenie:
		mov al, byte ptr ds:[cyfra1a]
		mov bl, byte ptr ds:[cyfra2a]
		mul bl
		mov byte ptr ds:[wynik], al
		ret
	print:
		mov dl, 10
		mov ah, 02h
		int 21h
		mov dl,13
		int 21h				;nowa linia
		jc ujemna
	print_number:
		mov cl, 10
		mov ah, 0
		mov al, byte ptr ds:[wynik]
		div cl
		add al, 30h
		add ah, 30h
		mov dl, al
		mov bl, ah
		mov ah, 2h
		int 21h
		mov dl, bl
		int 21h
		jmp koniec
	ujemna:
		mov al, byte ptr ds:[wynik]
		mov bl, 255
		sub bl, al
		inc bl
		add bl, 30h
		mov dl, '-'
		mov ah, 2h
		int 21h
		mov dl, bl
		int 21h
	koniec:
		mov ah,4ch
		int 21h

kod ends	
end start