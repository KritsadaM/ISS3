import getpass
from libs.ssh import SSHClient


def connection_protocol():
    status = dict({'UUT': SSHClient(host='127.0.0.1',
                                    user='kapok-tech',
                                    password='changeme',
                                    expectphrase='kapok-tech'),
                   'WTI': SSHClient(host='127.0.0.1',
                                    user='kapok-tech',
                                    password='changeme',
                                    expectphrase='kapok-tech')})
    return status
