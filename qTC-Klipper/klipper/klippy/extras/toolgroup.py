# Tool support
#
# Copyright (C) 2022  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging

class ToolGroup:
    #Physical     = 1 # Physical tool 
    #Virtual      = 2 # Virtual tool that has a Physical tool parent. If tool is parent tool it can be the same as virtual. Requred on virtual tool and on physical tool holding virtual tools.
    def __init__(self, config):
        self.printer = config.get_printer()
        self.name = config.get_name().split(' ')[1]
        gcode_macro = self.printer.load_object(config, 'gcode_macro')

        if not unicode(self.name, 'utf-8').isnumeric():
            raise config.error(
                    "Name of section '%s' contains illegal characters. Use only integer ToolGroup number."
                    % (config.get_name()))

        self.is_virtual = config.getboolean(    # If True then must have a physical_parent declared and shares extruder, hotend and fan with the physical_parent
            'is_virtual', False)
        self.physical_parent_id = config.getint(   # Tool used as a Physical parent for all toos of this group. Only used if the tool i virtual.
            'physical_parent', None)
        self.wipe_type = config.get('wipe_type', -1)     # -1 = none, 1= Only load filament, 2= Wipe in front of carriage, 3= Pebble wiper, 4= First Silicone, then pebble. Defaults to 0.
        self.pickup_gcode = config.get('pickup_gcode', '')
        self.dropoff_gcode = config.get('dropoff_gcode', '')
        self.wipe_type = config.get('wipe_type', None)                      # 0 = none, 1= Only load filament, 2= Wipe in front of carriage, 3= Pebble wiper, 4= First Silicone, then pebble. Defaults to 0.


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

    def get_pickup_gcode(self):
        return self.pickup_gcode

    def get_dropoff_gcode(self):
        return self.dropoff_gcode

    def get_status(self, eventtime= None):
        status = {
            "is_virtual": self.is_virtual,
            "physical_parent_id": self.physical_parent_id,
            "wipe_type": self.wipe_type
        }
        return status

def load_config_prefix(config):
    return ToolGroup(config)




