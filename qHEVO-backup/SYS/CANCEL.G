; stop.g
; called when a print is cancelled after a pause.
M568 S0 R0  	; Turn off Extruder
M140 S0		; Turn off Bed
M106 S0		; Fan off

G91 ;relative positioning
G1 Z+0.5 E-3 F3000 ;retract the filament a bit before lifting the nozzle to release some of the pressure

G90
G0 X10 Y290 F2400 ; position for easy part removal

M84		; Steppers off

M300 P300 S4000 ; Play sound