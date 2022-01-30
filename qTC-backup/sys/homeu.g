; Home U Axis

; check so the tool isn't already locked
if move.axes[3].machinePosition >= 10
  abort "homeu.g: Tool is engaged and locked"

G91                     ; Set relative mode
G1 U-360 F9000 H1       ; Big negative move to search for home endstop
G1 U6 F600              ; Back off the endstop
G1 U-10 F600 H1         ; Find endstop again slowly
G90                     ; Set absolute mode

;Save Tool Num for later
M98 P"/sys/custom/ToolControl/Save Tool Num" T-1	;Save tool as unloaded.

; If manually unlocked the tool
T-1 P0
echo "Homed U, setting active tool to T-1"