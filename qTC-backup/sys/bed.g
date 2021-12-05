; bed.g
; called to perform automatic bed compensation via G32
;



-------------------

T49						; Select and Set Z switch to Probe
M400                    ; make sure everything has stopped before we make changes
M561                    ; clear any bed transform
G90                     ; absolute positioning

; Using 3 independent leadscrews to adjust them independently.
; Probe the bed and do auto calibration
G1 X5 Y264.5 Z10 F10000        ; go to just above the first probe point
while true
  if iterations = 5
    abort "Too many auto calibration attempts"
  G30 P0 X5 Y264.5 Z-99999   		; probe near left leadscrew
  if result != 0
    echo "Failed first calibration point. Restarting"
    continue
  G30 P1 X495 Y495 Z-99999  		; probe near back leadscrew
  if result != 0
    echo "Failed second calibration point. Restarting"
    continue
  G30 P2 X495 Y5 Z-99999 S3 		; probe near front leadscrew and calibrate 3 motors
  if result != 0
    echo "Failed third calibration point. Restarting"
    continue
  if move.calibration.initial.deviation <= 0.03
    break
  echo "Repeating calibration because deviation is too high (" ^ move.calibration.initial.deviation ^ "mm)"
; end loop
;echo "Auto calibration successful, deviation", move.calibration.final.deviation ^ "mm"
echo "Gantry deviation of " ^ move.calibration.initial.deviation ^ "mm obtained."
;T-1 							; Deselect ProbeTool
