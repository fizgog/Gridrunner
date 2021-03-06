;-------------------------------------------------------------------------
; Gridrunner - Mode 2 Edition
;-------------------------------------------------------------------------
; BBC Conversion Shaun Lindsley
; Thanks to Jef Minter for producing an excellent game for the VIC20
; Special thanks to Rich Talbot-Watkins for the following: -
; BeebASm     - https://www.retrosoftware.co.uk/beebasm
; BeebSpriter - https://www.retrosoftware.co.uk/beebspriter
;-------------------------------------------------------------------------

; Memory space map
; NB somethings may be wrong

; &0000-&008F Language workspace            - Can be used
; &008F-&00FF                               - ????
; &0100-&01FF 6502 Stack                    - Don't use ***
; &0200-&02FF OS Workspace                  - Don't use ***
; &0300-&03FF OS Workspace                  - Don't use ***
; &0400-&04FF Basic workspace               - Can be used
; &0500-&05FF Basic workspace               - Can be used
; &0600-&06FF String buffer                 - Can be used
; &0700-&07FF Line input buffer             - Can be used
; &0800-&08FF Sound workspace               - Don't use as sound is required ***
; &0900-&09BF Envelopes 5-16                - Can be used if we only used enveloped below 5
; &09C0-&09FF Speech buffer                 - Can be used
; &0A00-&0AFF RS423 or Cassette buffer      - Can be used
; &0B00-&0BFF SoftKey (Function Keys)       - Can be used
; &0C00-&0CFF Chacter Defination 128-159    - Required for GRIDRUNNER characters - could use sprites though?
; &0D00-&0DFF OS Workspace                  - Don't use ***

; Sprites so far are 0x420 bytes (1,056 bytes in decimal) 
; We could load sprites into address 0900 - 0BFF (3 pages) 
; We could load sprites into address 0900 - 0CFF (4 pages) - if we don't need user defined chars
; NB That is if we run out of room


; Use following for vsync debugging
; LDA #&00: STA &FE21 ;white
; LDA #&01: STA &FE21 ;cyan
; LDA #&02: STA &FE21 ;magenta 
; LDA #&03: STA &FE21 ;blue 
; LDA #&04: STA &FE21 ;yellow
; LDA #&05: STA &FE21 ;green
; LDA #&06: STA &FE21 ;red
; LDA #&07: STA &FE21 ;black

; Defines

osrdch = &FFE0
osasci = &FFE3
oswrch = &FFEE
osword = &FFF1
osbyte = &FFF4
oscli  = &FFF7

PAL_black	= 0
PAL_red		= 1
PAL_green	= 2
PAL_yellow	= 3
PAL_blue	= 4
PAL_magenta = 5
PAL_cyan	= 6
PAL_white	= 7

; Frame rates
SHIP_FRAME_RATE             = $02
BULLET_FRAME_RATE           = $01
DROID_FRAME_RATE            = $03
ZAPPER_FRAME_RATE           = $0A
LASER_AND_POD_FRAME_RATE    = $0B
DROID_TIMER                 = $20
BOMB_FRAME_RATE             = $01

; Screen and grid sizes changes here to handle different modes
; for example Mode 1
SCOREXPOS           = 1
SCOREYPOS           = 1
HISCOREXPOS         = 13
HISCOREYPOS         = 1

MIN_X               = 1    
MIN_Y               = 2
MAX_X               = 20
MAX_Y               = 29

GRID_MIN_X          = MIN_X+1
GRID_MAX_X          = MAX_X-1
GRID_MIN_Y          = MIN_Y+1
GRID_MAX_Y          = MAX_Y-1

SHIP_MIN_Y          = MAX_Y-10       ; How far ship can travel up the grid
SHIP_MAX_Y          = MAX_Y-1
SHIP_START_X        = MAX_X / 2     ; Used for Ship start x position

ZAPPER_LEFT_X       = 0             ; Static
ZAPPER_LEFT_MIN_Y   = GRID_MIN_Y
ZAPPER_LEFT_MAX_Y   = MAX_Y-1

ZAPPER_BOTM_Y       = MAX_Y         ; Static
ZAPPER_BOTM_MIN_X   = MIN_X
ZAPPER_BOTM_MAX_X   = MAX_X

ZAPPER_LEFT_MIN_X   = MIN_X         ; Left zapper min x pos
LASER_MAX_X         = MAX_X
LASER_MAX_Y         = MAX_Y

LASER_FIRE_Y        = ZAPPER_BOTM_Y-1

BOMB_MAX_Y          = MAX_Y         ; How far down can the bomb go

DROID_MIN_Y         = GRID_MIN_Y
DROID_MAX_X         = MAX_X         ; Currently not used ??
DROID_MAX_Y         = MAX_Y         ; How far down can the droid go
DROIDYR             = MAX_Y-11      ; Droid row restart after getting to end of grid

