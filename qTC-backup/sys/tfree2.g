; Runs at the start of a toolchange.
; Note: tool offsets are applied at this point unless we preempt commands with G53!
; Note: Prior to this macro, XYZ have been saved to slot 2 by the firmware as though a G60 S2 were executed. 

M98 P"/sys/custom/ToolControl/TFree.g" Y300	; Run the general script for tool at Y position of the tool
