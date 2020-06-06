
DATA   SEGMENT 
INPUT0  DB  "Automatic identification without inputing point!",'$'
INPUT1  DB  "Please input a bin string: ",'$' 
INPUT2  DB  "Please input another bin string: ",'$'  
STR1 DB "X=",'$'
STR2 DB "Y=",'$'
STR3 DB "-[X]=",'$'
STR4 DB "[X]=",'$'
STR5 DB "[Y]=",'$'
STR6 DB "[XY]=",'$'

BUFFER1 DB 20  ;获取X
N1 DB ?   ;自动获取输入的字符个数
DB  20  DUP(0)
BUFFER2 DB 20  ;获取Y
N2 DB ?
DB  20  DUP(0) 

FX DB 20
DB  20  DUP(0) 
X DB 20
DB  20  DUP(0) 
Y DB 20
DB  20  DUP(0) 
C DB 20 
DB  20  DUP(0) 
                                ;部分积

CRLF   DB  0AH, 0DH,'$' 
DATA   ENDS 

CODE   SEGMENT                              
ASSUME CS:CODE, DS:DATA           
START:                                       
        MOV AX, DATA                         
        MOV DS, AX
        LEA DX, INPUT0                       ;打印提示输入信息    
        MOV AH, 09H							 
        INT 21H
        LEA DX, CRLF                         ;另取一行                   
        MOV AH, 09H							 
        INT 21H
        LEA DX, INPUT1                          
        MOV AH, 09H							 
        INT 21H
        LEA DX, BUFFER1                      ;接收字符串
        MOV AH, 0AH
        INT 21H
        MOV AL, N1
        ADD AL, 2                            ;对字符串处理
        MOV AH, 0
        MOV SI, AX
        MOV BUFFER1[SI], '$'
        LEA DX, CRLF                         ;另取一行                   
        MOV AH, 09H							 
        INT 21H

        LEA DX, INPUT2                          
        MOV AH, 09H							 
        INT 21H
        LEA DX, BUFFER2                      
        MOV AH, 0AH
        INT 21H
        MOV AL, N2
        ADD AL, 2                            
        MOV AH, 0
        MOV SI, AX
        MOV BUFFER2[SI], '$'
        LEA DX, CRLF                                        
        MOV AH, 09H							 
        INT 21H
        LEA DX, CRLF                                            
        MOV AH, 09H							 
        INT 21H
        
        LEA DX, STR1                        
        MOV AH, 09H							 
        INT 21H
        LEA DX, BUFFER1+2
		MOV AH, 09H							 
        INT 21H

		MOV AH,2
		MOV DL,20H
		INT 21H
		MOV AH,2
		MOV DL,20H
		INT 21H

        LEA DX, STR2                         ;打印Y信息    
        MOV AH, 09H							 
        INT 21H
        LEA DX, BUFFER2+2
		MOV AH, 09H							 
        INT 21H

;[X]----------------------------
        XOR DX, DX
SYMBOL1:
		MOV DL, BUFFER1[2]
		CMP DL, '-'
		JZ SYMBOL2
		CMP DL, '1'                     
		JZ DEAL2                      
        MOV BL, N1                      ;为正补一个0
        MOV BH, 0
        ADD BX, 1
        MOV CX, BX
        MOV SI, BX
FOR1:   
		MOV DL, BUFFER1[BX]
		MOV BUFFER1[BX+1], DL
		DEC BX
		LOOP FOR1
		MOV DL, '0'
		MOV BUFFER1[2], DL
		MOV BUFFER1[SI+2], '$'
		MOV DL, N1
		INC DL
		MOV N1, DL
		JMP ZHENG
DEAL2:
		MOV BL, N1                      ;为负补一个1
        MOV BH, 0
        ADD BX, 1
        MOV CX, BX
        MOV SI, BX
FOR2:	
		MOV DL, BUFFER1[BX]
		MOV BUFFER1[BX+1], DL
		DEC BX
		LOOP FOR2
		MOV DL, '1'
		MOV BUFFER1[2], DL
		MOV BUFFER1[SI+2], '$'
		MOV DL, N1
		INC DL
		MOV N1, DL
		JMP BUMA1

