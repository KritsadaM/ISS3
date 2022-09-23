import os
from libs import lib
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn


def recode_logs(data):
    raw_path = BuiltIn().get_variable_value("${Raw_logs_path}")
    test_name = BuiltIn().get_variable_value("${TEST NAME}")
    os.makedirs(raw_path) if not os.path.isdir(raw_path) else None
    if test_name:
        with open(f'{raw_path}/{test_name}.txt', 'a+', encoding="ISO-8859-1") as f:
            f.write(data)
        with open(f'{raw_path}/buffer.txt', 'a+', encoding="ISO-8859-1") as f:
            f.write(data)


def final_test_case():
    raw_path = BuiltIn().get_variable_value("${Raw_logs_path}")
    test_name = BuiltIn().get_variable_value("${TEST NAME}")
    if test_name:
        with open(f'{raw_path}/{test_name}.txt', 'a+', encoding="ISO-8859-1") as f:
            f.write(f'\n{"*"*100}\n'
                    f'STEP TEST NAME : {test_name}\n'
                    f'END TIME : {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n'
                    f'{"*"*100}\n')


class APDicts:
    userdict = dict()
