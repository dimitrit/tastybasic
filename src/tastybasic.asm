
#ifdef zemu
tty_data        .equ 7ch                    ; Z80 Emulator
tty_status      .equ 7dh
rx_full         .equ 1
tx_empty        .equ 0
#else
; tty_data        .equ 67h                  ; SBC V2
; tty_status      .equ 68h
; rx_full         .equ 1
; tx_empty        .equ 0
#endif

ctrlc           .equ 03h
bs              .equ 08h
lf              .equ 0ah
cr              .equ 0dh
ctrlo           .equ 0fh
ctrlu           .equ 15h

                .org 0h
start:
                ld sp,stack                 ; ** Cold Start **
                ld a,0ffh
                jp init

;*************************************************************
;
; *** GETLN *** FNDLN (& FRIENDS) ***
;
; 'GETLN' READS A INPUT LINE INTO 'BUFFER'.  IT FIRST PROMPT
; THE CHARACTER IN A (GIVEN BY THE CALLER), THEN IT FILLS
; THE BUFFER AND ECHOS.  IT IGNORES LF'S AND NULLS, BUT STILL
; ECHOS THEM BACK.  RUB-OUT IS USED TO CAUSE IT TO DELETE
; THE LAST CHARACTER (IF THERE IS ONE), AND ALT-MOD IS USED TO
; CAUSE IT TO DELETE THE WHOLE LINE AND START IT ALL OVER.
; CR SIGNALS THE END OF A LINE, AND CAUSE 'GETLN' TO RETURN.
;
; 'FNDLN' FINDS A LINE WITH A GIVEN LINE # (IN HL) IN THE
; TEXT SAVE AREA.  DE IS USED AS THE TEXT POINTER.  IF THE
; LINE IS FOUND, DE WILL POINT TO THE BEGINNING OF THAT LINE
; (I.E., THE LOW BYTE OF THE LINE #), AND FLAGS ARE NC & Z.
; IF THAT LINE IS NOT THERE AND A LINE WITH A HIGHER LINE #
; IS FOUND, DE POINTS TO THERE AND FLAGS ARE NC & NZ.  IF
; WE REACHED THE END OF TEXT SAVE AREA AND CANNOT FIND THE
; LINE, FLAGS ARE C & NZ.
; 'FNDLN' WILL INITIALIZE DE TO THE BEGINNING OF THE TEXT SAVE
; AREA TO START THE SEARCH.  SOME OTHER ENTRIES OF THIS
; ROUTINE WILL NOT INITIALIZE DE AND DO THE SEARCH.
; 'FNDLNP' WILL START WITH DE AND SEARCH FOR THE LINE #.
; 'FNDNXT' WILL BUMP DE BY 2, FIND A CR AND THEN START SEARCH.
; 'FNDSKP' USE DE TO FIND A CR, AND THEN START SEARCH.
;*************************************************************
getline:
                call outc                   ; ** GetLine **
                ld de,buffer                ; prompt and initalise pointer
gl1:
                call chkio                  ; check keyboard
                jr z,gl1                    ; no input, so wait
                cp bs                       ; erase last character?
                jr z,gl3                    ; yes
                call outc                   ; echo character
                cp lf                       ; ignore lf
                jr z,gl1
                or a                        ; ignore null
                jr z,gl1
                cp ctrlu                    ; erase the whole line?
                jr z,gl4                    ; yes
                ld (de),a                   ; save the input
                inc de                      ; and increment pointer
                cp cr                       ; was it cr?
                ret z                       ; yes, end of line
                ld a,e                      ; any free space left?
                cp bufend & 0ffh
                jr nz,gl1                   ; yes, get next char
gl3:
                ld a,e                      ; delete last character
                cp buffer & 0ffh            ; if there are any?
                jr z,gl4                    ; no, redo whole line
                dec de                      ; yes, back pointer
                ld a,5ch                    ; and echo a backslash
                call outc
                jr gl1                      ; and get next character
gl4:
                call crlf                   ; redo entire line
                jr getline

;*************************************************************
;
; *** PRTSTG *** QTSTG *** PRTNUM *** & PRTLN ***
;
; 'PRTSTG' PRINTS A STRING POINTED BY DE.  IT STOPS PRINTING
; AND RETURNS TO CALLER WHEN EITHER A CR IS PRINTED OR WHEN
; THE NEXT BYTE IS THE SAME AS WHAT WAS IN A (GIVEN BY THE
; CALLER).  OLD A IS STORED IN B, OLD B IS LOST.
;
; 'QTSTG' LOOKS FOR A BACK-ARROW, SINGLE QUOTE, OR DOUBLE
; QUOTE.  IF NONE OF THESE, RETURN TO CALLER.  IF BACK-ARROW,
; OUTPUT A CR WITHOUT A LF.  IF SINGLE OR DOUBLE QUOTE, PRINT
; THE STRING IN THE QUOTE AND DEMANDS A MATCHING UNQUOTE.
; AFTER THE PRINTING THE NEXT 3 BYTES OF THE CALLER IS SKIPPED
; OVER (USUALLY A JUMP INSTRUCTION.
;
; 'PRTNUM' PRINTS THE NUMBER IN HL.  LEADING BLANKS ARE ADDED
; IF NEEDED TO PAD THE NUMBER OF SPACES TO THE NUMBER IN C.
; HOWEVER, IF THE NUMBER OF DIGITS IS LARGER THAN THE # IN
; C, ALL DIGITS ARE PRINTED ANYWAY.  NEGATIVE SIGN IS ALSO
; PRINTED AND COUNTED IN, POSITIVE SIGN IS NOT.
;
; 'PRTLN' PRINTS A SAVED TEXT LINE WITH LINE # AND ALL.
;*************************************************************
printstr:
                ld b,a
prtstr1:
                ld a,(de)                   ; get a character
                inc de                      ; bump pointer
                cp b                        ; same as old A?
                ret z                       ; yes, return
                call outc                   ; no, show character
                cp cr                       ; was it a cr?
                jr nz,prtstr1               ; no, next character
                ret                         ; yes, returns

msg1            .db "TASTY BASIC",cr
how             .db "HOW?",cr
ok              .db "OK",cr
what            .db "WHAT?",cr
sorry           .db "SORRY",cr

;*************************************************************
;
; *** MAIN ***
;
; THIS IS THE MAIN LOOP THAT COLLECTS THE TINY BASIC PROGRAM
; AND STORES IT IN THE MEMORY.
;
; AT START, IT PRINTS OUT "(CR)OK(CR)", AND INITIALIZES THE
; STACK AND SOME OTHER INTERNAL VARIABLES.  THEN IT PROMPTS
; ">" AND READS A LINE.  IF THE LINE STARTS WITH A NON-ZERO
; NUMBER, THIS NUMBER IS THE LINE NUMBER.  THE LINE NUMBER
; (IN 16 BIT BINARY) AND THE REST OF THE LINE (INCLUDING CR)
; IS STORED IN THE MEMORY.  IF A LINE WITH THE SAME LINE
; NUMBER IS ALREADY THERE, IT IS REPLACED BY THE NEW ONE.  IF
; THE REST OF THE LINE CONSISTS OF A CR ONLY, IT IS NOT STORED
; AND ANY EXISTING LINE WITH THE SAME LINE NUMBER IS DELETED.
;
; AFTER A LINE IS INSERTED, REPLACED, OR DELETED, THE PROGRAM
; LOOPS BACK AND ASKS FOR ANOTHER LINE.  THIS LOOP WILL BE
; TERMINATED WHEN IT READS A LINE WITH ZERO OR NO LINE
; NUMBER; AND CONTROL IS TRANSFERED TO "DIRECT".
;
; TINY BASIC PROGRAM SAVE AREA STARTS AT THE MEMORY LOCATION
; LABELED "TXTBGN" AND ENDS AT "TXTEND".  WE ALWAYS FILL THIS
; AREA STARTING AT "TXTBGN", THE UNFILLED PORTION IS POINTED
; BY THE CONTENT OF A MEMORY LOCATION LABELED "TXTUNF".
;
; THE MEMORY LOCATION "CURRNT" POINTS TO THE LINE NUMBER
; THAT IS CURRENTLY BEING INTERPRETED.  WHILE WE ARE IN
; THIS LOOP OR WHILE WE ARE INTERPRETING A DIRECT COMMAND
; (SEE NEXT SECTION). "CURRNT" SHOULD POINT TO A 0.
;*************************************************************
rstart:
                ld sp,stack
st1:
                call crlf
                sub a                       ; a=0
                ld de,ok                    ; print ok
                call printstr
                ld hl,st2 + 1               ; literal zero
                ld (current),hl             ; reset current line pointer
st2:
                ld hl,0000h
                ld (loopvar),hl
                ld (stkgos),hl
st3:
                ld a,'>'                    ; initialise prompt
                call getline
                jp st3


init:
                ld (ocsw),a                 ; enable output control switch
                ld d,19h                    ; clear the screen
patloop:
                call crlf                   ; by outputting 25 clear lines
                dec d
                jr nz,patloop
                ld de,msg1                  ; then output welcome message
                call printstr
                ld hl,start                  ; initialise random pointer
                ld (rndptr),hl
                ld hl,textbegin             ; initialise text area pointers
                ld (textunfilled),hl
                jp rstart

chkio:
                in a,(tty_status)           ; check if character available
                bit rx_full,a
                ret z                       ; no, return
                in a,(tty_data)             ; get the character
                push bc                     ; is it a lf?
                ld b,a
                sub lf
                jr z,io1                    ; yes, ignore an return
                ld a,b                      ; no, restore a and bc
                pop bc
                cp ctrlo                    ; is it ctrl-o?
                jr nz,io2                   ; no, done
                ld a,(ocsw)                 ; toggle output control switch
                cpl
                ld (ocsw),a
                jr chkio                    ; get next character
io1:
                ld a,0h                     ; clear
                or a                        ; set the z-flag
                pop bc                      ; restore bc
                ret                         ; return with z set
io2:
                cp ctrlc                    ; is it ctrl-c?
                ret nz                      ; no
                jp rstart                   ; yes, restart tasty basic

crlf:
                ld a,cr
outc:
                push af
                ld a,(ocsw)                 ; check output control switch
                or a
                jr nz,uart_tx               ; output is enabled
                pop af                      ; output is disabled
                ret                         ; so return
uart_tx:
                call uart_tx_ready          ; see if transmit is available
                pop af                      ; restore the character
                out (tty_data),a            ; and send it
                cp cr                       ; was it a cr?
                ret nz                      ; no, return
                ld a,lf                     ; send a lf
                call outc
                ld a,cr                     ; restore register
                ret                         ; and return
uart_tx_ready:
                push af
uart_tx_ready_loop:
                in a,(tty_status)
                bit tx_empty,a
                jp z,uart_tx_ready_loop
                pop af
                ret

               .org 01000h                  ; following must be in ram
               
ocsw           .ds 1                        ; output control switch
current        .ds 2                        ; points to current line
stkgos         .ds 2                        ; saves sp in 'GOSUB'
varnext        .ds 2                        ; temp storage
stkinp         .ds 2                        ; save sp in 'INPUT'
loopvar        .ds 2                        ; 'FOR' loop save area
loopinc        .ds 2                        ; loop increment
looplmt        .ds 2                        ; loop limit
loopln         .ds 2                        ; loop line number
loopptr        .ds 2                        ; loop text pointer
rndptr         .ds 2                        ; random number pointer
textunfilled   .ds 2                        ; -> unfilled text area
textbegin      .ds 2                        ; start of text save area
               .org 07fffh
textend        .ds 0                        ; end of text area
varbegin       .ds 55                       ; variable @(0)
buffer         .ds 80                       ; input buffer
bufend         .ds 0
stack          .equ 0fe00h
               .end
