; homeall.g
; Home y, x, z, and Toolchanger Lock axes

; check so the tool isn't already locked
if {global.lastTool} >= 0
  abort "homeall.g: Tool already locked"
  
G91             			; relative positioning
G1 H2 Z+5 F6000				; Lift z so we don't crash
G90

M561						; Cancels any bed-plane fitting as the result of probing (or anything else) and returns the machine to moving in the user's coordinate system.
;T-1							; Ensure no tool is selected.
M98 P"homeu.g"				; Home U and drop any mounted tool before homing Z


	; --- Home axes XY ---
M98 P"homex.g"
M98 P"homey.g"

M98 P"homez.g"				; Home Z
G32							; Run 3-point bed calibration defined in bed.g
;G29 S1   					; Enable and load Mesh Bed Compensation

G0 Z5

M122 B0	; Prints diagnostics and resets the CAN counter for 6HC
M122 B1	; Prints diagnostics and resets the CAN counter for 3HC
M122 B2	; Prints diagnostics and resets the CAN counter for 3HC