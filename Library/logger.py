import os
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn


def message(msg):
    raw_path = BuiltIn().get_variable_value("${Raw_logs_path}")
    test_name = BuiltIn().get_variable_value("${TEST NAME}")
    os.makedirs(f'{raw_path}') if not os.path.isdir(f'{raw_path}') else None
    for i in [test_name, 'sequences_logs']:
        with open(f'{raw_path}/{i}.txt', 'a+', encoding="utf-8") as f:
            f.write(f'{msg}\r')


def timestamp_log(msg):
    raw_path = BuiltIn().get_variable_value("${Raw_logs_path}")
    test_name = BuiltIn().get_variable_value("${TEST NAME}")
    test_mode = BuiltIn().get_variable_value('${test_mode}')
    os.makedirs(f'{raw_path}') if not os.path.isdir(f'{raw_path}') else None
    for i in [test_name, 'sequences_logs']:
        with open(f'{raw_path}/{i}.txt', 'a+', encoding="utf-8") as f:
            if i == 'sequences_logs':
                f.write(f'[{datetime.utcnow().isoformat()[:-3]}]|{test_mode}|{test_name}|: {msg}\r')
            else:
                f.write(f'[{datetime.utcnow().isoformat()[:-3]}]: {msg}\r')


def info(msg):
    timestamp_log(msg=f'{"INFO":<8}: {msg}')


def debug(msg):
    timestamp_log(msg=f'{"DEBUG":<8}: {msg}')


def warning(msg):
    timestamp_log(msg=f'{"WARNING":<8}: {msg}')


def error(msg):
    timestamp_log(msg=f'{"ERROR":<8}: {msg}')
