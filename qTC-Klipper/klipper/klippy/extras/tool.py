# Tool support
#
# Copyright (C) 2022  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging

class Tool:
    def __init__(self, config = None):
        # If called without config then createa a dummy object.
        if config is None:
            self.name = None
            self.is_virtual = None
            self.physical_parent_id = None
            self.extruder = None
            self.fan = None
            self.meltzonelength = 0
            self.wipe_type = None
            self.zone = None
            self.park = None
            self.offset = None
            self.pickup_gcode = None
            self.dropoff_gcode = None
            return None

        # And from here we create the real object.
        self.printer = config.get_printer()
        self.gcode = config.get_printer().lookup_object('gcode')
        gcode_macro = self.printer.load_object(config, 'gcode_macro')
        self.toollock = self.printer.lookup_object('toollock')

        self.name = config.get_name().split()[-1]

        if not unicode(self.name, 'utf-8').isnumeric():
            raise config.error(
                    "Name of section '%s' contains illegal characters. Use only integer tool number."
                    % (config.get_name()))
        else:
            self.name = int(self.name)

        # ToolType, defaults to 0. Check if tooltype is defined.
        self.toolgroup = 'toolgroup ' + str(config.getint('tool_group'))
        if config.has_section(self.toolgroup):
            self.toolgroup = self.printer.lookup_object(self.toolgroup)
        else:
            raise config.error(
                    "Tooltype of '%s' is not defined. It must be configured before the tool."
                    % (config.get_name()))

        self.is_virtual = config.getboolean('is_virtual', 
                                            self.toolgroup.get_status()["is_virtual"])

        # Parent tool is used as a Physical parent for all tools of this group. Only used if the tool i virtual.
        self.physical_parent_id = config.getint('physical_parent', 
                                                self.toolgroup.get_status()["physical_parent_id"])

        if self.physical_parent_id is None:
            self.physical_parent_id = -1

        # Used as sanity check for tools that are virtual with same physical as themselves.
        if self.is_virtual and self.physical_parent_id == -1:
            raise config.error(
                    "Section Tool '%s' cannot be virtual without a valid physical_parent."
                    % (config.get_name()))

        
        if int(self.physical_parent_id) == int(self.name):
            self.physical_parent_id = -1;

        if self.physical_parent_id >= 0:
            pp = self.printer.lookup_object("tool " + str(self.physical_parent_id))
        else:
            pp = Tool()     # Initialize physical parent as a dummy object.

        pp_status = pp.get_status()

        self.extruder = config.get('extruder', pp_status['extruder'])      # Name of extruder connected to this tool. Defaults to None.
        self.fan = config.get('fan', pp_status['fan'])                     # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.meltzonelength = config.get('meltzonelength', 
                                         pp_status['meltzonelength'])      # Length of the meltzone for retracting and inserting filament on toolchange. 18mm for e3d Revo


        self.wipe_type = config.get('wipe_type', pp_status['wipe_type'])   # -1 = none, 1= Only load filament, 2= Wipe in front of carriage, 3= Pebble wiper, 4= First Silicone, then pebble. Defaults to None.
        if self.wipe_type is None:
            self.wipe_type = self.toolgroup.get_status()["wipe_type"]      # Toolgroup initializes as -1 while all other as None.

        self.zone = config.get('zone', pp_status['zone'])                  # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.park = config.get('park', pp_status['park'])                  # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".
        self.offset = config.get('offset', pp_status['offset'])            # Name of general fan configuration connected to this tool as a part fan. Defaults to "none".

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
        temp_pickup_gcode = pp.get_pickup_gcode()
        if temp_pickup_gcode is None:
            temp_pickup_gcode =  self.toolgroup.get_pickup_gcode()
        # Get the pickup_gcode parameter the tool and use the one from the toolgroup as default.
        self.pickup_gcode_template = gcode_macro.load_template(config, 'pickup_gcode', temp_pickup_gcode)

        temp_dropoff_gcode = pp.get_dropoff_gcode()
        if temp_dropoff_gcode is None:
            temp_dropoff_gcode = self.toolgroup.get_dropoff_gcode()
        self.dropoff_gcode_template = gcode_macro.load_template(config, 'dropoff_gcode', temp_dropoff_gcode)

        # Register commands
        self.gcode.register_command("T" + str(self.name), self.cmd_SelectTool, desc=self.cmd_SelectTool_help)


    cmd_SelectTool_help = "Select Tool"
    def cmd_SelectTool(self, gcmd):
        current_tool_id = int(self.toollock.get_tool_current())

        gcmd.respond_info("T" + str(self.name) + " Selected.") # + self.get_status()['state'])
        gcmd.respond_info("Current Tool is T" + str(current_tool_id) + ".") # + self.get_status()['state'])
        gcmd.respond_info("This tool is_virtual is " + str(self.is_virtual) + ".") # + self.get_status()['state'])


        if current_tool_id == self.name:              # If trying to select the already selected tool:
            return ""                                   # Exit

        if current_tool_id < -1:
            raise self.printer.command_error("TOOL_PICKUP: Unknown tool already mounted Can't park it before selecting new tool.")

        if self.extruder is not None:               # If the new tool to be selected has an extruder.
