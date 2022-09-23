import re
import time
import sys
import getpass
import paramiko
import logging
from libs import utils

logging.getLogger("paramiko").setLevel(logging.WARNING)


class SSHClient(object):
    def __init__(self, host, user, password, expectphrase=None, timeout=60, display=True):
        self.host = host
        self.user = user
        self.password = password
        self.expect = expectphrase
        self.timeout = timeout
        self.display = display
        self.client = paramiko.SSHClient()
        self.channel = None
        self.last_match = ''
        self.recbuf = ''

    def __del__(self):
        self.close()

    def __enter__(self):
        return self

    def __exit__(self, type, value, traceback):
        self.close()

    def open(self):
        self.client.load_system_host_keys()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.client.connect(hostname=self.host, username=self.user, password=self.password, timeout=self.timeout)
        self.channel = self.client.invoke_shell(width=80, height=24)
        self.expectphrase(self.expect if self.expect else f'{getpass.getuser()}')

    def send(self, command, expectphrase=None, timeout=None):
        self.channel.send(command)
        self.expectphrase(expectphrase, timeout=timeout if timeout else self.timeout) if expectphrase else None

    def expectphrase(self, re_strings='', timeout=None, strip_ansi=True):
        self.channel.settimeout(timeout if timeout else self.timeout)
        if isinstance(re_strings, str) and len(re_strings) != 0:
            re_strings = [re_strings]

        current_output = ''
        time.sleep(1)
        while (len(re_strings) == 0 or not [re_string for re_string in re_strings
                                            if re_string in current_output or re.search(re_string,
                                                                                        current_output, re.DOTALL)]):
            buffer = self.channel.recv(2048)
            if len(buffer) == 0:
                break
            buffer_decoded = buffer.decode('ISO-8859-1')
            buffer_decoded = buffer_decoded.replace('\r', '')
            if self.display:
                sys.stdout.write(buffer_decoded)
                sys.stdout.flush()

            if strip_ansi:
                buffer_decoded = re.sub(r'\x1b\[([0-9,A-Z]{1,2}(;[0-9]{1,2})?(;[0-9]{3})?)?[m|K]?', '', buffer_decoded)
            utils.recode_logs(buffer_decoded)
            current_output += buffer_decoded

        found_pattern = ''
        if len(re_strings) != 0:
            found_pattern = [(re_index, re_string)
                             for re_index, re_string in enumerate(re_strings)
                             if re_string in current_output or re.search(re_string, current_output, re.DOTALL)]
        self.recbuf = current_output
        if len(re_strings) != 0 and len(found_pattern) != 0:
            self.recbuf = (re.sub(f'{found_pattern[0][1]}$', '', self.recbuf))
            self.last_match = found_pattern[0][1]
            return found_pattern[0][0]
        else:
            return -1

    def close(self):
        try:
            self.client.close()
        except:
            pass
