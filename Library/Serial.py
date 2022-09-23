#!/usr/bin/env python

# ---------------------------------------------------------------
#
# Program name:        Serial.py                                #
# Program version:     1.0                                      #
# Author:              Khanchit   Srimanta                      #
# Purpose:             F5-W400                                  #
# ---------------------------------------------------------------
# History:  Feb 1,  2019    - Initial release - Khanchit        #
#                                                               #
# ---------------------------------------------------------------

"""This is the Serial library for calling with Robot Framework.

Calling class and function in the Serial library with Robot Framework.
"""

import time
import serial
import re
import io


class Serial(object):
    """Serial interface base class."""
    
    @property
    def session(self):
        return self._session
    
    def __init__(self, serialport, baudrate,
                 bytesize=serial.EIGHTBITS,
                 parity=serial.PARITY_NONE,
                 stopbits=serial.STOPBITS_ONE):
        """Initializes a serial interface"""
        self.linebreak = "\n"
        self._session = serial.Serial()
        self._session.port = serialport
        self._session.baudrate = baudrate
        self._session.bytesize = bytesize
        self._session.parity = parity
        self._session.stopbits = stopbits
        self._session.timeout = 1

    def open(self):
        """Opens the serial connection."""
        # Check connection status
        if self._session.isOpen():
            self.close()
        # Connect to port
        try:
            self._session.open()
        except Exception as e:
            raise Exception(e)

        return self._session.isOpen()
        
    def close(self):
        """Close the serial connection."""
        if self._session.isOpen():
            self._session.close()

    def write(self, command, no_lf=False):
        """Send a command while not waiting for a reply"""
        # if command == '\r\n':
        #     message = self.linebreak
        # else:
        #     message = command + self.linebreak
        if no_lf:
            message = command
        else:
            message = '{}{}'.format(command, self.linebreak)

        #self._session.write(bytes(message.encode("utf-8")))
        self._session.write(message.encode())

    def read(self):
        """Read from instrument"""
        return self._session.readline().rstrip()

    def send_expect_cmd(self, command, expect, timeout=10):
        """send command and query data until expect keyword."""
        response = ''
        found = False
        start_time = time.time()
        # Clear input buffer.
        self._session.reset_input_buffer()
        self._session.reset_output_buffer()
        self._session.flush()
        self._session.reset_input_buffer()
        self._session.reset_output_buffer()
        self._session.flush()
        # Send command.
        self.write(command)
        # Sleep time 1 sec.
        time.sleep(1)
        # Keep all data
        while True:
            try:
                res_by_line = self._session.readline().decode('ISO-8859-1')
            except UnicodeEncodeError: 
                res_by_line = ''
            #res_by_line = self._session.readline().decode('utf-8')

            response += res_by_line
            if re.search("CTRL\-l \+ b \: Send Break", res_by_line):
                self.write("\n")
            if re.search("Use\s+ctrl-x\s+to\s+quit\.", res_by_line):
                time.sleep(2)
                self.write("\n")
            if re.search("link\s+becomes\s+ready", res_by_line):
                self.write("\n")
            if re.search(expect, response):
                found = True
                break
            if time.time() - start_time > timeout:
                response = "{}{}".format(response, 
                '\nDetect_prompt : Time out for detect prompt type!!!')
                break

        return found, response
