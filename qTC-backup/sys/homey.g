; homey.g
; called to home the Y axis
;

M98 P"/sys/custom/EndStop_XY_Probe.g"		; Set XY switch to Probe

G91               		; relative positioning
G1 H1 Y-650 F1800 		; move quickly to Y endstop and stop there (first pass)
G1 Y5 F6000          	; go back a few mm
G1 H1 Y-10 F360         ; then move slowly to Y axis endstop
G90                     ; absolute positioning

G0 Y5 F1800 			; Move away so it won't trigger estop

M98 P"/sys/custom/EndStop_XY_Emergency.g"   ; Set XY switch to Emergency Stop button
