; Tool 1

; Create Heater
	M308 S2 P"2.temp1" Y"thermistor" T100000 B4725 C0.0000000706 A"T1 Heater"	; configure sensor 2 as thermistor on pin temp1
	M950 H2 C"2.out1" T2											; create nozzle heater output on out1 and map it to sensor 2
	M143 H2 S300													; set temperature limit for heater 1 to 300C (e3d v6 all metal)
	M307 H2 B0 S1.00												; disable bang-bang mode for heater  and set PWM limit

; Create Part Fan
	M950 F3 C"2.out4"	                            ; Define Part Cooling fan on out4 (4pin)
	M106 P3 C"Part Cooling T1"						; Setup Part Cooling Fan as Part Cooling T1

; Create Hotend Fan
	M950 F4 C"2.out7"	                            ; Define Hotend Fan on out7 (2pin)
	M106 P4 S255 T45 H2                             ; Setup Hotend Fan for thermal control, full on when H2 reaches 45C

; Create Tool
	M563 P1 S"Tool 1" D1 H2 F3          			; Define tool 1
	M572 D1 S0.025									; Set pressure advance on Extruder Drive 1
