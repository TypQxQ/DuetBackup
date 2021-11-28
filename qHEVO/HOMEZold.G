; homez.g
; called to home the Z axis
M98 Pstallsettingshome.g  ; Set stallsettings for homing.

M400                      ; make sure everything has stopped before we make changes

; Z
M561                      ; clear any bed transform

M913 Z50                  ; Only use 50% power not to dammage bed and hotend.
G90                       ; absolute positioning
G0 X20 Y20 F6000          ; Move to corner to probe
G30                       ; Home Z once so the next 2 homings won't try to home from middle of the bed each.

; Using 3 independent leadscrews to adjust them independently.
M561                                          ; clear any bed transform
M671 X-40.0:340.0:148.0 Y50.0:50.0:335.0 P2.0 ; Position of Z0(left), Z1(right) Leadscews and Z2(back).
G30 P0 X0 Y50 Z-99999                         ; probe near a leadscrew
G30 P1 X295 Y50 Z-99999                       ; probe near a leadscrew
G30 P2 X148 Y300 Z-99999 S3                   ; Probe near a leadscrew, save and make mesh.

M400                                          ; make sure everything has stopped before we make changes
M913 Z100                                     ; Set up power again
G29 S1                    ; Load and use Mesh auto bed compensation
M376 H20                  ; Tapper 10mm

M98 Pstallsettings.g  ; Set stallsettings for printing.
