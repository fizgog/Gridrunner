10REM GridRunner Loader
20REM Designed by Jeff Minter
30REM BBC Conversion Shaun Lindsley
40REM (c) 2021
50MODE7:ON ERROR GOTO 720
60VDU23;8202;0;0;0;28,0,31,19,17
70VDU23,224,&7C,&FE,&00,&C0,&DE,&C6,&C6,&7C   : REM G - $E0
80VDU23,225,&FC,&FE,&00,&C6,&FC,&D0,&C8,&C6   : REM R - $E1
90VDU23,226,&FC,&FC,&00,&30,&30,&30,&FC,&FC   : REM I - $E2
100VDU23,227,&FC,&FE,&00,&C6,&C6,&C6,&FE,&FC   : REM D - $E3
110VDU23,228,&C6,&C6,&00,&C6,&C6,&C6,&FE,&7C   : REM U - $E4
120VDU23,229,&C6,&C6,&00,&E6,&F6,&DE,&CE,&C6   : REM N - $E5
130VDU23,230,&FE,&FE,&00,&F0,&F0,&C0,&FE,&FE   : REM E - $E6
140
150VDU23,249,&07,&1C,&33,&36,&36,&33,&1C,&07   : REM $F9 - (c
160VDU23,250,&E0,&38,&CC,&0C,&0C,&CC,&38,&E0   : REM $FA - ) 
170VDU23,251,&00,&F3,&DB,&F3,&C3,&C3,&00,&00   : REM $FB   
180VDU23,252,&00,&03,&03,&03,&03,&DB,&00,&00   : REM $FC   
190VDU23,253,&00,&CC,&CC,&FC,&CC,&CC,&00,&00   : REM $FD   
200VDU23,254,&00,&F0,&66,&60,&66,&F0,&00,&00   : REM $FE   
210VDU23,255,&18,&3C,&66,&18,&7E,&FF,&E7,&C3   : REM $FF - Ship

224ENVELOPE 1,1,-10,-7,-3,3,7,20,70,-1,-1,-8,70,0 : REM Bullet
225ENVELOPE 2,6,0,0,0,1,1,1,126,-4,-1,-4,126,80 : REM Explosion
226ENVELOPE 3,1,0,0,0,0,0,0,127,-1,-1,-1,126,30 : REM Ship Explosion
227ENVELOPE 4,0,-15,-15,-15,100,100,100,0,0,0,-2,120,120 : REM Level Start and Laser

230PRINTTAB(0,0);CHR$(150);".//$///$///*//-";CHR$(149);"///$/ *%/ *%/ *%///*//-"
240PRINTTAB(0,1);CHR$(150);CHR$(255);"(l4";CHR$(255);"l.! ";CHR$(255);" j";CHR$(255);" ";CHR$(255);CHR$(149);CHR$(255);"l.!";CHR$(255);" j5";CHR$(255);"mz5";CHR$(255);"mz5";CHR$(255);"/ j=<'"
250PRINTTAB(0,2);CHR$(150);"+,.!/ )$///*//'";CHR$(149);"/ )$+//!/ +%/ +%///*%"","
260PRINTTAB(8,4)CHR$131"Designed by Jeff Minter"
270PRINTTAB(5,5)CHR$134"BBC Conversion Shaun Lindsley"'
280PRINTTAB(5,23);CHR$133;CHR$(136);"Press SPACE BAR to continue"
290VDU28,0,22,39,7
300PRINTCHR$135"SCENARIO:"'
310PRINTCHR$130"By the year 2190, the human race has"
320PRINTCHR$130"set up a huge solar-power collecting"
330PRINTCHR$130"power station in Earth's orbit to beam"
340PRINTCHR$130"down power to Earth."'
350PRINTCHR$130"Because of its lattice-like shape,"
360PRINTCHR$130"this power station is known simply as"
370PRINTCHR$130"""The Grid""."'
380PRINTCHR$130"Shortly after beginning operation, the"
390PRINTCHR$130"grid was found to be delivering less"
400PRINTCHR$130"power than predicted."
410REPEAT:UNTIL GET=32:CLS:*FX15
420PRINTCHR$130"Investigation teams were sent into"
430PRINTCHR$130"orbit. They discovered that the grid"
440PRINTCHR$130"had been invaded by alien droids, who"
450PRINTCHR$130"where using its power to reproduce"
460PRINTCHR$130"themselves, massing for an invasion of"
470PRINTCHR$130"Earth."'
480PRINTCHR$130"To combat the droids a special combat"
490PRINTCHR$130"ship was developed. The ship drew it's"
500PRINTCHR$130"power from the grid and with such vast"
510PRINTCHR$130"amounts of energy readily available,"
520PRINTCHR$130"was able to carry an awesomally"
530PRINTCHR$130"powerful plasma cannon."
540REPEAT:UNTIL GET=32:CLS:*FX15
550
600PRINTCHR$135"SCORING:"'
610PRINTCHR$131"     POD destroyed.............10"
620PRINTCHR$131"     DROID segment............100"
630PRINTCHR$131"     Leader DROID.............400"'
640PRINTCHR$135"EXTRA LIVES:"'
650PRINTCHR$130"One extra Gridrunner is awarded for"
660PRINTCHR$130"zapping one gridful of Droids."
670REPEAT:UNTIL GET=32:CLS:*FX15
680
720VDU28,0,24,39,7:CLS:*FX15
730PRINTTAB(13)CHR$133"Game Controls"'
740PRINTTAB(17)CHR$130"Z - Left"
750PRINTTAB(17)CHR$130"X - Right"
760PRINTTAB(17)CHR$130": - Up"
770PRINTTAB(17)CHR$130"/ - Down"'
780PRINTTAB(12)CHR$131"RETURN - Fire"'
790PRINTTAB(12)CHR$129"ESCAPE - Exit the game"'
800PRINTTAB(17)CHR$129"S - Sound on/off" 
810PRINTTAB(17)CHR$129"P - Pause on/off"     
820PRINTTAB(17)CHR$129"J - Joystick/Keyboard"
830PRINTTAB(7,16);CHR$133;"Press SPACE BAR to start"
840REPEAT:UNTIL GET=32:*FX15
860*RUN RUNNER


