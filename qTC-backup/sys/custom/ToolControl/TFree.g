;M291 S2 P{"Tool"^{state.currentTool}^" loaded at Y"^{param.Y}^" with temp "^{heat.heaters[tools[state.currentTool].heaters[0]].current}^" coldRetractTemperature temp being "^{heat.coldRetractTemperature}} R"Q"
; Runs at the start of a toolchange.
; Note: tool offsets are applied at this point unless we preempt commands with G53!
; Note: Prior to this macro, XYZ have been saved to slot 2 by the firmware as though a G60 S2 were executed. 

; Check so a tool is mounted before trying to unmount one.
;if sensors.gpIn[3].value!=0
;	abort "tfree_start.g: Tool not picked up.  Can't unmount when not mounted"


; Cold extrude prevention does not work on ext cards right now. We asume that if heatbed is under 40*C the printer isn't printing so no purge.
M106 S0								; Turn off toolheater.

if exists(tools[state.currentTool].heaters) 
  if #tools[state.currentTool].heaters > 0
    if heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
      G1 E-1 F2400					; Retract

;if heat.heaters[0].current > 40
;	G1 E-1 F2400					; Retract

G91                           		; Relative to move bed down
G0 Z5 F6000                   		; Move the bed further from the nozzle prior to any tool moves.  No G53 needed because this is a relative move.  Bed will be placed back in position in the post macro. 
G90                           		; Return to absolute

	; Prepare for moving
M400								; Wait for current moves to finish
G53 G0 X500 F34000       	  		; Rapid to the approach position with tool. (park_x, park_y - offset).  X first in case close to tool row. 
G53 G0 Y{param.Y} F34000  	  		; Rapid to the Y approach position with tool. 

M208 X600							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Deactivate.g"	; Don't use the X max as EmergencyStop.

	; Move into position
G53 G0 X555 F34000       			; Fast Move to the pickup position with tool-0.
G53 G0 X597 F6000        			; Move to the parking position with tool-0. This is 1mm less than pickup position

M581 P-1 T4							; Remove trigger for when tool disconects while disconnecting it.

	; Unlock
M98 P"/sys/custom/tool_unlock.g"	; Unlock the tool

	; Move back carriage
G53 G0 X575 F6000   				; Move the carraige to retract the pin until it clears the tool.
G53 G0 X500 F34000					; Rapid to a position where a future tool change won't hurt anything by returning to this position via its G60 S2

M581 P3 T4 S1						; Reattach trigger for when tool disconects after disconnecting it.

; Check so the tool is unmounted steady.
;if sensors.gpIn[3].value!=1
;  M208 S"tfree_end.g: Tool not unmounted correctly."
;  abort "tfree_end.g: Tool not unmounted correctly."


	; Finish up
M400								; Wait for current moves to finish
M208 X500							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Activate.g"	; Use the X max as EmergencyStop.

if exists(tools[state.currentTool].fans[0])
  if exists(fans[tools[state.currentTool].fans[0]])
    M106 P{tools[state.currentTool].fans[0]} S0			; Stop the partcooling fan

