var filename = "globals/"^{param.V}
echo > {var.filename} "if exists(global."^{param.V}^")"
echo >> {var.filename} "    set global."^{param.V}^" = "^{param.X}
echo >> {var.filename} "else"
echo >> {var.filename} "    global "^{param.V}^" = "^{param.X}
M98 P{var.filename}