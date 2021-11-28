; https://polygno.com/flow_rate_calculator
; Layer thickness (mm)	0.25
; Extrusion width (mm)	0.5
; Linear speed (mm/s)	100
; Volume flow (mm)3/s	12.50
; Filament speed (mm/s)	5.2
; Filament speed (mm/m)	312

M83     ;relative extrusions 
G1 F312 ;mm/min speed 
G1 E20  ;prime with 20mm 
G1 F3   ;slow extrude for pause 
G1 E0.1 ;0.1mm extrusion 
G1 F312 ;mm/min speed 
G1 E250 ;250mm extrusion x2 to 
G1 E250 ;trick max extrusion limit
G1 F312