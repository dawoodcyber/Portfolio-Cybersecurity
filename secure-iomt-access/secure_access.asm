;================================================
; IoMT Secure Access System
; AT89C52 - Keil A51 Compatible
; Crystal = 11.0592 MHz
; Password = 3434
;================================================

ORG 0000H
LJMP MAIN

;================================================
; BIT DEFINITIONS
;================================================

RS          BIT P3.5
EN          BIT P3.6

GREEN_LED   BIT P1.6
RED_LED     BIT P1.7
BUZZER      BIT P1.5

;================================================
; RAM VARIABLES
;================================================

ATTEMPT     EQU 30H
DIGIT1      EQU 31H
DIGIT2      EQU 32H
DIGIT3      EQU 33H
DIGIT4      EQU 34H

;================================================
; MAIN PROGRAM
;================================================

ORG 0100H




MAIN:

    MOV SP,#70H
    MOV ATTEMPT,#00H

    CLR GREEN_LED
    CLR RED_LED
	CLR BUZZER

    ACALL LCD_INIT

MAIN_LOOP:

    CLR GREEN_LED
    CLR RED_LED
	CLR BUZZER

    ACALL LCD_CLEAR
	

    MOV DPTR,#MSG_ENTER
    ACALL LCD_PRINT

    MOV A,#0C0H          ; Move cursor to Line 2, position 0
    ACALL LCD_COMMAND

;================================================
; GET PASSWORD
;================================================
;================================================
; GET 4-DIGIT PASSWORD (LOOP VERSION)
;================================================

GET_PASSWORD:

    MOV R0,#31H         ; Point to DIGIT1
    MOV R1,#04H         ; 4 digits required

GET_PASSWORD_LOOP:

    ACALL KEYPAD
    JZ GET_PASSWORD_LOOP

    MOV @R0,A           ; Store digit in RAM

    MOV A,#'*'
    ACALL LCD_DATA

    INC R0              ; Next RAM location

    DJNZ R1,GET_PASSWORD_LOOP

;================================================
; CHECK PASSWORD = 3434
;================================================

CHECK_PASSWORD:

    MOV A,DIGIT1
    CJNE A,#'3',WRONG_PASSWORD

    MOV A,DIGIT2
    CJNE A,#'4',WRONG_PASSWORD

    MOV A,DIGIT3
    CJNE A,#'3',WRONG_PASSWORD

    MOV A,DIGIT4
    CJNE A,#'4',WRONG_PASSWORD

;================================================
; ACCESS GRANTED
;================================================

ACCESS_GRANTED:

    SETB GREEN_LED
    CLR RED_LED

    ACALL LCD_CLEAR

    MOV DPTR,#MSG_GRANTED
    ACALL LCD_PRINT

    ACALL DELAY_10SEC

    CLR GREEN_LED
	MOV ATTEMPT,#00H
    SJMP MAIN_LOOP

;================================================
; WRONG PASSWORD
;================================================

WRONG_PASSWORD:

    INC ATTEMPT

    CLR GREEN_LED
    SETB RED_LED

    ACALL LCD_CLEAR

    MOV DPTR,#MSG_WRONG
    ACALL LCD_PRINT

    MOV A,ATTEMPT
    CJNE A,#03H,TRY_AGAIN

;================================================
; ACCOUNT BLOCKED
;================================================

ACCOUNT_BLOCKED:

    
	SETB RED_LED
	SETB BUZZER

    ACALL LCD_CLEAR

    MOV DPTR,#MSG_BLOCKED
    ACALL LCD_PRINT

    ACALL DELAY_10SEC

    CLR RED_LED
	CLR BUZZER

    MOV ATTEMPT,#00H
    LJMP MAIN_LOOP

;================================================
; TRY AGAIN
;================================================

TRY_AGAIN:

    ACALL DELAY_1SEC

    CLR RED_LED

    LJMP MAIN_LOOP

;================================================
; LCD INITIALIZATION
;================================================

LCD_INIT:

	ACALL DELAY_2SEC
    MOV A,#38H
    ACALL LCD_COMMAND

    MOV A,#0CH
    ACALL LCD_COMMAND

    MOV A,#01H
    ACALL LCD_COMMAND

    MOV A,#06H
    ACALL LCD_COMMAND

    RET

;================================================
; LCD COMMAND
;================================================

LCD_COMMAND:

    MOV P2,A

    CLR RS
    CLR EN

    SETB EN
    ACALL SMALL_DELAY
    CLR EN

    ACALL SMALL_DELAY

    RET

;================================================
; LCD DATA
;================================================

LCD_DATA:

    MOV P2,A

    SETB RS
    CLR EN

    SETB EN
    ACALL SMALL_DELAY
    CLR EN

    ACALL SMALL_DELAY

    RET

;================================================
; LCD CLEAR
;================================================

LCD_DELAY:

    MOV R5,#255

L1:
    MOV R6,#255

L2:
    DJNZ R6,L2
    DJNZ R5,L1

    RET

LCD_CLEAR:

    MOV A,#01H
    ACALL LCD_COMMAND

    ACALL LCD_DELAY

    RET

;================================================
; LCD PRINT STRING
;================================================

LCD_PRINT:

