#!/usr/bin/env python

# ---------------------------------------------------------------
#
# Program name:        ReSerial.py                              #
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


import serial
import time
from Serial import Serial
import re


class ReSerial(Serial):
    """This class for interface to the UUt with serial port"""

    def __init__(self, serialport, baudrate):
        super(ReSerial, self).__init__(serialport, baudrate,
                                       bytesize=serial.EIGHTBITS,
                                       parity=serial.PARITY_NONE,
                                       stopbits=serial.STOPBITS_ONE)

        """Initial the class object.

        Args:
          serialport: The serial port for serial interface.
          baudrate: The speed of serial port.

        Returns:
          None.

        Raise:
          None.

        """

    def open(self, max_retry=5):

        """Open port of serial interface.

        Args:
          max_retry: The max retry value.

        Returns:
          True: The status is passes.
          False: The status is failed.

        Raise:
          None.

        """

        for retry in range(0, max_retry):
            try:
                response = super(ReSerial, self).open()
                if response:
                    return response
            except Exception as ex:
                if retry == (max_retry - 1):
                    print('Unable to \
                    reconnect properly to the serial session')
                    raise
                else:
                    print('An error \
                    occurred [{0}] while connecting from serial \
                    session. Reconnecting {1}'.format(ex, retry))
                    time.sleep(2)

        return False

    def close(self):
        super(ReSerial, self).close()

    def write(self, command, max_retry=5, no_lf=False):
        for retry in range(0, max_retry):
            try:
                super(ReSerial, self).write(command, no_lf)
                return  True
            except Exception as ex:
                if retry == (max_retry - 1):
                    print('Unable to reconnect \
                    properly to the serial session')
                    raise
                else:
                    print('An error occurred [{0}] \
                    while writing from serial session. \
                    Reconnecting {1}'.format(ex, retry))
                    time.sleep(2)

        return False

    def send_expect_cmd(self, command, expect, time_out=20, max_retry=1):
        response = ""
        for retry in range(0, max_retry):
            try:
                found, response = super(ReSerial, self).send_expect_cmd(
                    command, expect, time_out)
                    
                if found or retry == (max_retry - 1):
                    return found, response

                super(ReSerial, self).write("\x03\n", no_lf=True)
                time.sleep(1)
                super(ReSerial, self).write("\x03\n", no_lf=True)

            except Exception as ex:
                if retry == (max_retry - 1):
                    print('Unable to reconnect \
                    properly to the serial session')
                    raise
                else:
                    print('An error occurred [{0}] \
                    while query from serial session. \
                    Reconnecting {1}'.format(ex, retry))
                    time.sleep(2)

        return False, "{}{}".format(response, '\nUnable to reconnect \
                    properly to the serial session')