SYMBOL2:
		MOV DL, BUFFER1[3]
		CMP DL, '1'                       
		JZ DEAL1                        ;-1为正
		MOV DL, '1'                     ;-0为负
		MOV BUFFER1[2], DL
		MOV BUFFER1[3], DL
		JMP BUMA1
DEAL1:
		MOV DL, '0'
		MOV BUFFER1[2], DL
		MOV BUFFER1[3], DL 
;传送原码到X保存-----------------

ZHENG:	LEA SI, BUFFER1+2

		MOV AX, SEG X
		MOV ES,AX
		LEA DI, X
		MOV CH, 0
		MOV CL, N1
		INC CX

		REP MOVSB

		JMP YUAN1

BUMA1:	
		MOV DL, BUFFER1[2]
		MOV X[0], DL                        ;符号位不变
		MOV DL, BUFFER1[3]
		MOV X[1], DL
		MOV BX, 4

ZERO2:
		MOV DL, BUFFER1[BX]
		CMP DL, '1'
		JNZ ONE2
		MOV DL, '0'
		MOV X[BX-2], DL
		INC BX
		JMP AGAIN2
ONE2:
		MOV DL, '1'
		MOV X[BX-2], DL
		INC BX
AGAIN2:	
		CMP BUFFER1[BX], '$'
		JNZ ZERO2

PRINT1:	
		MOV CX, 10
		MOV DL, N1
		MOV DH, 0
		MOV BX, DX
		DEC BX
		MOV AX, BX
S2:		
		MOV DL, X[BX]
		CMP DL, '0'
		JZ ONE5
		DEC BX
		LOOP S2 		

ONE5:
		MOV DL, X[BX]
		CMP DL, '0'
		JNZ ZERO5
		MOV DL, '1'
		MOV X[BX], DL
		INC BX
		JMP AGAIN5
ZERO5:
		MOV DL, '0'
		MOV X[BX], DL
		INC BX
AGAIN5:	
		CMP BX, AX
		JBE ONE5

YUAN1: 
		MOV BL, N1                  
        MOV BH, 0
		MOV SI, BX
		MOV X[SI],'$'
		LEA DX, CRLF                         ;另取一行                   
        MOV AH, 09H							 
        INT 21H
		LEA DX, STR4                         ;打印[x]信息    
        MOV AH, 09H							 
        INT 21H
		LEA DX, X
		MOV AH, 09H				 
        INT 21H

;[-X]--------------------------
		XOR DX, DX
		MOV SI, 4

		MOV DL, X[0]
		CMP DL, '1'
		JZ QUFU
		MOV DL, '1'
		MOV FX[0], DL
		MOV FX[1], DL
BUMA3:	
		MOV BX, 2

ZERO7:
		MOV DL, X[BX]
		CMP DL, '1'
		JNZ ONE7
		MOV DL, '0'
		MOV FX[BX], DL
		INC BX
		JMP AGAIN7
ONE7:
		MOV DL, '1'
		MOV FX[BX], DL
		INC BX
AGAIN7:	
		CMP X[BX], '$'
		JNZ ZERO7

	
		MOV CX, 10
		MOV DL, N1
		MOV DH, 0
		MOV BX, DX
		DEC BX
		MOV AX, BX
S5:		
		MOV DL, FX[BX]
		CMP DL, '0'
		JZ ONE8
		DEC BX
		LOOP S5		

ONE8:
		MOV DL, FX[BX]
		CMP DL, '0'
		JNZ ZERO8
		MOV DL, '1'
		MOV FX[BX], DL
		INC BX
		JMP AGAIN8
ZERO8:
		MOV DL, '0'
		MOV FX[BX], DL
		INC BX
AGAIN8:	
		CMP BX, AX
		JBE ONE8
		JMP PRINT3
QUFU:
		MOV DL, '0'
		MOV FX[0], DL
		MOV FX[1], DL
AGAIN1:	
		MOV DL, BUFFER1[SI]
		MOV FX[SI-2], DL
		INC SI

		CMP BUFFER1[SI], '$'
		JNZ AGAIN1

