; Runs after firmware thinks ToolN is selected
; Note: tool offsets are applied at this point!
; Note that commands prefixed with G53 will NOT apply the tool offset.

M98 P"/sys/custom/ToolControl/TPost.g"	; First part of script
