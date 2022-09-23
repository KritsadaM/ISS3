#!/usr/bin/env python

# ---------------------------------------------------------------
#
# Program name:        Common_Func.py                                #
# Program version:     1.0                                      #
# Author:              Khanchit   Srimanta                      #
# Purpose:             F5-W400                                  #
# ---------------------------------------------------------------
# History:  Feb 1,  2019    - Initial release - Khanchit        #
#                                                               #
# ---------------------------------------------------------------

"""This is the All the Common function for calling with Robot Framework.

Calling class and function in the Common_Func library with Robot Framework.
"""

import re
import datetime
import uuid


class Common_Func(object):
    """All the Common function for calling with Robot Framework."""


    def __init__(self):
        pass

    def uuid_get(self):

        """Verify keyword in the text with regular expression.

        Args:
          text: The text for matching.
          pattern: The regular expression pattern for matching text.

        Returns:
          True: Can matching text.
          False: Cannot matching text.

        Raise:
          None.

        """
        uuidOne = uuid.uuid1()

        return uuidOne,

    def set_mtd(self, bcm_ver_uut):

        """Check the BMC Version and set mtd value.

        Args:
          bcm_ver_uut: the BMC Version in the UUT.

        Returns:
          mtd4: if the BMC version >= 100.
          mtd5: if the BMC version < 100.

        Raise:
          None.

        """

        if int(bcm_ver_uut) >= 100:
            return "mtd4"
        else:
            return "mtd5"


    def verify_keyword_regexp(self, text, pattern):

        """Verify keyword in the text with regular expression.

        Args:
          text: The text for matching.
          pattern: The regular expression pattern for matching text.

        Returns:
          True: Can matching text.
          False: Cannot matching text.

        Raise:
          None.

        """

        if re.search('{}'.format(pattern), text):
            return True
        else:
            return False


    def verify_multi_keyword_regexp(self, text, pattern_list):

        """Verify keyword in the text with regular expression.

        Args:
          text: The text for matching.
          pattern_list: The regular expression pattern list for matching text.

        Returns:
          True: Can matching text.
          msg: The pass or fail message.
          False: Cannot matching text.

        Raise:
          None.

        """
        fail_data = ""
        count_error = 0
        for pattern in pattern_list.split("||"):
            if not re.search('{}'.format(pattern.strip()), text):
                count_error += 1
                fail_msg = 'Cannot expect keyword: "{}".'.format(pattern.strip())
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

        if count_error:
            return False, fail_data
        else:
            return True, "Verify all keyword in all data is complete."


    def verify_qsfp_keyword_regexp(self, text, pattern):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            pattern: The regular expression pattern for matching text.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(1, 49):
            if not re.search('{}{}'.format(num, pattern), text):
                count_error += 1
                fail_msg = 'The qsfp port {} not present.'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

        if count_error:
            return False, fail_data
        else:
            return True, "Verify the qsfp all port ready present."


    def check_rct_datetime(self, text_uut_time, pc_time):

        """Verify rct datetime with current datime.

        Args:
            pc_time: The current datetime in pc tester.
            text_uut_time: The current datetime in uut.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        uut_str_time = re.search('Current\s+Date\s+info\s+:\s+'
                                 '(\d+-\d+-\d+\s+\d+:\d+:\d+)', text_uut_time)

        if uut_str_time is None:
            return False, 'Cannot expect keyword: "Current Date info :"'

        pc_date_time = datetime.datetime.strptime(pc_time,
                                                '%Y-%m-%d %H:%M:%S')
        uut_date_time = datetime.datetime.strptime(uut_str_time.group(1),
                                                '%Y-%m-%d %H:%M:%S')

        time_diff = pc_date_time - uut_date_time

        if re.search("day", str(time_diff)):
            return False, "The rtc datetime ({}) mismatch the " \
                          "current datetime on PC ({}).".format(uut_date_time, 
                                                                pc_date_time)

        if not re.search("0:00:0", str(time_diff)):
            return False, "The rtc datetime ({}) mismatch the " \
                          "current datetime on PC ({}).".format(uut_date_time, 
                                                                pc_date_time)

        time_diff_num = int(str(time_diff).split(":")[2].strip())

        if time_diff_num >= 10:
            return False, "The rtc datetime ({}) mismatch the " \
                          "current datetime on PC ({}).".format(uut_date_time, 
                                                                pc_date_time)
        
        return True, "Verify the rtc datetime is complete."


    def verify_temp_monitor(self, text, current_temp_range, peak_temp_range):

        """Verify the temperature monitor.

        Args:
          text: The text for matching.
          current_temp_range: The current temperature range.
          peak_temp_range: The current temperature range.

        Returns:
          True: Can matching text.
          False: Cannot matching text.

        Raise:
          None.

        """
        fail_data = ""
        count_error = 0
        for num in range(0, 15):

            temp_uut = re.search("temperature\s+monitor\s+{}\:\s+current\=\s+"
                                 "(\S+)\,\s+peak\=\s+(\S+)".format(num), text)

            if temp_uut is None:
                count_error += 1
                fail_msg = 'Cannot expect temperature of temperature monitor {}.'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

            current_temp = float(temp_uut.group(1).strip())
            peak_temp = float(temp_uut.group(2).strip())

            low_current_range = float(current_temp_range.split("-")[0].strip())
            high_current_range = float(current_temp_range.split("-")[1].strip())

            low_peak_range = float(peak_temp_range.split("-")[0].strip())
            high_peak_range = float(peak_temp_range.split("-")[1].strip())

            if not low_current_range <= current_temp <= high_current_range:
                count_error += 1
                fail_msg = 'The temperature monitor {}: expect current temperature ' \
                           'range {} but got {}'.format(num, current_temp_range, current_temp)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

            if not low_peak_range <= peak_temp <= high_peak_range:
                count_error += 1
                fail_msg = 'The temperature monitor {}: expect peak temperature ' \
                           'range {} but got {}'.format(num, peak_temp_range, peak_temp)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)  

        if count_error:
            return False, fail_data
        else:
            return True, "Verify the all temperature monitor is complete."


    def verify_all_port_up_regexp(self, text, check_mode):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            check_mode: The mode for get data.
            
        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        start_text = ""
        end_text = ""
        expect = ""

        if check_mode == "port status check":
            start_text = "port\s+status\s+testing"
            end_text = "port\s+status\s+check\s+result"
            expect = "up"
        elif check_mode == "disable test":
            start_text = "disable\s+testing"
            end_text = "disable\s+test\s+result"
            expect = "!ena"
        elif check_mode == "enable test":
            start_text = "enable\s+testing"
            end_text = "enable\s+test\s+result"
            expect = "up"
        else:
            return False, "Check mode incorrect."

        port_data = self.get_section(start_text=start_text,
                                end_text=end_text, text=text)
        if port_data is None:
            count_error += 1
            fail_msg = 'Cannot get the section of {}'.format(check_mode)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

            return False, fail_data

        for num in range(0, 48):

            link_status = re.search('(cd{}\(.*\))\s+(\S+)\s+\S+\s+\S+'.format(num),
                                    port_data)
            if link_status is None:
                count_error += 1
                fail_msg = 'Cannot expect link status of port cd{}.'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

            if link_status.group(2).strip() != "{}".format(expect):
                count_error += 1
                fail_msg = 'The port {} link status not "{}" ' \
                        'but got "{}" !!!.'.format(
                    link_status.group(1).strip(), expect,
                    link_status.group(2).strip())
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

        if count_error:
            return False, fail_data
        else:
            return True, "Verify link status of all port is complete."


    def verify_all_port_package_regexp(self, text, pattern, min, max):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            pattern: The regular expression pattern for matching text.
            min: The min port for check.
            max: The max port for check.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(int(min), int(max) + 1):

            package_count = re.search('({}\.cd{})\s+\:\s+(.*)\s+\+(.*)'.format(pattern, num), text)
            if package_count is None:
                count_error += 1
                fail_msg = 'Cannot expect package count of port {}.cd{}'.format(pattern, num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

            if package_count.group(2).strip() != package_count.group(3).strip():
                count_error += 1
                fail_msg = 'The package count of port {} not equal '    \
                           'between ({}) and ({})!!!.'.format(package_count.group(1).strip(), 
                                                              package_count.group(2).strip(), 
                                                              package_count.group(3).strip())
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

        if count_error:
            return False, fail_data
        else:
            return True, "Verify package count of {} port cd{} - cd{} is complete.".format(pattern, min, max)

    def verify_all_port_qsfp_regexp(self, text):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            
        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(1, 49):

            link_status = re.search('{}\s+\|\s+Passed'.format(num), text)
            if link_status is None:
                count_error += 1
                fail_msg = 'Cannot expect Passed status of qsfp i2c port {}.'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

        if count_error:
            return False, fail_data
        else:
            return True, "Verify Passed status of qsfp i2c all port is complete."

    def verify_fan_speed_keyword(self, text, speed):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            speed: The speed of fan.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(1, 5):
            if not re.search('Successfully\s+set\s+fan\s+{}\s+speed\s+to\s+{}%'.format(num, speed), text):
                count_error += 1
                fail_msg = 'Cannot expect keyword: "Successfully set fan {} speed to {}%".'.format(num, speed)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

        if count_error:
            return False, fail_data
        else:
            return True, "Verify set all fan speed to {}% is complete.".format(speed)

    def verify_get_fan_speed_keyword(self, text, speed):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            speed: The speed of fan.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(1, 5):
            fan_speed = re.search('Fan\s+{}\s+RPMs\:\s+(\d+)\,\s+(\d+)\,\s+\((\d+)\%\)'.format(num), text)
            if fan_speed is None:
                count_error += 1
                fail_msg = 'Cannot expect keyword: "Fan {} RPMs: \d+, \d+, (\d+%)".'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

                continue

            speed_get = int(fan_speed.group(3).strip())
            speed_set = int(speed)
            low_peak_range = speed_set - 3
            high_peak_range = speed_set + 3

            if not low_peak_range <= speed_get <= high_peak_range:
                count_error += 1
                fail_msg = 'The Fan {} RPMs: expect speed ' \
                           'range {} - {} but got {}'.format(num, low_peak_range, high_peak_range, speed_get)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

        if count_error:
            return False, fail_data
        else:
            return True, "Verify get all fan speed to {}% is complete.".format(speed)


    def verify_pass_keyword_in_test_all(self, text, pattern_list):

        """Verify keyword in the text with regular expression.

        Args:
          text: The text for matching.
          pattern_list: The regular expression pattern list for matching text.

        Returns:
          True: Can matching text.
          msg: The pass or fail message.
          False: Cannot matching text.

        Raise:
          None.

        """
        fail_data = ""
        count_error = 0
        for pattern in pattern_list.split("||"):
            if not re.search('{}\s+\|\s+.*PASS.*\s+\|'.format(pattern.strip()), text):
                count_error += 1
                fail_msg = 'Cannot expect keyword: "{}  | PASS |".'.format(pattern.strip())
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

        if count_error:
            return False, fail_data
        else:
            return True, "Verify all keyword in all data is complete."

    def verify_eeprom_util(self, eeprom_type, text_util, text_eeprom, key_util, key_eeprom):

        """Verify keyword in the text with regular expression.

        Args:
        eeprom_type: The eeprom type for check.
        text_util: The response of command get eeprom for matching.
        text_eeprom: The text in eeprom config for matching.
        key_util: The key list for matching text in response.
        key_eeprom: The key list for matching text in eeprom config.

        Returns:
        True: Can matching text.
        msg: The pass or fail message.
        False: Cannot matching text.

        Raise:
        None.

        """
        all_data_util = {}
        all_data_eeprom = {}
        fail_data = ""
        count_error = 0
        value_data = None

        key_util_list = list(map(str.strip, key_util.split("||")))
        for key_we in key_util_list:
            if eeprom_type.upper() == "PEM":
                value_data = re.search('{}\s+\:\s+(\S+)'.format(key_we), text_util)
            elif eeprom_type.upper() in "FCM,SCM,FAN,SMB":
                value_data = re.search('{}\:\s+(\S+)'.format(key_we), text_util)
            else:
                return False, "The eeprom type mismatch data in list."
            
            if value_data is None:
                count_error += 1
                fail_msg = 'Cannot expect keyword: "{}:".'.format(key_we)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                all_data_util.update({key_we: "Empty"})
            else:
                all_data_util.update({key_we : value_data.group(1).strip()})

        if count_error:
            return False, fail_data

        print(all_data_util)

        key_eeprom_list = list(map(str.strip, key_eeprom.split("||")))
        for key_ee in key_eeprom_list:
            value_data = re.search('{}\s+\=\s+(.*)'.format(key_ee), text_eeprom)
            if value_data is None:
                count_error += 1
                fail_msg = 'Cannot expect keyword: "{}:".'.format(key_ee)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                all_data_eeprom.update({key_ee: "Empty"})
            else:
                all_data_eeprom.update({key_ee : value_data.group(1).strip()})

        if count_error:
            return False, fail_data
        
        print(all_data_eeprom)

        #Version
        ee_version = str(int(all_data_eeprom[key_eeprom_list[1]], 16))
        we_version = all_data_util[key_util_list[0]]
        if ee_version != we_version:
            count_error += 1
            fail_msg = 'Mismatch the Version' \
                        ' expect {} but got {}'.format(ee_version,
                                                        we_version)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Name
        ee_pro_name = all_data_eeprom[key_eeprom_list[2]]
        we_pro_name = all_data_util[key_util_list[1]]
        if ee_pro_name != we_pro_name:
            count_error += 1
            fail_msg = 'Mismatch the Product Name' \
                        ' expect {} but got {}'.format(ee_pro_name,
                                                        we_pro_name)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Part Number
        ee_pro_pn = all_data_eeprom[key_eeprom_list[3]]
        we_pro_pn = all_data_util[key_util_list[2]].replace("-", "")
        if ee_pro_pn != we_pro_pn:
            count_error += 1
            fail_msg = 'Mismatch the Product Part Number' \
                        ' expect {} but got {}'.format(ee_pro_pn,
                                                        we_pro_pn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #System Assembly Part Number
        ee_sys_ass_pn = all_data_eeprom[key_eeprom_list[4]]
        we_sys_ass_pn = all_data_util[key_util_list[3]].replace("-", "")
        if ee_sys_ass_pn != we_sys_ass_pn:
            count_error += 1
            fail_msg = 'Mismatch the System Assembly Part Number' \
                        ' expect {} but got {}'.format(ee_sys_ass_pn,
                                                        we_sys_ass_pn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Facebook PCBA Part Number
        ee_fb_pcba_pn = all_data_eeprom[key_eeprom_list[5]]
        we_fb_pcba_pn = all_data_util[key_util_list[4]].replace("-", "")
        if ee_fb_pcba_pn != we_fb_pcba_pn:
            count_error += 1
            fail_msg = 'Mismatch the Facebook PCBA Part Number' \
                        ' expect {} but got {}'.format(ee_fb_pcba_pn,
                                                        we_fb_pcba_pn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Facebook PCB Part Number
        ee_fb_pcb_pn = all_data_eeprom[key_eeprom_list[6]]
        we_fb_pcb_pn = all_data_util[key_util_list[5]].replace("-", "")
        if ee_fb_pcb_pn != we_fb_pcb_pn:
            count_error += 1
            fail_msg = 'Mismatch the Facebook PCB Part Number' \
                        ' expect {} but got {}'.format(ee_fb_pcb_pn,
                                                        we_fb_pcb_pn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #ODM PCBA Part Number
        ee_odm_pcba_pn = all_data_eeprom[key_eeprom_list[7]]
        we_odm_pcba_pn = all_data_util[key_util_list[6]]
        if ee_odm_pcba_pn != we_odm_pcba_pn:
            count_error += 1
            fail_msg = 'Mismatch the ODM PCBA Part Number' \
                        ' expect {} but got {}'.format(ee_odm_pcba_pn,
                                                        we_odm_pcba_pn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #ODM PCBA Serial Number
        ee_odm_pcba_sn = all_data_eeprom[key_eeprom_list[8]]
        we_odm_pcba_sn = all_data_util[key_util_list[7]]
        if ee_odm_pcba_sn != we_odm_pcba_sn:
            count_error += 1
            fail_msg = 'Mismatch the ODM PCBA Serial Number' \
                        ' expect {} but got {}'.format(ee_odm_pcba_sn,
                                                        we_odm_pcba_sn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Production State
        ee_pro_state = all_data_eeprom[key_eeprom_list[9]]
        we_pro_state = all_data_util[key_util_list[8]]
        if ee_pro_state != we_pro_state:
            count_error += 1
            fail_msg = 'Mismatch the Product Production State' \
                        ' expect {} but got {}'.format(ee_pro_state,
                                                        we_pro_state)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Version
        ee_pro_ver = all_data_eeprom[key_eeprom_list[10]]
        we_pro_ver = all_data_util[key_util_list[9]]
        if ee_pro_ver != we_pro_ver:
            count_error += 1
            fail_msg = 'Mismatch the Product Version' \
                        ' expect {} but got {}'.format(ee_pro_ver,
                                                        we_pro_ver)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Sub-Version
        pro_sub_ver = all_data_eeprom[key_eeprom_list[11]]
        we_pro_sub_ver = all_data_util[key_util_list[10]]
        if pro_sub_ver != we_pro_sub_ver:
            count_error += 1
            fail_msg = 'Mismatch the Product Sub-Version' \
                        ' expect {} but got {}'.format(pro_sub_ver,
                                                        we_pro_sub_ver)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Serial Number
        ee_pro_sn = all_data_eeprom[key_eeprom_list[12]]
        we_pro_sn = all_data_util[key_util_list[11]]
        if ee_pro_sn != we_pro_sn:
            count_error += 1
            fail_msg = 'Mismatch the Product Serial Number' \
                        ' expect {} but got {}'.format(ee_pro_sn,
                                                        we_pro_sn)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Product Asset Tag
        ee_pro_ass_tag = all_data_eeprom[key_eeprom_list[13]]
        we_pro_ass_tag = all_data_util[key_util_list[12]]
        if ee_pro_ass_tag != we_pro_ass_tag:
            count_error += 1
            fail_msg = 'Mismatch the Product Asset Tag' \
                        ' expect {} but got {}'.format(ee_pro_ass_tag,
                                                        we_pro_ass_tag)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #System Manufacturer
        ee_sys_mfg = all_data_eeprom[key_eeprom_list[14]]
        we_sys_mfg = all_data_util[key_util_list[13]]
        if ee_sys_mfg != we_sys_mfg:
            count_error += 1
            fail_msg = 'Mismatch the Product Asset Tag' \
                        ' expect {} but got {}'.format(ee_sys_mfg,
                                                        we_sys_mfg)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #System Manufacturing Date
        ee_sys_mfg_date = all_data_eeprom[key_eeprom_list[15]]
        we_sys_mfg_date = all_data_util[key_util_list[14]]
        ee_date = str(datetime.datetime.strptime(ee_sys_mfg_date,'%Y%m%d'))
        we_date = str(datetime.datetime.strptime(we_sys_mfg_date,'%m-%d-%y'))
        if ee_date != we_date:
            count_error += 1
            fail_msg = 'Mismatch the System Manufacturing Date' \
                        ' expect {} but got {}'.format(ee_sys_mfg_date,
                                                        we_sys_mfg_date)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #PCB Manufacturer
        ee_pcb_mfg = all_data_eeprom[key_eeprom_list[16]]
        we_pcb_mfg = all_data_util[key_util_list[15]]
        if ee_pcb_mfg != we_pcb_mfg:
            count_error += 1
            fail_msg = 'Mismatch the PCB Manufacturer' \
                        ' expect {} but got {}'.format(ee_pcb_mfg,
                                                        we_pcb_mfg)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Assembled At
        ee_ass_at = all_data_eeprom[key_eeprom_list[17]]
        we_ass_at = all_data_util[key_util_list[16]]
        if ee_ass_at != we_ass_at:
            count_error += 1
            fail_msg = 'Mismatch the Assembled At' \
                        ' expect {} but got {}'.format(ee_ass_at,
                                                        we_ass_at)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Local MAC
        if eeprom_type.upper() == "SMB":
            ee_local_mac = all_data_eeprom[key_eeprom_list[18]]
        elif eeprom_type.upper() in "FCM,SCM,FAN,PEM":
            ee_local_mac = "000000000000"
        else:
            ee_local_mac = "Mismatch Data"

        we_local_mac = all_data_util[key_util_list[17]].replace(":", "")
        if ee_local_mac != we_local_mac:
            count_error += 1
            fail_msg = 'Mismatch the Local MAC' \
                        ' expect {} but got {}'.format(ee_local_mac,
                                                        we_local_mac)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Extended MAC Base
        if eeprom_type.upper() == "SMB":
            ee_ext_mac_base = all_data_eeprom[key_eeprom_list[19]]
        elif eeprom_type.upper() in "FCM,SCM,FAN,PEM":
            ee_ext_mac_base = "000000000000"
        else:
            ee_ext_mac_base = "Mismatch Data"
        
        we_ext_mac_base = all_data_util[key_util_list[18]].replace(":",
                                                                    "")
        if ee_ext_mac_base != we_ext_mac_base:
            count_error += 1
            fail_msg = 'Mismatch the Extended MAC Base' \
                        ' expect {} but got {}'.format(ee_ext_mac_base,
                                                        we_ext_mac_base)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Extended MAC Address Size
        ee_ext_mac_size = str(int(all_data_eeprom[key_eeprom_list[20]], 16))
        we_ext_mac_size = all_data_util[key_util_list[19]]
        if ee_ext_mac_size != we_ext_mac_size:
            count_error += 1
            fail_msg = 'Mismatch the Extended MAC Address Size' \
                        ' expect {} but got {}'.format(ee_ext_mac_size,
                                                        we_ext_mac_size)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #Location on Fabric
        ee_loc_on_fab = all_data_eeprom[key_eeprom_list[21]]
        we_loc_on_fab = all_data_util[key_util_list[20]]
        if ee_loc_on_fab != we_loc_on_fab:
            count_error += 1
            fail_msg = 'Mismatch the Location on Fabric' \
                        ' expect {} but got {}'.format(ee_loc_on_fab,
                                                        we_loc_on_fab)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        #CRC8
        crc8 = "0x14"
        we_crc8 = all_data_util[key_util_list[21]]
        if crc8 != we_crc8:
            count_error += 1
            fail_msg = 'Mismatch the CRC8' \
                        ' expect {} but got {}'.format(crc8,
                                                        we_crc8)
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

        if count_error:
            return False, fail_data
        else:
            return True, "Verify all keyword in all data is complete."

    def get_section(self, start_text, end_text, text):

        """Get section text with regular expression.

        Args:
            start_text: The start text for matching.
            end_text: The end text for matching.
            text: The text for matching.

        Returns:
            msg: The text after get section is complete.
            None: Cannot matching text.

        Raise:
            None.

        """
        start = re.search(start_text, text)
        if start is not None:
            end = re.search(end_text, text[start.end():])
            return (text[
                start.end():end.start() + start.end() if end else len(text)])
        else:
            return None

    def verify_traffic_port_keyword(self, text):

        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(0, 48):
            if (num+1) > 47:
                end_text = "\[root\@localhost[ ]+.*\]\#"
            else:
                end_text = "port cd{} TX".format(num+1)

            port_data = self.get_section(start_text="port cd{} TX".format(num),
                                    end_text=end_text, text=text)
            if port_data is None:
                count_error += 1
                fail_msg = 'Cannot expect keyword: "port cd{} TX".'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

                continue

            if not re.search("TX\=RX\:\s+\[\s+Passed\s+\]", port_data):
                count_error += 1
                fail_msg = 'Cannot expect keyword: "TX=RX: [ Passed ]" of port cd{}.'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg) 

                continue

        if count_error:
            return False, fail_data
        else:
            return True, "Verify traffic testing all port is complete."

    def get_section_traffic_by_loop(self, data, current_loop, total_loop, pre_test=True):

        """Get section text with regular expression.

        Args:
            data: The text for matching.
            current_loop: The current loop for matching.
            total_loop: The total loop for matching.
            pre_test: The test mode for check.

        Returns:
            msg: The text after get section is complete.

        Raise:
            None.

        """
        start_text = None
        end_text = None
        
        if str(current_loop) != str(total_loop):
            start_text = "run\s+\#{}\s+test".format(current_loop)
            end_text = "run\s+\#{}\s+test".format(int(current_loop)+1)
        else:
            start_text = "run\s+\#{}\s+test".format(current_loop)
            if pre_test:
                end_text = "\[root\@localhost[ ]+.*\]\#"
            else:
                end_text = "END_LINE_LOGS"

        traffic_data = self.get_section(start_text=start_text,
                                    end_text=end_text, text=data)

        if traffic_data is None:
            return ""
        else:
            return  traffic_data

    def verify_xe_traffic_keyword(self, text):
        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0

        port_data = self.get_section(start_text="traffic testing",
                                    end_text="sleeping", text=text)
        if port_data is None:
            count_error += 1
            fail_msg = 'Cannot expect keyword: "XE traffic test".'
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

            return False, fail_data

        if not re.search("result\:\s+\[\s+Passed\s+\]", port_data):
            count_error += 1
            fail_msg = 'Cannot expect keyword: "result: [ Passed ]" ' \
                    'of XE Traffic test.'
            if not len(fail_data):
                fail_data = fail_msg
            else:
                fail_data = "{}||{}".format(fail_data, fail_msg)

            return False, fail_data

        return True, "Verify XE traffic test is complete."

    def verify_prbs_ber_traffic_keyword(self, text, ber_spec, mode="Test"):
        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.
            ber_spec: The BER range.
            mode: mode for check keyword.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        loop = 0
        for num in range(0, 48):
            if num > 15:
                loop = 4
            else:
                loop = 8

            for sub_loop in range(loop):
                if mode == "Test":
                    regx_data = "cd{}\[{}\]\s+\:\s+(\d.*)"
                    ber_data = re.search(regx_data.format(num, sub_loop), text)
                    if ber_data is None:
                        count_error += 1
                        fail_msg = 'Cannot expect keyword: "BER number of port ' \
                                'cd{}[{}]".'.format(
                            num, sub_loop)
                        if not len(fail_data):
                            fail_data = fail_msg
                        else:
                            fail_data = "{}||{}".format(fail_data, fail_msg)

                        continue
                    a = ber_data.group(0)
                    b = ber_data.group(1)
                    if not re.search("\d+", ber_data.group(1).strip()):
                        count_error += 1
                        fail_msg = 'Cannot expect keyword: "cd{}[{}] : Cannot ' \
                                'detect number.'.format(
                            num, sub_loop)
                        if not len(fail_data):
                            fail_data = fail_msg
                        else:
                            fail_data = "{}||{}".format(fail_data, fail_msg)

                        continue

                    ber_num = float(ber_data.group(1).strip())
                    ber_spec_num = float(ber_spec)

                    if ber_num > ber_spec_num:
                        count_error += 1
                        fail_msg = 'The BER of port cd{}[{}] : expect BER spec ' \
                                'range <{} but got {}'.format(num, sub_loop,
                                                                ber_spec_num,
                                                                ber_num)
                        if not len(fail_data):
                            fail_data = fail_msg
                        else:
                            fail_data = "{}||{}".format(fail_data, fail_msg)

                        continue
                else:
                    regx_data = "cd{}\[{}\]\s+\:\s+LossOfLock"
                    if not re.search(regx_data.format(num, sub_loop), text):
                        count_error += 1
                        fail_msg = 'Cannot expect keyword: "cd{}[{}] : ' \
                                'LossOfLock.'.format(
                            num, sub_loop)
                        if not len(fail_data):
                            fail_data = fail_msg
                        else:
                            fail_data = "{}||{}".format(fail_data, fail_msg)

                        continue

        if count_error:
            return False, fail_data
        else:
            return True, "Verify BER traffic testing all port is complete."

    def verify_l3_snake_traffic_keyword(self, text):
        """Verify keyword in the text with regular expression.

        Args:
            text: The text for matching.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """
        fail_data = ""
        count_error = 0
        for num in range(0, 48):

            tx_regx_data = "CDMIB_TBYT\.cd{}\s+\:\s+(\S+)".format(num)
            rx_regx_data = "CDMIB_RBYT\.cd{}\s+\:\s+(\S+)".format(num)

            tx_package = re.search(tx_regx_data, text)
            rx_package = re.search(rx_regx_data, text)

            if tx_package is None or rx_package is None:
                count_error += 1
                fail_msg = 'Cannot expect keyword: "TX or RX ' \
                        'package number of port cd{}".'.format(num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

            if not tx_package.group(1) == rx_package.group(1):
                count_error += 1
                fail_msg = 'L3 Snake Traffic Test: pakage TX = {} and ' \
                        'pakage RX = {} of port cd{} not equal".'.format(
                            tx_package.group(1), rx_package.group(1), num)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

        if count_error:
            return False, fail_data
        else:
            return True, "Verify L3 Snake Traffic Test all port is complete."

    def get_eeprom_keyword_regexp(self, text, key, eeprom_type):
    
        """Verify keyword in the text with regular expression.

        Args:
          text: The text for matching.
          key: The regular expression pattern for matching text.
          eeprom_type: The eeprom type for check.

        Returns:
          True: Can matching text.
          msg: The pass or fail message.
          False: Cannot matching text.

        Raise:
          None.

        """

        if eeprom_type.upper() in "PEM,PSU":
            value_data = re.search('{}\s+\:\s+(\S+)'.format(key.strip()), text)
        elif eeprom_type.upper() in "FCM,SCM,FAN,SMB":
            value_data = re.search('{}\:\s+(\S+)'.format(key.strip()), text)
        else:
            return False, "The eeprom type mismatch data in list."

        if value_data is None:
            fail_msg = 'Cannot expect keyword: "{}:".'.format(key.strip())
            return False, fail_msg

        return True, value_data.group(1)

    def check_hpmod_v2(self, data, set_addr_dd, offset_addr_dd, set_addr,
                   offset_addr):
        """Verify keyword in the text with regular expression.

        Args:
            data: The text for matching.
            set_addr_dd: The address power of qsfp DD.
            offset_addr_dd: The address of qsfp DD.
            set_addr: The address power of qsfp.
            offset_addr: The address of qsfp.

        Returns:
            True: Can matching text.
            msg: The pass or fail message.
            False: Cannot matching text.

        Raise:
            None.

        """

        fail_data = ""
        count_error = 0

        for num in range(1, 49):

            if num < 17:
                q_addr_set = set_addr_dd
                q_addr = offset_addr_dd
            else:
                q_addr_set = set_addr
                q_addr = offset_addr

            if not re.search('Port\s+\#{}\s+set\s+{}\s+to\s+offset\s+{}'
                            '\s+passed'.format(num, q_addr_set, q_addr), data):

                count_error += 1
                fail_msg = 'Cannot expect the keyword "Port #{} set {} ' \
                        'to offset {} passed"'.format(num, q_addr_set, q_addr)
                if not len(fail_data):
                    fail_data = fail_msg
                else:
                    fail_data = "{}||{}".format(fail_data, fail_msg)

                continue

        if count_error:
            return False, fail_data
        else:
            return True, "Verify set high power mode of QSFP-DD and QSFP-XX " \
                        "is complete."

    def get_bmc_version(text , message1, message2):
        with open(text, 'r') as f:
            data = ''.join(f.readlines())
        result = (
            data[data.index(message1):data.index(message2) + 1])
        line = result.splitlines()
        return line

    def Getlinenum(text , message1 , Path):
        lookup = 'the dog barked'

        with open(filename) as Path:
            for num, line in enumerate(myFile, 1):
                if lookup in line:
                    print 'found at line:', num

    def line_num_for_phrase_in_file(phrase, filename):
        with open(filename,'r') as f:
            for (i, line) in enumerate(f):
                if phrase in line:
                    return i
        return i
    
    def add_one_to_int(n):
        return n + 1