PRINT3:	MOV BL, N1                      
        MOV BH, 0
		MOV SI, BX
		MOV FX[SI], '$'

		MOV AH,2
		MOV DL,20H
		INT 21H
		MOV AH,2
		MOV DL,20H
		INT 21H

        LEA DX, STR3                         ;打印[-x]信息    
        MOV AH, 09H						 
        INT 21H
		LEA DX, FX
		MOV AH, 09H					 
        INT 21H

;[Y]----------------------------
		XOR DX, DX
		MOV AL, N2
		MOV AH, 0
		MOV SI, 4
		MOV CX, AX
		DEC CX
		DEC CX
		MOV DL, BUFFER2[2]
		CMP DL, '-'
		JZ SYMBOL4
		CMP DL, '1'                     
		JZ BUMA2                     
		JMP ZHENG1

SYMBOL4:
		MOV DL, BUFFER2[3]
		CMP DL, '1'                       
		JZ DEAL3                        ;-1为正
		MOV DL, '1'                     ;-0为负
		MOV BUFFER2[2], DL
XH1:	MOV DL, BUFFER2[SI]
		MOV BUFFER2[SI-1], DL
		INC SI
		LOOP XH1
		MOV SI, AX
		INC SI
		MOV BUFFER2[SI], '$'
		MOV DL, N2
		DEC DL
		MOV N2, DL
		JMP BUMA2
DEAL3:

		MOV DL, '0'
		MOV BUFFER2[2], DL
XH2:	MOV DL, BUFFER2[SI]
		MOV BUFFER2[SI-1], DL
		INC SI
		LOOP XH2
		MOV SI, AX
		INC SI
		MOV BUFFER2[SI], '$' 
		MOV DL, N2
		DEC DL
		MOV N2, DL		

;传送原码到Y保存-----------------
ZHENG1:	LEA SI, BUFFER2+2

		MOV AX, SEG Y
		MOV ES,AX
		LEA DI, Y
		MOV CH, 0
		MOV CL, N2

		REP MOVSB

		JMP YUAN2

BUMA2:	
		MOV BX, 3
		MOV DL, BUFFER2[2]
		MOV Y[0], DL                        ;符号位不变

ZERO3:
		MOV DL, BUFFER2[BX]
		CMP DL, '1'
		JNZ ONE3
		MOV DL, '0'
		MOV Y[BX-2], DL
		INC BX
		JMP AGAIN3
ONE3:
		MOV DL, '1'
		MOV Y[BX-2], DL
		INC BX
AGAIN3:	
		CMP BUFFER2[BX], '$'
		JNZ ZERO3

PRINT2:	
		MOV CX, 10
		MOV DL, N2
		MOV DH, 0
		MOV BX, DX
		DEC BX
		MOV AX, BX
S3:		
		MOV DL, Y[BX]
		CMP DL, '0'
		JZ ONE6
		DEC BX
		LOOP S3 		

ONE6:
		MOV DL, Y[BX]
		CMP DL, '0'
		JNZ ZERO6
		MOV DL, '1'
		MOV Y[BX], DL
		INC BX
		JMP AGAIN6
ZERO6:
		MOV DL, '0'
		MOV Y[BX], DL
		INC BX
AGAIN6:	
		CMP BX, AX
		JBE ONE6

YUAN2:	
		MOV DL, N2
		MOV DH, 0
		INC DL
		MOV N2, DL
		MOV DL, N2
		MOV SI, DX
		MOV Y[SI-1], '0'
		MOV Y[SI], '$'

PRINT4:
		MOV BL, N1                      
        MOV BH, 0
		MOV SI, BX
		MOV Y[SI], '$'
		MOV AH,2
		MOV DL,20H
		INT 21H
		MOV AH,2
		MOV DL,20H
		INT 21H
		LEA DX, STR5                         ;打印[Y]信息    
        MOV AH, 09H							 
        INT 21H
		LEA DX, Y
		MOV AH, 09H					 
        INT 21H


;至此求补码完毕-----------------------
;开始计算乘法-------------------------
		
		MOV DL, N1                           ;初始化部分积C
		MOV DH, 0
		MOV CX, DX
		LEA BX, C
		MOV DL, '0'
