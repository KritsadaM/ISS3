import paramiko
import time
import os
import getpass
import re
import sys
from datetime import datetime

def strip_ansi_func(text):
    r"""
    Removes all ansi directives from the string.

    References:
        http://stackoverflow.com/questions/14693701/remove-ansi
        https://stackoverflow.com/questions/13506033/filtering-out-ansi-escape-sequences

    Examples:
        >>> line = '\t\u001b[0;35mBlabla\u001b[0m     \u001b[0;36m172.18.0.2\u001b[0m'
        >>> escaped_line = strip_ansi(line)
        >>> assert escaped_line == '\tBlabla     172.18.0.2'
    """
    ansi_escape3 = re.compile(r'(\x9B|\x1B\[)[0-?]*[ -/]*[@-~]', flags=re.IGNORECASE)
    text = ansi_escape3.sub('', text)
    return text 

class Client(object):
    def __init__(self, host, user, password, expectphrase=None, timeout=60, display=False):
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
        self.open()

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
        self.channel = self.client.invoke_shell(width=120, height=48)
        time.sleep(.1)
        self.expectphrase(self.expect if self.expect else f'{getpass.getuser()}')

    def send(self, command, expectphrase=None, timeout=30):
        _command = command.replace('\n', '\\n').replace('\r', '')
        while not self.channel.send_ready():
            time.sleep(.009)
        self.channel.send(command)
        self.expectphrase(expectphrase, timeout=timeout if timeout else self.timeout) if expectphrase else None

    def expectphrase(self, re_strings='', timeout=None, strip_ansi=True):
        self.channel.settimeout(timeout if timeout else self.timeout)
        if isinstance(re_strings, str) and len(re_strings) != 0:
            re_strings = [re_strings]
        current_output = ''
        time.sleep(.1)
        while (len(re_strings) == 0 or not [re_string for re_string in re_strings if re_string in current_output or re.search(re_string,current_output, re.DOTALL)]):
            buffer = self.channel.recv(2048)
            if len(buffer) == 0:
                break
            buffer_decoded = buffer.decode('ISO-8859-1')
            buffer_decoded = buffer_decoded.replace('\r', '')
            if self.display:
                sys.stdout.write(buffer_decoded)
                sys.stdout.flush()

            if strip_ansi:
                buffer_decoded = strip_ansi_func(buffer_decoded)
            print(buffer_decoded, end= "")
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

def main():
    # with Client(host='localhost',user='miniphoton',password='Oboadmin') as c:
    #     c.send('ifconfig\r', expectphrase='\$')
    c = Client(host='localhost',user='miniphoton',password='Oboadmin')
    # c.open()
    c.send('ifconfig\r', expectphrase='\$')
    c.send('df\r', expectphrase='\$')
    # c.send('dmesg\r', expectphrase='\$')

if __name__ == '__main__':
    main()