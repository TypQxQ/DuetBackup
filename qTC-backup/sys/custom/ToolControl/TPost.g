;M291 S2 P"Now in TPOST" R"Q"

M116 P{state.nextTool} S5    	; Wait for set temperatures to be reached, +-5 degC

; Move nozzle to purge area
G53 G0 X570 F6000

	; Purge the nozzle
if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
  G1 E3 F500     			        ; Purge the nozzle. the amount when docked
  G1 E4 F100						; Purge the nozzle. to clean
  G4 H1.0                 			; Slight Delay
  G1 E-1.0 F2400				    ; Perform a retract to remove filament pressure.
  G53 G0 X505 F3000        			; Retract the entire tool and wipe Backwards.
  G53 G0 X525 F3000       			; Wipe Forwards.
  G53 G0 X505 F3000       			; Wipe Backwards.
  G53 G0 X525 F3000       			; Wipe Forwards.
  G53 G0 X505 F3000       			; Wipe Backwards.
  G53 G0 X525 F3000       			; Wipe Forwards.

G0 X500 F40000       				; Wipe Backwards, and move away from other tools, incase next move is Y only. 
M400 								; Wait for current moves to finish

; Check so the tool is mounted steady.
;if sensors.gpIn[3].value!=0
;  abort "0:/sys/custom/ToolControl/TPost.g: Tool not picked up correctly."

	; Prepare for printing
M208 X500							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Activate.g"	; Use the X max as EmergencyStop.

;if move.axes[3].machinePosition >10 && move.axes[3].machinePosition < 170  ; Check if locked on tool
;  echo move.axes[3].machinePosition
;  M400
;  M906 U1200			; Set to 120% of rated current
;  M400
;  G91                 ; Set relative mode
;  G0 U10 F9000 H0     ; Advance the lock a litle to tighten the lock
;  G90                 ; Set absolute mode
;  M400
;  M906 U900			; Set to 90% of rated current
;  echo move.axes[3].machinePosition

	; Restore for printing
G1 R2 X0 Y0 Z1     					; Restore prior position now accounting for new tool offset. X first to avoid certain collisions when near tool parking. 
G1 R2 Z0        					; Restore prior position now accounting for new tool offset
M106 R2         					; restore print cooling fan speed
;G1 E1 F2400     			         ; Prepare to print

if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
	G1 E-1 F2400				; Retract
