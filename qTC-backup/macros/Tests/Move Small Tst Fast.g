;M906 X1400 Y1400
;M915 P0.0:0.1 S-10 F1 R2

M201 X10000 Y10000	; Acceleration. Max 6000 på förra
M204 P15000 T15000
;M204 P10000 T10000
M566 X600 Y600	; Instant speed change, Max 2000 på förra.
M203 X48000 Y48000

;G1 F6000
G1 F48000
;G1 F18000

G1 X101 Y101 
G1 X101 Y199
G1 X200 Y199
G1 X200 Y101
G1 X101 Y101
G1 X200 Y101
G1 X200 Y199
G1 X101 Y199
G1 X101 Y101

G1 X200 Y199
G1 X101 Y101

G1 X200 Y101
G1 X101 Y199
G1 X200 Y101
G1 X101 Y101