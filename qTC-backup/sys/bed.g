; bed.g
; called to perform automatic bed compensation via G32
;

;G91								; Relative to move bed down
;G0 Z5 F6000						; Move the bed further from the nozzle prior to any tool moves.  No G53 needed because this is a relative move.
;G90								; Return to absolute

T49								; Select and Set Z switch to Probe

G30 P0 X5 Y264.5 Z-99999   		; probe near left leadscrew
G30 P1 X495 Y495 Z-99999  		; probe near back leadscrew
G30 P2 X495 Y5 Z-99999 S3 		; probe near front leadscrew and calibrate 3 motors

echo "Gantry deviation of " ^ move.calibration.initial.deviation ^ "mm obtained."
T-1 							; Deselect ProbeTool