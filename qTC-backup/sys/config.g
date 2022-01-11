; Configuration file for Duet 3 (firmware version 3)

; Maximum speed for e3d HighTorq at 31V, 1400mA (83% of 1680mA). (At 1500 back EMF is 32.7V so a no go.)
; Approximate peak back EMF due to rotation per motor: 14.1 V at 350.0 mm/s
; Approximate peak back EMF due to inductance per motor: 30.5 V at 350.0 mm/s
; Step pulse frequency: 56.0 kHz at 350.0 mm/s of max 300kHz with one stepper.
; Speed at which torque starts to drop (low slip angle): 241.2 mm/s @ 54.6 kHz
; Speed at which torque starts to drop (high slip angle): 315.8 mm/s @ 71.4 kHz



; ---------- General Preferences ----------
G90                                             ; send absolute coordinates...
M83                                             ; ...but relative extruder moves
M550 P"qTC"                                  	; set printer name
M552 S1 P192.168.1.210
M929 P"eventlog.txt" S3							; start logging to file eventlog.txt Debug level
M669 K1                                         ; select CoreXY mode

; ---------- Drives ----------
;M569 P0.0 S0 F4                                 ; physical drive 0.0 goes forwards  X
;M569 P0.1 S1 F4                                 ; physical drive 0.1 goes forwards  Y
M569 P0.2 S1	                                ; physical drive 0.2 goes forwards  Toolchanger Actuator
M569 P0.3 S1                                    ; physical drive 0.3 goes forwards	Z Back
M569 P0.4 S1                                    ; physical drive 0.4 goes forwards	Z Left
M569 P0.5 S1                                    ; physical drive 0.5 goes forwards	Z Front

M569 P0.0 S0	                                ; physical drive 0.0 X1

M569 P0.1 S0	                                ; For when Y is on same board
;M569 P0.1 S1	                                ; For when Y is on diffrent boards

M569 P1.0 S1                                    ; For when X is on same board
;M569 P1.0 S0                                    ; For when X is on diffrent boards

M569 P1.1 S1                                    ; physical drive 1.1 X2


M569 P2.0 S1                                    ; physical drive 2.0 goes forwards	E1
M569 P2.1 S1                                    ; physical drive 2.1 goes forwards	E2
M569 P2.2 S1                                    ; physical drive 2.2 goes forwards	E3

M584 X0.0:0.1 Y1.0:1.1 Z0.4:0.3:0.5 E2.0:2.1:2.2 U0.2 	; set drive mapping ( Z in the order of bed leveling )
;M584 X0.0:1.0 Y0.1:1.1 Z0.4:0.3:0.5 E2.0:2.1:2.2 U0.2 	; set drive mapping ( Z in the order of bed leveling )


;M350 X16 Y16 I1
M350 X32 Y32 I0
M350 E16 I0                          			; configure 16x for XY and E microstepping with interpolation
M350 U4 I1                    					; configure 1x microstepping with interpolation for U, better torque. x4 is original
M350 Z16 I0                    					; configure microstepping with interpolation. Full steps on Z means 200 steps per mm and a resolution of 0,005mm per step.

; ---------- Motor currents ----------
;M906 X2263 Y2263                        ; LDO XY motor currents (mA). 2263mA is 80% of 2828mA Peak Current. (2828mA Peak is 2000mA RMS)
                                        ; Do not exceed 90% of full XY motor current rating without heatsinking the XY motor drivers.

M906 X1400 Y1400 						; set motor currents (mA) 1200 is Good up to 400mm/s without back EMF at 31,1V on one stepper
M906 Z1400 
M906 E900 										; 900 for BMG up to 135*C. Rated for 1.4A so runing at 86% with 1200
M906 U900 i100 ;I60                           		; StepperOnline Toolchanger Elastic Lock Motor current and idle motor percentage, must be 60% idle and 90% current. Goes up to 120% when locking
M84 S30                                         ; Set idle timeout

; ---------- Steps per mm ----------
M92 X160 Y160 Z3200.00 E830 S16 		; set steps per mm as defined for 16 microsteps
M92 U11.515 S4                          ; Stepper-Online Toolchanger Elastic Lock Motor Steps/deg for U from (200 * 4 * 5.18181)/360

