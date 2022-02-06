.MODEL TINY
.CODE

	    ORG 256

BEGIN:	JMP START
COLS    EQU 32
ROWS    EQU 20
SEED    DW 11
A       DW 31
B       DW 13
GX0     DW 0
GY0     DW 0
GX1     DW 0
GY1     DW 0
GW      DW 0
GH      DW 0
GX      DW 0
GY      DW 0
GC      DB 0
SZ      DW 10
X       DW 0
Y       DW 0
XD      DW 1
YD      DW 0
SX      DW COLS*ROWS DUP(0)
SY      DW COLS*ROWS DUP(0)
SN      DW 1
FX      DW 0
FY      DW 0
BLINK   DB 0
QUIT    DB 0
START:

        CALL SRAND

        MOV AL,13H
        CALL MODE

        CALL HIDECURSOR

        MOV GX0,0
        MOV GY0,0
        MOV GW,320
        MOV GH,200
        MOV GC,01
        CALL FILLRECT

        CALL FOOD

START10:

        MOV AH,01
        INT 16H
        JZ START20

        CALL EVENT

START20:
        CMP BLINK,0
        JNE START30
        MOV BLINK,1
        CALL DRAWFOOD
        JMP START40
START30:
        CALL ERASEFOOD
        MOV BLINK,0
START40:        

        CALL DRAWHEAD

        MOV CX,0007H
        MOV DX,0A120H
        CALL DELAY

        CALL ADJUST

        CALL ERASETAIL

        CALL MOVE

        CALL CUT
 
        MOV AX,X
        CMP AX,FX
        JNE START50
        MOV AX,Y
        CMP AX,FY
        JNE START50

        INC SN
        
        CMP SN,COLS*ROWS
        JAE START60

        CALL FOOD

START50:

        CMP QUIT,1
        JNE START10

START60:                
        MOV CX,0007H
        MOV DX,0A120H
        CALL DELAY

        CALL SHOWCURSOR

        MOV AL,03
        CALL MODE

        RET



EVENT:
        MOV AH,00
        INT 16H

        CMP AL,27
        JE EVENT_QUIT
        CMP AL,'a'
        JE EVENT_LEFT
        CMP AL,'d'
        JE EVENT_RIGHT
        CMP AL,'w'
        JE EVENT_UP
        CMP AL,'s'
        JE EVENT_DOWN
        JMP EVENT10

EVENT_QUIT:
        MOV QUIT,1
        JMP EVENT10
EVENT_LEFT:
        CMP XD,1
        JE EVENT10
        MOV XD,-1
        MOV YD,0
        JMP EVENT10
EVENT_RIGHT:
        CMP XD,-1
        JE EVENT10
        MOV XD,1
        MOV YD,0
        JMP EVENT10
EVENT_UP:
        CMP YD,1
        JE EVENT10
        MOV XD,0
        MOV YD,-1
        JMP EVENT10
EVENT_DOWN:
        CMP YD,-1
        JE EVENT10
        MOV XD,0
        MOV YD,1
EVENT10:
        RET



MOVE:
        MOV AX,XD
        ADD X,AX
        MOV AX,YD
        ADD Y,AX
MOVE10:
        CMP X,0
        JGE MOVE20
        MOV X,COLS-1
MOVE20:
        CMP X,COLS-1
        JLE MOVE30
        MOV X,0
MOVE30:
        CMP Y,0
        JGE MOVE40
        MOV Y,ROWS-1
MOVE40:
        CMP Y,ROWS-1
        JLE MOVE50
        MOV Y,0
MOVE50:
        RET
    
    
        
ADJUST:
        CMP SN,0
        JE ADJUST40
        CMP SN,1
        JE ADJUST30
    
        MOV AX,SN
        DEC AX
        MOV CL,2
        MUL CL
        LEA BX,SX
        ADD BX,AX
        MOV CX,SN
        DEC CX
ADJUST10:
        MOV AX,WORD PTR [BX - 2]
        MOV WORD PTR [BX - 0],AX
        SUB BX,2
        LOOP ADJUST10

        MOV AX,SN
        DEC AX
        MOV CL,2
        MUL CL
        LEA BX,SY
        ADD BX,AX
        MOV CX,SN
        DEC CX
ADJUST20:
        MOV AX,WORD PTR [BX - 2]
        MOV WORD PTR [BX - 0],AX
        SUB BX,2
        LOOP ADJUST20
ADJUST30:
        LEA BX,SX
        MOV AX,X
        MOV WORD PTR [BX],AX
        
        LEA BX,SY
        MOV AX,Y
        MOV WORD PTR [BX],AX
ADJUST40:
        RET



DRAWHEAD:
        MOV AX,X
        MUL SZ
        MOV GX0,AX
        
        MOV AX,Y
        MUL SZ
        MOV GY0,AX
        
        MOV AX,SZ
        MOV GW,AX
        MOV GH,AX
        
        MOV GC,14
        
        CALL FILLRECT
        
        RET
        
  
        
