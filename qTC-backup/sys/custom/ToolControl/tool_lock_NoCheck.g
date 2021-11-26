; Set the ToolLock endstop as a EndStop.
M98 P"/sys/custom/ToolControl/setToolLockEndstopAsEndstop.g"

G91                 ; Set relative mode
M906 U700			; Set to 70% of rated current so we don't destroy anything
G0 U10 F9000 H0     ; Forward the limit switch with a small move so it's not at minimum anymore
M400
M906 U1200			; Set to 120% of rated current
G0 U200 X0.5 F9000 H4    ; Perform up to one rotation looking for the torque limit switch

M400
M906 U900			; Set to 90% of rated current
