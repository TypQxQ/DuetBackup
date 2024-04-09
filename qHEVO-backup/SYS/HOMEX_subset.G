G91                 ; relative positioning

G1 H1 X-310 F2000   ; move quickly to X axis endstop and stop there (first pass)

G1 X+5 F2000        ; go back a few mm
G1 H1 X-10 F360     ; move slowly to X axis endstop once more (second pass)

G1 X10