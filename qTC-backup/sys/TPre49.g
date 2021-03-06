; Mounting
; runs before firmware thinks Tool49 is selected
; Note: tool offsets are NOT applied at this point!
; Note that commands prefixed with G53 are not needed.

G91             			; relative positioning
G1 H2 Z+10 F6000			; Lift z so we don't crash
G90                         ; Return to absolute

; Check so no tool is mounted before trying to mount one.
if move.axes[3].machinePosition >= 10 ; check so the tool isn't already locked
  abort "0:/sys/custom/ToolControl/TPre.g: Tool already locked"

; Set Z Probe settings
M558 P8 C"1.io2.in" F250 H5 T40000 A2 S0.02		; Set the pin of Z probe
;G31 Z-1										; Set probe height as -1 so 0 is 1mm below the probe
G31 Z0										; Set probe height as -1 so 0 is 1mm below the probe


M400 								; Wait for current moves to finish
M208 X600							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Deactivate.g"	; Don't use the X max as EmergencyStop.

G0 X500	Y515 F40000       		; Rapid to the approach position with tool-0. (park_x, park_y - offset).  Y next to make a square move. 
G0 X590 F40000       			; Fast Move to the pickup position with tool.
G0 X598 F6000        			; Slow Move to the pickup position with tool-0.

;Lock the tool
M98 P"/sys/custom/ToolControl/tool_lock.g" 		; Lock the tool

; Move nozzle to purge area
G0 X580 F6000       			; Wipe Backwards, and move away from other tools, incase next move is X only. 
G0 X500 F40000       				; Wipe Backwards, and move away from other tools, incase next move is X only. (To tool coordinates)
G0 Y500 F40000       				; Move on Y to be inside the bed area
M400 								; Wait for current moves to finish

; Check so the tool is mounted steady
if !sensors.endstops[3].triggered	; If Toolchanger is not trigered then maybe it's not coupled.
  M98 P"/sys/custom/ToolControl/tool_lock_NoCheck.g" 	; Try locking the tool again. If the tool fell off then
  if move.axes[3].machinePosition > 170	; If lock is at maximum assume the lock turned without gripping the tool.
    M98 P"/sys/custom/ToolControl/Save Tool Num" T-2			; Set the saved tool as unknown loaded tool.
    abort "0:/sys/custom/ToolControl/TPost.g: Locked at maximum and thus not connected to tool."	; Abort.

; Prepare for probing
M208 X500							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/sys/custom/EndStop_X-Max_Activate.g"	; Use the X max as EmergencyStop.

