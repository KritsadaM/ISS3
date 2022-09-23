import configparser
import getpass
import json
import logging
import os
import platform
import sys
import re
# sys.path.insert(1, 'BOM')
# import input_data['serial_number']
# from ODCServer import ODCServer
from XMLCreator import XMLCreator


def main():
    input_data = json.loads(sys.argv[1])
    robot_path = input_data['robot_path']

    if platform.system() == "Linux":
        # linux
        main_path = "/opt/Robot_Debug/"
        if input_data["test_mode"] == "Production":
            main_path = "/opt/Robot/{}/".format(robot_path)
        bom_path = "{}ODC_Script/BOM/".format(main_path)
        log_path = "{}Logs/".format(main_path)
        temp_logs_path = "/tmp/"
    elif platform == "Darwin":
        # OS X
        main_path = "/opt/Robot_Debug/"
        if input_data["test_mode"] == "Production":
            main_path = "/opt/Robot/"
        bom_path = "{}ODC_Script/BOM/".format(main_path)
        log_path = "{}Logs/".format(main_path)
        temp_logs_path = "/tmp/"
    elif platform.system() == "Windows":
        # Windows...
        main_path = "C:\\Robot_Debug\\"
        if input_data["test_mode"] == "Production":
            main_path = "C:\\Robot\\"
        bom_path = "{}ODC_Script\\BOM\\".format(main_path)
        log_path = "{}Logs\\".format(main_path)
        temp_logs_path = "C:\\"
    else:
        main_path = "/opt/Robot_Debug/"
        if input_data["test_mode"] == "Production":
            main_path = "/opt/Robot/{}/".format(robot_path)
        bom_path = "{}ODC_Script/BOM/".format(main_path)
        log_path = "{}Logs/".format(main_path)
        temp_logs_path = "/tmp/"
    # input_data = json.loads(sys.argv[1])

    # if platform.system() == "Linux":
    #     # linux
    #     main_path = "/opt/Robot_Debug/"
    #     if input_data["test_mode"] == "Production":
    #         main_path = "/opt/Robot/"
    #     bom_path = "{}ODC_Script/BOM/".format(main_path)
    #     log_path = "{}Logs/".format(main_path)
    #     temp_logs_path = "/tmp/"
    # elif platform == "Darwin":
    #     # OS X
    #     main_path = "/opt/Robot_Debug/"
    #     if input_data["test_mode"] == "Production":
    #         main_path = "/opt/Robot/"
    #     bom_path = "{}ODC_Script/BOM/".format(main_path)
    #     log_path = "{}Logs/".format(main_path)
    #     temp_logs_path = "/tmp/"
    # elif platform.system() == "Windows":
    #     # Windows...
    #     main_path = "C:\\Robot_Debug\\"
    #     if input_data["test_mode"] == "Production":
    #         main_path = "C:\\Robot\\"
    #     bom_path = "{}ODC_Script\\BOM\\".format(main_path)
    #     log_path = "{}Logs\\".format(main_path)
    #     temp_logs_path = "C:\\"
    # else:
    #     main_path = "/opt/Robot_Debug/"
    #     if input_data["test_mode"] == "Production":
    #         main_path = "/opt/Robot/"
    #     bom_path = "{}ODC_Script/BOM/".format(main_path)
    #     log_path = "{}Logs/".format(main_path)
    #     temp_logs_path = "/tmp/"

    logging.basicConfig(filename='{}myapp.log'.format(temp_logs_path),
                        level=logging.DEBUG,
                        format='%(asctime)s %(levelname)s %(name)s %(message)s')
    logger = logging.getLogger(__name__)

    config = configparser.ConfigParser()
    section = config['DEFAULT']
    config.read(main_path+'/ODC_Script/ODC_Config.cfg')

    # Check ODC connecting
    # for i in range(0, 3):
    #     odc = ODCServer(section['Primary_ODC_IP'],
    #                     section['Business_Unit'])
    #     odc.connect()
    #     # True = ODC Online / False = ODC Down
    #     odc_status = odc.check_connection(profile=section['Bom_Profile'])
    #     if odc_status:
    #         break
    # ticket = odc.get_ticket(input_data["serial_number"]).decode("utf-8")
    # current_station = odc.get_current_station(
    #     input_data["serial_number"]).decode("utf-8")
    # logging.debug(current_station + "==" + input_data["logop"] + "\n")
    # if current_station != input_data["logop"]:
    #     break
    # username = getpass.getuser()
    # Create XML data
    # if input_data["test_mode"] == "Production":
    # file_name = open("{}{}.txt".format(bom_path, input_data["serial_number"]))
    # Value = file_name.readlines()
    # xml_data = XMLCreator()
    # xml_data.add_node('ticket', Value[0])
    # xml_data.add_node('sn', Value[1])
    # xml_data.add_node('station', current_station)
    # xml_data.add_node('testername', username)
    # xml_data.add_node('user', input_data['operation_id'])
    # xml_data.add_node('result', input_data['result'])
    # xml_data.add_node('description', '-')
    # xml_data.add_node('result', input_data['FAN1'])
    # xml_data.add_node('result', input_data['FAN2'])
    # xml_data.add_node('result', input_data['FAN3'])
    # xml_data.add_node('result', input_data['FAN4'])
    # xml_data.add_node('result', input_data['FAN5'])
    # xml_data.set_parameter()
    # if input_data['result'] == 'F':
    #     # test station name
    #     xml_data.add_par_node(input_data['test_station'])

    #     symptom_fail = ""
    #     symptom_msg = ""

    #     if input_data['test_station'].upper() in "SFT,BI,FST":

    #         if len(input_data['test_fail']) == 0:
        
    #             symptom_fail = "0.{}_{}".format(input_data['test_station'].upper(),
    #                                         "Loop_XX")

    #             if len(input_data['message_fail']) == 0:
    #                 symptom_msg = "Cannot get fail message or User aborted."
    #             else:
    #                 symptom_msg = input_data['message_fail']

    #         else:
    #             symptom_fail = input_data['test_fail']

    #             if len(input_data['message_fail']) == 0:
    #                 symptom_msg = "Cannot get fail message or User aborted."
    #             else:
    #                 symptom_msg = input_data['message_fail']

    #         fail_msg = symptom_msg.split("::")
    #         if len(fail_msg) > 1:
    #             failed_code = "{}_{}".format(
    #                             re.search("[0-9.]+(\S+)", 
    #                             symptom_fail.replace("_Step_Test","")).group(1), 
    #                             fail_msg[0].strip())
    #             xml_data.set_failure_code(re.sub('[^A-Za-z0-9_\/\\\\.\{\}\[\]\(\);:]+',
    #                                                 '_', failed_code)[:50])
    #         else:
    #             failed_code = "{}_{}_Step_Test".format(
    #                             re.search("[0-9.]+(\S+)", 
    #                             symptom_fail.replace("_Step_Test","")).group(1), 
    #                             input_data['test_station'].upper())
    #             xml_data.set_failure_code(re.sub('[^A-Za-z0-9_\/\\\\.\{\}\[\]\(\);:]+',
    #                                                 '_', failed_code)[:50])
    #     else:
    #         if len(input_data['test_fail']) == 0:
            
    #             symptom_fail = "{}_{}".format(input_data['test_station'].upper(),
    #                                         "TEST_STEP")

    #             if len(input_data['message_fail']) == 0:
    #                 symptom_msg = "Cannot get fail message or User aborted."
    #             else:
    #                 symptom_msg = input_data['message_fail']

    #         else:
    #             symptom_fail = input_data['test_fail']

    #             if len(input_data['message_fail']) == 0:
    #                 symptom_msg = "Cannot get fail message or User aborted."
    #             else:
    #                 symptom_msg = input_data['message_fail']

    #         xml_data.set_failure_code(re.sub('[^A-Za-z0-9_\/\\\\.\{\}\[\]\(\);:]+',
    #                                                 '_', symptom_fail)[:50])

    #     # message fail
    #     fail_msg_data = symptom_msg.split(' :: ')
    #     if len(fail_msg_data) == 1:
    #         xml_data.set_failure_data(fail_msg_data[0].strip())
    #     else:
    #         xml_data.set_failure_data(fail_msg_data[1].strip())

    # if os.path.exists("{}{}/{}.xml".format(log_path, input_data["uut_log_dir"], 
    #                                         input_data["serial_number"])):
    #     os.remove("{}{}/{}.xml".format(log_path,
    #                                    input_data["uut_log_dir"], 
    #                                    input_data["serial_number"]))
    # with open("{}{}/{}.xml".format(log_path, input_data["uut_log_dir"], 
    #                                 input_data["serial_number"]),
    #                                 "a+") as save_data:
    #     save_data.write('{} '.format(
    #         xml_data.print_xml_data().decode("utf-8")))

    # if input_data["test_mode"] == "Production" and input_data["test_abort"] != "ABORT":
    #     if odc.put_data("POST", "/des/" + section['Business_Unit'] + "/result.asp", 
    #                     xml_data.print_xml_data().decode("utf-8"), "text/xml"):
    #         if odc.process_data(ticket):
    #             logging.debug(
    #                 "Send data to ODC successful with ticket no. " + ticket + "\n")
    #         else:
    #             logging.warn("Send data to ODC not successful : " +
    #                          xml_data.print_xml_data().decode("utf-8") + "\n")
    #             response = {
    #                 "status": "Fail",
    #                 "error_message": "Send data to ODC not successful"
    #             }
    #             return json.dumps(response)
    #     else:
    #         logging.warn(
    #             "Post XML of {} to ODC not successful\n".format(ticket))
    #         response = {
    #             "status": "Fail",
    #             "error_message": "Post XML of {} to ODC not successful\n".format(ticket)
    #         }
    #         return json.dumps(response)
    # if "R3250F" in input_data["serial_number"]:
    #     logger.debug(input_data)
    #     os.rename('{}{}.py'.format(bom_path, input_data["serial_number"]), 
    #             '{}{}/{}_ODC_data.txt'.format(log_path, input_data["uut_log_dir"], 
    #             input_data["serial_number"]))
    # if "R3240" in input_data["serial_number"]:
    logger.debug(input_data)
    # os.rename('{}{}.py'.format(bom_path, input_data["serial_number"]), 
    #         '{}{}/{}_ODC_data.txt'.format(log_path, input_data["uut_log_dir"], 
    #         input_data["serial_number"]))
    # logger.debug(input_data)
    # os.rename('{}{}.py'.format(bom_path, input_data["serial_number"]), 
    #           '{}{}/{}_ODC_data.txt'.format(log_path, input_data["uut_log_dir"], 
    #           input_data["serial_number"]))
    response = {
        "status": "OK",
        "product_name": "FengHuangV2",
        "model": "CS8210-32X-DC-11",   
        "error_message": "Return value from ODC"
    }
    # if os.path.isfile('{}{}.py'.format(bom_path, input_data["serial_number"])):
    # os.remove("{}{}.txt".format(bom_path, input_data["serial_number"]))
    return json.dumps(response)


if __name__ == '__main__':
    print(main())
