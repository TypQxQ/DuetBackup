# Test module
#
# Copyright (C) 2022  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging


class Test:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()
        self.gcode = config.get_printer().lookup_object('gcode')

        gcode_macro = self.printer.load_object(config, 'gcode_macro')

        # Register commands
        self.gcode.register_mux_command("TEST_PY", "EXTRUDER", None, self.cmd_test_py)
        
    def cmd_test_py(self, gcmd):
        gcode_move = self.printer.lookup_object('gcode_move')
        # Get Current Position
        p = gcode_move._get_gcode_position()
        self.gcode.respond_info("X:%.3f Y:%.3f Z:%.3f E:%.3f" % tuple(p))

        self.gcode.respond_info("X%.3f Y%.3f" % (p[0], p[1]))
#        gcmd.respond_raw("X:%.3f Y:%.3f Z:%.3f E:%.3f" % tuple(p))

        
def load_config(config):
    return Test(config)