; Key codes
keyCodeESCAPE       = &8F
keyCodeRETURN       = &B6
keyCodeZ            = &9E
keyCodeX            = &BD
keyCodeColon        = &B7
keyCodeForwardSlash = &97
keyCodeP            = &C8
keyCodeS            = &AE
keyCodeJ            = &BA

; Sprite index
VERTICAL            = 0  ; 00
GRID                = 1  ; 01
LEFT_ZAPPER         = 2  ; 02
BOTTOM_ZAPPER       = 3  ; 03
HORIZ_LASER1        = 4  ; 04
HORIZ_LASER2        = 5  ; 05
VERTICAL_LASER1     = 6  ; 06
VERTICAL_LASER2     = 7  ; 07
SHIP                = 8  ; 08
BULLET_UP1          = 9  ; 09
BULLET_UP2          = 10 ; 0A
POD1                = 11 ; 0B
POD2                = 12 ; 0C
POD3                = 13 ; 0D
POD4                = 14 ; 0E
POD5                = 15 ; 0F
POD6                = 16 ; 10
BOMB_DOWN           = 17 ; 11
BOMB_RIGHT          = 18 ; 12 Not used in game
BOMB_LEFT           = 19 ; 13 Not used in game
EXPLOSION1          = 20 ; 17
EXPLOSION2          = 21 ; 18
EXPLOSION3          = 22 ; 19
LEADER1             = 23 ; 1A
LEADER2             = 24 ; 1B
LEADER3             = 25 ; 1C
LEADER4             = 26 ; 1D
DROID               = 27 ; 1E
SPACE               = 28 ; 1F
SOUND_ON            = 29 ; 20
SOUND_OFF           = 30 ; 21
PAUSE_ICON          = 31 ; 22
JOYSTICK_ICON       = 32 ; 23

; Define some zp locations
ORG 0

currentXPosition            = $02   ; Current char and position
currentYPosition            = $03
currentCharacter            = $04
currentColour               = $05
                            ; $06
                            ; $07
                            ; $08
currentExplosionCharacter   = $09   ; Ship
materializeShipOffset       = $0A
shipXPosition               = $0B
shipYPosition               = $0C
shipAnimationFrameRate      = $0D
                            ; $0E
bulletAndLaserFrameRate     = $0F   ; Bullets
bulletXPosition             = $10
bulletYPosition             = $11
bulletCharacter             = $12
                            ; $13
zapperFrameRate             = $14   ; Zappers
leftZapperYPosition         = $15
bottomZapperXPosition       = $16
laserAndPodInterval         = $17   ; Laser
laserShootInterval          = $18
laserCurrentCharacter       = $19
leftLaserXPosition          = $1A
leftLaserYPosition          = $1B
bottomLaserXPosition        = $1C
bottomLaserYPosition        = $1D
laserFrameRate              = $1E
PodInterval                 = $1F
currentDroidCharacter       = $20   ; Droid
noOfDroidSquadsCurrentLevel = $21
currentDroidIndex           = $22
droidsLeftToKill            = $23
droidFrameRate              = $24
droidTimer                  = $25
droidParts                  = $26
sizeOfDroidSquadForLevel    = $27
selectedLevel               = $28
shipLives                   = $29
highscoreposition           = $2A
CheckCharacter              = $2B ; No longer required ?
pauseFlag                   = $2C
soundFlag                   = $2D   
joystickFlag                = $2E  
specialCounter              = $2F

; Score 0000000 - 4 bytes for the BCD score
score1                      = $30   ; 00
score2                      = $31   ; 00
score3                      = $32   ; 00
score4                      = $33   ; 0
                            ; $34
                            ; $35
                            ; $36
                            ; $37
                            ; $39
                            ; $3A
                            ; $3B
                            ; $3C
                            ; $3D
                            ; $3E
                            ; $3F
workspace4                  = $40    ; and also &41, &42, &43
                            ; $44 - $6F
length                      = $70
counter                     = $71
counter2                    = $72
Temp                        = $73
Temp2                       = $74
saveX                       = $75   ; instead of stack
saveY                       = $76   ; instead of stack
saveA                       = $77   ; instead of stack
XYScreenAddress             = &78 ; and also &79 (&FFFF)
                            ; $7A - $84
textstartaddr               = &85 ; and also &86 (&FFFF)

ORG &0400
; Max 40 pods and/or bombs at each x,y coords use podArray to store
podArrayXPos = &0400            ; 0400-0427
podArrayYPos = &0428            ; 0428-0449
podArrayChar = &0450            ; 0450-0477

