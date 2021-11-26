; Script fails if EndStop is triggered when this is run

; -------------- X -------------- 
M574 X1 P"nil"              ; Free up pin from EndStop
M950 J1 C"!0.io1.in"		; Use the input pin on io0 on the main board
;M581 P1 T3 S1				; Use X to trigger Emergency Reset. PowerCycle afterwards.(Run Trigger3.g)

M98 P"/sys/custom/EndStop_X-Max_Activate.g"	; Use the X max as EmergencyStop.

; -------------- Y -------------- 
M574 Y1 P"nil"              ; Free up pin from EndStop
M950 J2 C"0.io2.in"			; Use the input pin on io0 on the main board
