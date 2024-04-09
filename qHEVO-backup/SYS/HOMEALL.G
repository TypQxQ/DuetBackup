; homeall.g
; called to home all axes

M568 S130		 ; Start heating extruder to probing temperature
M109 R130 		 ; Wait for extruder to reach probing before proceeding

M400                ; make sure everything has stopped before we make changes

M98 P"stallsettingshome.g" ; Set stallsettings for homing.

; Init the steppers for U and V
G92 X0 Y0 U0 V0
G1 H2 X0.1 Y0.1 U0.1 V0.1       ; Jerk a litle to initialize the steppers
G1 H2 X-0.1 Y-0.1 U-0.1 V-0.1 ; Jerk a litle to initialize the steppers
M400                ; make sure everything has stopped before we make changes

M913 X60 Y60 U60 V60     ; Use less power not to dammage belts.

G91                      ; relative positioning
G1 Z5 F6000 H2           ; lift Z relative to current position

M98 P"HOMEX_subset.G"    ; Call the actual homing of X
G1 X100 F6000 		 ; Move 5mm so not WA gets upset when homing sensorless.
M98 P"HOMEY_subset.G"    ; Call the actual homing of Y

M913 X100 Y100 U100 V100         ; Use full power.

M98 P"HOMEWA-subset.G"      ; Home carriage for active vibration dampening.

; Z
M561                      ; clear any bed transform

G90                       ; absolute positioning
G0 X150 Y150 U150 V150 F6000  ; Move to corner to probe
G30                       ; Home Z once so the next 3 homings won't try to home from middle of the bed each.

M400                      ; make sure everything has stopped before we make changes
;G29 S1                   ; Load and use Mesh auto bed compensation
;M376 H20                 ; Tapper 10mm


M98 P"stallsettings.g"      ; Set stallsettings for print.
G90                       ; absolute positioning

