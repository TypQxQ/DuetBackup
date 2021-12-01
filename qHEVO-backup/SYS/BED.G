; New Bed.g

; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28

M568 S130		  ; Start heating extruder to probing temperature
M109 R130 		  ; Wait for extruder to reach probing before proceeding

M98 P"/sys/speeds4probing.g"

M400                    ; make sure everything has stopped before we make changes
M561                    ; clear any bed transform

M671 X-38.0:332.0:148.0 Y38.0:38.0:324.0 P2.0 S2.0; Position of Z0(left), Z1(right) Leadscews and Z2(back).

G90                       ; absolute positioning

; Using 3 independent leadscrews to adjust them independently.
G30 P0 X0 Y38 Z-99999                         ; probe near a leadscrew
G30 P1 X290 Y38 Z-99999                       ; probe near a leadscrew
G30 P2 X148 Y295 Z-99999 S3                   ; Probe near a leadscrew, save and make mesh.

; Probe the bed and do auto calibration
G1 X0 Y38 Z10 F10000        ; go to just above the first probe point
while true
  if iterations = 5
    abort "Too many auto calibration attempts"
  G30 P0 X0 Y38 Z-99999
  if result != 0
    continue
  G30 P1 X290 Y38 Z-99999
  if result != 0
    continue
  G30 P2 X148 Y295 Z-99999 S3
  if result != 0
    continue
  if move.calibration.initial.deviation <= 0.03
    break
  echo "Repeating calibration because deviation is too high (" ^ move.calibration.initial.deviation ^ "mm)"
; end loop
echo "Auto calibration successful, deviation", move.calibration.final.deviation ^ "mm"
G1 X5 Y5 Z10 F10000                ; get the head out of the way
G29 S1 ; Load Heightmap
M98 P"/sys/speeds4printing.g"

