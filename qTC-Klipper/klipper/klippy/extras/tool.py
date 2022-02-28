# Tool support
#
# Copyright (C) 2022  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging

class DummyTool:
    def __init__(self):
        self.extruder = None

    def get_is_virtual(self):
        return None

    def get_physical_parent_id(self):
        return -1           # -1 is treated as not having a physical paretn.

    def get_extruder(self):
        return None

    def get_fan(self):
        return None

    def get_wipe_type(self):
        return None

    def get_meltzonelength(self):
        return 0

    def get_pickup_gcode(self):
        return None

    def get_dropoff_gcode(self):
        return None

    def get_zone(self):
        return None         # [X, Y] to do a fast approach for when parked. Requred on Physical tool

    def get_park(self):
        return None         # [X, Y] to do a slow approach for when parked. Requred on Physical tool

    def get_offset(self):
        return None         # Nozzle offset to probe. Requred on Physical tool


    def get_status(self, eventtime= None):
        status = {
            "is_virtual": None,
            "physical_parent_id": None,
            "extruder": None,
            "fan": None,
            "meltzonelength": 0,
            "wipe_type": None,
            "zone": None,
            "park": None,
            "offset": None,
        }
        return status


class Tool:
    def __init__(self):
        self.extruder = None
    
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name().split()[-1]
        self.id = str(config.get_name()).split(' ')[1]
        gcode_macro = self.printer.load_object(config, 'gcode_macro')

        if not unicode(self.id, 'utf-8').isnumeric():
            raise config.error(
                    "Name of section '%s' contains illegal characters. Use only integer tool number."
                    % (config.get_name()))
        else:
            self.id = int(self.id)

        # ToolType, defaults to 0. Check if tooltype is defined.
        self.toolgroup = 'toolgroup ' + str(config.getint('tool_group'))
        if config.has_section(self.toolgroup):
            self.toolgroup = self.printer.lookup_object(self.toolgroup)
        else:
            raise config.error(
                    "Tooltype of '%s' is not defined. It must be configured before the tool."
                    % (config.get_name()))

        self.is_virtual = config.getboolean('is_virtual', 
                                            self.toolgroup.get_is_virtual())

        # Tool used as a Physical parent for all toos of this group. Only used if the tool i virtual.
        self.physical_parent_id = config.getint('physical_parent', 
                                             self.toolgroup.get_physical_parent_id())
        if self.physical_parent_id is None:
            self.physical_parent_id = -1

        # Used as sanity check for tools that are virtual with same physical as themselves.
        if self.is_virtual and self.physical_parent_id == -1:
            raise config.error(
                    "Section Tool '%s' cannot be virtual without a valid physical_parent."
                    % (config.get_name()))

        # Initialize physical parent as a dummy object.
        self.pp = DummyTool()

        if int(self.physical_parent_id) == int(self.id):
            self.physical_parent_id = -1;
        elif self.physical_parent_id >= 0:
            self.pp = self.printer.lookup_object("tool " + str(self.physical_parent_id))

        self.extruder = config.get('extruder', self.pp.get_extruder())      # Name of extruder connected to this tool. Defaults to "none".
        self.fan = config.get('fan', self.pp.get_fan())                     # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.meltzonelength = config.get('meltzonelength', 
                                         self.pp.get_meltzonelength())      # Length of the meltzone for retracting and inserting filament on toolchange. 18mm for e3d Revo


        self.wipe_type = config.get('wipe_type', self.pp.get_wipe_type())   # -1 = none, 1= Only load filament, 2= Wipe in front of carriage, 3= Pebble wiper, 4= First Silicone, then pebble. Defaults to None.
        if self.wipe_type is None:
            self.wipe_type = self.toolgroup.get_wipe_type()                 # Toolgroup initializes as -1 while the other as None.

        self.zone = config.get('zone', self.pp.get_zone())                  # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.park = config.get('park', self.pp.get_park())                  # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.offset = config.get('offset', self.pp.get_offset())            # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".

        if self.zone is None or self.park is None or self.offset is None:
            raise config.error(
                    "Section Tool '%s' misses requred parameter."
                    % (config.get_name()))

        self.heater_state = 0                   # 0 = off, 1 = standby temperature, 2 = active temperature. Placeholder. Requred on Physical tool.
        self.heater_active_temp = 0             # Temperature to set when in active mode. Placeholder. Requred on Physical and virtual tool if any has extruder.
        self.heater_standby_temp = 0            # Temperature to set when in standby mode.  Placeholder. Requred on Physical and virtual tool if any has extruder.
        self.placeholder_standby_temp = 0       # Required placeholder if this tool has virtual tools. Holds last used standby temp of physical heater.

        self.idle_to_standby_time = config.get(
            'idle_to_standby_time', 30)                                     # Time in seconds from being parked to setting temperature to standby the temperature above. Use 0.1 to change imediatley to standby temperature. Requred on Physical tool
        self.idle_to_powerdown_time = config.get(
            'idle_to_powerdown_time', 600)                                  # Time in seconds from being parked to setting temperature to 0. Use something like 86400 to wait 24h if you want to disable. Requred on Physical tool.
        

        # The plain gcode string is to load for virtual tool having this tool as parent.
        self.pickup_gcode = config.get('pickup_gcode', None)
        self.dropoff_gcode = config.get('dropoff_gcode', None)


        # Get the pickup_gcode parameter from the parent and if none then from the toolgroup. If none is defined in parent and toolgroup then it returns empty.
        temp_pickup_gcode = self.pp.get_pickup_gcode()
        if temp_pickup_gcode is None:
            temp_pickup_gcode = self.pp.get_pickup_gcode()
        # Get the pickup_gcode parameter the tool and use the one from the toolgroup as default.
        self.pickup_gcode_template = gcode_macro.load_template(config, 'pickup_gcode', temp_pickup_gcode)

        temp_dropoff_gcode = self.pp.get_dropoff_gcode()
        if temp_dropoff_gcode is None:
            temp_dropoff_gcode = self.pp.get_dropoff_gcode()
        #self.dropoff_gcode_template = self.toolgroup.get_dropoff_gcode()
        self.dropoff_gcode_template = gcode_macro.load_template(config, 'dropoff_gcode', temp_dropoff_gcode)

        # Register commands
        self.gcode = config.get_printer().lookup_object('gcode')
        self.gcode.register_command("T" + str(self.id), self.cmd_SelectTool, desc=self.cmd_SelectTool_help)


    cmd_SelectTool_help = "Select Tool"
    def cmd_SelectTool(self, gcmd):
        gcmd.respond_info("T" + str(self.id) + " Selected.") # + self.get_status()['state'])
        tl = self.printer.lookup_object('toollock')
        gcmd.respond_info("Current Tool is T" + str(tl.get_tool_current()) + " Selected.") # + self.get_status()['state'])
        gcmd.respond_info("is_virtual is " + str(self.is_virtual) + ".") # + self.get_status()['state'])
        gcmd.respond_info("Parent extruder ." + str(self.pp.get_extruder()) + ".") # + self.get_status()['state'])

        current_tool_id = int(tl.get_tool_current())

        if current_tool_id == self.id:              # If trying to select the already selected tool:
            return ""                                   # Exit

        if current_tool_id < -1:
            raise self.printer.command_error("TOOL_PICKUP: Unknown tool already mounted Can't park it before selecting new tool.")

        if self.extruder is not None:               # If the new tool to be selected has an extruder.