#            self.gcode.run_script_from_command("M568 P%d A2" % int(self.name))
            pass

        if current_tool_id >= 0:                    # If there is a current tool already selected and it's a dropable.
            current_tool = self.printer.lookup_object('tool ' + str(current_tool_id))
                                                        # If the next tool is not another virtual tool on the same physical tool.
            
            gcmd.respond_info("self.physical_parent_id:" + str(self.physical_parent_id) + ".")
            gcmd.respond_info("current_tool.get_status()['physical_parent_id']:" + str(current_tool.get_status()["physical_parent_id"]) + ".")

            if int(self.physical_parent_id ==  -1 or
                        self.physical_parent_id) !=  int( 
                        current_tool.get_status()["physical_parent_id"]
                        ):
                gcmd.respond_info("Will Dropoff():")
                current_tool.Dropoff()
                current_tool_id = -1

        # Now we asume tool has been deselected if needed be.

        if not self.is_virtual:
            gcmd.respond_info("cmd_SelectTool: T" + str(self.name) + "- Not Virtual - Pickup")
            self.Pickup()
            #    SUB_TOOL_PICKUP_START {rawparams}                                    # Start Pickup tool
            #    SUB_TOOL_PICKUP_WIPE {rawparams}                                     # Wipe tool
            #    SUB_TOOL_PICKUP_END {rawparams}                                      # End Pickup tool code
            #    SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                   # Depresurize tool
        else:
            if current_tool_id >= 0:                 # If still has a selected tool: (This tool is a virtual tool with same physical tool as the last)
                current_tool = self.printer.lookup_object('tool ' + str(current_tool_id))
                gcmd.respond_info("cmd_SelectTool: T" + str(self.name) + "- Virtual - Tool is not Dropped - ")
                if self.physical_parent_id >= 0 and self.physical_parent_id == current_tool.get_status()["physical_parent_id"]:
                    gcmd.respond_info("cmd_SelectTool: T" + str(self.name) + "- Virtual - Same physical tool - Pickup")
                    current_tool.UnloadVirtual()
                    self.LoadVirtual()
                    return ""
                else:
                    gcmd.respond_info("cmd_SelectTool: T" + str(self.name) + "- Virtual - Not Same physical tool")
                    # Shouldn't reach this?
                    #self.Pickup()
                    #          SUB_TOOL_PICKUP_START T={tool_id}                                        # Pickup the physical tool for the virtual ERCF tool.
                    #                                                                             # Run ERCF code
                    #          RESPOND MSG="ERCF not implemented yet. Changing to ERCF with diffrent physical tool. From {current_tool_id} to {tool_id} with physical tool {tool.ercf_physical_tool|string}."
                    #          SUB_TOOL_PICKUP_WIPE {rawparams}                                   # Wipe tool
                    #          SUB_TOOL_PICKUP_END {rawparams}                                    # End Pickup tool code
                    #          SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                 # Depresurize tool
            else:
                gcmd.respond_info("cmd_SelectTool: T" + str(self.name) + "- Virtual - Tool is droped")
                self.Pickup()
                      #        SUB_TOOL_PICKUP_START T={tool_id}                                        # Pickup the physical tool for the virtual ERCF tool.
                      #                                                                           # Run ERCF code
                      #        RESPOND MSG="ERCF not implemented yet. Changing to ERCF with diffrent physical tool. From {current_tool_id} to {tool_id} with physical tool {tool.ercf_physical_tool|string}."
                      #        SUB_TOOL_PICKUP_WIPE {rawparams}                                   # Wipe tool
                      #        SUB_TOOL_PICKUP_END {rawparams}                                    # End Pickup tool code
                      #        SUB_TOOL_PICKUP_DEPRESURIZE_HOTEND                                 # Depresurize tool

        self.gcode.run_script_from_command("M117 T%d Loaded" % int(self.name))
        self.toollock.SaveCurrentTool(self.name)

    def Pickup(self):
        # Check if homed
        if not self.toollock.PrinterIsHomed():
            raise self.printer.command_error("Tool.Pickup: XYZ axis must be homed first. You can fakehome Z if needed.")
            return ""

        # If has an extruder then activate that extruder.
        if self.extruder is not None:
            self.gcode.run_script_from_command(
                "ACTIVATE_EXTRUDER extruder=%s" % 
                self.extruder)

        # Run the gcode for pickup.
        context = self.pickup_gcode_template.create_template_context()
        context['myself'] = self.get_status()
        self.pickup_gcode_template.run_gcode_from_command(context)

        # Restore fan if has a fan.
        if self.fan is not None:
            self.gcode.run_script_from_command(
                "SET_FAN_SPEED FAN=%s SPEED=%d" % 
                self.fan, 
                self.toollock.get_saved_fan_speed() )

        self.toollock.SaveCurrentTool(self.name)


    def Dropoff(self):
        # Check if homed
        if not self.toollock.PrinterIsHomed():
            gcmd.respond_info("Tool.Pickup: XYZ axis must be homed first. You can fakehome Z if needed.")
            return ""

        # Save fan if has a fan.
        if self.fan is not None:
            fanspeed = self.printer.lookup_object('fan_generic extruder_partfan').get_status(eventtime)["speed"]
            self.toollock.SaveFanSpeed(fanspeed)
            self.gcode.run_script_from_command(
                "SET_FAN_SPEED FAN=%s SPEED=0" % 
                self.fan)

        # Run the gcode for dropoff.
        context = self.dropoff_gcode_template.create_template_context()
        context['myself'] = self.get_status()
        self.dropoff_gcode_template.run_gcode_from_command(context)
        self.toollock.SaveCurrentTool(-1)   # Dropoff successfull

    def LoadVirtual(self):
        gcmd.respond_info("LoadVirtual: Virtual tools not implemented yet. T%d." % self.name )
        self.toollock.SaveCurrentTool(self.name)

    def UnloadVirtual(self):
        gcmd.respond_info("UnloadVirtual: Virtual tools not implemented yet. T%d." % self.name )



    def get_pickup_gcode(self):
        return self.pickup_gcode

    def get_dropoff_gcode(self):
        return self.dropoff_gcode


    def get_status(self, eventtime= None):
        status = {
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
