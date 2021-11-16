; Engage the toolchanger lock. RepRap Firmware V2.0.1 version.
if move.axes[3].machinePosition >= 10 ; check so the tool isn't already locked
  abort "tool_lock.g: Tool already locked"

G91                 ; Set relative mode
G0 U10 F9000 H0     ; Back off the limit switch with a small move
M400
M906 U1200			; Set to 120% of rated current
;G0 U200 X0.5 F9000 H1    ; Perform up to one rotation looking for the torque limit switch
G0 U200 X0.5 F9000 H4    ; Perform up to one rotation looking for the torque limit switch

M400
M906 U900			; Set to 90% of rated current

if move.axes[3].machinePosition > 170 ; If lock is at maximum
  M98 P"/sys/custom/ToolControl/Save Tool Num" T-2
  abort "tool_lock.g: Locked but not connected to tool."

G90                 ; Set absolute mode

; Save Tool Num for later
var tool = {state.nextTool}

if {state.currentTool} == {state.nextTool}
    echo "Manually locking tool, active tool unknown"
    set var.tool = -2
    
M98 P"/sys/custom/ToolControl/Save Tool Num" T{var.tool}
