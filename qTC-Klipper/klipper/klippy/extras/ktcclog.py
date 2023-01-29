# KTCC - Klipper Tool Changer Code
#
# Error handling based on Happy Hare rewrite of ERCF
#
# Copyright (C) 2023  Andrei Ignat <andrei@ignat.se>
#
# This file may be distributed under the terms of the GNU GPLv3 license.
import logging, logging.handlers, threading, queue, time
import math, os.path

# Forward all messages through a queue (polled by background thread)
class KtccQueueHandler(logging.Handler):
    def __init__(self, queue):
        logging.Handler.__init__(self)
        self.queue = queue

    def emit(self, record):
        try:
            self.format(record)
            record.msg = record.message
            record.args = None
            record.exc_info = None
            self.queue.put_nowait(record)
        except Exception:
            self.handleError(record)

# Poll log queue on background thread and log each message to logfile
class KtccQueueListener(logging.handlers.TimedRotatingFileHandler):
    def __init__(self, filename):
        logging.handlers.TimedRotatingFileHandler.__init__(
            self, filename, when='midnight', backupCount=5)
        self.bg_queue = queue.Queue()
        self.bg_thread = threading.Thread(target=self._bg_thread)
        self.bg_thread.start()

    def _bg_thread(self):
        while True:
            record = self.bg_queue.get(True)
            if record is None:
                break
            self.handle(record)

    def stop(self):
        self.bg_queue.put_nowait(None)
        self.bg_thread.join()

# Class to improve formatting of multi-line KTCC messages
class KtccMultiLineFormatter(logging.Formatter):
    def format(self, record):
        indent = ' ' * 9
        lines = super(KtccMultiLineFormatter, self).format(record)
        return lines.replace('\n', '\n' + indent)

