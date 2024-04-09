; Called to set stall detection settings used right now while printing.
M400                              ; make sure everything has stopped before we make changes

M18	; Motors off for moving steppers
M584 X0 Y6 Z1:9:2 E5 U4 V8 R0 S0 P7 ; 1=LeftZ(marked Y on Duet) 9=RearZ (Last on Duex), 2=RightZ (marked Z on Duet), 0=marked X, 3=marked E0, 4=marked E1
;M584 X0 Y6 Z1:9:2 E5 U3 V7 W4 A8 R0 S0 P7 ; 1=LeftZ(marked Y on Duet) 9=RearZ (Last on Duex), 2=RightZ (marked Z on Duet), 0=marked X, 3=marked E0, 4=marked E1
;M584 X3 Y4 U6 V7 P3                 ; Only use XYZ

;M350 X16 Y16 U16 V16 W16 A16 Z16 E16 I1          ; Configure microstepping with interpolation
;M350 X32 Y32 U32 V32 W32 A32 Z32 E32 I0          ; Configure microstepping with interpolation
M350 X32 Y32 U32 V32 Z32 E32 I0          ; Configure microstepping with interpolation
;M92 X80 Y80 U80 V80 W80 A80 Z1600 E830 S16       ; Set steps per mm (BMG = 415) on 1.8* Stepper
;M92 X79.907 Y80.028 U79.907 V80.028 Z1600 E830 S16
M92 X79.907 Y80.028 U79.907 V80.028 Z1600 E516 S16

; Set Axis parameters
M98 P"/sys/SetAxisParameters.g"

; Stall detection
; R3 Pausa och starta om, R1 logga, R2 pausa
M915 X Y S6 R1 F0                 ; S6 fungerar bra på X och Y
;M915 U V S6 R0 F1                 ; set U and V to sensitivity 4 so only optical switch will home!
M915 Z S7 R1 F0                   ; S8 funkar utan fel på Z
M915 E0 S8 R1 F1						; Log  axis stall on extruder

; Load speed settings for homing.
M98 P"/sys/speeds4probing.g"

; Endstops
M574 X1 P"xstop" S1								; Set active high endstops for X
M574 Y1 P"ystop" S1								; Set active high endstops for Y
M574 U1 V1 S3								; Set endstops controlled by motor load detection for U and V
