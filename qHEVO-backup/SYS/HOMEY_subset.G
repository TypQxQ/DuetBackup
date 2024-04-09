G91                     ; relative positioning

G1 H1 Y-310 F2000  ; move quickly to Y axis endstop and stop there (first pass)
;M114

G1 Y+5 F2000         ; go back a few mm
;M114
G1 H1 Y-10 F360   ; move slowly to Y axis endstop once more (second pass)
