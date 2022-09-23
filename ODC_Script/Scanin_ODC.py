import sys
import json
import configparser
from ODCServer import ODCServer
import ssl
import urllib.request
import xml.etree.ElementTree as ET
import os
import re
import getpass
import logging
import platform
import uuid


def main():
    # try:
    #     input_data = json.loads(sys.argv[1])
    #     mode = 'Robot' if input_data['test_mode'] == 'Production' else 'Robot_Debug'
    try:
        input_data = json.loads(sys.argv[1])
        robot_path = input_data['robot_path']

        if platform.system() == "Linux":
            # linux
            main_path = "/opt/Robot_Debug/"
            if input_data["test_mode"] == "Production":
                main_path = "/opt/Robot/{}/".format(robot_path)
            bom_path = "{}ODC_Script/BOM/".format(main_path)
            temp_logs_path = "/tmp/"

        elif platform == "Darwin":
            # OS X
            main_path = "/opt/Robot_Debug/"
            if input_data["test_mode"] == "Production":
                main_path = "/opt/Robot/"
            bom_path = "{}ODC_Script/BOM/".format(main_path)
            temp_logs_path = "/tmp/"

        elif platform.system() == "Windows":
            # Windows...
            main_path = "C:\\Robot_Debug\\"
            if input_data["test_mode"] == "Production":
                main_path = "C:\\Robot\\"
            bom_path = "{}ODC_Script\\BOM\\".format(main_path)
            temp_logs_path = "C:\\"

        else:
            main_path = "/opt/Robot_Debug/"
            if input_data["test_mode"] == "Production":
                main_path = "/opt/Robot/{}/".format(robot_path)
            bom_path = "{}ODC_Script/BOM/".format(main_path)
            temp_logs_path = "/tmp/"

        logging.basicConfig(filename='{}myapp.log'.format(
            temp_logs_path), level=logging.DEBUG, format='%(asctime)s %(levelname)s %(name)s %(message)s')
        logger = logging.getLogger(__name__)

        logger.info("111 = {}".format(input_data['robot_path']))

        config = configparser.ConfigParser()
        config.read(main_path+'/ODC_Script/ODC_Config.cfg')
        section = config['DEFAULT']
        odc_status = False
        odc = None
        PN_REV_PATH = "/opt/Robot/Config"
        #Check ODC conecting

        response = {
                    "serial_number": input_data["serial_number"],
                    "part_number": "TDE",
                    "product_reversion": 'Develop',
                    "shop_order": "",
                    "product_id": "",
                    "product_name": "TDE",
                    "switch_type": "eBay",
                    "chamber": "FCT",
                    "status": "OK",
                    "error_message": "-"
        }
        
        return json.dumps(response)
        
    except Exception as err:
        print(str(err))
        response = {
            'serial_number': '',
            'part_number': '',
            'product_reversion': '',
            'shop_order': '',
            'product_id': '',
            'status': 'FAIL',
            'error_message': 'Error in ODC script test, Please inform developer for fix issue.'
        }
    return json.dumps(response)


if __name__ == '__main__':
    print(main())