; ---------- Motor speeds ----------
M203 Z720 E3600 U9000 						; set maximum speeds (mm/min) (Z:12; E:60)
M566 Z100 E1200 U50     					; set maximum instantaneous speed changes (mm/min)
M201 Z100 E3000 U800     					; set accelerations (mm/s^2)
M98 P"/sys/custom/SetStandardSpeed.g"		; Macro to set current ant speeds of XY


; ---------- Set axis software limits and min/max switch-triggering positions ----------
; ---------- Adjusted such that (0,0) lies at the lower left corner  ----------
M208 X-3:500 Y-6:515 Z-0.2:600					; Set the Xmin
M208 U0:200										; Set Elastic Lock (U axis) max rotation angle

; ---------- Kinematic bed ball locations ----------
M671 X-49.5:523.5:523.5 Y262.5:553:-37 S10
M557 X10:470 Y10:480 P10                        ; define mesh grid with 10 points in each direction

M98 P"/sys/custom/conf_EndStops.g"				; Configure EndStops and Emergency Stops.

; ---------- Bed Heater ----------
M308 S0 P"0.temp0" Y"thermistor" T10000 B3435 A"Bed"			; configure sensor 0 as thermistor on pin 0.temp0 for the thermistor on buildplate
M950 H0 C"0.out0" T0 Q1											; create bed heater output on 0.out0 and map it to sensor 0, PWM 1Hz (Default 500), Recommended is up to 10Hz for SSD.
M308 S10 P"0.temp1" Y"thermistor" T100000 B4138 A"Bed Heater"	; configure sensor 10 as thermistor on pin 0.temp1 for the builtin thermistor in the heater pad.

M143 H0 P0 T0 A0 S110  							; set temperature limit for bed 0 to 120C
M143 H0 P1 T10 A2 S120  						; set temperature limit for heater mat 0 to 120C but only switch off temporarily.
M143 H0 P2 T10 A0 S130  						; set temperature limit for heater mat 0 to 130C and generate heater error.
M140 H0                                         ; map heated bed to heater 0

M308 S11 P"0.temp2" Y"thermistor" T100000 B4138 A"X-Stepper" ; configure sensor 11 as thermistor on pin 0.temp2 for the builtin thermistor
M950 F11 C"0.out7"	                            ; Define X-Stepper Fan on out7 (2pin)
M950 F12 C"0.out8"	                            ; Define Y-Stepper Fan on out7 (2pin)
M106 P11 S255 T30 H11 C"X-Stepper Fan"          ; Setup Hotend Fan for thermal control, full on when XY-Stepper reaches 45C
M106 P12 S255 T30 H11 C"Y-Stepper Fan"          ; Setup Hotend Fan for thermal control, full on when XY-Stepper reaches 45C


; ---------- Tool definitions ----------
M98 P"/sys/custom/tool_0.g"						; Macro to load the tool definitions for Tool0
M98 P"/sys/custom/tool_1.g"						; Macro to load the tool definitions for Tool1
M98 P"/sys/custom/tool_2.g"						; Macro to load the tool definitions for Tool2
M563 P49 S"Z-Probe"								; Set up Tool49 as Z-Probe

; Miscellaneous
M501                                            ; load saved parameters from non-volatile memory

; ---------- Init heaters ----------
M568 P0 S0 R0			; Set tool 0 operating and standby temperatures(-273 = "off")
M568 P1 S0 R0			; Set tool 1 operating and standby temperatures(-273 = "off")
M568 P2 S0 R0			; Set tool 2 operating and standby temperatures(-273 = "off")
T0 P0
T1 P0
T2 P0
T-1 P0

; Set global variables
if !exists(global.purgeOnToolChange)
  global purgeOnToolChange=true
else
  set global.purgeOnToolChange=true

; Load persistant global variables
M98 P"globals/lastTool"

; Set last active tool
if {global.lastTool} == -2
    M291 S2 P"Unknown tool loaded" R"Tool Detected"
    G92 U169
elif {global.lastTool} >= 0
    M291 S2 P{"Tool Loaded on Power Off, automatically setting tool to T"^{global.lastTool}} R"Power Resume Tool Auto Set"
    T{global.lastTool} P0
    G92 U169
else
    G28 U                             ; home coupler
