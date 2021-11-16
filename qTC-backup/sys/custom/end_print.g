; Custom gcode to run at end of print

M104 S0 T0		; turn off extruder 0
M104 S0 T1		; turn off extruder 1
M104 S0 T2		; turn off extruder 2
T-1         	; desect current tool
G91 			; relative moves
G0 Z20  		; move bed down another 20mm
G90 			; absolute moves
M140 S0 		; turn off bed
G0 X500 Y500 F30000	; Move toolhead out of the way
M84 S600		; disable motors after ten mins of inactivity