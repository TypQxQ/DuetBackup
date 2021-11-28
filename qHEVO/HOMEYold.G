; homey.g
; called to home the Y axis

M98 Pstallsettingshome.g  ; Set stallsettings for homing.

G91                       ; relative positioning
G1 Z5 F6000 S2            ; lift Z relative to current position

M98 PHOMEY_subset.G       ; Call the actual homing

M400                      ; make sure everything has stopped before we make changes
G1 Z-5 F6000 S2           ; lower Z again

M98 Pstallsettings.g      ; Set stallsettings for printing.
G90                       ; absolute positioning