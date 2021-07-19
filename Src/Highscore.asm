;-------------------------------------------------------------------------
; GridRunner - highscore code
;-------------------------------------------------------------------------

.highscore_best
EQUS 17,2,"___ BEST  7 ___",0           ; 0 is used for terminator

.highscore_titles
EQUS 17,7,"RANK  SCORE    NAME",0

.highscore_entry
EQUS 17,8,"ENTER YOUR INITIALS",0

; Total of 7 highscores
.highscore_rank
EQUS "1ST",0
EQUS "2ND",0
EQUS "3RD",0
EQUS "4TH",0
EQUS "5TH",0
EQUS "6TH",0
EQUS "7TH",0

; highscore is 7 digits 0000000 
; and needs 4 location
.highscore1
EQUB $00,$00,$00,$00,$00,$00,$00

.highscore2
EQUB $00,$50,$00,$50,$00,$50,$10

.highscore3
EQUB $03,$02,$02,$01,$01,$00,$00

.highscore4
EQUB $00,$00,$00,$00,$00,$00,$00

.highscore_name
EQUS "STL",0
EQUS "JCM",0
EQUS "RTW",0
EQUS "STL",0
EQUS "JCM",0
EQUS "STL",0
EQUS "JCM",0

.osword_block
EQUW highscore_name_entry       ; address of highscore_name_entry
EQUB 3                          ; maximum number of characters
EQUB &20                        ; minimum allowed character
EQUB &7E                        ; maximum allowed characters

.highscore_name_entry
EQUS "   ",0 

;-------------------------------------------------------------------------
; CheckHighScore
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are undefined
;-------------------------------------------------------------------------
.CheckHighScore
{
    LDX #$06
.check_next_score
    LDA score4          
    CMP highscore4,X    ; Score four check
    BCC score_lower
    BNE score_higher
    ; score 4 is same
    LDA score3          
    CMP highscore3,X    ; score three check
    BCC score_lower
    BNE score_higher
    ; score 3 is the same
    LDA score2          
    CMP highscore2,X    ; score two check
    BCC score_lower
    BNE score_higher
    ; score 2 is the same
    LDA score1          
    CMP highscore1,X    ; score one check
    BCC score_lower

.score_higher
    DEX
    BPL check_next_score

.score_lower
    CPX #$06
    BNE new_high_score

    ; Not made the highscore table
    LDA #$FF
    STA highscoreposition
    JMP DisplayHighScore
    ; return

.new_high_score
    INX
    STX highscoreposition

    LDX #$06
    CPX highscoreposition
    BEQ skip_moving_scores_down

.move_high_score_loop    
    LDA highscore4 - 1,X
    STA highscore4,X
    LDA highscore3 - 1,X
    STA highscore3,X
    LDA highscore2 - 1,X
    STA highscore2,X
    LDA highscore1 - 1,X
    STA highscore1,X
    DEX
    CPX highscoreposition
    BNE move_high_score_loop

.skip_moving_scores_down
    ; insert highscore
    LDA score4
    STA highscore4,X
    LDA score3
    STA highscore3,X
    LDA score2
    STA highscore2,X
    LDA score1
    STA highscore1,X

    ; insert blank initials?
    TXA
    ASL A
    ASL A
    TAX
    ; 3 letters so don't bother with a loop
    LDA #' '
    STA highscore_name,X
    STA highscore_name + 1,X
    STA highscore_name + 2,X

    JMP DisplayHighScore
    ; return
}

;-------------------------------------------------------------------------
; DisplayHighScore
;-------------------------------------------------------------------------
; On entry  : highscoreposition $FF         - Display only
;           :                   $00 - $06   - highscore entry     
; On exit   :
;-------------------------------------------------------------------------
.DisplayHighScore
{
    JSR ClearScreen

    JSR showGridrunner

    LDX #03
    LDY #10
    JSR setTextPos

    LDA #highscore_best MOD 256:STA textstartaddr
    LDA #highscore_best DIV 256:STA textstartaddr+1
    JSR putText

    LDX #01
    LDY #13
    JSR setTextPos

    LDA #highscore_titles MOD 256:STA textstartaddr
    LDA #highscore_titles DIV 256:STA textstartaddr+1
    JSR putText

    LDX #0

.loop    
    STX saveX

    TXA
    ADC #1
    JSR setTextColour

    TXA
    ASL A
    ADC #15
    STA currentYPosition

    LDX #$02
    LDY currentYPosition
    JSR setTextPos

    ; show rank
    LDA #highscore_rank MOD 256 : STA textstartaddr
    LDA #highscore_rank DIV 256 : STA textstartaddr + 1

    LDA saveX
    ASL A
    ASL A
    TAY
    JSR putTextOffset
    
    LDA #07
    STA currentXPosition

    ; show highscore
    LDX saveX
    LDA highscore1,X : STA workspace4
    LDA highscore2,X : STA workspace4 + 1
    LDA highscore3,X : STA workspace4 + 2
    LDA highscore4,X : STA workspace4 + 3
    JSR PrintHighScore

    ; move 2 spaces along (could use tab)
    LDA #' '
    JSR oswrch
    LDA #' '
    JSR oswrch

    ; Show name
    LDA #highscore_name MOD 256 : STA textstartaddr
    LDA #highscore_name DIV 256 : STA textstartaddr+1

    LDA saveX
    ASL A
    ASL A
    TAY
    JSR putTextOffset

    INX
    CPX #7
    BNE loop

    ; if position is not FF then enter a new high score
    LDA highscoreposition
    BPL EnterHighScore
    RTS
}

;-------------------------------------------------------------------------
;EnterHighScore
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.EnterHighScore
{
    ; flush keyboard buffer
    LDA #$0F
    LDX #$FF
    JSR osbyte

    LDX #01
    LDY #07
    JSR setTextPos

    LDA #highscore_entry MOD 256:STA textstartaddr
    LDA #highscore_entry DIV 256:STA textstartaddr+1
    JSR putText

    ; set colour
    LDA highscoreposition
    ADC #1
    JSR setTextColour

    ; position on highscore line
    LDX #16
    LDA highscoreposition
    ASL A
    ADC #15
    TAY
    JSR setTextPos

    ; Read line from input OSWORD call
    LDA #0
    LDX #osword_block MOD 256
    LDY #osword_block DIV 256
    JSR osword

    ; Y contains line length including carriage return if used
    DEY         
    BMI skip_name_entry

    LDA highscoreposition
    ASL A
    ASL A
    ADC #$02
    TAX

.copy_name_loop   
    LDA highscore_name_entry,Y
    STA highscore_name,X
    DEX
    DEY
    BPL copy_name_loop

.skip_name_entry
    ; Clear enter you initials using 'space character' loop
    LDX #01
    LDY #07
    JSR setTextPos

    LDA #' '
.clear_loop
    JSR oswrch
    INX
    CPX #20
    BNE clear_loop

    LDA #$FF
    STA highscoreposition
    RTS
}

;-------------------------------------------------------------------------
