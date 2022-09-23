import sys
import os
from timeit import default_timer as timer
from datetime import datetime, timedelta
import logging

raw_path = '/tftpboot/Logs/sequence/'
os.makedirs(raw_path) if not os.path.isdir(raw_path) else None
logging.basicConfig(filename=f"/tftpboot/Logs/sequence/{datetime.now().strftime('%Y%m%d_%H%M%S')}.log",
                    format='%(asctime)s.%(msecs)03d: %(levelname)s: %(message)s',
                    datefmt='%Y-%m-%dT%H:%M:%S',
                    level=logging.DEBUG)

start = timer()


class SequenceDefinition(object):
    def __init__(self, name):
        self.name = name
        self.finalization = True

    def add_step(self, function, name, finalization=False, **kwargs):
        if finalization:
            self.finalization = True

        if self.finalization:
            logging.info(f' ---> Starting Step "{name}"')
            result = function(**kwargs) if kwargs else function()
            if 'PASS' == result:
                logging.info(f'<--- Sequence= {name}, Result= PASS Runtime: {timedelta(seconds=timer()-start)}')
            else:
                logging.warning(f'Sequence= {name}, Result= FAIL Runtime: {timedelta(seconds=timer()-start)}')
                self.finalization = False
