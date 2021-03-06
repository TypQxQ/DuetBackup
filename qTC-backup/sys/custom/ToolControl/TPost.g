; Runs after firmware thinks ToolN is selected
; Note: tool offsets are applied at this point!
; Note that commands prefixed with G53 will NOT apply the tool offset.

M116 P{state.nextTool} S1    	; Wait for set temperatures to be reached, +-5 degC

; Move nozzle to purge area
G0 X575 F6000

M83 ; Relative extrusion

	; Purge the nozzle
if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldExtrudeTemperature & global.purgeOnToolChange=true
  G1 E3 F500     			    	; Purge the nozzle. the amount when docked (8,33mm/s)
  G1 E5 F100						; Purge the nozzle. to clean (1,66mm/s)
  G4 H1.0               	  		; Slight Delay
  G1 E-1.0 F2400					; Perform a retract to remove filament pressure. (40mm/s)
  G0 X555 F6000        				; Retract the entire tool and wipe Backwards. (50mm/s)
  G0 X575 F6000       				; Wipe Forwards.
  G0 X555 F6000       				; Wipe Backwards.
  G0 X575 F6000     	  			; Wipe Forwards.
  G0 X555 F6000		       			; Wipe Backwards.
  G0 X575 F6000       				; Wipe Forwards.

G0 X500 F40000       				; Wipe Backwards, and move away from other tools, in case next move is Y only. 
M400 								; Wait for current moves to finish

; Check so the tool is mounted steady
if !sensors.endstops[3].triggered	; If Toolchanger is not trigered then maybe it's not coupled.
  M98 P"/sys/custom/ToolControl/tool_lock_NoCheck.g" 	; Try locking the tool again. If the tool fell off when coupling
  if move.axes[3].machinePosition > 170	; If lock is at maximum assume the lock turned without gripping the tool.
    M98 P"/sys/custom/ToolControl/Save Tool Num" T-2			; Set the saved tool as unknown loaded tool.
    abort "0:/sys/custom/ToolControl/TPost.g: Locked at maximum and thus not connected to tool."	; Abort.

; Set the ToolLock endstop as a Trigger. This does not work because it is not secure enough. Might try again with metal toolplate.
; M98 P"/sys/custom/ToolControl/setToolLockEndstopAsTrigger.g"

	; Prepare for printing
M208 X508							; Set axis software limits and min/max switch-triggering positions. Extended with tools. Endstop is at 512 right now.
M98 P"/sys/custom/EndStop_X-Max_Activate.g"	; Use the X max as EmergencyStop.


	; Restore for printing
;G1 R2 X0 Y0 Z1 F40000    					; Restore prior position now accounting for new tool offset. X first to avoid certain collisions when near tool parking. 
;G1 R2 Z0        					; Restore prior position now accounting for new tool offset
M106 R2         					; restore print cooling fan speed

if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
	G1 E1 F2400				; DeRetract
