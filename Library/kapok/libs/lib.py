import sys
from libs import conn
from libs import utils
from libs import sequence_definitions

from robot.libraries.BuiltIn import BuiltIn

apdicts = utils.APDicts()


class PASS:
    def __init__(self): BuiltIn().log(message='PASS')


class FAIL:
    def __init__(self): BuiltIn().fail(msg='FAIL')


def getconnections():
    return conn.connection_protocol()


# def add_this_arg(func):
#     def wrapped(*args, **kwargs):
#         return func(wrapped, *args, **kwargs)
#     return wrapped
#
#
# def add_tst_data(**kwargs):
#     test_info(**kwargs)
#
#
# @add_this_arg
# def test_info(this, serial_number, container):
#     this.serial_number = serial_number
#     this.container = container
