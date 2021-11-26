; Set the ToolLock endstop as a EndStop.
M98 P"/sys/custom/ToolControl/setToolLockEndstopAsEndstop.g"

; Disengage the toolchanger lock
G91                 ; Set relative movements
M906 U700			; Set to 70% of rated current so we don't destroy anything
M400
G0 U-4 F9000 H2     ; Back off the limit switch with a small move, so the limit switch isn't triggered.
M906 U900			; Set to 90% of rated current
M400
G0 U-360 F9000 H1   ; Perform up to one rotation looking for the home limit switch.
G90                 ; Restore absolute movements

;Save Tool Num for later
M98 P"/sys/custom/ToolControl/Save Tool Num" T-1	;Save tool as unloaded.

; If manually unlocked the tool
if {state.currentTool} == {state.nextTool}			
    T-1 P0
    echo "Manually removed tool, setting active tool to T-1"