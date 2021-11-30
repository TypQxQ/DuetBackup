 M117 X Not Implemented. Use G28 / Home All
 M291 P"Homing X" R"X Not Implemented. Use G28 / Home All" T5 ; Display new message

; M400                     ; make sure everything has stopped before we make changes
; M98 Pstallsettingshome.g ; Set stallsettings for homing.

; G91                      ; relative positioning
; G1 Z2 F6000 S2           ; lift Z relative to current position

; M98 PHOMEY_subset.G      ; Call the actual homing of Y
; G1 Y5 V5 F6000 S2        ; Move 5mm so not X gets upset when homing sensorless.
; M98 PHOMEX_subset.G      ; Call the actual homing of X

; M98 Pstallsettings.g      ; Set stallsettings for print.
; G90                       ; absolute positioning

; M99                       ; end macro
