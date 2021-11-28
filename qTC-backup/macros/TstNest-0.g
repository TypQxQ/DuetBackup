M950 J3 C"0.io3.in"		; Use the input pin on io3 on the main board as carriage coupling check.
; Mounting
; runs after firmware thinks Tool49 is selected
; Note: tool offsets are applied at this point!
; Note that commands prefixed with G53 will NOT apply the tool offset.

; Check so no tool is mounted before trying to mount one.
if sensors.gpIn[3].value!=1
  echo "value not 1"

G91             			; relative positioning
;G1 H2 Z+5 F6000				; Lift z so we don't crash
G90                         ; Return to absolute

; Set Z Probe settings
M558 P8 C"1.io2.in" F250 H5 T24000 A2 S0.02		; Set the pin of Z probe
G31 Z-1											; Set probe height as -1 so 0 is 1mm below the probe


M400 								; Wait for current moves to finish
;M208 X600							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/macros/TstNest-1.g"	; Don't use the X max as EmergencyStop.

;G53 G0 X500	Y515 F20000       		; Rapid to the approach position with tool-0. (park_x, park_y - offset).  Y next to make a square move. 
;G53 G0 X590 F30000       			; Fast Move to the pickup position with tool.
;G53 G0 X598 F3000        			; Slow Move to the pickup position with tool-0.

	;Lock the tool
;M98 P"/sys/custom/tool_lock.g" 		; Lock the tool

; Move nozzle to purge area
;G53 G0 X580 F6000       			; Wipe Backwards, and move away from other tools, incase next move is Y only. 
;G0 X500 F30000       				; Wipe Backwards, and move away from other tools, incase next move is Y only. (To tool coordinates)
M400 								; Wait for current moves to finish

M582 T4
; Check so the tool is mounted steady.
echo sensors.gpIn[3].value

if sensors.gpIn[3].value!=0
  echo "value not 0"
  ;  M118 S"value not 0"
  ;M118 S"tpost49.g: Tool not picked up correctly."
  ;abort "tpost49.g: Tool not picked up correctly."

M118 S"Value checked and outside if"

; Prepare for probing
M208 X500							; Set axis software limits and min/max switch-triggering positions. Extended with tools
M98 P"/macros/TstNest-1.g"	; Use the X max as EmergencyStop.
