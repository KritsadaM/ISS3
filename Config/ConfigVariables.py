from configparser import ConfigParser


def get_variables(name, file):
    config = ConfigParser()
    config.read(file)
    variables = {}
    for section in config.sections():
        variables.update({f'{name}.{section}.{key}': value for key, value in config.items(section)})
    return variables
