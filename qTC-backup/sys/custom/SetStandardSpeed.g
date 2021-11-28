;M906 X1200 Y1200	; Stepper current
;M204 P1000 T6000	; Acceleration Print and Travel
;M201 X6000 Y6000	; Max acceleration (mm/s^2) (e3d ToolChanger har 6000)
;M566 X800 Y800 P1	; Maximum instantaneous speed changes (mm/min) (5mm/s) (e3d ToolChanger har 400) (Slipped with 1000/1500 that I tested with)
;M203 X33900 Y33900 	; set maximum speeds (mm/min) (XY:565) 70,8% of this is 400. Only one stepper wworking with max 400mm/s in diagonal

M906 X1400 Y1400	; Stepper current
M204 P1000 T3000	; Acceleration Print and Travel
;M201 X4000 Y4000	; Changed from this 05/10/2021
M201 X4000 Y4000	; Max acceleration (mm/s^2) (e3d ToolChanger har 6000)
M566 X300 Y300 P1	; Maximum instantaneous speed changes (mm/min) (5mm/s) (e3d ToolChanger har 400) (Slipped with 1000/1500 that I tested with)
M203 X33900 Y33900 	; set maximum speeds (mm/min) (XY:565) 70,8% of this is 400. Only one stepper wworking with max 400mm/s in diagonal