#            self.gcode.run_script_from_command("M568 P%d A2" % int(self.id))
            pass

        if current_tool_id >= 0:                    # If there is a current tool already selected and it's a dropable.
                                                        # If the next tool is not another virtual tool on the same physical tool.
            if int(self.physical_parent_id) !=  int( self.printer.lookup_object('tool ' + str(current_tool_id)).get_physical_parent_id()):
                self.Dropoff()
                current_tool_id = -1

        # Now we asume tool has been deselected if needed be.

        if not self.is_virtual:
            gcmd.respond_info("cmd_SelectTool: T" + str(self.id) + "- Not Virtual - Pickup")
            self.Pickup()
            #    SUB_TOOL_PICKUP_START {rawparams}                                    # Start Pickup tool
            #    SUB_TOOL_PICKUP_WIPE {rawparams}                                     # Wipe tool
            #    SUB_TOOL_PICKUP_END {rawparams}                                      # End Pickup tool code
            #    SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                   # Depresurize tool
        else:
            if current_tool_id >= 0:                 # If still has a selected tool: (This tool is a virtual tool with same physical tool as the last)
                gcmd.respond_info("cmd_SelectTool: T" + str(self.id) + "- Virtual - Tool is not Dropped - ")
                if self.physical_parent_id >= 0 and self.physical_parent_id == self.printer.lookup_object('tool ' + str(current_tool_id)).get_physical_parent_id():
                    gcmd.respond_info("cmd_SelectTool: T" + str(self.id) + "- Virtual - Same physical tool - Pickup")
                    self.printer.lookup_object('tool ' + str(current_tool_id)).UnloadVirtual()
                    self.LoadVirtual()
                    return ""
                else:
                    gcmd.respond_info("cmd_SelectTool: T" + str(self.id) + "- Virtual - Not Same physical tool")
                    self.Pickup()
                    #          SUB_TOOL_PICKUP_START T={tool_id}                                        # Pickup the physical tool for the virtual ERCF tool.
                    #                                                                             # Run ERCF code
                    #          RESPOND MSG="ERCF not implemented yet. Changing to ERCF with diffrent physical tool. From {current_tool_id} to {tool_id} with physical tool {tool.ercf_physical_tool|string}."
                    #          SUB_TOOL_PICKUP_WIPE {rawparams}                                   # Wipe tool
                    #          SUB_TOOL_PICKUP_END {rawparams}                                    # End Pickup tool code
                    #          SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                 # Depresurize tool
            else:
                gcmd.respond_info("cmd_SelectTool: T" + str(self.id) + "- Virtual - Tool is droped")
                self.Pickup()
                      #        SUB_TOOL_PICKUP_START T={tool_id}                                        # Pickup the physical tool for the virtual ERCF tool.
                      #                                                                           # Run ERCF code
                      #        RESPOND MSG="ERCF not implemented yet. Changing to ERCF with diffrent physical tool. From {current_tool_id} to {tool_id} with physical tool {tool.ercf_physical_tool|string}."
                      #        SUB_TOOL_PICKUP_WIPE {rawparams}                                   # Wipe tool
                      #        SUB_TOOL_PICKUP_END {rawparams}                                    # End Pickup tool code
                      #        SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                 # Depresurize tool

        self.gcode.run_script_from_command("M117 T%d Loaded" % int(self.id))
        self.printer.lookup_object('toollock').SaveCurrentTool(self.id)

    def Pickup(self):
        context = self.pickup_gcode_template.create_template_context()
        context['myself'] = self.get_status()
        self.pickup_gcode_template.run_gcode_from_command(context)   # Park the current tool.

        if self.fan is not None:
            self.gcode.run_script_from_command(
                "SET_FAN_SPEED FAN=%s SPEED=%d" % 
                self.fan, 
                self.printer.lookup_object('toollock').get_saved_fan_speed() )

    def Dropoff(self):
        # Deselect Virtual tool if this is virtual.
        self.dropoff_gcode_template.run_gcode_from_command()   # Park the current tool.

    def LoadVirtual(self):
        gcmd.respond_info("LoadVirtual: Virtual tools not implemented yet. T%d." % self.id )
        self.printer.lookup_object('toollock').SaveCurrentTool(self.id)

    def UnloadVirtual(self):
        gcmd.respond_info("UnloadVirtual: Virtual tools not implemented yet. T%d." % self.id )



    def get_is_virtual(self):
        return self.is_virtual

    def get_physical_parent_id(self):
        return self.physical_parent_id

    def get_extruder(self):
        return self.extruder

    def get_fan(self):
        return self.fan

    def get_wipe_type(self):
        return self.wipe_type

    def get_meltzonelength(self):
        return self.meltzonelength

    def get_pickup_gcode(self):
        return self.pickup_gcode

    def get_dropoff_gcode(self):
        return self.dropoff_gcode

    def get_zone(self):
        return self.zone         # [X, Y] to do a fast approach for when parked. Requred on Physical tool

    def get_park(self):
        return self.park         # [X, Y] to do a slow approach for when parked. Requred on Physical tool

    def get_offset(self):
        return self.offset         # Nozzle offset to probe. Requred on Physical tool




    def get_status(self, eventtime= None):
        status = {
            "id": self.id,
            "name": self.name,
            "is_virtual": self.is_virtual,
            "physical_parent_id": self.physical_parent_id,
            "extruder": self.extruder,
            "fan": self.fan,
            "wipe_type": self.wipe_type,
            "meltzonelength": self.meltzonelength,
            "zone": str(self.zone).split(','),
            "park": str(self.park).split(','),
            "offset": str(self.offset).split(',')
        }
        return status

def load_config_prefix(config):
    return Tool(config)
