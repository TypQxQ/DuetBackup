M48
M18
M569 P1.2 S1	                                ; physical drive 0.2 goes forwards  Toolchanger Actuator
M584 E2.0:2.1:2.2:1.2 	; set drive mapping ( Z in the order of bed leveling )
M906 E1600

; Create Tool
	M563 P48 S"PTFE Cleaner" D3           			; Define tool 48
    T48 P0											; Mount the Tool
	M302 P1