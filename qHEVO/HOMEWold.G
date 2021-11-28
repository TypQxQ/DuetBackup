; homeW.g
; called to home the U axis
;
;M98 Pstallsettingshome.g  ; Set stallsettings for homing.

M400                 ; make sure everything has stopped before we make changes



M913 W30 A30        ; set motor current to 50%
M915 W S2 R0 F0     ; set W to sensitivity 32, do nothing when stall, unfiltered
M574 W1 S3          ; set endstops to use motor stall
M915 A S2 R0 F0     ; set A to sensitivity 32, do nothing when stall, unfiltered
M574 A1 S3          ; set endstops to use motor stall

G91                  ; relative positioning
G1 S1 W-310 F4000    ; Move to W min

M400              ; make sure everything has stopped before we make changes
G90 ; absolute positioning
M913 U100 V100 ; set motor current to 100%


;M98 Pstallsettings.g  ; Set stallsettings for print.
M99 ; end macro