class KtccLog:
    TOOL_UNKNOWN = -2
    TOOL_UNLOCKED = -1
    EMPTY_TOOL_STATS = {'pickups_completed': 0, 'droppoffs_completed': 0, 'pickups_started': 0, 'droppoffs_started': 0, 'time_selected': 0, 'time_heater_active': 0, 'time_heater_standby': 0, 'tracked_start_time_selected':0, 'tracked_start_time_active':0, 'tracked_start_time_standby':0}

    VARS_KTCC_TOOL_STATISTICS_PREFIX = "ktcc_statistics_tool"

    def __init__(self, config):
        self.config = config
        self.gcode = config.get_printer().lookup_object('gcode')
        self.printer = config.get_printer()
        self.reactor = self.printer.get_reactor()

        self.printer.register_event_handler('klippy:connect', self.handle_connect)
        self.printer.register_event_handler("klippy:disconnect", self.handle_disconnect)
        self.printer.register_event_handler("klippy:ready", self.handle_ready)

        # Logging
        self.log_level = config.getint('log_level', 1, minval=0, maxval=3)
        self.logfile_level = config.getint('logfile_level', 3, minval=-1, maxval=4)
        self.log_statistics = config.getint('log_statistics', 0, minval=0, maxval=1)
        self.log_visual = config.getint('log_visual', 1, minval=0, maxval=2)

        # Logging
        self.queue_listener = None
        self.ktcc_logger = None

        # Register commands
        handlers = [
            'KTCC_LOG_TRACE', 'KTCC_LOG_DEBUG', 'KTCC_LOG_INFO', 'KTCC_LOG_ALWAYS', 
            'KTCC_SET_LOG_LEVEL', 'KTCC_DUMP_STATS', 'KTCC_RESET_STATS']
        for cmd in handlers:
            func = getattr(self, 'cmd_' + cmd)
            desc = getattr(self, 'cmd_' + cmd + '_help', None)
            self.gcode.register_command(cmd, func, False, desc)

    def handle_connect(self):
        # Load saved variables
        self.variables = self.printer.lookup_object('save_variables').allVariables

        # Setup background file based logging before logging any messages
        if self.logfile_level >= 0:
            logfile_path = self.printer.start_args['log_file']
            dirname = os.path.dirname(logfile_path)
            if dirname == None:
                ktcc_log = '/tmp/ktcc.log'
            else:
                ktcc_log = dirname + '/ktcc.log'
            self.debug("ktcc_log=%s" % ktcc_log)
            self.queue_listener = KtccQueueListener(ktcc_log)
            self.queue_listener.setFormatter(KtccMultiLineFormatter('%(asctime)s %(message)s', datefmt='%I:%M:%S'))
            queue_handler = KtccQueueHandler(self.queue_listener.bg_queue)
            self.ktcc_logger = logging.getLogger('ktcc')
            self.ktcc_logger.setLevel(logging.INFO)
            self.ktcc_logger.addHandler(queue_handler)

        self._load_persisted_state()


    def _load_persisted_state(self):
        swap_stats = self.variables.get("ktcc_statistics_swaps", {})
        try:
            if swap_stats is None or swap_stats == {}:
                raise Exception("Couldn't find any saved statistics.")
            self.debug("Loading statistics for KTCC: %s" % str(swap_stats))
            self.total_swaps = swap_stats['total_swaps'] or 0
            self.time_spent_swaping = swap_stats['time_spent_swaping'] or 0
            self.time_spent_unloading = swap_stats['time_spent_unloading'] or 0
            self.total_pauses = swap_stats['total_pauses'] or 0
            self.time_spent_paused = swap_stats['time_spent_paused'] or 0
            self.total_toollocks = swap_stats['total_toollocks'] or 0
            self.total_toolunlocks = swap_stats['total_toolunlocks'] or 0
            self.total_toolpickups = swap_stats['total_toolpickups'] or 0
            self.total_tooldropoffs = swap_stats['total_tooldropoffs'] or 0
        except Exception:
            # Initializing statistics
            self._reset_statistics()

        self.tool_statistics = {}
        for tool in self.printer.lookup_objects('tool'):
            try:
                toolname=str(tool[0])
                toolname=toolname[toolname.rindex(' ')+1:]
                self.tool_statistics[toolname] = self.variables.get("%s%s" % (self.VARS_KTCC_TOOL_STATISTICS_PREFIX, toolname), self.EMPTY_TOOL_STATS.copy())
                self.tool_statistics[toolname]["tracked_start_time_selected"] = 0
                self.tool_statistics[toolname]["tracked_start_time_active"] = 0
                self.tool_statistics[toolname]["tracked_start_time_standby"] = 0


            except Exception as err:
                self.debug("Unexpected error in toolstast: %s" % err)

        # self.trace(str(self.tool_statistics))

    def handle_disconnect(self):
        self.always('KTCC Shutdown')
        if self.queue_listener != None:
            self.queue_listener.stop()

    def handle_ready(self):
        self.always('KlipperToolChangerCode Ready')

####################################
# LOGGING FUNCTIONS                #
####################################
    def get_status(self, eventtime):
        return {'encoder_pos': "?"}

    def always(self, message):
        if self.ktcc_logger:
            self.ktcc_logger.info(message)
        self.gcode.respond_info(message)

    def info(self, message):
        if self.ktcc_logger and self.logfile_level > 0:
            self.ktcc_logger.info(message)
        if self.log_level > 0:
            self.gcode.respond_info(message)

    def debug(self, message):
        message = "- DEBUG: %s" % message
        if self.ktcc_logger and self.logfile_level > 1:
            self.ktcc_logger.info(message)
        if self.log_level > 1:
            self.gcode.respond_info(message)

    def trace(self, message):
        message = "- - TRACE: %s" % message
        if self.ktcc_logger and self.logfile_level > 2:
            self.ktcc_logger.info(message)
        if self.log_level > 2:
            self.gcode.respond_info(message)

    # Fun visual display of KTCC state
    def _display_visual_state(self):
        if self.log_visual > 0 and not self.calibrating:
            self.always(self._state_to_human_string())

    def _log_level_to_human_string(self, level):
        log = "OFF"
        if level > 2: log = "TRACE"
        elif level > 1: log = "DEBUG"
        elif level > 0: log = "INFO"
        elif level > -1: log = "ESSENTIAL MESSAGES"
        return log

    def _visual_log_level_to_human_string(self, level):
        log = "OFF"
        if level > 1: log = "SHORT"
        elif level > 0: log = "LONG"
        return log



