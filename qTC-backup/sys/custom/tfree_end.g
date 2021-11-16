; Runs when parking a tool,
; Note: tool offsets are applied at this point unless we preempt commands with G53!
; Note: Prior to this macro, XYZ have been saved to slot 2 by the firmware as though a G60 S2 were executed. 

	; Prepare for moving
M400 								;Wait for current moves to finish
G90
M106 S0
M208 X600							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Deactivate.g"	; Don't use the X max as EmergencyStop.

M302 P0                 			; Prevent Cold Extrudes, just in case temp setpoints are at 0
M400								; Wait for current moves to finish

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

