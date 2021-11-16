; Disengage the toolchanger lock

G91                 ; Set relative movements
G0 U-4 F9000 H2     ; Back off the limit switch with a small move
G0 U-360 F9000 H1   ; Perform up to one rotation looking for the home limit switch
G90                 ; Restore absolute movements

;Save Tool Num for later
M98 P"/sys/custom/ToolControl/Save Tool Num" T-1
;echo "Global Tool Num:", {global.lastTool}
if {state.currentTool} == {state.nextTool}
    T-1 P0
    echo "Manually removed tool, setting active tool to T-1"