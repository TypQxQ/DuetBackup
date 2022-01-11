; Runs before firmware thinks ToolN is selected
; Note: tool offsets are NOT applied at this point!

;G91                           ; Relative to move bed down
;G0 Z5 F6000                   ; Move the bed further from the nozzle prior to any tool moves.  No G53 needed because this is a relative move.  Bed will be placed back in position in the post macro. 
;G90                           ; Return to absolute

; Check so no tool is mounted before trying to mount one.
if move.axes[3].machinePosition >= 10 ; check so the tool isn't already locked
  abort "0:/sys/custom/ToolControl/TPre.g: Tool already locked"
;if sensors.gpIn[3].value!=1
;  abort "tpost49.g: Tool already picked up.  Manually return tool to the dock"

if move.axes[0].machinePosition < 500 ; If the possition is inside printable area then no toolinterference will occur in moving the tool in X+Y. This should always be true btw.
  G0 X500 Y{param.Y} F40000		; Rapid to the approach position with tool-0. (park_x, park_y - offset).  X first in case close to tool row. (4 example above camera)
else	; Move first X and then Y.
  G0 X500 F40000       			; Rapid to the approach position with tool-0. (park_x, park_y - offset).  X first in case close to tool row. (4 example above camera)
  G0 Y{param.Y} F34000			; Rapid to the approach position with tool-0. (park_x, park_y - offset).  Y next to make a square move. 

;M116 P{state.nextTool} S5    	; Wait for set temperatures to be reached, +-5 degC

	; Prepare for moving
M400 							; Wait for current moves to finish
M208 X600						; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Deactivate.g"	; Don't use the X max as EmergencyStop.
;echo "X-Max Deactivated"

G53 G0 X575 F40000       		; Fast Move to the pickup position with tool.
G53 G0 X598 F6000        		; Move to the pickup position with tool-0. Is 1mm more than parking position

	;Lock the tool
M98 P"/sys/custom/ToolControl/tool_lock.g" 	; Lock the tool
