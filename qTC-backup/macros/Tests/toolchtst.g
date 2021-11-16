echo move.axes[3].machinePosition

if move.axes[3].machinePosition >10 && move.axes[3].machinePosition < 170 ; If locked and not 
  echo "Lock a litle more"

if move.axes[3].machinePosition > 10 ; qqq
  echo ">10"
  
if move.axes[3].machinePosition < 170
  echo "<170"

