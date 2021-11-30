G90                          ; Force coordinates to be absolute relative to the origin
M83 ;set extruder to absolute mode
G92 E0                       ; Set extruder to 0 zero


M291 P"Please wait while the nozzle is being heated up" R"Unloading PLA" T5 ; Display message
G10 S200 ; Heat up the current tool to 200C
M116 ; Wait for the temperatures to be reached

M291 P"Feeding filament..." R"Loading PLA" T5 ; Display new message
G1 E10 F600 ; Feed 10mm of filament at 600mm/min
G1 E100 F3000 ; Feed 470mm of filament at 3000mm/min
G1 E20 F300 ; Feed 20mm of filament at 300mm/min
G4 P1000 ; Wait one second
G1 E-3 F1800 ; Retract 3mm of filament at 1800mm/min
M400 ; Wait for moves to complete
M292 ; Hide the message
G10 S0 ; Turn off the heater again