CHU:	MOV [BX],DL
		INC BX
		LOOP CHU

		MOV DL, N1                           
		MOV DH, 0
		MOV BX, DX
		PUSH BX

		MOV DL, N2
		MOV DH, 0
		MOV SI, DX
		PUSH SI

		MOV DH, 0
D1:		MOV DL, 0
		INC DH
		POP SI
		POP BX
		PUSH BX
		PUSH SI
		DEC SI

		CMP N2, DH
		JZ ESP1
		CMP DH, 2
		JB S0

		MOV CX, SI
		MOV AL, C[BX-1]
S1:		MOV DL, Y[SI-1]
		MOV Y[SI], DL
		DEC SI
		LOOP S1
		MOV Y[0], AL
		MOV CX, BX
		DEC CX	
S4:		
		DEC BX
		MOV DL, C[BX-1]
		MOV C[BX], DL
		LOOP S4
		POP SI
		POP BX
		PUSH BX
		PUSH SI
		DEC SI

S0:		MOV AL, Y[SI]
		MOV DL, Y[SI-1]
		CMP DL, AL
		JZ DENG0                             ;00或11
		JG A10                               ;10
		JL A01							     ;01

DENG0: 	
		JMP D1	

ESP0:	JMP D1
ESP1:	JMP FINISH
ESP2:	JMP D1

A10:   
		MOV AH, 30H
B10:	DEC BX
		MOV DL, FX[BX]                     
		MOV AL, C[BX]
		ADD DL, AL
		ADD DL, AH
		CMP DL, 93H
		JZ JW0
		CMP DL, 92H 
		JZ JW1
		CMP DL, 91H
		JZ Z10
		MOV DL, '0'
		MOV C[BX], DL
		CMP FX[BX-1], 0
		JZ ESP0
		JMP A10

Z10:	MOV DL, '1'
		MOV C[BX], DL
		CMP FX[BX-1], 0
		JZ ESP0
		JMP A10 

JW1:	MOV AH, 31H
		MOV DL, '0'
		MOV C[BX], DL
		CMP FX[BX-1], 0
		JZ ESP2
		JMP B10 

JW0:
		MOV AH, 31H
		MOV DL, '1'
		MOV C[BX], DL
		CMP FX[BX-1], 0
		JZ ESP0
		JMP B10         


ESP3:	JMP ESP0
ESP4:	JMP FINISH
ESP5:	JMP ESP2

A01:   
		MOV AH, 30H
B01:	DEC BX
		MOV DL, X[BX]                       
		MOV AL, C[BX]
		ADD DL, AL
		ADD DL, AH
		CMP DL, 93H
		JZ JW2
		CMP DL, 92H
		JZ JW3
		CMP DL, 91H
		JZ Z11
		MOV DL, '0'
		MOV C[BX], DL
		CMP X[BX-1], 0
		JZ ESP3
		JMP A01

Z11:	MOV DL, '1'
		MOV C[BX], DL
		CMP X[BX-1], 0
		JZ ESP3
		JMP A01 

JW3:	MOV AH, 31H
		MOV DL, '0'
		MOV C[BX], DL
		CMP X[BX-1], 0
		JZ ESP3
		JMP B01 

JW2:
		MOV AH, 31H
		MOV DL, '1'
		MOV C[BX], DL
		CMP X[BX-1], 0
		JZ ESP3
		JMP B01         


FINISH: 
		LEA DX, CRLF                         ;另取一行                   
        MOV AH, 09H							 
        INT 21H

        MOV CX, 4
        LEA BX, C
        MOV DL, N1                    
		MOV DH, 0
		MOV BX, DX
		MOV SI, 0
S00:    MOV DL, Y[SI]
		MOV C [BX+SI], DL    
		INC SI
		LOOP S00
		MOV C[1], '.'
    	MOV BX, -1
S01:	INC BX
		CMP C[BX], 0 
		JNZ S01
		MOV C[BX], '$'

		LEA DX, STR6                        
        MOV AH, 09H							 
        INT 21H
		LEA DX, C
		MOV AH, 09H					 
        INT 21H

		MOV AH, 4CH                          ;返回DOS系统
        INT 21H

CODE   ENDS                                  
END    START