####################################
# STATISTICS FUNCTIONS             #
####################################
    def _reset_statistics(self):
        self.debug("Reseting KTCC statistics.")
        self.total_swaps = 0
        self.time_spent_swaping = 0
        self.time_spent_unloading = 0
        self.total_pauses = 0
        self.time_spent_paused = 0
        self.tracked_start_time = 0
        self.pause_start_time = 0
        self.total_toollocks = 0
        self.total_toolunlocks = 0
        self.total_toolpickups = 0
        self.total_tooldropoffs = 0

    def track_swap_completed(self):
        self.total_swaps += 1
        self._persist_swap_statistics()

    def track_swap_start(self):
        self.tracked_start_time = time.time()

    def track_swap_end(self):
        self.time_spent_swaping += time.time() - self.tracked_start_time

    def track_total_toolunlocks(self):
        self.total_toolunlocks += 1
        self._persist_swap_statistics()

    def track_total_toollocks(self):
        self.total_toollocks += 1
        self._persist_swap_statistics()

    def track_total_toolpickups(self):
        self.total_toolpickups += 1
        self._persist_swap_statistics()

    def track_total_tooldropoffs(self):
        self.total_tooldropoffs += 1
        self._persist_swap_statistics()

    def track_selected_tool_start(self, tool_id):
        self._set_tool_statistics(tool_id, 'tracked_start_time_selected', time.time())

    def track_selected_tool_end(self, tool_id):
        self._set_tool_statistics_time_diff(tool_id, 'time_selected', 'tracked_start_time_selected')
        self._persist_tool_statistics()

    def track_active_heater_start(self, tool_id):
        self._set_tool_statistics(tool_id, 'tracked_start_time_active', time.time())

    def track_active_heater_end(self, tool_id):
        self._set_tool_statistics_time_diff(tool_id, 'time_heater_active', 'tracked_start_time_active')
        self._persist_tool_statistics()


    def track_standby_heater_start(self, tool_id):
        self._set_tool_statistics(tool_id, 'tracked_start_time_standby', time.time())

    def track_standby_heater_end(self, tool_id):
        self._set_tool_statistics_time_diff(tool_id, 'time_heater_standby', 'tracked_start_time_standby')
        self._persist_tool_statistics()

    def _seconds_to_human_string(self, seconds):
        result = ""
        hours = int(math.floor(seconds / 3600.))
        if hours >= 1:
            result += "%d hours " % hours
        minutes = int(math.floor(seconds / 60.) % 60)
        if hours >= 1 or minutes >= 1:
            result += "%d minutes " % minutes
        result += "%d seconds" % int((math.floor(seconds) % 60))
        return result

    def _swap_statistics_to_human_string(self):
        msg = "KTCC Statistics:"
        msg += "\n%d swaps completed" % self.total_swaps
        msg += "\n%s spent mounting tools" % self._seconds_to_human_string(self.time_spent_swaping)
        msg += "\n%s spent unmounting tools" % self._seconds_to_human_string(self.time_spent_unloading)
        # msg += "\n%s spent paused (%d pauses total)" % (self._seconds_to_human_string(self.time_spent_paused), self.total_pauses)
        msg += "\n%d tool unlocks completed" % self.total_toolunlocks
        msg += "\n%d tool locks completed" % self.total_toollocks
        msg += "\n%d tool pickups completed" % self.total_toolpickups
        msg += "\n%d tool dropoffs completed" % self.total_tooldropoffs
        return msg

    def _dump_statistics(self, report=False):
        if self.log_statistics or report:
            self.always(self._swap_statistics_to_human_string())
            self._dump_tool_statistics()
        # This is good place to update the persisted stats...
        self._persist_swap_statistics()
        self._persist_tool_statistics()

    def _dump_tool_statistics(self):
        msg = "Tool Statistics:\n"
        for tool_id in self.tool_statistics:
            # self.trace(str(tool))
            msg += "Tool#%s:\n" % (tool_id)
            msg += "Completed %d out of %d pickups.\n" % (self.tool_statistics[tool_id]['pickups_completed'], self.tool_statistics[tool_id]['pickups_started'])
            msg += "Completed %d out of %d droppoffs.\n" % (self.tool_statistics[tool_id]['droppoffs_completed'], self.tool_statistics[tool_id]['droppoffs_started'])
            msg += "Time spent selected %s, active heater %s, standby heater %s.\n" % (self._seconds_to_human_string(self.tool_statistics[tool_id]['time_selected']), self._seconds_to_human_string(self.tool_statistics[tool_id]['time_heater_active']), self._seconds_to_human_string(self.tool_statistics[tool_id]['time_heater_standby']))
            msg += "------------"

        self.always(msg)

    def _persist_swap_statistics(self):
        swap_stats = {
            'total_swaps': self.total_swaps,
            'time_spent_swaping': round(self.time_spent_swaping, 1),
            'time_spent_unloading': round(self.time_spent_unloading, 1),
            'total_pauses': self.total_pauses,
            'time_spent_paused': self.time_spent_paused,
            'total_toolunlocks': self.total_toolunlocks,
            'total_toollocks': self.total_toollocks,
            'total_toolpickups': self.total_toolpickups,
            'total_tooldropoffs': self.total_tooldropoffs
            }
        self.gcode.run_script_from_command("SAVE_VARIABLE VARIABLE=%s VALUE=\"%s\"" % ("ktcc_statistics_swaps", swap_stats))

    def _persist_tool_statistics(self):
        for tool in self.tool_statistics:
            try:
                self.gcode.run_script_from_command("SAVE_VARIABLE VARIABLE=%s%s VALUE=\"%s\"" % (self.VARS_KTCC_TOOL_STATISTICS_PREFIX, tool, self.tool_statistics[tool]))
            except Exception as err:
                self.debug("Unexpected error in _persist_tool_statistics: %s" % err)

    def increase_tool_statistics(self, key, tool_id, count=1):
        try:
            # if self.tool_statistics.get(str(tool_id)) is not None:
            if str(tool_id) in self.tool_statistics:
                if isinstance(count, float):
                    self.tool_statistics[str(tool_id)][key] = round(self.tool_statistics[str(tool_id)][key] + count, 3)
                else:
                    self.tool_statistics[str(tool_id)][key] += count
            else:
                self.debug("increase_tool_statistics: Unknown tool provided to record tool stats: %s" % tool_id)
                # self.debug(str(self.tool_statistics))
        except Exception as e:
            self.debug("Exception whilst tracking tool stats: %s" % str(e))
            self.debug("increase_tool_statistics: Error while tool: %s provided to record tool stats while key: %s and count: %s" % (tool_id, str(key), str(count)))
        # self.trace("increase_tool_statistics: Tool: %s provided to record tool stats while key: %s and count: %s" % (tool_id, str(key), str(count)))

    def _set_tool_statistics(self, tool_id, key, value):
        try:
            if str(tool_id) in self.tool_statistics:
                self.tool_statistics[str(tool_id)][key] = value
            else:
                self.debug("_set_tool_statistics: Unknown tool: %s provided to record tool stats while key: %s and value: %s" % (tool_id, str(key), str(value)))
        except Exception as e:
            self.debug("Exception whilst tracking tool stats: %s" % str(e))
            self.debug("_set_tool_statistics: Error while tool: %s provided to record tool stats while key: %s and value: %s" % (tool_id, str(key), str(value)))
        # self.trace("_set_tool_statistics: Tool: %s provided to record tool stats while key: %s and value: %s" % (tool_id, str(key), str(value)))

    def _set_tool_statistics_time_diff(self, tool_id, final_time_key, start_time_key):
        # self.trace("_set_tool_statistics_time_diff: Tool: %s provided to record tool stats while final_time_key: %s and start_time_key: %s" % (tool_id, str(final_time_key), str(start_time_key)))
        try:
            if str(tool_id) in self.tool_statistics:
                tool_stat= self.tool_statistics[str(tool_id)]
                if tool_stat[start_time_key] is not None and tool_stat[start_time_key] != 0:
                    # self.trace("_set_tool_statistics_time_diff: value before running: final_time_key: %s, start_time_key: %s" % (str(tool_stat[final_time_key]), str(tool_stat[start_time_key])))
                    tool_stat[final_time_key] = time.time() - tool_stat[start_time_key]
                    tool_stat[start_time_key] = 0
                    # self.trace("_set_tool_statistics_time_diff: value after running: final_time_key: %s, start_time_key: %s" % (str(tool_stat[final_time_key]), str(tool_stat[start_time_key])))
            else:
                self.debug("_set_tool_statistics_time_diff: Unknown tool: %s provided to record tool stats while final_time_key: %s and start_time_key: %s" % (tool_id, str(final_time_key), str(start_time_key)))
        except Exception as e:
            self.debug("Exception whilst tracking tool stats: %s" % str(e))
            self.debug("_set_tool_statistics_time_diff: Error while tool: %s provided to record tool stats while final_time_key: %s and start_time_key: %s" % (tool_id, str(final_time_key), str(start_time_key)))
        # self.trace("_set_tool_statistics_time_diff: Tool: %s provided to record tool stats while final_time_key: %s and start_time_key: %s" % (tool_id, str(final_time_key), str(start_time_key)))

