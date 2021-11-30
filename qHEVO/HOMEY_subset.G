G91                     ; relative positioning

G1 S1 Y-310 V-310 F2000  ; move quickly to Y axis endstop and stop there (first pass)

G92 V0

G1 Y+5 V+5 F2000         ; go back a few mm
G1 S1 Y-10 V-10 F360   ; move slowly to Y axis endstop once more (second pass)

G92 V0  ; Also set the V min.
