M400                              ; make sure everything has stopped before we make changes

; Set acceleration and max speed and jerk for homing. To high and sensorless homing fails.
M203 X24000 Y24000 U24000 V24000	; SET MAXIMUM SPEEDS (MM/MIN) 400mm/s
M201 X6000 Y6000 U6000 V6000 		; SET ACCELERATIONS (MM/S^2)
; M566 X480 Y480 U480 V480 W480 A480				; Max instant change 8mm/s.
M566 X300 Y300 U300 V300 				; Max instant change 8mm/s.

; M204 P1000 T5000	; Accelerate 1000 on print and 5000 on travel
M204 P1000 T3000	; Accelerate 1000 on print and 5000 on travel

; E for initial setup
M203 E3600	; Max speed 60mm/s
M201 E3000	; Max acceleration (MM/S^2)
M566 E1200	; Max instant change 20mm/s

; Z for smoother probing.
M203 Z720	; Max speed 12mm/s
M201 Z500	; Max acceleration (MM/S^2)
M566 Z24	; Max instant change 0,4mm/s