### LOGGING AND STATISTICS FUNCTIONS GCODE FUNCTIONS

    cmd_KTCC_RESET_STATS_help = "Reset the KTCC statistics"
    def cmd_KTCC_RESET_STATS(self, gcmd):
        self._reset_statistics()
        self._dump_statistics(True)
        self._persist_swap_statistics()
        # self._persist_gate_statistics()

    cmd_KTCC_DUMP_STATS_help = "Dump the KTCC statistics"
    def cmd_KTCC_DUMP_STATS(self, gcmd):
        self._dump_statistics(True)

    cmd_KTCC_SET_LOG_LEVEL_help = "Set the log level for the KTCC"
    def cmd_KTCC_SET_LOG_LEVEL(self, gcmd):
        self.log_level = gcmd.get_int('LEVEL', self.log_level, minval=0, maxval=4)
        self.logfile_level = gcmd.get_int('LOGFILE', self.logfile_level, minval=0, maxval=4)
        self.log_visual = gcmd.get_int('VISUAL', self.log_visual, minval=0, maxval=2)
        self.log_statistics = gcmd.get_int('STATISTICS', self.log_statistics, minval=0, maxval=1)

    cmd_KTCC_LOG_ALWAYS_help = "Log allways MSG"
    def cmd_KTCC_LOG_ALWAYS(self, gcmd):
        msg = gcmd.get('MSG')
        self.always(msg)

    cmd_KTCC_LOG_INFO_help = "Log info MSG"
    def cmd_KTCC_LOG_INFO(self, gcmd):
        msg = gcmd.get('MSG')
        self.info(msg)

    cmd_KTCC_LOG_DEBUG_help = "Log debug MSG"
    def cmd_KTCC_LOG_DEBUG(self, gcmd):
        msg = gcmd.get('MSG')
        self.debug(msg)

    cmd_KTCC_LOG_TRACE_help = "Log trace MSG"
    def cmd_KTCC_LOG_TRACE(self, gcmd):
        msg = gcmd.get('MSG')
        self.trace(msg)

    # cmd_KTCC_STATUS_help = "Complete dump of current KTCC state and important configuration"
    # def cmd_KTCC_STATUS(self, gcmd):
    #     config = gcmd.get_int('SHOWCONFIG', 0, minval=0, maxval=1)
    #     msg = "KTCC with %d gates" % (len(self.selector_offsets))
    #     msg += " is %s" % ("DISABLED" if not self.is_enabled else "PAUSED/LOCKED" if self.is_paused else "OPERATIONAL")
    #     msg += " with the servo in a %s position" % ("UP" if self.servo_state == self.SERVO_UP_STATE else "DOWN" if self.servo_state == self.SERVO_DOWN_STATE else "unknown")
    #     msg += ", Encoder reads %.2fmm" % self._counter.get_distance()
    #     msg += "\nSelector is %shomed" % ("" if self.is_homed else "NOT ")
    #     msg += ". Tool %s is selected " % self._selected_tool_string()
    #     msg += " on gate %s" % self._selected_gate_string()
    #     msg += ". Toolhead position saved pending resume" if self.saved_toolhead_position else ""
    #     msg += "\nFilament position: %s" % self._state_to_human_string()
        
    #     if config:
    #         msg += "\n\nConfiguration:\nFilament homes"
    #         if self._must_home_to_extruder():
    #             if self.homing_method == self.EXTRUDER_COLLISION:
    #                 msg += " to EXTRUDER using COLLISION DETECTION (current %d%%)" % self.extruder_homing_current
    #             else:
    #                 msg += " to EXTRUDER using STALLGUARD"
    #             if self._has_toolhead_sensor():
    #                 msg += " and then"
    #         msg += " to TOOLHEAD SENSOR" if self._has_toolhead_sensor() else ""
    #         msg += " after a %.1fmm calibration reference length" % self._get_calibration_ref()
    #         if self.sync_load_length > 0 or self.sync_unload_length > 0:
    #             msg += "\nGear and Extruder steppers are synchronized during "
    #             load = False
    #             if self._has_toolhead_sensor() and self.sync_load_length > 0:
    #                 msg += "load (up to %.1fmm)" % (self.toolhead_homing_max)
    #                 load = True
    #             elif self.sync_load_length > 0:
    #                 msg += "load (%.1fmm)" % (self.sync_load_length)
    #                 load = True
    #             if self.sync_unload_length > 0:
    #                 msg += " and " if load else ""
    #                 msg += "unload (%.1fmm)" % (self.sync_unload_length)
    #         else:
    #             msg += "\nGear and Extruder steppers are not synchronized"
    #         msg += ". Tip forming current is %d%%" % self.extruder_form_tip_current
    #         msg += "\nSelector homing is %s - blocked gate detection and recovery %s possible" % (("sensorless", "may be") if self.sensorless_selector else ("microswitch", "is not"))
    #         msg += "\nClog detection is %s" % ("ENABLED" if self.enable_clog_detection else "DISABLED")
    #         msg += " and EndlessSpool is %s" % ("ENABLED" if self.enable_endless_spool else "DISABLED")
    #         p = self.persistence_level
    #         msg += ", %s state is persisted across restarts" % ("All" if p == 4 else "Gate status & TTG map & EndlessSpool groups" if p == 3 else "TTG map & EndlessSpool groups" if p == 2 else "EndlessSpool groups" if p == 1 else "No")
    #         msg += "\nLogging levels: Console %d(%s)" % (self.log_level, self._log_level_to_human_string(self.log_level))
    #         msg += ", Logfile %d(%s)" % (self.logfile_level, self._log_level_to_human_string(self.logfile_level))
    #         msg += ", Visual %d(%s)" % (self.log_visual, self._visual_log_level_to_human_string(self.log_visual))
    #         msg += ", Statistics %d(%s)" % (self.log_statistics, "ON" if self.log_statistics else "OFF")
    #     msg += "\n\nTool/gate mapping%s" % (" and EndlessSpool groups:" if self.enable_endless_spool else ":")
    #     msg += "\n%s" % self._tool_to_gate_map_to_human_string()
    #     msg += "\n\n%s" % self._swap_statistics_to_human_string()
    #     self._log_always(msg)

def load_config(config):
    return KtccLog(config)
