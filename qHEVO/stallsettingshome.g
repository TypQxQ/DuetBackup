; Called to set stall detection settings used right now while printing.

M400                              ; make sure everything has stopped before we make changes

M584 X0 Y6 U3 V7 P5
;M584 X3 Y4 U6 V7 P3                 ; Only use XYZ

M913 X50 Y50 U40 V40 Z70          ; Use less power not to dammage belts.

; R3 Pausa och starta om, R1 logga, R2 pausa
M915 X Y S6 R1 F0                 ; S6 fungerar bra på X och Y
M915 U V S6 R0 F1                 ; set U and V to sensitivity 4 so only optical switch will home!
M915 Z S7 R1 F0                   ; S8 funkar utan fel på Z

; Load speed settings for homing.
M98 P"/sys/speeds4probing.g"

M574 X1 S1                        ; Set active high endstops for Y
M574 U1 S3                        ; set endstops to use motor stall on U
M574 Y1 S1                        ; Set active high endstops for Y
M574 V1 S3                        ; set endstops to use motor stall on V

M99  ; Return
