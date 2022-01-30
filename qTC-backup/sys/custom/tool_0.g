; Tool 0

; Create Heater
	M308 S1 P"2.temp0" Y"thermistor" T100000 B4725 C0.0000000706 A"T0 Heater"	; configure sensor 1 as thermistor on pin temp0
	M950 H1 C"2.out0" T1											; create nozzle heater output on out0 and map it to sensor 1
	M143 H1 S300													; set temperature limit for heater 1 to 300C (e3d v6 all metal)
	M307 H1 B0 S1.00												; disable bang-bang mode for heater  and set PWM limit

; Create Part Fan
	M950 F1 C"2.out3"	                            ; Define Part Cooling fan on out3 (4pin)
	M106 P1 C"Part Cooling T0"						; Setup Part Cooling Fan as Part Cooling T0

; Create Hotend Fan
	M950 F2 C"2.out6"	                            ; Define Hotend Fan on out6 (2pin)
	M106 P2 S255 T45 H1                             ; Setup Hotend Fan for thermal control, full on when H1 reaches 45C

; Filament Runout Sensor - D0 is first extruder, P1 is simple sensor (high signal when filament present), S0 disables because it will always be fed by the extruder.
    M591 D0 P1 C"2.io2.in" S0

; Create Tool
	M563 P0 S"Tool 0" D0 H1 F1          			; Define tool 0
	M572 D0 S0.025									; Set pressure advance on Extruder Drive 0
