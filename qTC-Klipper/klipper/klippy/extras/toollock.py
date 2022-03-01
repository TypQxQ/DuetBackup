# Tool support
#
# Copyright (C) 2022  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging


class ToolLock:
    def __init__(self, config):
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()
        #self.printer.add_object("ToolLock", self)
        self.saved_fan_speed = 0          # Saved partcooling fan speed when deselecting a tool with a fan.
        self.tool_current = -2            # -2 Unknown tool locked, -1 No tool locked, 0 and up are tools.
        self.init_printer_to_last_tool = config.getboolean(
            'init_printer_to_last_tool', True)
        self.purge_on_toolchange = config.getboolean(
            'purge_on_toolchange', True)
        #self.tool_move_direction = config.getchoice(
        #    'tool_move_direction', {'X': 'X', 'Y': 'Y'})
        #self.safe_max_direction = config.getint(
        #    'safe_max_direction')        # Maximum safe print position in tool_move_direction

        # G-Code macros
        gcode_macro = self.printer.load_object(config, 'gcode_macro')

        self.tool_lock_gcode_template = gcode_macro.load_template(config, 'tool_lock_gcode', '')
        self.tool_unlock_gcode_template = gcode_macro.load_template(config, 'tool_unlock_gcode', '')
        #self.tool_lock_gcode_template = gcode_macro.load_template(config, 'tool_lock_gcode')
        self.custom_select_gcode_template = gcode_macro.load_template(config, 'custom_select_gcode', '')
        self.custom_deselect_gcode_template = gcode_macro.load_template(config,
                                                          'custom_deselect_gcode', '')

        # Register commands
        self.gcode = config.get_printer().lookup_object('gcode')
        self.gcode.register_command("SAVE_CURRENT_TOOL", self.cmd_SAVE_CURRENT_TOOL, desc=self.cmd_SAVE_CURRENT_TOOL_help)
        self.gcode.register_command("TOOL_LOCK", self.cmd_TOOL_LOCK, desc=self.cmd_TOOL_LOCK_help)
        self.gcode.register_command("TOOL_UNLOCK", self.cmd_TOOL_UNLOCK, desc=self.cmd_TOOL_UNLOCK_help)
        self.gcode.register_command("T_1", self.cmd_T_1, desc=self.cmd_T_1_help)
        self.gcode.register_command("SET_AND_SAVE_FAN_SPEED", self.cmd_SET_AND_SAVE_FAN_SPEED, desc=self.cmd_SET_AND_SAVE_FAN_SPEED_help)

        self.gcode.register_mux_command("TEST_PY", "EXTRUDER", None,
                                    self.cmd_test_py)
        
        self.printer.register_event_handler("klippy:ready", self.Initialize_Tool_Lock)



    def cmd_test_py(self, gcmd):
        eventtime = self.reactor.monotonic()
        fanspeed = self.printer.lookup_object('fan_generic extruder_partfan').get_status(eventtime)["speed"]
        gcmd.respond_info("Fanspeed:" + str(fanspeed))
        
    cmd_TOOL_LOCK_help = "Save the current tool to file to load at printer startup."
    def cmd_TOOL_LOCK(self, gcmd = None):
        self.gcode.respond_info("TOOL_LOCK running. ")# + gcmd.get_raw_command_parameters())
        if int(self.tool_current) != -1:
            self.gcode.respond_info("TOOL_LOCK is already locked with tool " + str(self.tool_current) + ".")
        else:
            self.tool_lock_gcode_template.run_gcode_from_command()
            self.SaveCurrentTool(-2)
            self.gcode.respond_info("Locked")

    cmd_T_1_help = "Deselect all tools"
    def cmd_T_1(self, gcmd = None):
        self.gcode.respond_info("T_1 running. ")# + gcmd.get_raw_command_parameters())
        if self.tool_current != -1:
            self.printer.lookup_object('tool ' + str(self.tool_current)).Dropoff()
        return ""

    cmd_TOOL_UNLOCK_help = "Save the current tool to file to load at printer startup."
    def cmd_TOOL_UNLOCK(self, gcmd = None):
        self.gcode.respond_info("TOOL_UNLOCK running. ")
        self.tool_unlock_gcode_template.run_gcode_from_command()
        self.SaveCurrentTool(-1)
        return ""

    def SaveCurrentTool(self, t):
        self.tool_current = str(t)
        save_variables = self.printer.lookup_object('save_variables')
        save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
            "SAVE_VARIABLE", "SAVE_VARIABLE", {"VARIABLE": "tool_current", 'VALUE': t}))
        return ""

    cmd_SAVE_CURRENT_TOOL_help = "Save the current tool to file to load at printer startup."
    def cmd_SAVE_CURRENT_TOOL(self, gcmd):
        t = gcmd.get_int('T', None, minval=-2)
        if t is not None:
            self.SaveCurrentTool(t)

    def Initialize_Tool_Lock(self):
        if not self.init_printer_to_last_tool:
            return ""

        self.gcode.respond_info("Initialize_Tool_Lock running.")
        save_variables = self.printer.lookup_object('save_variables')
        try:
            self.tool_current = save_variables.allVariables["tool_current"]
        except:
            self.tool_current = -1
            save_variables.cmd_SAVE_VARIABLE(self.gcode.create_gcode_command(
                "SAVE_VARIABLE", "SAVE_VARIABLE", {"VARIABLE": "tool_current", 'VALUE': self.tool_current }))

        if self.tool_current == -1:
            self.cmd_TOOL_UNLOCK()
        else:
            t = self.tool_current
            self.cmd_TOOL_LOCK()
            self.tool_current = t
        return ""

    cmd_SET_AND_SAVE_FAN_SPEED_help = "Save the fan speed to be recovered at ToolChange."
    def cmd_SET_AND_SAVE_FAN_SPEED(self, gcmd):
        fanspeed = gcmd.get_float('S', 1, minval=0, maxval=255)
        tool_id = gcmd.get_int('P', self.tool_current, minval=0)

        # If value is >1 asume it is given in 0-255 and convert to percentage.
        if fanspeed > 1:
            fanspeed=fanspeed / 255.0

        self.SetAndSaveFanSpeed(tool_id, fanspeed)

    def SetAndSaveFanSpeed(self, tool_id, fanspeed):
        self.gcode.respond_info("ToolLock.SetAndSaveFanSpeed: Change fan speed for T%d to %d." % tool_id, fanspeed)
        tool = self.printer.lookup_object("tool " + str(tool_id))

        if tool.fan is none:
            self.gcode.respond_info("ToolLock.SetAndSaveFanSpeed: Tool %d has no fan." % tool_id)
        else:
            SaveFanSpeed(fanspeed)
            self.gcode.run_script_from_command(
                "SET_FAN_SPEED FAN=%s SPEED=%d" % 
                tool.fan, 
                fanspeed)

    def SaveFanSpeed(self, fanspeed):
        self.saved_fan_speed = float(fanspeed)
       
    def get_tool_current(self):
        return self.tool_current

    def get_saved_fan_speed(self):
        return self.saved_fan_speed

    def get_purge_on_toolchange(self):
        return self.purge_on_toolchange

    def get_status(self, eventtime= None):
        status = {
            "tool_current": self.tool_current,
            "saved_fan_speed": self.saved_fan_speed,
            "purge_on_toolchange": self.purge_on_toolchange 
        }
        return status

def load_config(config):
    return ToolLock(config)

