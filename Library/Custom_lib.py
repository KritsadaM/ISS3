import base64
import uuid
import paramiko
import time
import os
import getpass
import re
import sys
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
import logger as log

# paramiki_log_path = "{}/paramiko.log".format(BuiltIn().get_variable_value("${Raw_logs_path}"))
# paramiko.util.log_to_file("{paramiki_log_path}", level="WARN")

def ssh_open(hostname=None,username=None, password=None):
    global client
    log.message('-' * 109)
    log.message(f'Start SSH to => {hostname} <='.center(109, "_"))
    log.message(f"{'-'*109}\n")
    client = Client(host=hostname,user=username,password=password)

def ssh_cmd(command=None, prompt=None, timeout=30, expect=None, unexpect=None , retry=1):
    log.info(f"Sending command : {command}")
    client.send(f'{command}\r', prompt=prompt, timeout=timeout, expect=expect, unexpect=unexpect, retry=retry)

def ssh_close():
    log.message(f"\n\n{'-' * 109}")
    log.message(f'Closed SSH'.center(109, "_"))
    log.message('-' * 109)
    client.close()

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

def initial_test_case():
    log.message('-' * 109)
    log.message(f'SERIAL NUMBER  :  {BuiltIn().get_variable_value("${serial_number}")}')
    log.message(f'STEP TEST NAME  : {BuiltIn().get_variable_value("${TEST NAME}")}')
    log.message(f'START TIME  :     {datetime.now().isoformat(" ")[:-3]}')
    log.message(f"{'-'*109}\n")

def finalize_test_case():
    log.message(f"\n\n{'-' * 109}")
    log.message(f'SERIAL NUMBER  :  {BuiltIn().get_variable_value("${serial_number}")}')
    log.message(f'STEP TEST NAME  : {BuiltIn().get_variable_value("${TEST NAME}")}')
    log.message(f'START TIME  :     {datetime.now().isoformat(" ")[:-3]}')
    log.message('-'*109)

def write_to_file(path, msg):
    os.makedirs(f'{path}') if not os.path.isdir(f'{path}') else None
    for i in [BuiltIn().get_variable_value("${TEST NAME}"), 'buffer_logs']:
        with open(f'{path}/{i}.raw', 'a+', encoding="utf-8") as f:
            f.write(msg)


def save_log(msg):
        write_to_file(BuiltIn().get_variable_value('${Raw_logs_path}'), msg)

class Client(object):
    def __init__(self, host, user, password, prompt=None, timeout=60, display=False):
        self.host = host
        self.user = user
        self.password = password
        self.expect = prompt
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
        self.prompt(self.expect if self.expect else f'{getpass.getuser()}')

    def send(self, command, prompt=None, timeout=30, expect=None, unexpect=None, retry=1):
        expect = [x.strip() for x in expect.split(',')] if "," in expect else expect
        unexpect = [x.strip() for x in unexpect.split(',')] if "," in unexpect else unexpect
        for i in range(1, retry+1):
            status = []
            _command = command.replace('\n', '\\n').replace('\r', '')
            timeout = int(timeout)
            while not self.channel.send_ready():
                time.sleep(.009)
            self.channel.send(command)
            self.prompt(prompt, timeout=timeout if timeout else self.timeout) if prompt else None
            if expect != None:
                status.append(self.check_expect(expect))
            if unexpect != None:
                status.append(self.check_unexpect(unexpect))
            if all(status):
                    return True
            if i != retry:
                log.warning(f"Could not get pass criteria with '{_command}'")
                log.warning(f"Try sending the command '{_command}' for the {i} time.")
        fail()
        

    def prompt(self, re_strings='', timeout=None, strip_ansi=True):
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
            save_log(buffer_decoded)
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
    
    def check_expect(self, expect):
        results = []
        for i in expect if isinstance(expect, list) else [expect]:
            for key in re.findall(r'[^.]?\$\{(.+?)\}', i):
                i = i.replace(f'${{{key}}}', str(userdict[key]))
            s = i if i in self.recbuf else None
            if not s:
                s = re.search(i, self.recbuf)
                s = s.group(0) if s else ''
            log.info('-' * 50)
            log.info(f"\tCheck Received String:")
            log.info(f"\tExpect: '{i}'")
            log.info(f"\tActual: '{s}'")
            log.info(f"\t---> {'PASS' if s else 'FAIL'}")
            results.append(bool(s))
        return all(results)
    
    def check_unexpect(self, unexpect):
        results = []
        for i in unexpect if isinstance(unexpect, list) else [unexpect]:
            for key in re.findall(r'[^.]?\$\{(.+?)\}', i):
                i = i.replace(f'${{{key}}}', str(userdict[key]))
            s = i if i in self.recbuf else None
            if not s:
                s = re.search(i, self.recbuf)
                s = s.group(0) if s else ''
            log.info('-' * 50)
            log.info(f"\tCheck Unexpected String:")
            log.info(f"\tExpect: '{i}'")
            log.info(f"\tActual: '{s}'")
            log.info(f"\t---> {'FAIL' if s else 'PASS'}")
            results.append(not bool(s))
        return all(results)

def fail(msg=None):
    msg = msg if msg else f"{BuiltIn().get_variable_value('${TEST NAME}')}: FAILED"
    log.error(msg)
    try: 
        ssh_close()
    except:
        log.error("Could not close SSH session")
    BuiltIn().fail(msg=msg)

