;-------------------------------------------------------------------------
; GridRunner - Droid code
;-------------------------------------------------------------------------

; Droid segment info
; 00 - Middle segment    00000000
; 01 - Going left mask   00000001
; 02 - Going right mask  00000010
; 03 -                   00000011
; 40 - Head segment      01000000
; 41 - head going right  01000001
; 42 - head going left   01000010
; 80 - tail segment      10000000  
; FD - ?                 11111101 

DROID_SIZE = $FF ; Using 1 page each for x, y and droid segment info
DROID_EMPTY_SLOT = $FF

; Max 32 levels 
.noOfDroidSquadsForLevel
EQUB    $01,$02,$02,$03,$03,$03,$04,$04
EQUB    $04,$04,$05,$05,$10,$06,$06,$06
EQUB    $06,$06,$06,$06,$06,$06,$06,$06
EQUB    $06,$06,$07,$07,$07,$07,$07,$07

.sizeOfDroidSquadsForLevels
EQUB    $06,$06,$06,$07,$07,$08,$08,$09
EQUB    $0C,$0C,$0A,$0A,$03,$0F,$10,$10
EQUB    $11,$12,$13,$14,$14,$14,$15,$15
EQUB    $16,$16,$16,$17,$03,$18,$18,$19

;-------------------------------------------------------------------------
; ClearDroidArray
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains $FF
;           : X is underfined
;-------------------------------------------------------------------------
.ClearDroidArray
{
    LDA #DROID_EMPTY_SLOT
    LDX #DROID_SIZE
.loop  
    STA droidStatusArray,X
    STA droidXPositionArray,X
    STA droidYPositionArray,X
    DEX 
    BNE loop
    RTS 
}
;-------------------------------------------------------------------------
; DrawDroids
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are undefined
;-------------------------------------------------------------------------
.DrawDroids
{
    DEC droidFrameRate
    BEQ start

.droid_exit    
    RTS
 
.start
    LDA #DROID_FRAME_RATE
    STA droidFrameRate
    JSR UpdateDroidsRemaining
    LDA noOfDroidSquadsCurrentLevel
    BEQ droid_exit

    TAX
    INC currentDroidCharacter
    LDA currentDroidCharacter
    CMP #LEADER4+1
    BNE droid_head_reset_bypass

    LDA #LEADER1
    STA currentDroidCharacter

.droid_head_reset_bypass
    STX currentDroidIndex
    
    ; Draw grid over
    LDA droidXPositionArray,X
    STA currentXPosition
    LDA droidYPositionArray,X
    STA currentYPosition

    LDA #GRID
    STA currentCharacter
    JSR DrawDroidSegment

    LDX currentDroidIndex
    LDA droidStatusArray,X
    AND #$40                    ;  Head segment (left or right)
    BNE DroidBody
    
    ; Draw segment
    LDA droidXPositionArray - $01,X
    STA droidXPositionArray,X
    STA currentXPosition
    LDA droidYPositionArray - $01,X
    STA droidYPositionArray,X
    STA currentYPosition

    LDA #DROID
    STA currentCharacter
    JSR PlotCharSprite

.resume_drawing_droids
    LDX currentDroidIndex
    DEX
    BNE droid_head_reset_bypass
    RTS
    ; Return

.DroidBody
    LDA droidStatusArray,X
    AND #$02
    BNE DroidMovingLeft
    
    INC currentXPosition
    INC currentXPosition

.DroidMovingLeft
    DEC currentXPosition

    LDA currentXPosition
    CMP #MAX_X
    BEQ over

    CMP #$00
    BEQ over
    
    JSR getChar
    CMP #GRID
    BEQ add_droid 

    CMP #SHIP
    BNE over
    JMP ExplodeShip
    ; Return
   
 .over  
    LDX currentDroidIndex
    JSR CheckShipCollision
    STA currentXPosition
    INC currentYPosition
    LDA currentYPosition
    CMP #DROID_MAX_Y
    BNE not_reached_bottom

    ; Reached bottom
    LDA droidStatusArray,X
    ORA #$01                    ; %00000001
    AND #$FD                    ; %11111101
    STA droidStatusArray,X
  
    ; Jump back to position 14 of the grid
    LDA #$01
    STA droidXPositionArray,X
    STA currentXPosition
    LDA #DROIDYR
    STA droidYPositionArray,X
    STA currentYPosition

    JMP add_segment
    ; Return

.not_reached_bottom
    LDA droidStatusArray,X
    EOR #$03
    STA droidStatusArray,X

    ; Draw the droid segment
.add_segment    
    LDA currentXPosition
    STA droidXPositionArray,X
    LDA currentYPosition
    STA droidYPositionArray,X

    LDA currentDroidCharacter
    STA currentCharacter
    JSR PlotCharSprite

    LDX currentDroidIndex
    JMP resume_drawing_droids
    ; Return

.add_droid
    LDX currentDroidIndex
    JMP add_segment  
    ; Return          
}

;-------------------------------------------------------------------------
; CheckShipCollision
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.CheckShipCollision
{
    ;CMP #SHIP
    ;BEQ over
    LDA droidXPositionArray,X
.over    
    RTS
}

;-------------------------------------------------------------------------
; DrawDroidSegment
;-------------------------------------------------------------------------
; On entry  : X contains droid index
; On exit   : A is underfined
;           : X is preserved
;-------------------------------------------------------------------------
.DrawDroidSegment
{
    LDA droidStatusArray,X
    AND #$80                    ; %10000000 - Tail segment
    BEQ segment_exit
    JMP PlotCharSprite
    ; Return

.segment_exit
    RTS    
}

