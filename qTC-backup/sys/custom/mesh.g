; Only run if actually called with parameters.
var m557PointsX = 9 ; Number of probe points default in X
var m557PointsY = 9 ; Number of probe points default in Y

if !exists(param.X) ; m557MinX
  echo "/sys/custom/mesh.g: Could not find m557MinX parameter to run mesh."
  M99
if !exists(param.U) ; m557MaxX
  echo "/sys/custom/mesh.g: Could not find m557MaxX parameter to run mesh."
  M99
if !exists(param.Y) ; m557MinY
  echo "/sys/custom/mesh.g: Could not find m557MinY parameter to run mesh."
  M99
if !exists(param.V) ; m557MaxY
  echo "/sys/custom/mesh.g: Could not find m557MaxY parameter to run mesh."
  M99

if (param.U - param.X) < 100
  set var.m557PointsX = 5
if (param.V - param.Y) < 100
  set var.m557PointsY = 5
if (param.U - param.X) < 50
  set var.m557PointsX = 3
if (param.V - param.Y) < 50
  set var.m557PointsY = 3
if (param.U - param.X) < 5
  echo "Print area too small for mesh."
  G29 S2 ; Clear all meshes
  M99 ; Do not run any mesh.
if (param.V - param.Y) < 5
  echo "Print area too small for mesh."
  G29 S2 ; Clear all meshes
  M99 ; Do not run any mesh.
; End if

;M117 {var.m557PointsX}
;M117 {var.m557PointsY}

M557 X{param.X,param.U} Y{param.Y,param.V} P{var.m557PointsX,var.m557PointsY} ; put your required spacing here
M557

; Mount Z Tool
T49

; Set the new dive height
;M558 P8 C"1.io2.in" F250 H5 T40000 A2 S0.02		; Set the pin of Z probe
M558 H3

while true
  if iterations = 10
    abort "Too many auto calibration attempts"
  G29 S0 ; Probe mesh
  if result != 0
    echo "Failed Mesh. Restarting"
    continue
  if move.compensation.meshDeviation.deviation <= 0.1 & move.compensation.meshDeviation.deviation >= -0.1 & move.compensation.meshDeviation.mean <= 0.1 & move.compensation.meshDeviation.mean >= -0.1
    break
  echo "Repeating mesh because deviation or mean is too high."
; end loop
;echo "Auto calibration successful, deviation", move.calibration.final.deviation ^ "mm"




G0 Z5

;T-1