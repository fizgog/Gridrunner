\ ******************************************************************
\ *	Gridrunner - Bombs code
\ ******************************************************************

; Should we actually use a seperate array or just piggy back
; on Pods array.
; POD_SIZE      = $28 - Located in pod.6502
BOMB_EMPTY_SLOT = $FF

;-------------------------------------------------------------------------
; UpdateBombs
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is either #BOMB_DOWN or underfined
;           : X is underfined
;-------------------------------------------------------------------------
.UpdateBombs
{
    ;Add this to slow down bomb decent
    ;DEC BombInterval
    ;BEQ start
    ;RTS

.start
    LDX #POD_SIZE
.loop
    LDA podArrayChar,X
    CMP #BOMB_DOWN
    BNE not_found
    JSR FallingBombs

.not_found
    DEX
    BNE loop
    RTS
}

;-------------------------------------------------------------------------
; FallingBombs
;-------------------------------------------------------------------------
; On entry  : A contains #BOMB_DOWN
;           : X contains index of bomb entry in the pod array
; On exit   : 
;-------------------------------------------------------------------------
.FallingBombs
{
    ; Save x index of falling bomb
    STX saveX

    LDA podArrayXPos,X
    STA currentXPosition

    LDA podArrayYPos,X
    STA currentYPosition
    
    ; Erase existing bomb
    LDA #GRID
    STA currentCharacter
    JSR PlotCharSprite

    INC currentYPosition
    LDA currentYPosition

    CMP #BOMB_MAX_Y
    BEQ remove_bomb

    JSR getChar
  
    CMP #GRID
    BEQ move_down

    CMP #BOMB_DOWN
    BEQ move_down

    CMP #SHIP
    BEQ explode_the_ship

    ; Remove pods in bombs path
    JSR CheckRemovePod
    
.move_down
    LDX saveX
    INC podArrayYPos,X
    LDA #BOMB_DOWN ;podArrayChar,X Should always be #BOMB_DOWN
    STA currentCharacter
    JMP PlotCharSprite
    ; Return

.remove_bomb
    LDX saveX
    LDA #BOMB_EMPTY_SLOT
    STA podArrayChar,X
    RTS

.explode_the_ship
    JMP ExplodeShip
    ; Return
}

;-------------------------------------------------------------------------
; CheckRemovePod
;-------------------------------------------------------------------------
; On entry  : A contains #POD (1-6)
;           : X contains index of pod entry in the pod array
; On exit   : A is unknown
;           : X is preserved
;-------------------------------------------------------------------------
.CheckRemovePod
{
    CMP #POD1
    BCC not_found       ; <

    CMP #POD6+1
    BCS not_found       ; >=

    ; Remove pod from the array
    LDA #$FF
    STA podArrayChar,X
    STA podArrayXPos,X
    STA podArrayYPos,X

.not_found
    RTS
}

;-------------------------------------------------------------------------
