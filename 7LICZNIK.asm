SEG_ON EQU P1.6 ;włączenie wyświetlacza 7-segm.
				;Stałe używane w programie
DISPLAY EQU 00001000B
DISPLAY1 EQU 00000100B
DISPLAY2 EQU 00000010B
DISPLAY3 EQU 00000001B ;wybrane wskaźniki - 2i5
;---------------------------
JED EQU 00000110B
DWA EQU 01011011B
TRZ EQU 01001111B
CZT EQU 01100110B
PIE EQU 01101101B
SZE EQU 01111101B
SIE EQU 00000111B
OSI EQU 01111111B
DZI EQU 01101111B
PRZ EQU 10000000B
	LJMP START
	ORG 100H
START:
	MOV R0,#CSDS ;adres bufora
	;wyboru wskaźnika
	MOV R1,#CSDB ;adres bufora
	;danych wskaźnika
	MOV R2,#CSDB ;adres bufora
	;danych wskaźnika
	MOV R3,#CSDB ;adres bufora
	;danych wskaźnika
	MOV A,#DISPLAY
	MOVX @R0,A ;wpisz wybrane wskaźniki
	MOV A,#JED
	MOVX @R1,A ;wpisz wybrane wskaźniki
	CLR SEG_ON ;włącz wyświetlacz 7-segm
	
	LCALL LCD_INIT
	LCALL WAIT_KEY
	MOV R1, A
	
	
	SJMP $