; Ship explosion array 8 bytes for each x and y coords
explosionXPosArray  = &0480     ; 0480-0487
explosionYPosArray  = &0490     ; 0490-0497

ORG &0500
; Droid array 255 bytes $FF
droidXPositionArray = &0500     ; 0500-05FF
droidYPositionArray = &0600     ; 0600-06FF
droidStatusArray    = &0700     ; 0700-07FF

ORG &1900
GUARD &3000

.start

;-------------------------------------------------------------------------
; Initialise
;-------------------------------------------------------------------------
.Initialise

    ; wipe zero page
    LDA #0
    LDX #$FF
.zp_loop
    STA 0,X
    DEX
    BNE zp_loop

    ; switch to mode 2 and initialise
    LDX #0   
.init_loop
    LDA setup_screen,X
    JSR oswrch
    INX
    CPX #18
    BNE init_loop

    ; Turn off Auto Repeat vsync_delay ?
    LDX #0
    LDA #$0B
    JSR osbyte
    
    LDA #$80                ; %10000000 - set bit 7 to 1
    STA pauseFlag           ; NB
    STA soundFlag           ; Use BMI if bit 7 is 1
    STA joystickFlag        ; Use BPL if bit 7 is 0

    LDA #15                 ; Countdown timer for pressing special keys
    STA specialCounter

    LDA #$FF                ; DEfault to $FF for no entry into highscore
    STA highscoreposition

;-------------------------------------------------------------------------
; TitleScreen
;-------------------------------------------------------------------------
.TitleScreen
{
    ; TODO reset plater score when game starts
    ; so it's still there in the title screens
    ; Reset Player 1 Score
    LDA #0
    STA score1
    STA score2
    STA score3
    STA score4

    ; Reset ships to 5
    LDA #5
    STA shipLives

    ; Reset level
    LDA #1
    STA selectedLevel

    LDA #PAL_white
    STA currentColour

    LDX #SCOREXPOS
    LDY #SCOREYPOS
    JSR setTextPos
    JSR PrintScore

    LDA #HISCOREXPOS
    STA currentXPosition
    LDA #HISCOREYPOS
    STA currentYPosition

    LDX #0
    LDA highscore1,X : STA workspace4
    LDA highscore2,X : STA workspace4 + 1
    LDA highscore3,X : STA workspace4 + 2
    LDA highscore4,X : STA workspace4 + 3
    JSR PrintHighScore

    JSR TitleAttractMode
    
    ; selected level is 0 based
    DEC selectedLevel
}

;-------------------------------------------------------------------------
; NextLevel
;-------------------------------------------------------------------------
.NextLevel    
    JSR DisplayNextLevel
    JSR DrawNewLevelScreen
    ; Drop through to game loop

;-------------------------------------------------------------------------
; MainLoop - Game
;-------------------------------------------------------------------------
.MainLoop
    JSR CheckSpecialKeys

    JSR UpdateShip
    JSR UpdateBullet
    JSR UpdateZappers
    JSR DrawLaser
    JSR UpdatePods
    JSR UpdateBombs
    JSR DrawDroids

    LDA #1
    JSR vsync_delay

    JSR CheckLevelComplete

    ; Quit pressed
    BIT joystickFlag
    BPL joystick_in_use

    LDX #keyCodeESCAPE
    JSR isKeyPressed
    BNE MainLoop
    ; Should we exit program with Escape or not?
    BEQ TitleScreen

.joystick_in_use
    JSR isJoystickPressed
    BCC MainLoop
    ; Should we exit program with Escape or not?
    BCS TitleScreen
    
.exit_game
    ; Never gets here as we don't Escape out of game
    ; Break key exists game
    RTS

;-------------------------------------------------------------------------
; TitleAttractMode
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.TitleAttractMode
{
.title
    JSR DisplayTitleScreen

.update_level
    LDA #0
    STA counter2

    LDA #4
    JSR vsync_delay

    LDX #15
    LDY #13
    JSR setTextPos

    LDA selectedLevel
    JSR BCDtoScreen

.title_screen_loop
    
    JSR CheckSpecialKeys
    
    LDA #1
    JSR vsync_delay
    INC counter2
    BEQ high_score

.Check_key_up
    LDX #keyCodeColon
    JSR isKeyPressed
    BNE Check_key_down

    LDA selectedLevel
    CMP #$31
    BEQ title_screen_loop
    SED
    ADC #1
    STA selectedLevel
    CLD
    BNE update_level

.Check_key_down
    LDX #keyCodeForwardSlash
    JSR isKeyPressed
    BNE Check_fire
    LDA selectedLevel
    CMP #$01
    BEQ title_screen_loop
    SED
    SBC #1
    STA selectedLevel
    CLD
    BNE update_level

.Check_fire    
    LDX #keyCodeRETURN
    JSR isKeyPressed
    BNE title_screen_loop

    JSR isJoystickPressed
    BCS title_screen_loop

    RTS
    ; Return

.high_score
    LDA #0
    STA counter2
    JSR DisplayHighScore

.high_score_loop

    JSR CheckSpecialKeys

    LDA #1
    JSR vsync_delay
    INC counter2
    BEQ title
    LDX #keyCodeRETURN
    JSR isKeyPressed
    BNE high_score_loop

    JSR isJoystickPressed
    BCS title_screen_loop

    RTS
    ; Return
}

