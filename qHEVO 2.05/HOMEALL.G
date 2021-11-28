; homeall.g
; called to home all axes

M104 S130		 ; Start heating extruder to probing temperature
M109 R130 		 ; Wait for extruder to reach probing before proceeding

M400                     ; make sure everything has stopped before we make changes
M98 Pstallsettingshome.g ; Set stallsettings for homing.

G91                      ; relative positioning
G1 Z5 F6000 S2           ; lift Z relative to current position

M98 PHOMEY_subset.G      ; Call the actual homing of Y
G1 Y5 V5 F6000 S2        ; Move 5mm so not X gets upset when homing sensorless.
M98 PHOMEX_subset.G      ; Call the actual homing of X

M913 X60 Y60 U60 V60          ; Use less power not to dammage belts.

; Z
M561                      ; clear any bed transform

G90                       ; absolute positioning
G0 X20 Y20 U20 V20 F6000  ; Move to corner to probe
G30                       ; Home Z once so the next 3 homings won't try to home from middle of the bed each.

M400                      ; make sure everything has stopped before we make changes
;G29 S1                   ; Load and use Mesh auto bed compensation
;M376 H20                 ; Tapper 10mm

;M290 Z0.2 R0             ; Babystep to Buildtak height
;M290 Z0.1 R0             ; Babystep to Ultrabase height
;M290 Z0 R0                ; Reset Babystep 

M98 PHOMEWA-subset.G      ; Home carriage for active vibration dampening.

M98 Pstallsettings.g      ; Set stallsettings for print.
G90                       ; absolute positioning

M99                       ; end macro


