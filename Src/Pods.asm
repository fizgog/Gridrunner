;-------------------------------------------------------------------------
; GridRunner - Pod code
;-------------------------------------------------------------------------

POD_SIZE           = $28
POD_EMPTY_SLOT     = $FF

; This is the sequence in which the yellow pods decay before exploding.
.PodDecaySequence
EQUB    $EA,POD1,POD2,POD3,POD4,POD5,POD6,$FF

;-------------------------------------------------------------------------
; ClearPodArray
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains $FF
;           : X is underfined   
;-------------------------------------------------------------------------
.ClearPodArray
{
    LDA #POD_EMPTY_SLOT
    LDX #POD_SIZE
.loop  
    STA podArrayXPos,X
    STA podArrayYPos,X
    STA podArrayChar,X
    DEX 
    BPL loop
    RTS 
}

;-------------------------------------------------------------------------
; CreatePodArrayEntry
;-------------------------------------------------------------------------
; Called from Zappers when X and Y collide together
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.CreatePodArrayEntry
{
    LDX #POD_SIZE
.loop
    LDA podArrayChar,X
    CMP #POD_EMPTY_SLOT
    BEQ found_empty_space
    DEX
    BNE loop
    ; No free slots in the array
    RTS

.found_empty_space
    LDA #POD3
    STA currentCharacter
    STA podArrayChar,X
    LDA currentXPosition
    STA podArrayXPos,X
    LDA currentYPosition
    STA podArrayYPos,X
    JMP PlotCharSprite
}

;-------------------------------------------------------------------------
; UpdatePods
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdatePods
{
    LDA laserAndPodInterval
    CMP #$05
    BEQ start
    RTS

.start
    DEC laserAndPodInterval
    ; Loop through pod array to find and update all pods
    LDX #POD_SIZE
.loop
    LDA podArrayChar,X
    CMP #POD_EMPTY_SLOT 
    BEQ pod_not_found

    CMP #BOMB_DOWN
    BEQ pod_not_found

.decay_pod
    INC podArrayChar,X
    STA currentCharacter

    LDA podArrayXPos,X
    STA currentXPosition

    LDA podArrayYPos,X
    STA currentYPosition

    JSR PlotCharSprite

.pod_not_found   
    DEX
    BNE loop
    RTS
}

;-------------------------------------------------------------------------
; FindPod
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains pod [1-6]
;           : X contains index into array
;-------------------------------------------------------------------------
.FindPod
{
    LDX #POD_SIZE
.loop
    LDA podArrayXPos,X
    CMP currentXPosition
    BNE skip
    LDA podArrayYPos,X
    CMP currentYPosition
    BNE skip
    LDA podArrayChar,X
    RTS
.skip
    DEX
    BNE loop  
    LDA #GRID
    RTS
}

;-------------------------------------------------------------------------