;-------------------------------------------------------------------------
; showGridrunner
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.showGridrunner
{
    LDX #05
    LDY #04
    JSR setTextPos

    LDA #GridrunnerLogo MOD 256:STA textstartaddr
    LDA #GridrunnerLogo DIV 256:STA textstartaddr+1
    JMP putText
    ; Return
}    

;-------------------------------------------------------------------------
; DisplayTitle
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayTitleScreen
{
    JSR ClearScreen

    JSR showGridrunner

    LDX #0
    LDY #0
    JSR setTextPos

    LDA #GridrunnerScores MOD 256:STA textstartaddr
    LDA #GridrunnerScores DIV 256:STA textstartaddr+1
    JSR putText

    ; Designer
    LDA #PAL_yellow
    JSR setTextColour

    LDX #5
    LDY #7
    JSR setTextPos
    LDA #author MOD 256: STA textstartaddr
    LDA #author DIV 256: STA textstartaddr+1
    JSR putText

    LDA #PAL_white
    JSR setTextColour
        
    ; BBC conversion
    LDX #5
    LDY #9
    JSR setTextPos
    LDA #conversion MOD 256: STA textstartaddr
    LDA #conversion DIV 256: STA textstartaddr+1
    JSR putText

    ; Fire to start
    LDX #1
    LDY #17
    JSR setTextPos
    LDA #helptext MOD 256: STA textstartaddr
    LDA #helptext DIV 256: STA textstartaddr+1
    JSR putText

    LDA #PAL_red
    JSR setTextColour

    ; Level Select
    LDX #3
    LDY #13
    JSR setTextPos

    LDA #levelSelectText MOD 256: STA textstartaddr
    LDA #levelSelectText DIV 256: STA textstartaddr+1
    JSR putText
    RTS
}

;-------------------------------------------------------------------------
; CheckLevelComplete
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.CheckLevelComplete
{
    LDA droidsLeftToKill
    BNE not_complete
    LDA noOfDroidSquadsCurrentLevel
    BNE not_complete
    
    ; selected level is 0 based
    INC selectedLevel
    JSR DisplayNextLevel
    JMP DrawNewLevelScreen

.not_complete
    RTS
}

;-------------------------------------------------------------------------
; GameOver
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.GameOver
{
    ; Display and enter new highscore if achieved 
    JSR CheckHighScore
    
    LDA #$80
    JSR vsync_delay

    JMP TitleScreen
    ; Return
}

;-------------------------------------------------------------------------
; DisplayNextLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DisplayNextLevel
{
    JSR ClearScreen

    JSR showGridrunner

    LDA #PAL_green
    JSR setTextColour

    LDX #6
    LDY #8
    JSR setTextPos

    LDA #LivesLeft MOD 256: STA textstartaddr
    LDA #LivesLeft DIV 256: STA textstartaddr+1
    JSR putText
    LDA shipLives
    JSR BCDtoScreen

    LDA #PAL_red
    JSR setTextColour

    LDX #3
    LDY #12
    JSR setTextPos

    LDA #BattleStations MOD 256: STA textstartaddr
    LDA #BattleStations DIV 256: STA textstartaddr+1
    JSR putText

    LDA #PAL_white
    JSR setTextColour

    LDX #2
    LDY #14
    JSR setTextPos

    LDA #EnterGridArea MOD 256: STA textstartaddr
    LDA #EnterGridArea DIV 256: STA textstartaddr+1
    JSR putText

    LDA #8
    JSR setTextColour

    INC selectedLevel
    LDA selectedLevel

    JSR BCDtoScreen
    DEC selectedLevel

    ;Level Select Sound
    LDX #LevelSelectSound MOD 256
    LDY #LevelSelectSound DIV 256
    JSR PlaySound 

    LDA #$80
    JSR vsync_delay
    JMP PrepareNextLevel
}

;-------------------------------------------------------------------------
; PrepareNextLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.PrepareNextLevel
{
    LDA selectedLevel
    CMP #$20 ; 32 levels only
    BNE over  
    DEC selectedLevel
.over    
    LDX selectedLevel
    LDA noOfDroidSquadsForLevel,X
    STA droidsLeftToKill
    LDA sizeOfDroidSquadsForLevels,X
    STA sizeOfDroidSquadForLevel
    LDA laserFrameRateForLevel,X
    STA laserFrameRate
    RTS
}

