import time, os
import cv2
import numpy as np
import math
import requests
from requests.exceptions import InvalidURL, HTTPError, RequestException, ConnectionError
import cvTools

class CVToolDebug:
    def __init__(self):
        self.cv_tools = cvTools.CVTools()
        self.camera_address = "http://192.168.1.204/webcam2/stream"
        self.streamer = MjpegStreamReader(self.camera_address)
        return

    def _find_nozzle_positions(self):
        image = self.streamer.get_single_frame()
        if image is None:
            return None
        returnimg_img, key =self.cv_tools.detect_nozzles(image)
        return

    def get_single_frame(self):
        if self.session is None: 
            # TODO: Raise error: stream is not running
            return None

        with self.session.get(self.camera_address, stream=True) as stream:
            if stream.ok:
                chunk_size = 1024
                bytes_ = b''
                for chunk in stream.iter_content(chunk_size=chunk_size):
                    bytes_ += chunk
                    a = bytes_.find(b'\xff\xd8')
                    b = bytes_.find(b'\xff\xd9')
                    if a != -1 and b != -1:
                        jpg = bytes_[a:b+2]
                        return cv2.imdecode(np.frombuffer(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)

        return None

class MjpegStreamReader:
    def __init__(self, camera_address):
        self.camera_address = camera_address
        self.session = requests.Session()

    def can_read_stream(self, printer):
        # TODO: Clean this up and return actual errors instead of this...stuff...
        try:
            with self.session.get(self.camera_address) as _:
                return True
        except InvalidURL as _:
            raise printer.config_error("Could not read nozzle camera address, got InvalidURL error %s" % (self.camera_address))
        except ConnectionError as _:
            raise printer.config_error("Failed to establish connection with nozzle camera %s" % (self.camera_address))
        except Exception as e:
            raise printer.config_error("Nozzle camera request failed %s" % str(e))

    def open_stream(self):
        # TODO: Raise error, stream already running 
        self.session = requests.Session()

    def get_single_frame(self):
        if self.session is None: 
            # TODO: Raise error: stream is not running
            return None

        with self.session.get(self.camera_address, stream=True) as stream:
            if stream.ok:
                chunk_size = 1024
                bytes_ = b''
                for chunk in stream.iter_content(chunk_size=chunk_size):
                    bytes_ += chunk
                    a = bytes_.find(b'\xff\xd8')
                    b = bytes_.find(b'\xff\xd9')
                    if a != -1 and b != -1:
                        jpg = bytes_[a:b+2]
                        return cv2.imdecode(np.frombuffer(jpg, dtype=np.uint8), cv2.IMREAD_COLOR)

        return None

    def close_stream(self):
        if self.session is not None:
            self.session.close()
            self.session = None

q = CVToolDebug()
q._find_nozzle_positions()