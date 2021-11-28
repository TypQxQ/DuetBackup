if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed
	G28
;echo move.axes[0].homed, move.axes[1].homed, move.axes[2].homed, move.axes[3].homed