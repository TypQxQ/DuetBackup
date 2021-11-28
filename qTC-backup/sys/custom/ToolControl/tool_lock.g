; Engage the toolchanger lock.
if move.axes[3].machinePosition >= 10 ; check so the tool isn't already locked
  abort "0:/sys/custom/ToolControl/tool_lock.g: Tool already locked"

; Run the actually tool_lock code.
M98 P"/sys/custom/ToolControl/tool_lock_NoCheck.g"

; If lock is at maximum assume the lock turned without gripping the tool.
if move.axes[3].machinePosition > 170
  M98 P"/sys/custom/ToolControl/Save Tool Num" T-2			; Set the saved tool as unknown loaded tool.
  abort "0:/sys/custom/ToolControl/tool_lock.g: Locked but not connected to tool."	; Abort.

G90                 ; Set absolute mode

; Save Tool Number for later.
var tool = {state.nextTool}

; If not called inside a TPre for a tool then we don't know whitch tool is loaded.
if {state.currentTool} == {state.nextTool}
    echo "Manually locking tool, active tool unknown"
    set var.tool = -2
    
; Save the current mounted tool to a permanent variable.
M98 P"/sys/custom/ToolControl/Save Tool Num" T{var.tool}