;-------------------------------------------------------------------------
; DrawNewLevel
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawNewLevelScreen
{
    JSR ClearScreen
    JSR DrawGrid

    JSR MaterializeShip
    JSR ClearPodArray
    JSR ClearDroidArray

    ; Init Ship
    LDA #SHIP_FRAME_RATE
    STA shipAnimationFrameRate

    LDA #DROID_FRAME_RATE
    STA droidFrameRate

    LDA #BULLET_FRAME_RATE
    STA bulletAndLaserFrameRate

    LDA #$FF
    STA bulletXPosition
    STA bulletYPosition

    ; Init Zappers
    LDA #ZAPPER_FRAME_RATE
    STA zapperFrameRate

    LDA #ZAPPER_BOTM_MIN_X
    STA bottomZapperXPosition
    LDA #ZAPPER_LEFT_MIN_Y
    STA leftZapperYPosition

    LDA #LASER_AND_POD_FRAME_RATE
    STA laserAndPodInterval
    STA laserShootInterval

    LDA #$00
    STA noOfDroidSquadsCurrentLevel
    
    LDA #LEADER1
    STA currentDroidCharacter
    
    ;LDA #DROID_TIMER
    LDA #$01
    STA droidTimer

    LDA sizeOfDroidSquadForLevel
    STA sizeOfDroidSquadForLevel
    
    LDA droidsLeftToKill 
    STA droidsLeftToKill
    
    LDA #$00
    STA droidParts
    RTS
}

;-------------------------------------------------------------------------
; DrawGrid
;-------------------------------------------------------------------------
; On entry  :
; On exit   : 
;-------------------------------------------------------------------------
.DrawGrid
{
    ; Draw Vertical section
    LDA #VERTICAL
    STA currentCharacter

    LDX #1
.draw_vertical_line_loop
    STX currentXPosition
    LDY #GRID_MIN_Y
.draw_horizontal_line_loop    
    STY currentYPosition
    JSR PlotCharSprite

    INY
    CPY #MAX_Y
    BNE draw_horizontal_line_loop
    INX
    CPX #MAX_X
    BNE draw_vertical_line_loop

    ; Draw Grid section
    LDA #GRID
    STA currentCharacter

    LDY #GRID_MIN_Y
.draw_vertical_line_loop2    
    STY currentYPosition
    LDX #1
.draw_horizontal_line_loop2
    STX currentXPosition
    JSR PlotCharSprite
    INX
    CPX #MAX_X
    BNE draw_horizontal_line_loop2
    INY
    CPY #MAX_Y
    BNE draw_vertical_line_loop2
    RTS
}

include "ship.asm"
include "zappers.asm"
include "pods.asm"
include "bombs.asm"
include "droids.asm"
include "highscore.asm"

;-------------------------------------------------------------------------
; AddScore100's
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : 
;-------------------------------------------------------------------------
.AddScore100
{
    SED
    CLC
    ADC score2
    JMP AddScore100s    ; Jump into AddScore10 instead to save on code
    ;STA score2

    ;LDA score3
    ;ADC #$00
    ;STA score3

    ;LDA score4
    ;ADC #$00
    ;STA score4
    ;CLD
    ;RTS
}

;-------------------------------------------------------------------------
; AddScore10's
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : 
;-------------------------------------------------------------------------
.AddScore10
{
    SED
    CLC
    ADC score1
    STA score1

    LDA score2
    ADC #$00
.^AddScore100s      ; Global label - called from AddScore100    
    STA score2

    LDA score3
    ADC #$00
    STA score3

    LDA score4
    ADC #$00
    STA score4
    CLD
    RTS
}

;-------------------------------------------------------------------------
; ClearScreen
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A and X are underfined
;-------------------------------------------------------------------------
.ClearScreen
{
    LDX #6
.loop
    LDA mode2_clear_grid,X
    JSR oswrch
    DEX
    BPL loop
    RTS
}

;-------------------------------------------------------------------------
; CalcXYCharAddress
;-------------------------------------------------------------------------
; 8x8 Character based address calculation only
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.CalcXYCharAddress
{
    TYA
    PHA

    LDA currentYPosition
    ASL A                       ; A = A * 2
    TAY

    LDA LookUp640,  Y   : STA XYScreenAddress
    LDA LookUp640 + 1,Y : STA XYScreenAddress + 1

    LDA #$30                    ; Mode 2 Base screen location MSB
    ADC XYScreenAddress + 1
    STA XYScreenAddress + 1

    LDA #0
    STA Temp
    LDA currentXPosition
    ASL A                       ; A = A * 2     
    ASL A                       ; A = A * 4     
    ASL A                       ; A = A * 8     
    ROL Temp                    ; Save carry
    ASL A                       ; A = A * 16    
    ROL Temp                    ; Save carry
    ASL A                       ; A = A * 32
    ROL Temp                    ; Save carry

    ADC XYScreenAddress
    STA XYScreenAddress
    LDA Temp
    ADC XYScreenAddress + 1
    STA XYScreenAddress + 1

    PLA
    TAY
    RTS
}

