; Runs at the start of a toolchange if the current tool is tool1.
; Note: tool offsets are applied at this point unless we preempt commands with G53!
; Note: Prior to this macro, XYZ have been saved to slot 2 by the firmware as though a G60 S2 were executed. 

; Check so a tool is mounted before trying to unmount one.
;if sensors.gpIn[3].value!=0
;	abort "tfree_start.g: Tool not picked up.  Can't unmount when not mounted"


; Cold extrude prevention does not work on ext cards right now. We asume that if heatbed is under 40*C the printer isn't printing so no purge.
if heat.heaters[0].current > 40
	G1 E-1 F2400				; Retract

G91                           ; Relative to move bed down
G0 Z5 F6000                   ; Move the bed further from the nozzle prior to any tool moves.  No G53 needed because this is a relative move.  Bed will be placed back in position in the post macro. 
G90                           ; Return to absolute

G53 G0 X500 	 F34000       ; Rapid to the approach position with tool. (park_x, park_y - offset).  X first in case close to tool row. 
