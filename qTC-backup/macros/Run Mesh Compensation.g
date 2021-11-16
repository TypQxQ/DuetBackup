; Check the user is ready
M291 P"Check that plate is empty and ready for bed probing." R"Mesh" S3

T49
; ---------------- First carriage probe ----------------
G29

G0 Z5

T-1