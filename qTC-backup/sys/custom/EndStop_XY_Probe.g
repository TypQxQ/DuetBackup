; -------------- X -------------- 
M950 J1 C"nil"				; Free up X endstop pin from Emergencystop script.
M574 X1 S1 P"!0.io1.in"		; Endstop for X is on io0 on 6HC uses a reprap microswitch
M98 P"/sys/custom/EndStop_X-Max_Deactivate.g"	; Don't use the X max as EmergencyStop.

; -------------- Y -------------- 
M950 J2 C"nil"				; Free up Y endstop pin from Emergencystop script.
M574 Y1 S1 P"0.io2.in"		; Endstop for Y is on io1 on 6HC uses a microswitch