;-------------------------------------------------------------------------
; PlotCharSprite
;-------------------------------------------------------------------------
; This plots an 8x8 sprite at character position X,Y
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.PlotCharSprite
{
    TXA
    PHA

    JSR CalcXYCharAddress   ; Screen address is stored in XYScreenAddress

    LDA XYScreenAddress:STA sprite_write+1
    LDA XYScreenAddress+1:STA sprite_write+2

    LDA currentCharacter
    ASL A   ; A = A * 2 (2 bytes for address)
    TAX
    LDA sprlist,X: STA sprite_read+1
    LDA sprlist+1,X: STA sprite_read+2

    LDX #31 ; game sprites are always 8x8 (Mode 2 are 4 bits * 8 bits => 0-31)
.sprite_read    
    LDA $FFFF,X
.sprite_write    
    STA $FFFF,X
    DEX
    BPL sprite_read
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; GetChar
;-------------------------------------------------------------------------
; LDA #$87 : JSR osbyte - Too slow - don't ever use
;-------------------------------------------------------------------------
; On entry  :
; On exit   : A contains sprite character index
;           : X may contain index into pod array
;-------------------------------------------------------------------------
.getChar 
{
    JSR FindShip
    CMP #SHIP
    BEQ found

    JSR FindDroid
    CMP #GRID
    BNE found

    JSR FindPod
    CMP #GRID
    BNE found

.found
    RTS    
}   

;-------------------------------------------------------------------------
; PutChar - obsolete too slow - use PlotCharSprite instead
;-------------------------------------------------------------------------
; On entry  :
; On exit   :
;-------------------------------------------------------------------------
;.putChar
;{
;    LDA currentColour
;    JSR setTextColour

;    LDX currentXPosition
;    LDY currentYPosition
;    JSR setTextPos

;    LDA currentCharacter
;    JMP oswrch
;}

;-------------------------------------------------------------------------
; PrintScore
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : X and Y are preserved
;-------------------------------------------------------------------------
.PrintScore
{
    TXA
    PHA
    TYA
    PHA

    LDA currentColour
    JSR setTextColour

    LDX #SCOREXPOS
    LDY #SCOREYPOS
    JSR setTextPos

    LDA score4
    JSR BCDtoScreenOneChar
    LDA score3
    JSR BCDtoScreen
    LDA score2
    JSR BCDtoScreen
    LDA score1
    JSR BCDtoScreen
    
    PLA
    TAY
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; PrintHighScore
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : X and Y are preserved
;-------------------------------------------------------------------------
.PrintHighScore
{
    TXA
    PHA
    TYA
    PHA

    LDX currentXPosition
    LDY currentYPosition
    JSR setTextPos

    LDA workspace4 + 3
    JSR BCDtoScreenOneChar
    LDA workspace4 + 2
    JSR BCDtoScreen
    LDA workspace4 + 1
    JSR BCDtoScreen
    LDA workspace4
    JSR BCDtoScreen
    
    PLA
    TAY
    PLA
    TAX
    RTS
}

;-------------------------------------------------------------------------
; BCDtoScreen
;-------------------------------------------------------------------------
; On entry  : A contains value
; On exit   : A is underfined
;           : X and Y are preserved
;-------------------------------------------------------------------------
.BCDtoScreen
{
    PHA
    LSR A:LSR A:LSR A:LSR A
    JSR onedigit
    PLA
.*BCDtoScreenOneChar    ; Global label    
    AND #$0F
.onedigit    
    ORA #48
    JMP oswrch
}

;-------------------------------------------------------------------------
; CheckSpecialKeys
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.CheckSpecialKeys
{
    LDA specialCounter
    DEC specialCounter
    BEQ start
    BNE exit
    
.start
    LDA #15
    STA specialCounter

    ; Sound On / Off
    LDX #keyCodeS
    JSR isKeyPressed
    BNE not_sound
    LDA soundFlag
    EOR #$80
    STA soundFlag

.not_sound
    ; Pause On / Off
    LDX #keyCodeP
    JSR isKeyPressed
    BNE not_pause
    LDA pauseFlag
    EOR #$80
    STA pauseFlag

.not_pause
    ; Keyboard / Joystick
    LDX #keyCodeJ
    JSR isKeyPressed
    BNE not_keyboard_joystick
    LDA joystickFlag
    EOR #$80
    STA joystickFlag

.not_keyboard_joystick
  
.exit
    JSR ShowSpecials

    ; if pause then loop back
    BIT pauseFlag
    BMI special_exit
    LDA #1
    JSR vsync_delay
    
    BIT pauseFlag
    BPL CheckSpecialKeys
    
.special_exit
    RTS
}

;-------------------------------------------------------------------------
; ShowSpecial
;-------------------------------------------------------------------------
; Display icons along the bottom right
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.ShowSpecials
{
    LDY #30
    STY currentYPosition

    ; Pause icon
    LDX #39
    STX currentXPosition
    LDA #PAUSE_ICON
    STA currentCharacter
    BIT pauseFlag
    BPL shows_pause_on

    LDA #SPACE
    STA currentCharacter

.shows_pause_on    
    JSR PlotCharSprite

    ; Sound icon
    LDX #38
    STX currentXPosition
    
    LDA #SOUND_ON
    STA currentCharacter

    BIT soundFlag
    BMI show_sound_on

    LDA #SOUND_OFF
    STA currentCharacter

.show_sound_on    
    JSR PlotCharSprite

    ; Joystick icon
    LDX #37
    STX currentXPosition
    LDA #JOYSTICK_ICON
    STA currentCharacter

    BIT joystickFlag
    BPL show_joysatick_on
    
    LDA #SPACE
    STA currentCharacter

.show_joysatick_on
    JSR PlotCharSprite

    RTS
}

;-------------------------------------------------------------------------
; IsKeyPressed
;-------------------------------------------------------------------------
; On entry  : X contains inkey value
; On exit   : A is preserved
;           : X contains key value
;           : Y is underfined
;-------------------------------------------------------------------------
.isKeyPressed
{
    LDA #$81
    LDY #$FF
    JSR osbyte
    CPX #$FF
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickPressed
;-------------------------------------------------------------------------
; On entry  : 
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickPressed
{
    LDX #$00
    LDA #&80
    JSR osbyte
    TXA
    LSR A
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickMoved1
;-------------------------------------------------------------------------
; On entry  : X contains
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickMoved1
{
    LDA #&80
    JSR osbyte
    CPY #$25
    RTS
}

;-------------------------------------------------------------------------
; IsJoystickMoved2
;-------------------------------------------------------------------------
; On entry  : X contains 
; On exit   : 
;-------------------------------------------------------------------------
.isJoystickMoved2
{
    LDA #&80
    JSR osbyte
    CPY #$DB
    RTS
}

;-------------------------------------------------------------------------
; SetTextColour
;-------------------------------------------------------------------------
; On entry  : A contains colour value
; On exit   : A is preserved
;-------------------------------------------------------------------------
.setTextColour
{
    PHA
    LDA #17
    JSR oswrch
    PLA
    JMP oswrch
}

;-------------------------------------------------------------------------
; SetTextPos
;-------------------------------------------------------------------------
; On entry  : X contains horizontal character position
;           : Y contains vertical character position
; On exit   : A is undefined
;           : X and y are preserved
;-------------------------------------------------------------------------
.setTextPos
{
    LDA #31
    JSR oswrch
    TXA
    JSR oswrch
    TYA
    JMP oswrch
}

;-------------------------------------------------------------------------
; PutText
;-------------------------------------------------------------------------
; On entry  : A contains text address
; On exit   : A and Y are undefined
;-------------------------------------------------------------------------
.putText
{
    LDY #0
    JMP putTextOffset
}

;-------------------------------------------------------------------------
; PutTextOffset
;-------------------------------------------------------------------------
; On entry  : A contains text address
;           : Y contains offset into text
; On exit   : A and Y are undefined
;-------------------------------------------------------------------------
.putTextOffset
{
.loop
    LDA (textstartaddr),Y 
    BEQ finished
    JSR osasci
    INY
    BNE loop
.finished
    RTS
}

;-------------------------------------------------------------------------
; PlaySound
;-------------------------------------------------------------------------
; On entry  : X and Y point to sound address
; On exit   : A contains 7
;-------------------------------------------------------------------------
.PlaySound
{
    BIT soundFlag
    BPL sound_exit
    LDA #$07
    JMP osword

.sound_exit
    RTS
}

;-------------------------------------------------------------------------
; vsync_delay
;-------------------------------------------------------------------------
; On entry  : A contains duration
; On exit   : A contains 19   
;           : X and Y are underfined
;-------------------------------------------------------------------------
.vsync_delay
{
    STA counter
.vsync_delay_loop    
    LDA #19
    JSR osbyte

    DEC counter
    BNE vsync_delay_loop
    CLI
    RTS
}
;-------------------------------------------------------------------------

; Mode 2
.setup_screen
EQUB 22,2
EQUB 23,1,0,0,0,0,0,0,0,0
EQUB 19,9,1,0,0,0

.mode2_clear_grid 
EQUB 26,12,2,19,30,0,28    ; VDU28,2,31,19,2:CLS:VDU26  NB:Reversed for speed

.GridrunnerLogo
EQUS 17,6,$E0,$E1,$E2,$E3,17,5,$E1,$E4,$E5,$E5,$E6,$E1,0

.GridrunnerScores
EQUS 17,5," SCORE       HISCORE",0

.author
EQUS $F9,$FA,"1982 JCM",0

.conversion
EQUS $F9,$FA,"2021 STL",0

.helptext
EQUS "PRESS FIRE TO BEGIN",0

.levelSelectText
EQUS "ENTER LEVEL ",0

.LivesLeft
EQUS "LIVES ",0

.BattleStations
EQUS "BATTLE  STATIONS",0

.EnterGridArea
EQUS "ENTER GRID AREA ",0

; Standard Mode 2 (20x32) character lookup table
.LookUp640
EQUB $00,$00,$80,$02,$00,$05,$80,$07,$00,$0A,$80,$0C,$00,$0F,$80,$11
EQUB $00,$14,$80,$16,$00,$19,$80,$1B,$00,$1E,$80,$20,$00,$23,$80,$25
EQUB $00,$28,$80,$2A,$00,$2D,$80,$2F,$00,$32,$80,$34,$00,$37,$80,$39
EQUB $00,$3C,$80,$3E,$00,$41,$80,$43,$00,$46,$80,$48,$00,$4B,$80,$4D

; Sound Info
;-----------------
; chan     2 bytes
; vol      2 bytes
; pitch    2 bytes
; duration 2 bytes

.FireBulletSound
EQUW &11
EQUW 1
EQUW 150
EQUW 5
EQUW 2

.ExplosionSound
EQUW 0
EQUW 3
EQUW 5
EQUW 10

.ShipExplosionSound
EQUW 0
EQUW 3
EQUW 6
EQUW 40

.FireLaserSound
EQUW &12
EQUW 4
EQUW 100
EQUS 2

.LevelSelectSound
EQUW &11
EQUW 4
EQUW 25
EQUW 50

.sprite_data
INCBIN "SpriteData.bin"

.sprlist
EQUW sprite_data            ; Vertical
EQUW sprite_data + $20      ; Grid
EQUW sprite_data + $40      ; Left Zapper
EQUW sprite_data + $60      ; Bottom Zapper
EQUW sprite_data + $80      ; Horiz Laser1
EQUW sprite_data + $A0      ; Horiz Laser2
EQUW sprite_data + $C0      ; Vertical Laser1
EQUW sprite_data + $E0      ; Vertical Laser2
EQUW sprite_data + $100     ; Ship
EQUW sprite_data + $120     ; Bullet Up1
EQUW sprite_data + $140     ; Bullet Up2
EQUW sprite_data + $160     ; Pod1
EQUW sprite_data + $180     ; Pod2
EQUW sprite_data + $1A0     ; Pod3
EQUW sprite_data + $1C0     ; Pod4
EQUW sprite_data + $1E0     ; Pod5
EQUW sprite_data + $200     ; Pod6
EQUW sprite_data + $220     ; Bomd Down
EQUW sprite_data + $240     ; Bomb Right
EQUW sprite_data + $260     ; Bomb Left
EQUW sprite_data + $280     ; Explosion1
EQUW sprite_data + $2A0     ; Explosion2
EQUW sprite_data + $2C0     ; Explosion3
EQUW sprite_data + $2E0     ; Leader1
EQUW sprite_data + $300     ; Leader2
EQUW sprite_data + $320     ; Leader3
EQUW sprite_data + $340     ; Leader4
EQUW sprite_data + $360     ; Droid
EQUW sprite_data + $380     ; Space         (NB: We could EOR zappers and pause sprite with some sort of plot mode)
EQUW sprite_data + $3A0     ; SoundON
EQUW sprite_data + $3C0     ; SoundOff
EQUW sprite_data + $3E0     ; Pause
EQUW sprite_data + $400     ; Joystick


\ ******************************************************************
\ *	End address to be saved
\ ******************************************************************
.end

\ ******************************************************************
\ *	Save the code
\ ******************************************************************

SAVE "RUNNER", start, end
puttext "BOOT", "!BOOT",&FFFF
putbasic "Grid.bas", "GRID"

\\ run command line with this
\\ beebasm -v -i Gridrunner.6502 -do Gridrunner.ssd -opt 3
