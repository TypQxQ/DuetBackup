G90                          ; Force coordinates to be absolute relative to the origin
M83 ;set extruder to absolute mode
G92 E0                       ; Set extruder to 0 zero


M291 P"Please wait while the nozzle is being heated up" R"Unloading PET-G" T5 ; Display message
M109 S235 ; Heat up the current tool to 200C
M116 ; Wait for the temperatures to be reached

M291 P"Extruding filament..." R"For unloading PET-G" T5 ; Display another message
G1 E10 F300 ; Retract 20mm of filament at 300mm/min (5/s)

M291 P"Retracting filament..." R"Unloading PET-G" T5 ; Display another message
G1 E-100 F3600 ; Retract 20mm of filament at 3600mm/min (60/s)
G1 E-480 F3600 ; Retract 480mm of filament at 3000mm/min
M400 ; Wait for the moves to finish
M292 ; Hide the message again
M84 E0 ; Turn off extruder drives 1 and 2
M104 S0 ; Turn off the heater again