ERASETAIL:
        CMP SN,0
        JE ERASETAIL10
        
        MOV AX,SN
        DEC AX
        MOV CL,2
        MUL CL
        LEA BX,SX
        ADD BX,AX
        MOV AX,WORD PTR [BX]
        MUL SZ
        MOV GX0,AX
        
        MOV AX,SN
        DEC AX
        MOV CL,2
        MUL CL
        LEA BX,SY
        ADD BX,AX
        MOV AX,WORD PTR [BX]
        MUL SZ
        MOV GY0,AX
        
        MOV AX,SZ
        MOV GW,AX
        MOV GH,AX
        
        MOV GC,01
        
        CALL FILLRECT

ERASETAIL10:
        RET



FOOD:
        CALL RAND
        MOV BX,32
        CALL MODULO
        MOV FX,AX
        
        CALL RAND
        MOV BX,20
        CALL MODULO
        MOV FY,AX
        
FOOD10:
        MOV CX,SN
        MOV SI,0
FOOD20:
        MOV AX,SI
        PUSH CX
        MOV CL,2
        MUL CL
        POP CX
        LEA BX,SX
        ADD BX,AX
        MOV AX,FX
        CMP AX,WORD PTR [BX]
        JNE FOOD40
        
        MOV AX,SI
        PUSH CX
        MOV CL,2
        MUL CL
        POP CX
        LEA BX,SY
        ADD BX,AX
        MOV AX,FY
        CMP AX,WORD PTR [BX]
        JNE FOOD40
        
        INC FX
        CMP FX,COLS-1
        JBE FOOD10
        MOV FX,0
        INC FY
        CMP FY,ROWS-1
        JBE FOOD10
        MOV FY,0
        JMP FOOD20

FOOD30:
        LOOP FOOD20
FOOD40:
        RET



DRAWFOOD:
        MOV AX,FX
        MUL SZ
        MOV GX0,AX
        MOV AX,FY
        MUL SZ
        MOV GY0,AX
        MOV AX,SZ
        MOV GW,AX
        MOV GH,AX
        MOV GC,14
        CALL FILLRECT
        RET



ERASEFOOD:
        MOV AX,FX
        MUL SZ
        MOV GX0,AX
        MOV AX,FY
        MUL SZ
        MOV GY0,AX
        MOV AX,SZ
        MOV GW,AX
        MOV GH,AX
        MOV GC,01
        CALL FILLRECT
        RET



CUT:
        CMP SN,4
        JBE CUT40
        
        MOV CX,SN
        MOV SI,0
CUT10:
        MOV AX,SI
        PUSH CX
        MOV CL,2
        MUL CL
        POP CX
        LEA BX,SX
        ADD BX,AX
        MOV AX,WORD PTR[BX]
        CMP AX,X
        JNE CUT20

        MOV AX,SI
        PUSH CX
        MOV CL,2
        MUL CL
        POP CX
        LEA BX,SY
        ADD BX,AX
        MOV AX,WORD PTR[BX]
        CMP AX,Y
        JE CUT30
CUT20:
        INC SI
        ADD BX,2
        LOOP CUT10
        JMP CUT40
CUT30:
        MOV QUIT,1        
CUT40:
        RET



DELAY:    
        MOV AX, 8600H
        INT 15H
        RET



MODE:
        MOV AH,00
        INT 10H
        RET



DRAWPOINT:
        MOV AH,0CH
        INT 10H
        RET
    


FILLRECT:
        MOV AX,GX0
        MOV GX,AX
        MOV AX,GY0
        MOV GY,AX
        MOV CX,GH
FILLRECT10:
        PUSH CX
        MOV CX,GW
        MOV AX,GX0
        MOV GX,AX
FILLRECT20:
        PUSH CX
        MOV CX,GX
        MOV DX,GY
        MOV AL,GC
        CALL DRAWPOINT
        INC GX
        POP CX
        LOOP FILLRECT20
        INC GY
        POP CX
        LOOP FILLRECT10
        RET



SRAND:
        MOV     AH,00H
        INT     1AH
        MOV     SEED,DX
        RET



RAND:
        MOV     AX,SEED
        MUL     A
        ADC     AX,B
        MOV     B,DX
        MOV     SEED,AX
        MOV     DX,AX
        RET



MODULO:
        CMP     AX,BX
        JB      MODULO10
        SUB     AX,BX
        JMP     MODULO
MODULO10:
        RET


HIDECURSOR:
        MOV AH,01
        MOV CH,32
        MOV CL,00
        INT 10H
        RET


SHOWCURSOR:
     	MOV AH,01
        MOV CH,06
     	MOV CL,07
     	INT 10H
        RET



END BEGIN