PRINT_LOOP:

    CLR A
    MOVC A,@A+DPTR

    JZ PRINT_END

    ACALL LCD_DATA

    INC DPTR

    SJMP PRINT_LOOP

PRINT_END:

    RET

;================================================
; SIMPLE DELAY
;================================================

SMALL_DELAY:

    MOV R7,#50

SD1:
    DJNZ R7,SD1

    RET
	
;================================================
; 1 SECOND DELAY
;================================================

DELAY_1SEC:

    MOV R5,#10

D1_LOOP1:

    MOV R6,#255

D1_LOOP2:

    MOV R7,#255

D1_LOOP3:

    DJNZ R7,D1_LOOP3
    DJNZ R6,D1_LOOP2
    DJNZ R5,D1_LOOP1

    RET
;================================================
; 2 SECOND DELAY
;================================================

DELAY_2SEC:

    MOV R5,#20

D2_LOOP1:

    MOV R6,#255

D2_LOOP2:

    MOV R7,#255

D2_LOOP3:

    DJNZ R7,D2_LOOP3
    DJNZ R6,D2_LOOP2
    DJNZ R5,D2_LOOP1

    RET

;================================================
; 10 SECOND DELAY
;================================================

DELAY_10SEC:

    MOV R4,#5

D10_LOOP:

    ACALL DELAY_2SEC
    DJNZ R4,D10_LOOP

    RET

;================================================
; 4x4 MATRIX KEYPAD
; ROWS -> P3.0-P3.3
; COLS -> P1.0-P1.3
;================================================

;================================================
; 4x4 MATRIX KEYPAD
; ROWS -> P3.0-P3.3
; COLS -> P1.0-P1.3
;================================================

KEYPAD:

    SETB P3.0
    SETB P3.1
    SETB P3.2
    SETB P3.3

;================ ROW 1 =================

CLR P3.0
SETB P3.1
SETB P3.2
SETB P3.3

JNB P1.0,KEY_1
JNB P1.1,KEY_2
JNB P1.2,KEY_3
JNB P1.3,KEY_A

;================ ROW 2 =================

SETB P3.0
CLR P3.1
SETB P3.2
SETB P3.3

JNB P1.0,KEY_4
JNB P1.1,KEY_5
JNB P1.2,KEY_6
JNB P1.3,KEY_B

;================ ROW 3 =================

SETB P3.0
SETB P3.1
CLR P3.2
SETB P3.3

JNB P1.0,KEY_7
JNB P1.1,KEY_8
JNB P1.2,KEY_9
JNB P1.3,KEY_C

;================ ROW 4 =================

SETB P3.0
SETB P3.1
SETB P3.2
CLR P3.3

JNB P1.0,KEY_STAR
JNB P1.1,KEY_0
JNB P1.2,KEY_HASH
JNB P1.3,KEY_D

NO_KEY:

    CLR A
    RET

;================================================
; KEY DEFINITIONS
;================================================

KEY_1:
    MOV A,#'1'
    ACALL WAIT_RELEASE
    RET

KEY_2:
    MOV A,#'2'
    ACALL WAIT_RELEASE
    RET

KEY_3:
    MOV A,#'3'
    ACALL WAIT_RELEASE
    RET

KEY_A:
    MOV A,#'A'
    ACALL WAIT_RELEASE
    RET

KEY_4:
    MOV A,#'4'
    ACALL WAIT_RELEASE
    RET

KEY_5:
    MOV A,#'5'
    ACALL WAIT_RELEASE
    RET

KEY_6:
    MOV A,#'6'
    ACALL WAIT_RELEASE
    RET

KEY_B:
    MOV A,#'B'
    ACALL WAIT_RELEASE
    RET

KEY_7:
    MOV A,#'7'
    ACALL WAIT_RELEASE
    RET

KEY_8:
    MOV A,#'8'
    ACALL WAIT_RELEASE
    RET

KEY_9:
    MOV A,#'9'
    ACALL WAIT_RELEASE
    RET

KEY_C:
    MOV A,#'C'
    ACALL WAIT_RELEASE
    RET

KEY_STAR:
    MOV A,#'*'
    ACALL WAIT_RELEASE
    RET

KEY_0:
    MOV A,#'0'
    ACALL WAIT_RELEASE
    RET

KEY_HASH:
    MOV A,#'#'
    ACALL WAIT_RELEASE
    RET

KEY_D:
    MOV A,#'D'
    ACALL WAIT_RELEASE
    RET

;================================================
; WAIT UNTIL KEY RELEASED
;================================================

WAIT_RELEASE:

WR1:

    JB P1.0,WR2
    SJMP WR1

WR2:

    JB P1.1,WR3
    SJMP WR1

WR3:

    JB P1.2,WR4
    SJMP WR1

WR4:

    JB P1.3,EXIT_RELEASE
    SJMP WR1

EXIT_RELEASE:

    ACALL SMALL_DELAY

    RET

;================================================
; STRINGS
;===============================================
MSG_ENTER:
DB 'Enter Password',00H

MSG_GRANTED:
DB 'Access Granted!',00H

MSG_WRONG:
DB 'Ooops, Try Again!',00H

MSG_BLOCKED:
DB 'Access Blocked',00H

END

