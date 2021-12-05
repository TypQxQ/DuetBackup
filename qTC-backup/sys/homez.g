; homez.g
; called to home the Z axis
;

; P8 --> probe type: Unfiltered switch
; C"1.io2.in" --> endstop
; Fnnn --> Feed rate (i.e. probing speed, mm/min)
; H5 --> dive height
; Tnnn --> Travel speed to and between probe points (mm/min)
; A1 --> Probe once 
; S0.02 --> tolerance when probing multiple times

;M558 P8 C"1.io2.in" F250 H5 T24000 A2 S0.02		; Set the pin of Z probe
;G31 Z-1											; Set probe height as -1 so 0 is 1mm below the probe

; Mount Z tool
T49											; Mount probe

M561 										; Disable any Mesh Bed Compensation
G90											; Set to Absolute Positioning
G0 X255 Y255 F34000 						; Move to the center of the bed

G30

; Unmount Z tool
;T-1
