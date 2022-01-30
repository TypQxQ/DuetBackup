; Tool 2

; Create Heater
	M308 S3 P"2.temp2" Y"thermistor" T100000 B4725 C0.0000000706 A"T2 Heater"	; configure sensor 3 as thermistor on pin temp2
	M950 H3 C"2.out2" T3											; create nozzle heater output on out2 and map it to sensor 3
	M143 H3 S300													; set temperature limit for heater 1 to 300C (e3d v6 all metal)
	M307 H3 B0 S1.00												; disable bang-bang mode for heater  and set PWM limit

; Create Part Fan
	M950 F5 C"2.out5"	                            ; Define Part Cooling fan on out5 (4pin)
	M106 P5 C"Part Cooling T2"						; Setup Part Cooling Fan as Part Cooling T2

; Create Hotend Fan
	M950 F6 C"2.out8"	                            ; Define Hotend Fan on out8 (2pin)
	M106 P6 S255 T45 H3                             ; Setup Hotend Fan for thermal control, full on when H3 reaches 45C

; Create Tool
;	M563 P2 S"Tool 2" D2 H3 F5          			; Define tool 2 with Extruder 2, Heater 3 and partcoolingfan 5
	M572 D2 S0.025									; Set pressure advance on Extruder Drive 2
