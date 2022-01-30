; ---------- Endstops ----------
;--- 0.0 = Emergency Button
;--- 0.1 = X
;--- 0.2 = Y
;--- 0.3 = Carriage connection to tool.
;--- 0.4 = KnobProbe
;--- 0.5 = -
;--- 0.6 = -
;--- 0.7 = U
;--- 0.8 = Z-Plate Emergency Stop
;--- 1.0 = - (Reserved for PanelDue)
;--- 1.1 = - (Reserved in case of BL-Touch)
;--- 1.2 = Z Probe
;--- 1.3 = Z Emergency Stop when Z moves above highest point.
;--- 1.4 = X Max at 503mm
;--- 1.5 = -

; ---------- XY EndStops as emergency reset ----------
M98 P"/sys/custom/EndStop_XY_Emergency.g"   	; Set XY switch to Emergency Stop button


M950 J0 C"!0.io0.in"		; Use the input pin on io0 on the main board for Emergency Button
M950 J6 C"1.io3.in"		; Use the input pin on io3 on the exp1 EStop for Zmin
M950 J7 C"!0.io8.in"		; Use the input pin on io8 on the main board EStop for Z-Plate
M950 J14 C"1.io4.in"	; Use the input pin on io4 on the exp1 board as X max.

M581 P0:1:2:6:7:14 T3 S1		; Use triggers as Emergency Reset. PowerCycle afterwards.(Run Trigger3.g)


; ---------- EndStops ----------
M574 Z0											; No Z endstop

; ---------- Z-Probe ----------
; Is configured in tpost49.g or ZTATP, depending on situation.

; ---------- Carriage coupling ----------
M950 J3 C"0.io3.in"		; Use the input pin on io3 on the main board as carriage coupling check.
M581 P3 T4 S1			; Use triggers as info.(Run Trigger4.g)

; ---------- U ToolLock EndStop as emergency reset ----------
M574 U1	S1 P"0.io7.in"	; U uses two microswitches in series
M950 J15 C"nil"		; Use the input pin on io3 on the main board as carriage coupling check.
M581 P15 T5 S1		; Use pin 15 for Trigger5.

