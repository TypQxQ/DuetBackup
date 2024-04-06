G91                       ; relative positioning

G1 H1 X-310 U-310 F2000   ; move quickly to Y axis endstop and stop there (first pass)

G92 U0

G1 X+5 U+5 F2000           ; go back a few mm
G1 H1 X-10 U-10 F360     ; move slowly to Y axis endstop once more (second pass)

G92 U0 ; Also set the U min.
