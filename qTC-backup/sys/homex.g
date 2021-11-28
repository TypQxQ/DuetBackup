; homex.g
; called to home the X axis
;

M98 P"/sys/custom/EndStop_XY_Probe.g"		; Set XY switch to Probe

G91               		; relative positioning
G1 H1 X-650 F1800 		; move quickly to X or Y endstop and stop there (first pass)
G1 X5 F6000          	; go back a few mm
G1 H1 X-10 F360         ; move slowly to X axis endstop once more (second pass)
G90                     ; absolute positioning

G0 X5 F1800 			; Move away so it won't trigger estop

M98 P"/sys/custom/EndStop_XY_Emergency.g"   ; Set XY switch to Emergency Stop button