;-------------------------------------------------------------------------
; UpdateDroidsRemaining
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are underfined
;-------------------------------------------------------------------------
.UpdateDroidsRemaining ; Create new droid?
{
    LDA droidParts
    BNE create_droid
    DEC droidTimer
    BEQ start
    RTS 
    ; Return

.create_droid
    INC noOfDroidSquadsCurrentLevel
    LDX noOfDroidSquadsCurrentLevel
    LDA #$0A
    STA droidXPositionArray,X
    LDA #DROID_MIN_Y
    STA droidYPositionArray,X
    LDA #$00
    STA droidStatusArray,X
    DEC droidParts
    LDA droidParts
    CMP #$01
    BEQ remove_droid_part
    RTS 
    ; Return

.remove_droid_part 
    DEC droidParts
    DEC droidsLeftToKill
    LDA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray,X
    RTS    
    ; Return

.start
    LDA droidsLeftToKill
    BNE init_leader_roid
    RTS 
    ; Return

.init_leader_roid
    LDA #DROID_TIMER
    STA droidTimer
    LDA sizeOfDroidSquadForLevel
    STA droidParts
    INC noOfDroidSquadsCurrentLevel
    LDX noOfDroidSquadsCurrentLevel
    LDA #$0A
    STA droidXPositionArray,X
    LDA #DROID_MIN_Y
    STA droidYPositionArray,X
    LDA #$41                        ; Head going right
    STA droidStatusArray,X
    RTS   
}

;-------------------------------------------------------------------------
; UpdateDroidStatus
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateDroidStatus
{
    STX currentDroidIndex
.droid_loop
    DEX
    LDA droidStatusArray,X
    AND #$40                        ; Head segment (left or right)
    BEQ droid_loop
    LDA droidStatusArray,X
    NOP
    NOP
    LDX currentDroidIndex
    JSR toggle_droid_control_state
    LDA droidStatusArray - $01,X
    ORA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray - $01,X
    RTS
    ; Return

.toggle_droid_control_state
    ORA droidStatusArray + $01,X
    STA droidStatusArray + $01,X
    RTS        
}

;-------------------------------------------------------------------------
; DroidCollision
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DroidCollision
{
    ;JSR PlayExplosion
    LDX #ExplosionSound MOD 256
    LDY #ExplosionSound DIV 256
    JSR PlaySound

    CMP #DROID
    BEQ droid_segment_hit
    ; Otherwise Lead droid hit
    ; Increase score by 300 (Head is worth 400)
    LDA #$03
    JSR AddScore100
    
.droid_segment_hit
    ; Increase score by 100 (segment is worth 100)
    LDA #$01
    JSR AddScore100

    LDA #PAL_white
    STA currentColour
    JSR PrintScore

    ; Remove bullet
    LDA #$FF
    STA bulletYPosition

    LDX noOfDroidSquadsCurrentLevel
.droid_hit_position
    LDA droidXPositionArray,X
    CMP currentXPosition
    BEQ droid_has_been_hit ; found
.droid_hit_wrong_position  
    DEX    
    BNE droid_hit_position
    RTS
    ; Return

.droid_has_been_hit
    LDA droidYPositionArray,X
    CMP currentYPosition
    BNE droid_hit_wrong_position
    LDA droidStatusArray,X
    AND #$C0
    BNE droid_control_character
    JSR UpdateDroidStatus

    ;Update droid arrays
.droid_loop    
    LDA droidYPositionArray + $01,X
    STA droidYPositionArray,X
    LDA droidXPositionArray + $01,X
    STA droidXPositionArray,X
    LDA droidStatusArray + $01,X
    STA droidStatusArray,X
    CPX noOfDroidSquadsCurrentLevel
    BEQ droid_segment_destroyed
    INX
    JMP droid_loop
    ; Return

.droid_segment_destroyed  
    DEC noOfDroidSquadsCurrentLevel
    ; Drop pod
    JMP CreatePodArrayEntry
    ; Return

.droid_control_character
    CMP #$C0                        ; %11000000
    BEQ droid_loop
    CMP #$40                        ; %01000000 - Head segment (left or right)
    BEQ droid_head
    LDA droidStatusArray - $01,X
    ORA #$80                        ; %10000000 - Tail segment
    STA droidStatusArray - $01,X
    JMP droid_loop
    ; Return

.droid_head
    LDA droidStatusArray + $01,X
    ORA droidStatusArray,X
    STA droidStatusArray + $01,X
    JMP droid_loop
    ; Return
}

;-------------------------------------------------------------------------
; FindDroid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains either #GRID, #DROID or #LEADER1
;           : X contains index into array
;-------------------------------------------------------------------------
.FindDroid
{
    LDX #DROID_SIZE
.loop
    LDA droidXPositionArray,X
    CMP currentXPosition
    BNE skip
    LDA droidYPositionArray,X
    CMP currentYPosition
    BNE skip

    ; Droid found - but which part of it
    LDA droidStatusArray,X
    AND #$40                    ; %01000000 - Head segment (left or right)
    BEQ segment_found
    
    LDA #LEADER1
    RTS
    ; Return

.segment_found
    LDA #DROID
    RTS
    ; Return

.skip
    DEX
    BNE loop
    LDA #GRID ; Default to Grid        
    RTS
}

;-------------------------------------------------------------------------


