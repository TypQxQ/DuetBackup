; homeWA-subset.g
; called to home the W and A axis, move over to UV for homing.
;

M400                ; make sure everything has stopped before we make changes

M98 P"/sys/SetAxisParameters.g"	; Set Axis parameters


                    ; Set carriage home to front, so not to bump into idlers on back.
M569 P4 S0          ; Drive 4 goes forward U for homing
M569 P8 S0          ; Drive 8 goes forward V for homing

M913 U40 V40        ; Use less power not to dammage belts.
M915 U V S3 R0 F0   ; set U and V to sensitivity 2, do nothing when stall, unfiltered. This works for homing!

M574 U1 S3          ; set endstops to use motor stall
M574 V1 S3          ; set endstops to use motor stall

;     Set acceleration and max speed and jerk for homing. To high and sensorless homing fails.
M201 U1000 V1000    ; SET ACCELERATIONS (MM/S^2)
M203 U24000 V24000  ; SET MAXIMUM SPEEDS (MM/MIN)
M566 U300 V300      ; Jerk

M400
G91                 ; relative positioning
G1 H1 U-310 F4000   ; Move to W min
G0 U10 F4000        ; Move out of the way so not to interfere with next homing
G1 H1 V-310 F4000   ; Move to A min

M400                ; make sure everything has stopped before we make changes
M913 U100 V100      ; Use full power not slip on big and fast movements.
G90                 ; Absolute positioning

;M400                ; make sure everything has stopped before we make changes
;G0 U5 V5 F24000     ; Move 5
M400                ; make sure everything has stopped before we make changes
G92 U0 V0           ; Set UV position as 0 so to move the carriage 5mm towards center
G0 X150 Y150 U155 V155 F24000 ; Move to where UV will be at 5

; Return carriage home to back by inverting motors
M400                ; make sure everything has stopped before we make changes
M569 P4 S1          ; Drive 4 goes backwards U (W)
M569 P8 S1          ; Drive 8 goes backwards V (A)

G92 U150 V150           ; Set UV position as 5

; Folowing are set in stallsettings again.
; M584 U10 V11 P3
; M584 X0:3:4 Y6:7:8 U10 V11 P3    ; Använd bara som XY

M99  ; Return