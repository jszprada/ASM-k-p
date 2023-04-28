BUF EQU P1.6
;USTAWIENIE WYSWIETLANIA 
WY_M EQU 00001000B
WY_PRZ EQU 00000100B
WY_S EQU 00000010B
WY_MS EQU 00000001B
;USTAWIENIE LICZB
ZERO EQU 00111111B
JEDEN EQU 00000110B
DWA EQU 01011011B
TRZY EQU 01001111B
CZTERY EQU 01100110B
PIEC EQU 01101101B
SZESC EQU 01111101B
SIEDEM EQU 00000111B
OSIEM EQU 01111111B
DZIEWIEC EQU 01101111B
;USTAWIENIE MYSLNIKA
MYSLNIK EQU 01000000B
;USTAWIENIE CZYSZCZENIA
WYCZYSC EQU 00000000B
; PRZERWANIA
;********* Ustawienie TIMERÓW *********
;TIMER 0
T0_G EQU 0 ;GATE
T0_C EQU 0 ;COUNTER/-TIMER
T0_M EQU 1 ;MODE (0..3)
TIM0 EQU T0_M+T0_C*4+T0_G*8
;TIMER 1
T1_G EQU 0 ;GATE
T1_C EQU 0 ;COUNTER/-TIMER
T1_M EQU 1 ;MODE (0..3)
TIM1 EQU T1_M+T1_C*4+T1_G*8
TMOD_SET EQU TIM0+TIM1*16
;50[ms] = 50 000[ms]*(11.0592[MHz]/12) =
; = 46 080 cykli = 180 * 256
TH0_SET EQU 256-180
TL0_SET EQU 0
;**************************************
	LJMP START
;********* Przerwanie Timer 0 *********
	ORG 0BH
	MOV TH0,#TH0_SET 
	MOV A, 40H
	JZ DALEJ
	LJMP ALARM
DALEJ:
	DJNZ R3,NO_01SEK
	MOV R3, #22;ABY MINUTA W PROGRAMI TRWAŁA MNIEJWIECEJ TYLE CO W RZECZYWISTOSCI, MIEZYŁEM TO
	LCALL SEKUNDY
NO_01SEK:
	RETI
;**************************************
	ORG 100H
SEKUNDY:
	MOV A, R4
	SUBB A, #1
	MOV R4, A
	MOV A, R4
	JZ POLOWA_LICZBY
	
	RET	
POLOWA_LICZBY:
	MOV A, R5
	CJNE A, #1, ZMNIEJSZAJ_P_L
	MOV R5, #0
	MOV R4, #9
	
	RET
ZMNIEJSZAJ_P_L:
	MOV R4, #9
	MOV A, R5
	JZ DRUGA_POLOWA_LICZBY
	SUBB A, #1
	MOV R5, A
	MOV A, R5
	JZ DRUGA_POLOWA_LICZBY
	
	RET
DRUGA_POLOWA_LICZBY:
	MOV A, R6
	CJNE A, #1, ZMNIEJSZAJ_D_P_L
	MOV R6, #0
	MOV R5, #5
	MOV R4, #9
	
	RET
ZMNIEJSZAJ_D_P_L:
	MOV R4, #9
	MOV R5, #5
	MOV A, R6
	JZ ALARM
	SUBB A, #1
	MOV R6, A
	JZ ALARM
	
	RET
ALARM:
	MOV 40H, #1
	CPL P1.5
	CPL P1.7
	MOV A,#10
	LCALL DELAY_100MS
	LJMP ALARM
	
START:
	MOV 40H, #0;SPRAWDZENIE ALRMU 
	MOV R3, #2
	MOV R0,#CSDS 
	MOV R1,#CSDB
	MOV A,#WY_M
	MOVX @R0,A 
	CLR BUF
	LCALL WAIT_KEY
	MOV B, #10
	DIV AB
	SWAP A
	ADD A, B
	MOV R6, A
	JZ SK
	SUBB A, #1
	MOV R6, A
SK:
	MOV R4, #9
	MOV R5, #5
	MOV TMOD,#TMOD_SET 
	MOV TH0,#TH0_SET 
	MOV TL0,#TL0_SET
	SETB EA 
	SETB ET0 
	SETB TR0 
	MOV A, R6

WYSWIETL:
	MOV A,#WYCZYSC
    MOVX @R1,A
	;WYSWIETLANIE MINUTE
	MOV A,#WY_M
	MOVX @R0,A
	MOV A, R6
	LCALL WYSWIETL_CYFRE_P
	
	MOV A,#WYCZYSC
    MOVX @R1,A
	;WYSWIETLENIE MYSLNIKA
	MOV A,#WY_PRZ
	MOVX @R0,A
	MOV A, #MYSLNIK
	MOVX @R1,A 
	
	MOV A,#WYCZYSC
    MOVX @R1,A
	;WYSWIETLENIE SEKUND
	MOV A,#WY_S
	MOVX @R0,A
	MOV A, R5
	LCALL WYSWIETL_CYFRE_P
	
	MOV A,#WYCZYSC
    MOVX @R1,A
	;WYSWIETLENIE MILISEKUND
	MOV A,#WY_MS
	MOVX @R0,A
	MOV A, R4
	LCALL WYSWIETL_CYFRE_P
	
	LJMP WYSWIETL
;POLACZENIE LICZBY Z KLAWIATURY Z POSTACIA TEJ LICZBY DLA WYSWIETLACZA 
WYSWIETL_CYFRE_P:
	CJNE A, #0, C_Z
	MOV A, #ZERO
	LJMP WYJ
C_Z:
	CJNE A, #1, C_J
	MOV A, #JEDEN
	LJMP WYJ
C_J:
	CJNE A, #2, C_D
	MOV A, #DWA
	LJMP WYJ
C_D:
	CJNE A, #3, C_T
	MOV A, #TRZY
	LJMP WYJ
C_T:
	CJNE A, #4, C_C
	MOV A, #CZTERY
	LJMP WYJ
C_C:
	CJNE A, #5, C_P
	MOV A, #PIEC
	LJMP WYJ
C_P:
	CJNE A, #6, C_SZ
	MOV A, #SZESC
	LJMP WYJ
C_SZ:
	CJNE A, #7, C_S
	MOV A, #SIEDEM
	LJMP WYJ
C_S:
	CJNE A, #8, C_O
	MOV A, #OSIEM
	LJMP WYJ
C_O:
	MOV A, #DZIEWIEC
WYJ:
	MOVX @R1,A
	
	RET
STOP:			
	LJMP	STOP	
	NOP