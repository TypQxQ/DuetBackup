; homeall.g
; Home y, x, z, and Toolchanger Lock axes

G91             			; relative positioning
G1 H2 Z+5 F6000				; Lift z so we don't crash

	; --- Home axes XY ---
;M913 X70 Y70				; Use less Power on XY
M98 P"homex.g"
M98 P"homey.g"
;M913 X100 Y100				; Use full Power on XY

