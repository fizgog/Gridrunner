;-------------------------------------------------------------------------
; GridRunner - Zapper code
;-------------------------------------------------------------------------

; Each level has it's own rate of fire for the zapper
.laserFrameRateForLevel
EQUB    $10,$10,$10,$0F,$0E,$0D,$0C,$0B
EQUB    $0A,$09,$09,$09,$09,$09,$09,$09
EQUB    $08,$08,$08,$08,$07,$07,$07,$07
EQUB    $07,$07,$07,$07,$07,$06,$06,$05

;-------------------------------------------------------------------------
; UpdateZappers
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.UpdateZappers
{
.start    
    DEC zapperFrameRate
    BNE zapperexit

    LDA #ZAPPER_FRAME_RATE
    STA zapperFrameRate
    
    LDA #ZAPPER_LEFT_X
    STA currentXPosition

    LDA leftZapperYPosition
    STA currentYPosition

    ; Could use EOR and remove space sprite from system
    LDA #SPACE
    STA currentCharacter
    JSR PlotCharSprite

    INC leftZapperYPosition
    LDA leftZapperYPosition
    CMP #ZAPPER_LEFT_MAX_Y
    BNE skip_left_zapper_reset

    LDA #ZAPPER_LEFT_MIN_Y
    STA leftZapperYPosition
    
.skip_left_zapper_reset
    ; plot left zapper
    LDA leftZapperYPosition
    STA currentYPosition
    LDA #LEFT_ZAPPER
    STA currentCharacter
    JSR PlotCharSprite

    LDA #ZAPPER_BOTM_Y
    STA currentYPosition
    LDA bottomZapperXPosition
    STA currentXPosition

    LDA #SPACE
    STA currentCharacter
    JSR PlotCharSprite

    INC bottomZapperXPosition
    LDA bottomZapperXPosition
    CMP #ZAPPER_BOTM_MAX_X
    BNE skip_bottom_zapper_reset

    LDA #ZAPPER_BOTM_MIN_X
    STA bottomZapperXPosition
.skip_bottom_zapper_reset
    ; plot bottom zapper
    LDA bottomZapperXPosition
    STA currentXPosition
    LDA #BOTTOM_ZAPPER
    STA currentCharacter
    JSR PlotCharSprite

    DEC laserAndPodInterval
    BNE zapperexit

    ; Fire zapper
    LDX #FireLaserSound MOD 256
    LDY #FireLaserSound DIV 256
    JSR PlaySound

    LDA #LASER_AND_POD_FRAME_RATE
    STA laserAndPodInterval

    LDA #$FF
    STA laserShootInterval

    ; Init Bottom zapper laser
    LDA #VERTICAL_LASER1
    STA laserCurrentCharacter
    LDA #ZAPPER_LEFT_MIN_X
    STA leftLaserXPosition
    LDA leftZapperYPosition
    STA leftLaserYPosition
    LDA #LASER_FIRE_Y
    STA bottomLaserYPosition
    LDA bottomZapperXPosition
    STA bottomLaserXPosition

.zapperexit
    RTS
}

;-------------------------------------------------------------------------
; DrawLaser
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawLaser{
    ;LDA bulletAndLaserFrameRate
    ;CMP #$05
    ;BEQ start
    ;RTS
    LDA laserShootInterval
    CMP #$FF
    BEQ start
    RTS
.start
    DEC bulletAndLaserFrameRate
    INC laserCurrentCharacter
    LDA laserCurrentCharacter
    CMP #VERTICAL_LASER2+1
    BNE skip_over
    
    LDA #VERTICAL_LASER1
    STA laserCurrentCharacter

.skip_over
    
    LDA laserCurrentCharacter
    STA currentCharacter

    ;Bottom laser code
    LDA #LASER_FIRE_Y
    STA bottomLaserYPosition

.bottom_laser_loop
    LDA bottomLaserXPosition
    STA currentXPosition
    LDA bottomLaserYPosition
    STA currentYPosition
    JSR PlotCharSprite

    DEC bottomLaserYPosition
    LDA bottomLaserYPosition
    CMP #MIN_Y
    BNE bottom_laser_loop

    ; Bottom laser shot ship
    LDA shipXPosition
    CMP bottomLaserXPosition
    BEQ destroy_ship
    
    ; Left laser fire
    LDA leftLaserYPosition
    STA currentYPosition

    LDA leftLaserXPosition
    STA currentXPosition

    ; This check is required for the first column
    CMP bottomLaserXPosition
    BEQ drop_pod

    LDA #GRID
    STA currentCharacter
    JSR PlotCharSprite

    INC leftLaserXPosition
    LDA leftLaserXPosition
    STA currentXPosition
    CMP bottomLaserXPosition
    BEQ drop_pod

    ; A contains current character found
    JSR getChar
    CMP #SHIP
    BEQ destroy_ship

    LDA laserCurrentCharacter
    CLC 
    SBC #$01
    STA currentCharacter
    JMP PlotCharSprite

.destroy_ship
    JSR WipeBottomLaser
    LDA #$00
    STA laserShootInterval
    JSR ExplodeShip
    RTS

.drop_pod
    JSR WipeBottomLaser

    LDA leftLaserYPosition
    STA currentYPosition
    JSR CreatePodArrayEntry
    LDA #$00
    STA laserShootInterval

.laserexitp
    RTS
}

;-------------------------------------------------------------------------
; WipeBottomLaser
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.WipeBottomLaser
{
    LDA #LASER_FIRE_Y
    STA currentYPosition
    LDA bottomLaserXPosition
    STA currentXPosition

    LDA #GRID
    STA currentCharacter
.loop
    JSR PlotCharSprite
    DEC currentYPosition
    LDA currentYPosition

    CMP #MIN_Y
    BNE loop
    RTS
}

;-------------------------------------------------------------------------
