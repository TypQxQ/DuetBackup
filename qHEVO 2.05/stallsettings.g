; Called to set stall detection settings used right now while printing.

M400               ; make sure everything has stopped before we make changes

M584 X0:3:4 Y6:7:8 U10 V11 W12 A13 P3    ; Använd bara XY
;M584 X0:3 Y6:7 U10 V11 W12 A13 P3    ; Använd bara XY men utan DynamicCarriage

M913 X100 Y100 U100 V100 W100 A100 E100 Z100             ; Return power to the motors.

; R3 Pausa och starta om, R1 logga, R2 pausa
M915 X Y S9 R1 F1  ; S10 funkar utan fel- S9 testar 19/05
M915 Z S7 R0 F1    ; S funkar utan fel- S6 testad ger fel.
M915 E S9 R1 F1    ; S10 funkar utan fel 19/05.

; Load speed settings for printing.
M98 P"/sys/speeds4printing.g"

M593 F31 ; cancel ringing at 31Hz
;M593 F0 ; 

;M572 D0 S0.64 ; Pressure advance
;M572 D0 S0 ; Pressure advance disabled

M99  ; Return