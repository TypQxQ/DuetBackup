M400 ; make sure everything has stopped before we make changes

; Set acceleration and max speed and jerk for homing. To high and sensorless homing fails.
M203 X6000 Y6000 U6000 V6000 W12000 A12000	; SET MAXIMUM SPEEDS (MM/MIN) 100mm/s
M201 X500 Y500 U500 V500 W2000 A2000		; SET ACCELERATIONS (MM/S^2)
M566 X300 Y300 U300 V300 W480 A480			; 5mm/s on XYUV and 8mm/s on WA for sensorless homing.

; E for initial setup
M203 E3600	; Max speed 60mm/s
M201 E3000	; Max acceleration (MM/S^2)
M566 E1200	; Max instant change 20mm/s

; Z for smoother probing.
M203 Z720	; Max speed 12mm/s
M201 Z250	; Max acceleration (MM/S^2)
M566 Z10	; Max instant change 0,17mm/s

M204 P500 T500	; Accelerate 500 on print and 500 on travel
