; resume.g
; called before a print from SD card is resumed
;
; generated by RepRapFirmware Configuration Tool v2.1.8 on Tue Mar 17 2020 22:56:05 GMT+0100 (centraleuropeisk normaltid)
;T R1					; Resume tool doesn't work
G1 R1 X0 Y0 Z5 F30000 ; go to 5mm above position of the last print move
G1 R1 X0 Y0          ; go back to the last print move
M83                  ; relative extruder moves
G1 E3 F3600         ; extrude 10mm of filament
