; Runs before firmware thinks ToolN is selected
; Note: tool offsets are NOT applied at this point!

M98 P"/sys/custom/ToolControl/TPre.g" Y5	; Run the general script for tool at Y position of the tool
