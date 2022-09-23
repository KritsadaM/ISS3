*** Keywords ***
########################################################################################################################################

                                ##  ###    ##  ##  ########     ##      ##       ##  #######  ########
                                ##  ## #   ##  ##     ##       ####     ##       ##       ##  ## 
                                ##  ##  #  ##  ##     ##      ##  ##    ##       ##     ##    ########
                                ##  ##   # ##  ##     ##     ########   ##       ##   ##      ##
                                ##  ##    ###  ##     ##    ##      ##  #######  ##  #######  ########   
                                                            
########################################################################################################################################
Set_suit_variable
    ${TextFileContent}=    OperatingSystem.Get File    ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    @{expect_list}=   Split String    ${TextFileContent}    \n
    FOR   ${i}  IN  @{expect_list}
        ${length} =	Get Length	${i}
        Exit For Loop If   "${length}" == "0"
        @{temp}=   Split String   ${i}   = "
        ${key}=  Set Variable   ${temp}[0]
        ${vartemp}=  Set Variable   ${temp}[1]
        @{var_temp1}=   Split String   ${vartemp}   "
        ${var}=  Set Variable   ${var_temp1}[0]
        ${key}=  Strip String   ${key}
        ${var}=  Strip String   ${var}
        Save_to_logs     ${key} = ${var}\n
        Set Global Variable     ${${key}}     ${var}
    END

Check_ODC_Patrameter
    [Arguments]   
    log.debug    *************** Parameter Check are not blank ***************
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${CURDIR}    Robot_Debug
    Run Keyword If    '${status}' == 'FAIL'    Check_ODC_Patrameter_Robot
    Run Keyword If    '${status}' == 'PASS'    Check_ODC_Patrameter_Robot_Debug

Check_ODC_Patrameter_Robot_Debug
    [Arguments] 
    ${Parameter}=  OperatingSystem.Get File    ${CURDIR}${/}..${/}../ODC_Script${/}BOM${/}${serial_number}.py
    @{message_list}=    Split String           ${Parameter}               \n
    FOR    ${i}    IN       @{message_list}
        Save_to_logs    ${i}\n
        ${status}    ${std_out}=     Run Keyword And Ignore Error    Should Not Contain    ${i}     ""
        Run Keyword If          '${status}' == 'FAIL'    FAIL    Check empty ODC string: "${i}"
    END
    # Save_to_logs    Cell = "${slot_location}"\n
    ${Mac_length}      Get Length     ${MAC}
    Save_to_logs    Mac size = "${Mac_length}"\n
    Run Keyword If    '${Mac_length}' != '12'    FAIL    Mac size Incorrect\n
    # BMC_MAC_Calculate    Mac_cal_size=383
    ${BMC_Mac}   MacAddress.mac_converter    address=${MAC}    size=${383}
    ${BMC_Mac}    Remove String    ${BMC_Mac}    -
    log.debug     pythonmac = ${BMC_Mac} \n
    Set Global Variable     ${BMC_Mac}
    Save_to_logs    Cell = "${slot_location}"\n
    Save_to_logs    BMC_Mac = "${BMC_Mac}"\n

Check_ODC_Patrameter_Robot
    [Arguments] 
    ${Parameter}=  OperatingSystem.Get File    ${CURDIR}${/}..${/}..${/}ODC_Script${/}BOM${/}${serial_number}.py
    @{message_list}=    Split String           ${Parameter}               \n
    FOR    ${i}    IN       @{message_list}
        Save_to_logs    ${i}\n
        ${status}    ${std_out}=     Run Keyword And Ignore Error    Should Not Contain    ${i}     ""
        Run Keyword If          '${status}' == 'FAIL'    FAIL    Check empty ODC string: "${i}"
    END
    ${Mac_length}      Get Length     ${MAC}
    Save_to_logs    Mac size = "${Mac_length}"\n
    Run Keyword If    '${Mac_length}' != '12'    FAIL    Mac size Incorrect\n
    ${BMC_Mac}   MacAddress.mac_converter    address=${MAC}    size=${383}
    ${BMC_Mac}    Remove String    ${BMC_Mac}    -
    log.debug     pythonmac = ${BMC_Mac} \n
    Set Global Variable     ${BMC_Mac}
    Save_to_logs    Cell = "${slot_location}"\n
    Save_to_logs    BMC_Mac = "${BMC_Mac}"\n

BMC_MAC_Calculate
    [Arguments]    ${Mac_cal_size}
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+${Mac_cal_size}
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    Set Global Variable     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n

Diag_Login_And_Connect
    Run    /usr/bin/pkill -HUP -f "^telnet ${TelnetIP}.+${Port_Telnet}"
    Util_Test_Execution         test_case=Power_Cyling
    ...                         retry_loop=5

Retey_to_Power_cycling
    Power_Cyling

Command_Power_Cyling
    [Arguments]   ${Comamnd}    ${retry_loop}=4      ${sleep_time}=5
    ${max_loop}=    Evaluate      ${retry_loop}-1
    
    FOR  ${loop}  IN RANGE   0    ${retry_loop}
        Run Keyword If     ${loop}>=${max_loop}      GEN_FAIL
        sleep     ${sleep_time}
        ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_CLOSE
        ${test_status}     ${std_out}=   
        ...                Run Keyword And Ignore Error       Command_Power_Cyling_1    ${Comamnd}
        Run Keyword If	   '${test_status}' == 'FAIL'    	  Continue For Loop
        Run Keyword If	   '${test_status}' == 'PASS'	      Exit For Loop

    END

Kill_telnet_port
    [Arguments] 
    START_SSH_server    ${USERNAME_SSH_server}    ${PASSWORD_SSH_server}
    SSHLibrary.Write    sudo /usr/bin/pkill -HUP -f "^telnet ${TelnetIP}.+${Port_Telnet}"
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}
    SSH_CLOSE

Util_Test_Execution
    [Arguments]     ${test_case}    ${retry_loop}=2      ${sleep_time}=5
    ${max_loop}=    Evaluate      ${retry_loop}-1
    
    FOR  ${loop}  IN RANGE   0    ${retry_loop}
        Run Keyword If     ${loop}>=${max_loop}      GEN_FAIL
        sleep     ${sleep_time}
        ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_CLOSE
        ${test_status}     ${std_out}=   
        ...                Run Keyword And Ignore Error       ${test_case}
        Run Keyword If	   '${test_status}' == 'FAIL'    	  Continue For Loop
        Run Keyword If	   '${test_status}' == 'PASS'	      Exit For Loop

    END

GEN_FAIL
    Save_to_logs   ${TEST NAME}= !!! ${space} F A I L E D ${space} !!!\r
    FAIL

pro_dummu_sys_eeprom

    Diag_Telnet_Execute_Command_12              command=ls
    ...                                         expect_string=fru_cfg
    ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/system.cfg -s 8192 -a -o bin/system.bin
    ...                                         expect_string=FRU file "bin/system.bin" created
    ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t system
    ...                                         expect_string=Passed
    ...                                         path=/home/cel_diag/silverstone
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         expect_string=Passed
    ...                                         path=/home/cel_diag/silverstone

Diag_FPGA_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 1 -f firmware/fpga/${FPGA_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed

Diag_BIOS_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 2 -f firmware/bios/${BIOS_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Sleep   20s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 3 -f firmware/bios/${BIOS_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300

Diag_CPLD_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 4 -f firmware/cpld/${CPLD_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300

Diag_BMC_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 5 -f firmware/bmc/${BMC_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Sleep   60s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 6 -f firmware/bmc/${BMC_File_Name}
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Diag_Login_And_Connect

Firmware_Version_Check
    Swap_BMC
    log.debug    *************** CPLD Version Check ***************
    Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x03 0 1 0
    ...                                 expect_string=${Firmware_Version.CPLD_Base_Board}
    Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x03 1 1 0
    ...                                 expect_string=${Firmware_Version.CPLD_Fan_Board}
    Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x01 1 0x1a 1 0xe0
    ...                                 expect_string=${Firmware_Version.CPLD_ComE}
    Swap_COME
    Diag_Telnet_Execute_Command_12            command=i2cget -f -y 4 0x30 0x00
    ...                                 expect_string=${Firmware_Version.CPLD_Switch1}
    Diag_Telnet_Execute_Command_12            command=i2cget -f -y 4 0x31 0x00
    ...                                 expect_string=${Firmware_Version.CPLD_Switch1}

    log.debug    *************** FPGA Version Check ***************
    Diag_Telnet_Execute_Command_12            command=./bin/cel-upgrade-test -F -d 1
    ...                                 expect_string=${Firmware_Version.FPGA_Version}

    log.debug    *************** BMC Version Check ***************
    Diag_Telnet_Execute_Command_12            command=./bin/cel-upgrade-test -F -d 5
    ...                                 expect_string=${Firmware_Version.BMC2_Version}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-upgrade-test -F -d 6
    ...                                 expect_string=${Firmware_Version.BMC2_Version}

    log.debug    *************** Diag Version Check ***************
    Diag_Telnet_Execute_Command_12            command=./bin/cel-upgrade-test -v
    ...                                 expect_string=${Firmware_Version.Diag_Version}

    log.debug    *************** Bios Version Check ***************
    Diag_Telnet_Execute_Command_12            command=./bin/cel-upgrade-test -F -d 2
    ...                                 expect_string=${Firmware_Version.Bios_Version}

Diag_Modify_CPU_MAC_address_check
    Diag_Telnet_Execute_Command_12            command=./tools/eeupdate64e /NIC=3 /MAC_DUMP
    ...                                 expect_string=${MAC}
    Diag_Telnet_Execute_Command_12            command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_12            command=ping ${SSH_IP} -c 5
    ...                                 expect_string=5 received, 0% packet loss
    Swap_BMC
    Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC             command=ifconfig
    ...                                 wait_for=${BMC_IP_2}
    Diag_Telnet_Execute_Command         command=ping ${BMC_IP_2} -c 5
    ...                                 wait_for=\#
    ...                                 expect_string=5 packets received, 0% packet loss
    Swap_COME

Diag_Modify_CPU_MAC_address_test
    Diag_Telnet_Execute_Command_12            command=./tools/eeupdate64e /nic=3 /mac=${MAC}
    ...                                 expect_string=Done
    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12            command=./tools/eeupdate64e /NIC=3 /MAC_DUMP
    ...                                 expect_string=${MAC}
    Diag_Telnet_Execute_Command_12            command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_12            command=ping ${SSH_IP} -c 5
    ...                                 expect_string=5 received, 0% packet loss
    Swap_BMC
    Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC             command=ifconfig
    ...                                 wait_for=${BMC_IP_2}
    Diag_Telnet_Execute_Command         command=ping ${BMC_IP_2} -c 5
    ...                                 wait_for=\#
    ...                                 expect_string=5 packets received, 0% packet loss
    Swap_COME
   
Diag_SMBIOS_FRU_Burning
    [Arguments]
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${UUID}=  Convert To Uppercase  ${UUID}
    # ${MAC}    Convert To List    ${MAC}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru --all -t smbios -d 1
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Manufacturer" -D "Celestica"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Product" -D "${TLV_Version.Product_Name}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Version" -D "${REV}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System UUID" -D "${UUID}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Serial Number" -D "${TLA_SN}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System SKU Number" -D "${PRODUCT_PN}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Family Name" -D "${TLV_Version.Product_Name}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Manufacturer" -D "Celestica"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Product" -D "${BASE_BOARD_PN}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Version" -D "${BASE_BOARD_REV}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Serial Number" -D "${MAC}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Asset Tag" -D "${COME_PN}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Location In Chassis" -D "${SMBios_Version.Board_Location_Chassis}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Manufacturer" -D "Celestica"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Version" -D "${SMBios_Version.Chassis_Version}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Asset Tag" -D "${SMBios_Version.Chassis_Asset_Tag}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
 
EEPROM_CHECK_TEST_FOR_TLV_testcase
    ${SERIAL}    Remove String    ${TLA_SN}    ${TLA_REV}
    ${MAC}    Convert To List    ${MAC}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --dump -t tlv -d 1
    ...                                 parse_string=${TLV_Version.Product_Name},${TLA_PN},${SERIAL},${MACADD},Device Version.+0x26.+1.+1,${TLA_REV},${TLV_Version.ONIE_Version},${TLV_Version.Manufacturer},Country Code.+${TLV_Version.Country_Code},${TLV_Version.Diag_Version},${TAGID}

EEPROM_CHECK_TEST_FOR_SMBIOS_FRU_testcase
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${UUID}=  Convert To Uppercase  ${UUID}
    # ${MAC}    Convert To List    ${MAC}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    ...                                 parse_string=Chassis Manufacturer.+Celestica,Chassis Version.+${SMBios_Version.Chassis_Version},${SMBios_Version.Chassis_Asset_Tag},Board Manufacturer.+Celestica,${BASE_BOARD_PN},${MAC},Board Version.+${BASE_BOARD_REV},${COME_PN},${SMBios_Version.Board_Location_Chassis},System Manufacturer.+Celestica,${TLV_Version.Product_Name},System Version.+${REV},${TLA_SN},0X${UUID}

EEPROM_CHECK_TEST_FOR_BMC_FRU_testcase
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${COME_REV}=    Get Substring    ${COME_REV}    0    2
    ${BMC_REV}=    Get Substring    ${BMC_REV}    0    2
    ${SWITCH_BOARD_REV}=    Get Substring    ${SWITCH_BOARD_REV}    0    2
    ${FAN_BOARD_REV}=    Get Substring    ${FAN_BOARD_REV}    0    2
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+383
    # ${BMC_Mac}    Convert To HEX    ${loop_count}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # ${BMC_Mac_count}    Evaluate    12-${Maccount}
    # ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    # ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # log.debug    The last BMC mac is: ${BMC_Mac}\n
    # Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.

    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                 parse_string=Board Mfg .+: Celestica,Board Product.+: Dell,Board Serial.+: ${BMC_SN},Board Part Number.+${BMC_PN},Board Extra.+: ${BMC_REV},Board Extra.+: ${BMC_Mac},Board Extra.+: ${UUID},Board Extra.+: ${BMC_Product},Board Extra.+: ${PRODUCT_PN},Board Extra.+: ${REV}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Base Board,Board Serial.+: ${BASE_BOARD_SN},Board Part Number.+: ${BASE_BOARD_PN},Board Extra.+: Z9332F-ON-baseboard,Board Extra.+: ${BASE_BOARD_REV},Product Manufacturer.+Celestica,Product Name.+: Z9332F-ON,Product Part Number.+: ${PRODUCT_PN},Product Version.+: ${REV},Product Serial.+: ${TLA_SN},Product Extra.+: ${Fan_type},Product Extra.+: ${MAC},Product Extra.+: 384
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                 parse_string=Board Mfg.+Celestica,Board Product.+: COMe CPU Board,Board Serial.+: ${COME_SN},Board Part Number.+: ${COME_PN},Board Extra.+: Z9332F-ON_COME,Board Extra.+: ${COME_REV}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Switch Board,Board Serial.+: ${SWITCH_BOARD_SN},Board Part Number.+: ${SWITCH_BOARD_PN},Board Extra.+: ${SWITCH_BOARD_REV}
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan_board
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan control Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_SN}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${FAN_BOARD_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_REV}
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan1
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN1}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan2
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN2}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan3
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN3}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan4
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN4}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan5
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN5}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan6
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN6}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan7
    Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN7}
    Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    log.debug    ******* CHECK EEPROM BMC *******
    log.debug    BMC SN\ \ \ \ \ \ : ${BMC_SN}
    log.debug    BMC PN\ \ \ \ \ \ : ${BMC_PN}
    log.debug    BMC REV : ${BMC_REV}
    log.debug    LAST MAC\ \ \ \ : ${BMC_Mac}
    log.debug    UUID\ \ \ \ \ \ \ \ : ${UUID}
    log.debug    PN SYSTEM\ \ : ${PRODUCT_PN}
    log.debug    REV SYSTEM\ \ : ${REV}
    log.debug    **********************************
    log.debug    ***** CHECK EEPROM BASE BOARD *****
    log.debug    BASE BOARD SN\ \ \ \ \ \ : ${BASE_BOARD_SN}
    log.debug    BASE BOARD PN\ \ \ \ \ \ : ${BASE_BOARD_PN}
    log.debug    BASE BOARD REV\ \ \ \ \ \ : ${BASE_BOARD_REV}
    log.debug    SN SYSTEM\ \ : ${TLA_SN}
    log.debug    PN SYSTEM\ \ : ${PRODUCT_PN}
    log.debug    REV SYSTEM\ \ : ${REV}
    log.debug    FIRST MAC\ \ \ \ \ \ \ \ \ \ : ${MAC}
    log.debug    **********************************
    log.debug    ***** CHECK EEPROM COME *****
    log.debug    COME SN\ \ \ \ \ : ${COME_SN}
    log.debug    COME PN\ \ \ \ \ : ${COME_PN}
    log.debug    COME REV\ \ \ \ \ : ${COME_REV}
    log.debug    **********************************
    log.debug    **********************************
    log.debug    ******* CHECK EEPROM SWITCH *******
    log.debug    SWITCH SN\ \ \ \ \ : ${SWITCH_BOARD_SN}
    log.debug    SWITCH PN\ \ \ \ \ : ${SWITCH_BOARD_PN}
    log.debug    SWITCH REV\ \ \ \ \ : ${SWITCH_BOARD_REV}
    log.debug    **********************************
    log.debug    ***** CHECK EEPROM FAN_BOARD AND FAN1-7 *****
    log.debug    FAN_BOARD SN : ${FAN_BOARD_SN}
    log.debug    FAN_BOARD PN : ${FAN_BOARD_PN}
    log.debug    FAN1 SN\ \ \ \ \ \ : ${FAN1}
    log.debug    FAN1 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN2 SN\ \ \ \ \ \ : ${FAN2}
    log.debug    FAN2 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN3 SN\ \ \ \ \ \ : ${FAN3}
    log.debug    FAN3 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN4 SN\ \ \ \ \ \ : ${FAN4}
    log.debug    FAN4 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN5 SN\ \ \ \ \ \ : ${FAN5}
    log.debug    FAN5 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN6 SN\ \ \ \ \ \ : ${FAN6}
    log.debug    FAN6 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    FAN7 SN\ \ \ \ \ \ : ${FAN7}
    log.debug    FAN7 PN\ \ \ \ \ \ : ${Fan_PN}
    log.debug    **********************************
    Should Contain    ${Fan_PN}    ${Fan_PN}
    Should Contain    ${Fan_PN}    ${Fan_PN}
    Should Contain    ${Fan_PN}    ${Fan_PN}
    Should Contain    ${Fan_PN}    ${Fan_PN}
    Should Contain    ${Fan_PN}    ${Fan_PN}
    Should Contain    ${Fan_PN}    ${Fan_PN}
    log.debug    ***** COMPARE P/N FAN1 - FAN7 *****
    log.debug    P/N FAN1 - FAN7 : ${Fan_PN} \ \IS MATCH
    log.debug    **********************************

START_SSH_Get_TLV_TIME
    [Arguments] 
    START_SSH_server    ${USERNAME_SSH_server}    ${PASSWORD_SSH_server}
    SSHLibrary.Write    date +'%m/%d/%Y %H:%M:%S'
    ${TLV_GET}=    SSHLibrary.Read Until    \$
    # Save_to_logs     ${TLV_GET}
    ${TLV_TIME_GET}=    Get Line    ${TLV_GET}    0
    Set Global Variable         ${TLV_TIME_GET}
    # ${RTC_GET}=    Set Variable    ${output}
    SSH_CLOSE
    # [Return]   ${output}

Diag_TLV_eeprom_programming
    [Arguments]
    START_SSH_Get_TLV_TIME
    sleep  1
    # ${SN_A}=    Get Substring    ${SN}    0    20
    ${SERIAL}    Remove String    ${TLA_SN}    ${TLA_REV}
    ${MAC}    Convert To List    ${MAC}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --all
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --dump -t tlv -d 1
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x21 -D ${TLV_Version.Product_Name}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x22 -D ${TLA_PN}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x23 -D ${SERIAL}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x24 -D ${MACADD}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x25 -D "${TLV_TIME_GET}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x26 -D 1
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x27 -D ${TLA_REV}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x29 -D ${TLV_Version.ONIE_Version}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2B -D ${TLV_Version.Manufacturer}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2C -D ${TLV_Version.Country_Code}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2E -D ${TLV_Version.Diag_Version}
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2F -D ${TAGID}
    ...                                 parse_string=Programming passed
    ${vender_ext}   Set Variable    ${TLV_Version.Vendor_Extension}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0xFD -D "${vender_ext}"
    ...                                 parse_string=Programming passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-test --dump -t tlv -d 1
    ...                                 parse_string=${TLV_Version.Product_Name},${TLA_PN},${SERIAL},${MACADD},${TLV_TIME_GET},Device Version.+0x26.+1.+1,${TLA_REV},${TLV_Version.ONIE_Version},${TLV_Version.Manufacturer},Country Code.+${TLV_Version.Country_Code},${TLV_Version.Diag_Version},${TAGID}

Diag_Eeprom_BMC_FRU_Test
    @{component_list}=     Create List     bmc  come  switch  system  fan_board  fan1  fan2  fan3  fan4  fan5  fan6  fan7
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${COME_REV}=    Get Substring    ${COME_REV}    0    2
    ${BMC_REV}=    Get Substring    ${BMC_REV}    0    2
    ${SWITCH_BOARD_REV}=    Get Substring    ${SWITCH_BOARD_REV}    0    2
    ${FAN_BOARD_REV}=    Get Substring    ${FAN_BOARD_REV}    0    2
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+383
    # ${BMC_Mac}    Convert To HEX    ${loop_count}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # ${BMC_Mac_count}    Evaluate    12-${Maccount}
    # ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    # ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # log.debug    The last BMC mac is: ${BMC_Mac}\n
    # Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.
    FOR     ${i}    IN     @{component_list}
        ${out_config}               Diag_Telnet_Execute_Command_12              command=cat ${i}.cfg
                                    ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
        ${out_config}               Get Lines Containing String     ${out_config}       =
        ${out_config}               Split String                    ${out_config}       \n
        Set Suite Variable       ${${i}_config}    ${out_config}
        log.debug    ${bmc_config}\n
    END
    # ${bmc_config}               Diag_Telnet_Execute_Command_12              command=cat bmc.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${come_config}              Diag_Telnet_Execute_Command_12              command=cat come.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${switch_config}            Diag_Telnet_Execute_Command_12              command=cat switch.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${system_config}            Diag_Telnet_Execute_Command_12              command=cat system.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan_board_config}          Diag_Telnet_Execute_Command_12              command=cat fan_board.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg

    # ${fan1_config}          Diag_Telnet_Execute_Command_12              command=cat fan1.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan2_config}          Diag_Telnet_Execute_Command_12              command=cat fan2.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan3_config}          Diag_Telnet_Execute_Command_12              command=cat fan3.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan4_config}          Diag_Telnet_Execute_Command_12              command=cat fan4.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan5_config}          Diag_Telnet_Execute_Command_12              command=cat fan5.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan6_config}          Diag_Telnet_Execute_Command_12              command=cat fan6.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    # ${fan7_config}          Diag_Telnet_Execute_Command_12              command=cat fan7.cfg
    #                             ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg

    # ${bmc_config}               Get Lines Containing String     ${bmc_config}       =
    # ${bmc_config}               Split String                    ${bmc_config}       \n
    # log.debug    ${bmc_config}\n
    # ${come_config}               Get Lines Containing String     ${come_config}       =
    # ${come_config}               Split String                    ${come_config}       \n
    # log.debug    ${come_config}\n
    # ${switch_config}               Get Lines Containing String     ${switch_config}       =
    # ${switch_config}               Split String                    ${switch_config}       \n
    # log.debug    ${switch_config}\n
    # ${system_config}               Get Lines Containing String     ${system_config}       =
    # ${system_config}               Split String                    ${system_config}       \n
    # log.debug    ${system_config}\n
    # ${fan_board_config}               Get Lines Containing String     ${fan_board_config}       =
    # ${fan_board_config}               Split String                    ${fan_board_config}       \n
    # log.debug    ${fan_board_config}\n
    # ${fan1_config}               Get Lines Containing String     ${fan1_config}       =
    # ${fan1_config}               Split String                    ${fan1_config}       \n
    # log.debug    ${fan1_config}\n
    # ${fan2_config}               Get Lines Containing String     ${fan2_config}       =
    # ${fan2_config}               Split String                    ${fan2_config}       \n
    # log.debug    ${fan2_config}\n
    # ${fan3_config}               Get Lines Containing String     ${fan3_config}       =
    # ${fan3_config}               Split String                    ${fan3_config}       \n
    # log.debug    ${fan3_config}\n
    # ${fan4_config}               Get Lines Containing String     ${fan4_config}       =
    # ${fan4_config}               Split String                    ${fan4_config}       \n
    # log.debug    ${fan4_config}\n
    # ${fan5_config}               Get Lines Containing String     ${fan5_config}       =
    # ${fan5_config}               Split String                    ${fan5_config}       \n
    # log.debug    ${fan5_config}\n
    # ${fan6_config}               Get Lines Containing String     ${fan6_config}       =
    # ${fan6_config}               Split String                    ${fan6_config}       \n
    # log.debug    ${fan6_config}\n
    # ${fan7_config}               Get Lines Containing String     ${fan7_config}       =
    # ${fan7_config}               Split String                    ${fan7_config}       \n
    # log.debug    ${fan7_config}\n
    Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/*.bin
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[2]/product_name=Fan control Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[3]/serial_number=${FAN_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[4]/part_number=${FAN_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[5]/board_custom_1=${FAN_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[2]/serial_number=${BMC_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[3]/part_number=${BMC_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[4]/customer_1=${BMC_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[5]/customer_2=${BMC_Mac}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[6]/customer_3=${UUID}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[7]/customer_4=NA/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[8]/product_mfg=Z9332F-ON-BMC/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[9]/product_name=Dell/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[10]/product_part_num=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[11]/product_ver=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[2]/product_name=Base Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[3]/serial_number=${BASE_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[4]/part_number=${BASE_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[5]/customer_1=Z9332F-ON-baseboard/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[6]/customer_2=${BASE_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[7]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[8]/product_name=Z9332F-ON/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[9]/part_number=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[10]/version=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[11]/serial_number=${TLA_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[12]/customer_3=${Fan_type}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[13]/customer_4=${MAC}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[14]/customer_5=384/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[2]/product_name=COMe CPU Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[3]/serial_number=${COME_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[4]/part_number=${COME_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[5]/customer_1=Z9332F-ON_COME/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[6]/customer_2=${COME_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[2]/product_name=Switch Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[3]/serial_number=${SWITCH_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[4]/part_number=${SWITCH_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[5]/customer_1=${SWITCH_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg

    FOR     ${i}    IN RANGE    1   8
        EEPROM_FAN    ${i}    ${FAN${i}}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan${i}_config}
    END

    # EEPROM_FAN    1    ${FAN1}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan1_config}
    # EEPROM_FAN    2    ${FAN2}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan2_config}
    # EEPROM_FAN    3    ${FAN3}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan3_config}
    # EEPROM_FAN    4    ${FAN4}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan4_config}
    # EEPROM_FAN    5    ${FAN5}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan5_config}
    # EEPROM_FAN    6    ${FAN6}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan6_config}
    # EEPROM_FAN    7    ${FAN7}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan7_config}
    sleep    1s
    FOR     ${i}    IN     @{component_list}
        ${var1} =	Set Variable If	'${i}' == 'come'	4096	8192
        Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/${i}.cfg -s ${var1} -a -o bin/${i}.bin
        ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    END
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan1.cfg -s 8192 -a -o bin/fan1.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan2.cfg -s 8192 -a -o bin/fan2.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan3.cfg -s 8192 -a -o bin/fan3.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan4.cfg -s 8192 -a -o bin/fan4.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan5.cfg -s 8192 -a -o bin/fan5.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan6.cfg -s 8192 -a -o bin/fan6.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan7.cfg -s 8192 -a -o bin/fan7.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan_board.cfg -s 8192 -a -o bin/fan_board.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/come.cfg -s 4096 -a -o bin/come.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/bmc.cfg -s 8192 -a -o bin/bmc.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/switch.cfg -s 8192 -a -o bin/switch.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/system.cfg -s 8192 -a -o bin/system.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    FOR     ${i}    IN RANGE    0   14
        Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 ${i} 0
    END
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 0 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 1 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 2 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 3 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 4 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 5 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 6 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 7 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 8 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 9 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 10 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 11 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 12 0
    # Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 13 0
    FOR     ${i}    IN     @{component_list}
        Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t ${i}
        ...                                         expect_string=Passed
    END
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t bmc
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t system
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t come
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan_board
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t switch
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan1
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan2
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan3
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan4
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan5
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan6
    # ...                                 expect_string=Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan7
    # ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12      command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/bin/*.bin

    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                 parse_string=Board Mfg .+: Celestica,Board Product.+: Dell,Board Serial.+: ${BMC_SN},Board Part Number.+${BMC_PN},Board Extra.+: ${BMC_REV},Board Extra.+: ${BMC_Mac},Board Extra.+: ${UUID},Board Extra.+: Z9332F-ON-BMC,Board Extra.+: ${PRODUCT_PN},Board Extra.+: ${REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Base Board,Board Serial.+: ${BASE_BOARD_SN},Board Part Number.+: ${BASE_BOARD_PN},Board Extra.+: Z9332F-ON-baseboard,Board Extra.+: ${BASE_BOARD_REV},Product Manufacturer.+Celestica,Product Name.+: Z9332F-ON,Product Part Number.+: ${PRODUCT_PN},Product Version.+: ${REV},Product Serial.+: ${TLA_SN},Product Extra.+: ${Fan_type},Product Extra.+: ${MAC},Product Extra.+: 384
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                 parse_string=Board Mfg.+Celestica,Board Product.+: COMe CPU Board,Board Serial.+: ${COME_SN},Board Part Number.+: ${COME_PN},Board Extra.+: Z9332F-ON_COME,Board Extra.+: ${COME_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Switch Board,Board Serial.+: ${SWITCH_BOARD_SN},Board Part Number.+: ${SWITCH_BOARD_PN},Board Extra.+: ${SWITCH_BOARD_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan_board
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan control Board,Board Serial.+: ${FAN_BOARD_SN},Board Part Number.+: ${FAN_BOARD_PN},Board Extra.+: ${FAN_BOARD_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan1
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN1},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan2
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN2},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan3
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN3},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan4
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN4},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan5
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN5},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan6
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN6},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan7
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN7},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan_board
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan control Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${FAN_BOARD_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_REV}
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan1
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN1}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan2
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN2}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan3
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN3}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan4
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN4}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan5
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN5}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan6
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN6}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -r -t fan7
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN7}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_type}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # log.debug    ******* CHECK EEPROM BMC *******
    # log.debug    BMC SN\ \ \ \ \ \ : ${BMC_SN}
    # log.debug    BMC PN\ \ \ \ \ \ : ${BMC_PN}
    # log.debug    BMC REV : ${BMC_REV}
    # log.debug    LAST MAC\ \ \ \ : ${BMC_Mac}
    # log.debug    UUID\ \ \ \ \ \ \ \ : ${UUID}
    # log.debug    PN SYSTEM\ \ : ${PRODUCT_PN}
    # log.debug    REV SYSTEM\ \ : ${REV}
    # log.debug    **********************************
    # log.debug    ***** CHECK EEPROM BASE BOARD *****
    # log.debug    BASE BOARD SN\ \ \ \ \ \ : ${BASE_BOARD_SN}
    # log.debug    BASE BOARD PN\ \ \ \ \ \ : ${BASE_BOARD_PN}
    # log.debug    BASE BOARD REV\ \ \ \ \ \ : ${BASE_BOARD_REV}
    # log.debug    SN SYSTEM\ \ : ${TLA_SN}
    # log.debug    PN SYSTEM\ \ : ${PRODUCT_PN}
    # log.debug    REV SYSTEM\ \ : ${REV}
    # log.debug    FIRST MAC\ \ \ \ \ \ \ \ \ \ : ${MAC}
    # log.debug    **********************************
    # log.debug    ***** CHECK EEPROM COME *****
    # log.debug    COME SN\ \ \ \ \ : ${COME_SN}
    # log.debug    COME PN\ \ \ \ \ : ${COME_PN}
    # log.debug    COME REV\ \ \ \ \ : ${COME_REV}
    # log.debug    **********************************
    # log.debug    **********************************
    # log.debug    ******* CHECK EEPROM SWITCH *******
    # log.debug    SWITCH SN\ \ \ \ \ : ${SWITCH_BOARD_SN}
    # log.debug    SWITCH PN\ \ \ \ \ : ${SWITCH_BOARD_PN}
    # log.debug    SWITCH REV\ \ \ \ \ : ${SWITCH_BOARD_REV}
    # log.debug    **********************************
    # log.debug    ***** CHECK EEPROM FAN_BOARD AND FAN1-7 *****
    # log.debug    FAN_BOARD SN : ${FAN_BOARD_SN}
    # log.debug    FAN_BOARD PN : ${FAN_BOARD_PN}
    # log.debug    FAN1 SN\ \ \ \ \ \ : ${FAN1}
    # log.debug    FAN1 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN2 SN\ \ \ \ \ \ : ${FAN2}
    # log.debug    FAN2 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN3 SN\ \ \ \ \ \ : ${FAN3}
    # log.debug    FAN3 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN4 SN\ \ \ \ \ \ : ${FAN4}
    # log.debug    FAN4 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN5 SN\ \ \ \ \ \ : ${FAN5}
    # log.debug    FAN5 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN6 SN\ \ \ \ \ \ : ${FAN6}
    # log.debug    FAN6 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    FAN7 SN\ \ \ \ \ \ : ${FAN7}
    # log.debug    FAN7 PN\ \ \ \ \ \ : ${Fan_PN}
    # log.debug    **********************************
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # log.debug    ***** COMPARE P/N FAN1 - FAN7 *****
    # log.debug    P/N FAN1 - FAN7 : ${Fan_PN} \ \IS MATCH
    # log.debug    **********************************

Diag_Eeprom_BMC_FRU_Test_1
    @{component_list}=     Create List     bmc  come  switch  system  fan_board  fan1  fan2  fan3  fan4  fan5  fan6  fan7
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${COME_REV}=    Get Substring    ${COME_REV}    0    2
    ${BMC_REV}=    Get Substring    ${BMC_REV}    0    2
    ${SWITCH_BOARD_REV}=    Get Substring    ${SWITCH_BOARD_REV}    0    2
    ${FAN_BOARD_REV}=    Get Substring    ${FAN_BOARD_REV}    0    2
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+383
    # ${BMC_Mac}    Convert To HEX    ${loop_count}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # ${BMC_Mac_count}    Evaluate    12-${Maccount}
    # ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    # ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    # ${Maccount}      Get Length     ${BMC_Mac}
    # log.debug    The last BMC mac is: ${BMC_Mac}\n
    # Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.
    # FOR     ${i}    IN     @{component_list}
    #     ${out_config}               Diag_Telnet_Execute_Command_12              command=cat ${i}.cfg
    #                                 ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    #     ${out_config}               Get Lines Containing String     ${out_config}       =
    #     ${out_config}               Split String                    ${out_config}       \n
    #     Set Suite Variable       ${${i}_config}    ${out_config}
    #     log.debug    ${bmc_config}\n
    # END
    ${bmc_config}               Diag_Telnet_Execute_Command_12              command=cat bmc.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${come_config}              Diag_Telnet_Execute_Command_12              command=cat come.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${switch_config}            Diag_Telnet_Execute_Command_12              command=cat switch.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${system_config}            Diag_Telnet_Execute_Command_12              command=cat system.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan_board_config}          Diag_Telnet_Execute_Command_12              command=cat fan_board.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg

    ${fan1_config}          Diag_Telnet_Execute_Command_12              command=cat fan1.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan2_config}          Diag_Telnet_Execute_Command_12              command=cat fan2.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan3_config}          Diag_Telnet_Execute_Command_12              command=cat fan3.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan4_config}          Diag_Telnet_Execute_Command_12              command=cat fan4.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan5_config}          Diag_Telnet_Execute_Command_12              command=cat fan5.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan6_config}          Diag_Telnet_Execute_Command_12              command=cat fan6.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${fan7_config}          Diag_Telnet_Execute_Command_12              command=cat fan7.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg

    ${bmc_config}               Get Lines Containing String     ${bmc_config}       =
    ${bmc_config}               Split String                    ${bmc_config}       \n
    log.debug    ${bmc_config}\n
    ${come_config}               Get Lines Containing String     ${come_config}       =
    ${come_config}               Split String                    ${come_config}       \n
    log.debug    ${come_config}\n
    ${switch_config}               Get Lines Containing String     ${switch_config}       =
    ${switch_config}               Split String                    ${switch_config}       \n
    log.debug    ${switch_config}\n
    ${system_config}               Get Lines Containing String     ${system_config}       =
    ${system_config}               Split String                    ${system_config}       \n
    log.debug    ${system_config}\n
    ${fan_board_config}               Get Lines Containing String     ${fan_board_config}       =
    ${fan_board_config}               Split String                    ${fan_board_config}       \n
    log.debug    ${fan_board_config}\n
    ${fan1_config}               Get Lines Containing String     ${fan1_config}       =
    ${fan1_config}               Split String                    ${fan1_config}       \n
    log.debug    ${fan1_config}\n
    ${fan2_config}               Get Lines Containing String     ${fan2_config}       =
    ${fan2_config}               Split String                    ${fan2_config}       \n
    log.debug    ${fan2_config}\n
    ${fan3_config}               Get Lines Containing String     ${fan3_config}       =
    ${fan3_config}               Split String                    ${fan3_config}       \n
    log.debug    ${fan3_config}\n
    ${fan4_config}               Get Lines Containing String     ${fan4_config}       =
    ${fan4_config}               Split String                    ${fan4_config}       \n
    log.debug    ${fan4_config}\n
    ${fan5_config}               Get Lines Containing String     ${fan5_config}       =
    ${fan5_config}               Split String                    ${fan5_config}       \n
    log.debug    ${fan5_config}\n
    ${fan6_config}               Get Lines Containing String     ${fan6_config}       =
    ${fan6_config}               Split String                    ${fan6_config}       \n
    log.debug    ${fan6_config}\n
    ${fan7_config}               Get Lines Containing String     ${fan7_config}       =
    ${fan7_config}               Split String                    ${fan7_config}       \n
    log.debug    ${fan7_config}\n
    Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/*.bin
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[2]/product_name=Fan control Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[3]/serial_number=${FAN_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[4]/part_number=${FAN_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${fan_board_config}[5]/board_custom_1=${FAN_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[2]/serial_number=${BMC_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[3]/part_number=${BMC_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[4]/customer_1=${BMC_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[5]/customer_2=${BMC_Mac}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[6]/customer_3=${UUID}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[7]/customer_4=NA/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[8]/product_mfg=Z9332F-ON-BMC/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[9]/product_name=Dell/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[10]/product_part_num=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${bmc_config}[11]/product_ver=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[2]/product_name=Base Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[3]/serial_number=${BASE_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[4]/part_number=${BASE_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[5]/customer_1=Z9332F-ON-baseboard/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[6]/customer_2=${BASE_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[7]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[8]/product_name=Z9332F-ON/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[9]/part_number=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[10]/version=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[11]/serial_number=${TLA_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[12]/customer_3=${Fan_type}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[13]/customer_4=${MAC}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${system_config}[14]/customer_5=384/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[2]/product_name=COMe CPU Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[3]/serial_number=${COME_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[4]/part_number=${COME_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[5]/customer_1=Z9332F-ON_COME/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${come_config}[6]/customer_2=${COME_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[2]/product_name=Switch Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[3]/serial_number=${SWITCH_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[4]/part_number=${SWITCH_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${switch_config}[5]/customer_1=${SWITCH_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg

    # FOR     ${i}    IN RANGE    1   8
    #     EEPROM_FAN    ${i}    ${FAN${i}}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan${i}_config}
    # END

    EEPROM_FAN    1    ${FAN1}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan1_config}
    EEPROM_FAN    2    ${FAN2}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan2_config}
    EEPROM_FAN    3    ${FAN3}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan3_config}
    EEPROM_FAN    4    ${FAN4}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan4_config}
    EEPROM_FAN    5    ${FAN5}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan5_config}
    EEPROM_FAN    6    ${FAN6}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan6_config}
    EEPROM_FAN    7    ${FAN7}    ${Fan_PN}    ${Time_Stamp_test_result}    ${fan7_config}
    sleep    1s
    # FOR     ${i}    IN     @{component_list}
    #     ${var1} =	Set Variable If	'${i}' == 'come'	4096	8192
    #     Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan1.cfg -s ${var1} -a -o bin/${i}.bin
    #     ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # END
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan1.cfg -s 8192 -a -o bin/fan1.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan2.cfg -s 8192 -a -o bin/fan2.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan3.cfg -s 8192 -a -o bin/fan3.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan4.cfg -s 8192 -a -o bin/fan4.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan5.cfg -s 8192 -a -o bin/fan5.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan6.cfg -s 8192 -a -o bin/fan6.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan7.cfg -s 8192 -a -o bin/fan7.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/fan_board.cfg -s 8192 -a -o bin/fan_board.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/come.cfg -s 4096 -a -o bin/come.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/bmc.cfg -s 8192 -a -o bin/bmc.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/switch.cfg -s 8192 -a -o bin/switch.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12            command=./ipmi-fru-it -c fru_cfg/system.cfg -s 8192 -a -o bin/system.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # FOR     ${i}    IN RANGE    0   14
    #     Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 ${i} 0
    # END
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 0 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 1 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 2 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 3 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 4 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 5 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 6 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 7 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 8 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 9 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 10 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 11 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 12 0
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x10 13 0
    # FOR     ${i}    IN     @{component_list}
    #     Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t ${i}
    #     ...                                         expect_string=Passed
    # END
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t bmc
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t system
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t come
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan_board
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t switch
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan1
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan2
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan3
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan4
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan5
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan6
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eeprom-bmc-test -w -t fan7
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12      command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/bin/*.bin

    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                 parse_string=Board Mfg .+: Celestica,Board Product.+: Dell,Board Serial.+: ${BMC_SN},Board Part Number.+${BMC_PN},Board Extra.+: ${BMC_REV},Board Extra.+: ${BMC_Mac},Board Extra.+: ${UUID},Board Extra.+: Z9332F-ON-BMC,Board Extra.+: ${PRODUCT_PN},Board Extra.+: ${REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Base Board,Board Serial.+: ${BASE_BOARD_SN},Board Part Number.+: ${BASE_BOARD_PN},Board Extra.+: Z9332F-ON-baseboard,Board Extra.+: ${BASE_BOARD_REV},Product Manufacturer.+Celestica,Product Name.+: Z9332F-ON,Product Part Number.+: ${PRODUCT_PN},Product Version.+: ${REV},Product Serial.+: ${TLA_SN},Product Extra.+: ${Fan_type},Product Extra.+: ${MAC},Product Extra.+: 384
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                 parse_string=Board Mfg.+Celestica,Board Product.+: COMe CPU Board,Board Serial.+: ${COME_SN},Board Part Number.+: ${COME_PN},Board Extra.+: Z9332F-ON_COME,Board Extra.+: ${COME_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Switch Board,Board Serial.+: ${SWITCH_BOARD_SN},Board Part Number.+: ${SWITCH_BOARD_PN},Board Extra.+: ${SWITCH_BOARD_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan_board
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan control Board,Board Serial.+: ${FAN_BOARD_SN},Board Part Number.+: ${FAN_BOARD_PN},Board Extra.+: ${FAN_BOARD_REV}
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan1
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN1},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan2
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN2},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan3
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN3},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan4
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN4},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan5
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN5},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan6
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN6},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-bmc-test -r -t fan7
    ...                                 parse_string=Board Mfg.+: Celestica,Board Product.+: Fan Board,Board Serial.+: ${FAN7},Board Part Number.+: ${Fan_PN},Board Extra.+: ${Fan_Rev},Board Extra.+: ${Fan_type},Board Extra.+: A00

EEPROM_FAN
    [Arguments]    ${command1}    ${command2}    ${command3}    ${command4}    ${fan_config}
    sleep    2s
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[0]/mfg_datetime=${command4}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[2]/product_name=Fan Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[3]/serial_number=${command2}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[4]/part_number=${command3}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[5]/customer_1=${Fan_Rev}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[6]/customer_2=${Fan_type}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12            command=sed 's/${fan_config}[7]/customer_3=A00/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg

CONVERT_FAN_PN 
    ${length1}=    Get length   ${Fan_PN}
    ${length2}=    Get length   ${Fan_PN}
    ${length3}=    Get length   ${Fan_PN}
    ${length4}=    Get length   ${Fan_PN}
    ${length5}=    Get length   ${Fan_PN}
    ${length6}=    Get length   ${Fan_PN}
    ${length7}=    Get length   ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length1} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length2} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length3} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length4} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length5} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length6} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Variable if    ${length7} == 5    0${Fan_PN}    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}
    ${Fan_PN}    Set Global Variable    ${Fan_PN}      

Diag_CPLD_and_FPGA_access_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-test --all
    ...                                 expect_string=cpld test all: Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-test -w -d 2 -R 1 -D 1
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-test -r -d 1 -R 1
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-test -l

Diag_FAN_CPLD_access_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -w -R 2 -D 0x10
    ...                                         expect_string=write Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -r -R 1
    ...                                         expect_string=read Passed
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x01 0x00
    sleep    1s
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x00
    ...                                         expect_string=00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test --all
    ...                                         expect_string=cpld test all: Passed
    ...                                         unexpect_string=Failed
    sleep    1s
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x01 0x01
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x00
    ...                                         expect_string=01
    sleep    5s

Diag_QSFP_Control_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sfp-test --all
    ...                                 expect_string=OPT testall: Passed

Diag_SFP_and_QSFP_EEPROM_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-qsfp-test --all
    ...                                 unexpect_string=absent,Absent
    ...                                 parse_string=qsfp 1.+Present,qsfp 2.+Present,qsfp 3.+Present,qsfp 4.+Present,qsfp 5.+Present,qsfp 6.+Present,qsfp 7.+Present,qsfp 8.+Present,qsfp 9.+Present,qsfp10.+Present,qsfp11.+Present,qsfp12.+Present,qsfp13.+Present,qsfp14.+Present,qsfp15.+Present,qsfp16.+Present,qsfp17.+Present,qsfp18.+Present,qsfp19.+Present,qsfp20.+Present,qsfp21.+Present,qsfp22.+Present,qsfp23.+Present,qsfp24.+Present,qsfp25.+Present,qsfp26.+Present,qsfp27.+Present,qsfp28.+Present,qsfp29.+Present,qsfp30.+Present,qsfp31.+Present,qsfp32.+Present

Diag_PSU_All_Test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-psu-test --all
    ...                                 expect_string=Psu test : Passed

Diag_PSU_test
    # Diag_Telnet_Execute_Command         command=ipmitest power on
    # ...                                 wait_for=#
    Diag_Telnet_Execute_Command         command=ipmitest sdr elist | grep _Status
    ...                                 parse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected,PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                 wait_for=#
    Swap_COME
    Diag_Telnet_Execute_Command_12            command=./bin/cel-psu-test --all
    ...                                 expect_string=Psu test : Passed
    ${output1}                          Diag_Telnet_Execute_Command_12            command=ipmitool fru print 3
    ${output2}                          Diag_Telnet_Execute_Command_12            command=ipmitool fru print 4
    ${out_psu1_1}=                      Get Lines Containing String    ${output1}    Board Part Number
    ${out_psu2_1}=                      Get Lines Containing String    ${output2}    Board Part Number
    log.debug                           *************************************
    log.debug                           ***** COMPARE P/N PSU1 AND PSU2 *****
    log.debug                           PSU1 ${out_psu1_1} \n
    log.debug                           PSU2 ${out_psu2_1} \n
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${out_psu1_1}    ${out_psu2_1}
    Run Keyword If                      '${status}' == 'FAIL'    FAIL     Board Part Number PSU1 != PSU2
    log.debug                           PSU1 AND PSU2 P/N IS MATCH\n
    log.debug                           *************************************
    log.debug                           ***** CHECKED ALL PSU1 and PSU2 *****

Diag_PSU_test_1
    Swap_BMC
    # Diag_Telnet_Execute_Command         command=ipmitest power on
    # ...                                 wait_for=#
    Diag_Telnet_Execute_Command               command=ipmitest sdr elist | grep _Status
    ...                                       parse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected,PSU2_Status.+39h.+ok.+10.2
    ...                                       unparse_string=PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                       wait_for=#

Diag_PSU_test_2
    # Diag_Telnet_Execute_Command         command=ipmitest power on
    # ...                                 wait_for=#
    Diag_Telnet_Execute_Command               command=ipmitest sdr elist | grep _Status
    ...                                       parse_string=PSU1_Status.+2Fh.+ok.+10.1,PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                       unparse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected
    ...                                       wait_for=#

Diag_Temperature_CPU_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-temp-test --all
    ...                                       expect_string=Temp test all --> Passed

Diag_Temperature_BMC_test
    Sleep    3S
    Diag_Telnet_Execute_Command_12            command=./bin/cel-temp-bmc-test -r --all
    ...                                       expect_string=Read sensor temp : Passed

Diag_RTC_Access_Test
    ## Get UTC Time## date +'%Y%m%d %H%M%S'
    Diag_Telnet_Execute_Command_12            command=./bin/cel-rtc-test --all
    ...                                       expect_string=RTC test : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-rtc-test -r
    START_SSH_Get_RTC
    Diag_Telnet_Execute_Command_12            command=./bin/cel-rtc-test -w -D '${RTC_GET}'
    ...                                       expect_string=successfully
    Diag_Telnet_Execute_Command_12            command=./bin/cel-rtc-test -r
    Diag_Login_And_Connect
    START_SSH_Compare_RTC

Diag_Memory_Test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-mem-test --all
    ...                                       expect_string=MEM test: Passed

Diag_Fan_Speed_Test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test --all
    ...                                       expect_string=Fan Test all Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -S -d 1 -D 20
    ...                                       expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -S -d 1 -D 50
    ...                                       expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -S -d 1 -D 100
    ...                                       expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -S -d 1 -D 50
    ...                                       expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 1
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 2
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 3
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 4
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 5
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 6
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 7
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 8
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 9
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 10
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 11
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 12
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 13
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 14
    ...                                       expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-fan-test -r -d 15
    ...                                       expect_string=Read \ fan \ Passed
    
Diag_PCIe_test 
    Diag_Telnet_Execute_Command_12            command=./bin/cel-pci-test --all
    ...                                       expect_string=PCIe test : Passed

Diag_CPU_Test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpu-test --all
    ...                                       expect_string=CPU test : Passed

Diag_TPM_Test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-tpm-test -all
    ...                                       expect_string=TPM test all Passed

Diag_SOL_functional_test
    Swap_BMC
    sleep  5
    Diag_Telnet_Execute_BMC                   command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC                   command=ifconfig
    ...                                       wait_for=${BMC_IP_2}
    sleep  20
    START_SSH_server    ${USERNAME_SSH_server}    ${PASSWORD_SSH_server}
    log.debug    sending command --> ipmitool -I lanplus -H ${BMC_IP_2} -U admin -P admin sol activate
    ${output}=    SSHLibrary.Write    ipmitool -I lanplus -H ${BMC_IP_2} -U admin -P admin sol activate
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    SOL Session operational
    Save_to_logs       ${output}\r
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    log.debug      ----------------------------------------------------------------------------\n
    log.debug      Found SOL Session operational\r
    log.debug      **** PASSED ****\r
    log.debug      ----------------------------------------------------------------------------\n
    ${output}=    SSHLibrary.Write   ~.
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    \$
    Save_to_logs       ${output}\r
    Swap_COME

Diag_CPU_information_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpu-test --all
    ...                                       expect_string=CPU test : Passed

Diag_Uart_MUX_test
    Swap_BMC
    Swap_COME
    
Diag_Uart_internal_test
    Diag_SSH_Execute_Command                  command=./bin/cel-uart-test --all
    ...                                       expect_string=Uart Test : PASSED
    Diag_SSH_Execute_Command                  command=./bin/cel-uart-test -w -d 1 -t cfg -D "115200 8 0 e"
    ...                                       expect_string=Passed
    Diag_SSH_Execute_Command                  command=./bin/cel-uart-test -r -d 1 -t cfg
    ...                                       expect_string=Passed
    Diag_Login_And_Connect

Diag_Sata_SSD_Test
    MtEcho_usb_plug
    log.debug    \n*************** USB has been pluged ***************\r
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                       expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -t --all
    ...                                       expect_string=SSD test : Passed
    Diag_Telnet_Execute_Command_12            command=smartctl -a /dev/sda
    ...                                       expect_string=result: PASSED,${Firmware_Version.SSD_FW_Version}

Diag_Sata_SSD_Test_BI
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                       expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -t --all
    ...                                       expect_string=SSD test : Passed
    Diag_Telnet_Execute_Command_12            command=smartctl -a /dev/sda
    ...                                       expect_string=result: PASSED,${Firmware_Version.SSD_FW_Version}

Diag_cpld_test_with_bmc
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-ipmi-test --all
    ...                                       expect_string=cpld test all : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-ipmi-test -r -t 1 -R 1 
    ...                                       parse_string=${CPLD_Version}
    ...                                       unparse_string=FAIL
    Diag_Telnet_Execute_Command_12            command=./bin/cel-cpld-ipmi-test -w -t 1 -R 27 -D 0
    ...                                       parse_string=software_scratch.*0x01.*0x00
    ...                                       unparse_string=FAIL

Diag_Storage_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test --all
    ...                                       expect_string=Storage test : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -w -d 2 -C 2
    ...                                       expect_string=Storage write data : Passed
    # Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -r -d 2 -C 2
    # ...                                 expect_string=Storage read data : Passed
    MtEcho_usb_remove
    log.debug    \n*************** USB has been removed ***************\r

Diag_Storage_test_BI
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test --all
    ...                                       expect_string=Storage test : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                       expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-storage-test -r -d 1 -C 10
    ...                                       expect_string=Storage read data : Passed

Diag_PHY_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-phy-test --all 
    ...                                       expect_string=PHY test : Passed

Diag_Present_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-present-ipmi-test --all
    ...                                       expect_string=Fan Present test : Passed

Diag_BMC_I2C_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-i2c-bmc-test -s --all
    ...                                       expect_string=I2C BMC test : Passed
    ...                                       time_out=300
    Diag_Telnet_Execute_Command_12            command=./bin/cel-i2c-bmc-test -r -p /dev/i2c-8 -A 0x0d -R 0x32 -C 1
    ...                                       expect_string=I2C BMC read:Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-i2c-bmc-test -w -p /dev/i2c-8 -A 0x0d -R 0x32 -D 0x20 -C 1
    ...                                       expect_string=I2C BMC write:Passed

Diag_CPU_I2C_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-i2c-test --all
    ...                                       expect_string=I2C test : Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-i2c-test -s --bus 0

Diag_Sysinfo_test
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test --all
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 1
    ...                                       expect_string=${Firmware_Version.Bios_Version}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 2
    ...                                       expect_string=${Firmware_Version.FPGA_Version}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 3
    ...                                       expect_string=${Firmware_Version.CPLD_Base_Board}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 4
    ...                                       expect_string=${Firmware_Version.CPLD_Switch1}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 5
    ...                                       expect_string=${Firmware_Version.CPLD_Switch2}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 6
    ...                                       expect_string=${Firmware_Version.CPLD_ComE}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 7
    ...                                       expect_string=${Firmware_Version.CPLD_Fan_Board2}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 8
    ...                                       expect_string=${Firmware_Version.BMC2_Version}
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sysinfo-test -d 9
    ...                                       expect_string=${Firmware_Version.BMC2_Version}
    
Diag_Sensor_test
    Diag_Telnet_Execute_Command_12            command=ipmitool sensor
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sensor-ipmi-test --all
    # ...                                 expect_string=Sensor test : Passed
    ...                                       time_out=600

Diag_Sensor_test_BI
    Diag_Telnet_Execute_Command_12            command=ipmitool sensor
    Diag_Telnet_Execute_Command_12            command=./bin/cel-sensor-ipmi-test --all
    # ...                                     expect_string=Sensor test : Passed
    ...                                       time_out=600

Diag_ETH_test 
    Diag_Telnet_Execute_Command_12            command=sed 's/"10.194.78.83"/"${SSH_IP}"/g' -i /home/cel_diag/midstone100X/diag_configs/eth.yaml
    Diag_Telnet_Execute_Command_12            command=./bin/cel-eth-test --all
    ...                                       expect_string=ETH test : Passed
    Diag_Telnet_Execute_Command_12            command=sed 's/"${SSH_IP}"/"10.194.78.83"/g' -i /home/cel_diag/midstone100X/diag_configs/eth.yaml

    ${status}   ${output}=  Run Keyword And Ignore Error    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    sleep    10
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    TELNET_OPEN     ${time_out}
    Telnet.Write    ifconfig eth0 "${BMC_IP_2}" up
    ${stdout} =      Telnet.Read Until               \#
    ${stdout} =      Telnet.Read Until               \#
    ${stdout} =      Telnet.Read Until               \#
    Save_to_logs    msg=${stdout}
    Telnet.Write    ping "${local_host_ip}" -c5
    ${stdout} =      Telnet.Read Until               \#
    ${stdout} =      Telnet.Read Until               \#
    Save_to_logs    msg=${stdout}
    Should Contain    ${stdout}     5 received
    TELNET_CLOSE
    sleep  30
    Swap_COME
   
    Diag_Telnet_Execute_Command_12            command=cat eth.yaml
    ...                                       path=/home/cel_diag/midstone100X/diag_configs
    ...                                       expect_string=10.194.78.83

Diag_BACKUP_BIOS_BOOT_UP_testcase
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x05 0x01 0x04
    Command_Power_Cyling_2                    ipmitool power cycle
    Diag_Telnet_Execute_Command_12            command=ipmitool raw 0x3a 0x0b 1
    Diag_Telnet_Execute_Command_12            command=ipmitool sensor | grep SW_VDD_CORE
    Diag_Login_And_Connect



Diag_SHOW_SENSOR_testcase
    sleep    10s
    @{search_list}=     Create List     TEMP_FAN_U52  TEMP_FAN_U17  TEMP_SW_U52  TEMP_SW_U16  TEMP_BB_U3  TEMP_CPU  TEMP_SW_Internal 
    ...                                 PowerStatus  PSU1_Status  PSU2_Status
    ...                                 Fan1_Status  Fan2_Status  Fan3_Status  Fan4_Status  Fan5_Status  Fan6_Status  Fan7_Status    
    ...                                 Fan1_Front  Fan2_Front  Fan3_Front  Fan4_Front  Fan5_Front  Fan6_Front  Fan7_Front  
    ...                                 Fan1_Rear  Fan2_Rear  Fan3_Rear  Fan4_Rear  Fan5_Rear  Fan6_Rear  Fan7_Rear 
    ...                                 PSU1_Fan  PSU2_Fan  
    ...                                 BMC_XP3R3V  BMC_XP2R5V  BMC_XP1R2V  BMC_XP1R15V
    ...                                 BB_XP12R0V  BB_XP5R0V     
    ...                                 COME_XP3R3V  COME_XP1R82V  COME_XP1R05V  COME_XP1R7V  COME_XP1R2V  COME_XP1R3V  COME_XP1R5V  COME_XP2R5V
    ...                                 SW_XP3R3V_EARLY  SW_VDD_CORE  SW_XP0R8V  SW_XP3R3V_R  SW_XP3R3V_L  SW_XP1R8V  SW_XP1R2V  SW_XP1R0V_FPGA  SW_XP1R2V_FPGA  SW_XP1R8V_FPGA  SW_XP3R3V  SW_PVDD0P8
    ...                                 PSU1_VIn  PSU1_CIn  PSU1_PIn  PSU1_Temp1  PSU1_Temp2  PSU1_VOut  PSU1_COut  PSU1_POut
    ...                                 PSU2_VIn  PSU2_CIn  PSU2_PIn  PSU2_Temp1  PSU2_Temp2  PSU2_VOut  PSU2_COut  PSU2_POut
    ...                                 SW_U04_VIn  SW_U04_CIn  SW_U04_PIn  SW_U04_VOut  SW_U04_COut  SW_U04_POut  SW_U04_Temp  SW_U14_VIn  SW_U14_CIn  SW_U14_PIn  SW_U14_VOut  SW_U14_COut  SW_U14_POut  SW_U14_Temp
    ...                                 SW_U4403_VIn1  SW_U4403_CIn1  SW_U4403_PIn1  SW_U4403_VOut1  SW_U4403_COut1  SW_U4403_POut1  SW_U4403_Temp 
    ...                                 SEL  Watchdog2

    ${recbuf}=    Diag_Telnet_Execute_Command_12    command=ipmitool sensor
    log.debug     Limit String is ${space}${space} ${space} = any string should not 'na'or'cr' is passed
    FOR  ${i}  IN   @{search_list}
        ${val}=   Get Lines Containing String   ${recbuf}   ${i} 
        ${val2}=  Split String   ${val}    |
        ${val3}=  Strip String   ${val2}[3]
        Verify_None_NA_String_Found   ${val3}   ${i}
    END

Diag_SHOW_SENSOR_testcase_BI
    sleep    60s
    log.debug     sleep 60s
    @{search_list}=     Create List     TEMP_FAN_U52  TEMP_FAN_U17  TEMP_SW_U52  TEMP_SW_U16  TEMP_BB_U3  TEMP_CPU  TEMP_SW_Internal 
    ...                                 PowerStatus  PSU1_Status  PSU2_Status
    ...                                 Fan1_Status  Fan2_Status  Fan3_Status  Fan4_Status  Fan5_Status  Fan6_Status  Fan7_Status    
    ...                                 Fan1_Front  Fan2_Front  Fan3_Front  Fan4_Front  Fan5_Front  Fan6_Front  Fan7_Front  
    ...                                 Fan1_Rear  Fan2_Rear  Fan3_Rear  Fan4_Rear  Fan5_Rear  Fan6_Rear  Fan7_Rear 
    ...                                 PSU1_Fan  PSU2_Fan  
    ...                                 BMC_XP3R3V  BMC_XP2R5V  BMC_XP1R2V  BMC_XP1R15V
    ...                                 BB_XP12R0V  BB_XP5R0V     
    ...                                 COME_XP3R3V  COME_XP1R82V  COME_XP1R05V  COME_XP1R7V  COME_XP1R2V  COME_XP1R3V  COME_XP1R5V  COME_XP2R5V
    ...                                 SW_XP3R3V_EARLY  SW_VDD_CORE  SW_XP0R8V  SW_XP3R3V_R  SW_XP3R3V_L  SW_XP1R8V  SW_XP1R2V  SW_XP1R0V_FPGA  SW_XP1R2V_FPGA  SW_XP1R8V_FPGA  SW_XP3R3V  SW_PVDD0P8
    ...                                 PSU1_VIn  PSU1_CIn  PSU1_PIn  PSU1_Temp1  PSU1_Temp2  PSU1_VOut  PSU1_COut  PSU1_POut
    ...                                 PSU2_VIn  PSU2_CIn  PSU2_PIn  PSU2_Temp1  PSU2_Temp2  PSU2_VOut  PSU2_COut  PSU2_POut
    ...                                 SW_U04_VIn  SW_U04_CIn  SW_U04_PIn  SW_U04_VOut  SW_U04_COut  SW_U04_POut  SW_U04_Temp  SW_U14_VIn  SW_U14_CIn  SW_U14_PIn  SW_U14_VOut  SW_U14_COut  SW_U14_POut  SW_U14_Temp
    ...                                 SW_U4403_VIn1  SW_U4403_CIn1  SW_U4403_PIn1  SW_U4403_VOut1  SW_U4403_COut1  SW_U4403_POut1  SW_U4403_Temp 
    ...                                 SEL  Watchdog2

    ${recbuf}=    Diag_Telnet_Execute_Command_12    command=ipmitool sensor
    log.debug     Limit String is ${space}${space} ${space} = any string should not 'na'or'cr' is passed
    FOR  ${i}  IN   @{search_list}
        ${val}=   Get Lines Containing String   ${recbuf}   ${i} 
        ${val2}=  Split String   ${val}    |
        ${val3}=  Strip String   ${val2}[3]
        Run Keyword If    '${i}' == 'PSU1_Temp1'    Verify_None_NA_String_Found_BI   ${val3}   ${i}
        ...    ELSE IF    '${i}' == 'PSU2_Temp1'    Verify_None_NA_String_Found_BI   ${val3}   ${i}
        ...       ELSE    Verify_None_NA_String_Found   ${val3}   ${i}
        # Verify_None_NA_String_Found   ${val3}   ${i}
    END

Verify_None_NA_String_Found 
    [Arguments]    ${std_val}    ${name}
    log.debug     Verify limit name ${space}${space} = ${name}
    log.debug     UUT actual value ${space}${space} ${space}= '${std_val}'
    ${cap_val} =   Convert To String  ${std_val}
    ${verify_result}   ${std_out}=    Run Keyword And Ignore Error   Should Not Be Equal As Strings    ${cap_val}   na
    Run Keyword If    '${verify_result}' == 'FAIL'    VERIFY LIMIT FAIL : ${name} = na
    ${verify_result}   ${std_out}=    Run Keyword And Ignore Error   Should Not Be Equal As Strings    ${cap_val}   cr
    Run Keyword If    '${verify_result}' == 'FAIL'    VERIFY LIMIT FAIL : ${name} = cr
    log.debug     Limit verify ${space} ${space} ${space} ${space} = !!! ${space} P A S S E D ${space} !!!\r

Verify_None_NA_String_Found_BI
    [Arguments]    ${std_val}    ${name}
    log.debug     Verify limit name ${space}${space} = ${name}
    log.debug     UUT actual value ${space}${space} ${space}= '${std_val}'
    ${cap_val} =   Convert To String  ${std_val}
    ${verify_result}   ${std_out}=    Run Keyword And Ignore Error   Should Not Be Equal As Strings    ${cap_val}   na
    Run Keyword If    '${verify_result}' == 'FAIL'    VERIFY LIMIT FAIL : ${name} = na
    ${verify_result}   ${std_out}=    Run Keyword And Ignore Error   Should Not Be Equal As Strings    ${cap_val}   cr
    Run Keyword If    '${verify_result}' == 'FAIL'    log.debug     Limit verify = !!! Accepting Error !!!\n
    ${verify_result}   ${std_out}=    Run Keyword And Ignore Error   Should Not Be Equal As Strings    ${cap_val}   ok
    Run Keyword If    '${verify_result}' == 'FAIL'    log.debug     Limit verify = !!! P A S S E D !!!\n
    # log.debug     Limit verify ${space} ${space} ${space} ${space} = !!! ${space} P A S S E D ${space} !!!\r


Diag_SDK_Function_Test_BI
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    Diag_Telnet_Execute_Command_12      command=md5sum pcieg3fw.bin
    ...                                 path=/home/cel_sdk/silverstone
    ...                                 expect_string=c09945e3537cc0027f7d9730338e8a04
    TELNET_Send_Command_expect_prompt    ./auto_load_user.sh    BCM.0>

Diag_SDK_Function_Test
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/IMG_R1141-F9019-01_R01_Mtecho_Ebay_B2F/pcieg3fw.bin /home/cel_sdk/silverstone    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    Diag_Telnet_Execute_Command_12      command=md5sum pcieg3fw.bin
    ...                                 path=/home/cel_sdk/silverstone
    ...                                 expect_string=c09945e3537cc0027f7d9730338e8a04
    TELNET_Send_Command_expect_prompt    ./auto_load_user.sh    BCM.0>
    
Diag_Check_SDK_Version_Test
    ${output}=    SSH_Send_traffic    version
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    ${SDK_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Version SDK Mismatch with ${SDK_Version}
    log.debug    \n*************** Version SDK check ${SDK_Version} PASSED ***************\r

Diag_TH3_Firmware_Version_Check
    ${output1}=    SSH_Send_traffic    pciephy fw version
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    ${Firmware_Version.PCIE1_FW_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Version Firmware Mismatch with ${Firmware_Version.PCIE1_FW_Version}
    log.debug    \n*************** Version Firmware check ${Firmware_Version.PCIE1_FW_Version} PASSED ***************\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    ${Firmware_Version.PCIE2_FW_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Version Firmware Mismatch with ${Firmware_Version.PCIE2_FW_Version}
    log.debug    \n*************** Version Firmware check ${Firmware_Version.PCIE2_FW_Version} PASSED ***************\r

Diag_SDK_Link_up_Check
    # SSH_Send_traffic    phy control cd lt=1
    SSH_Send_traffic    sleep 60    100s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r

Diag_SDK_Link_up_Check_BI
    SSH_Send_traffic    phy control cd0 lt=1
    SSH_Send_traffic    sleep 60    100s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r


MtEcho_Link_retry
    MtEcho_traffic_retry
	FOR     ${i}    IN RANGE    10
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END

Diag_Snake_Traffic_External_Test_BI
    Util_Test_Execution         test_case=TG_Port_Start
    ...                         retry_loop=5
    SSH_Send_traffic    phy control cd lt=1
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r
    # MtEcho_TGplug
    Util_Test_Execution         test_case=TG_Port_Stop
    ...                         retry_loop=5
    log.debug    \n*************** UUT FRONT LED confirmed BLUE ***************\r  
    Set Global Variable    ${traffic_passflag}    passed
    SSH_Send_traffic    clear c
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r
    Util_Test_Execution         test_case=TG_Port_Start
    ...                         retry_loop=5
    SSH_Send_traffic    sleep 900    950s
    SSH_Send_traffic    sleep 900    950s
    SSH_Send_traffic    sleep 900    950s
    SSH_Send_traffic    sleep 900    950s
    SSH_Send_traffic    sleep 900    950s
    SSH_Send_traffic    sleep 700    750s
    Util_Test_Execution         test_case=TG_Port_Stop
    ...                         retry_loop=5
    sleep    5s
    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug   RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset  
    log.debug    ******* result of traffic test is ${traffic_passflag} ******** \n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${traffic_passflag}    passed
    Run Keyword If     '${status}' == 'FAIL'    FAIL    !! Snake Traffic test fail !!
    # MtEcho_TGremove
    sleep    30s

Diag_Snake_Traffic_External_Test
    Util_Test_Execution         test_case=TG_Port_Start
    ...                         retry_loop=5
    SSH_Send_traffic    phy control cd lt=1
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r
    MtEcho_TGplug
    Util_Test_Execution         test_case=TG_Port_Stop
    ...                         retry_loop=5
    log.debug    \n*************** UUT FRONT LED confirmed BLUE ***************\r  
    Set Global Variable    ${traffic_passflag}    passed
    SSH_Send_traffic    clear c
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r
    Util_Test_Execution         test_case=TG_Port_Start
    ...                         retry_loop=5
    SSH_Send_traffic    sleep 300    400s
    SSH_Send_traffic    sleep 300    400s
    SSH_Send_traffic    sleep 300    400s
    Util_Test_Execution         test_case=TG_Port_Stop
    ...                         retry_loop=5
    sleep    5s
    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug   RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset  
    log.debug    ******* result of traffic test is ${traffic_passflag} ******** \n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${traffic_passflag}    passed
    Run Keyword If     '${status}' == 'FAIL'    FAIL    !! Snake Traffic test fail !!
    MtEcho_TGremove
    sleep    30s

Snake_rfcs_traffic_passflagset 
    [Arguments]         
    Set Global Variable    ${traffic_passflag}    failed
    log.debug    RSCF CHECK *********************** result failed \n       

Snake_traffic_passflagset 
    [Arguments]    ${i}    ${j}    ${rp1}    ${tp1}      
    Set Global Variable    ${traffic_passflag}    failed
    log.debug    compair_cd${i} RP${j}value ${rp1}==TP${j}value ${tp1} *********************** result failed \n      

Diag_Snake_traffic_Internal_test
    Set Global Variable    ${traffic_passflag}    passed 
    SSH_Send_traffic    clear c
    ${console}=    SSH_Send_traffic    ps cd
    Should Contain X Times    ${console}    up    33 
    SSH_Send_traffic    vlan clear
    SSH_Send_traffic    vlan remove 1 pbm=all
    SSH_Send_traffic    for i=0,30 'expr $i+1; vlan create 4$i pbm=cd$i-cd$? ubm=cd$i-cd$?'
    SSH_Send_traffic    vlan create 431 pbm=cd31,cd0 ubm=cd31,cd0
    SSH_Send_traffic    for i=0,31 'pvlan set cd$i 4$i'
    SSH_Send_traffic    for i=0,30 'expr $i+1; l2 add Port=cd$? MACaddress=0x2 Vlanid=4$i'
    SSH_Send_traffic    l2 add Port=cd0 MACaddress=0x2 Vlanid=431
    SSH_Send_traffic    tx 10000 U=true PBM=cd0 UBM=cd L=295 SM=0x1 DM=0x2;
    SSH_Send_traffic    sleep 210    300s
    SSH_Send_traffic    port cd0 en=0
    SSH_Send_traffic    port cd0 en=1
    sleep    10s
    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug    RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset  
    log.debug    ******* result of traffic test is ${traffic_passflag} ******** \n

Snake_traffic_test_retry
    [Arguments]    ${loop} 
    MtEcho_traffic_retry
    Set Global Variable    ${traffic_passflag}    passed 
    SSH_Send_traffic    \r    
    SSH_Send_traffic    clear c
    ${console}=    SSH_Send_traffic    ps cd
    Should Contain X Times    ${console}    up    33 
    SSH_Send_traffic    vlan clear
    SSH_Send_traffic    vlan remove 1 pbm=all
    SSH_Send_traffic    for i=0,30 'expr $i+1; vlan create 4$i pbm=cd$i-cd$? ubm=cd$i-cd$?'
    SSH_Send_traffic    vlan create 431 pbm=cd31,cd0 ubm=cd31,cd0
    SSH_Send_traffic    for i=0,31 'pvlan set cd$i 4$i'
    SSH_Send_traffic    for i=0,30 'expr $i+1; l2 add Port=cd$? MACaddress=0x2 Vlanid=4$i'
    SSH_Send_traffic    l2 add Port=cd0 MACaddress=0x2 Vlanid=431
    SSH_Send_traffic    tx 10000 U=true PBM=cd0 UBM=cd L=295 SM=0x1 DM=0x2;
    SSH_Send_traffic    sleep 210
    SSH_Send_traffic    port cd0 en=0
    SSH_Send_traffic    port cd0 en=1
    sleep    10s
    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug    RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset    
    log.debug    ******* result of traffic retry loop ${loop} test is ${traffic_passflag} ******** \n
        
Snake_traffic_check        
    [Arguments]    ${rpkt}    ${tpkt}       
    ${rpkt1}=    Replace String Using Regexp    ${rpkt}    (${space}|\t)    ${empty}
    ${tpkt1}=    Replace String Using Regexp    ${tpkt}    (${space}|\t)    ${empty} 
        FOR    ${i}    IN RANGE    0    32             
            ${rp}=    Get Lines Containing String    ${rpkt1}    cd${i}:
            ${rp}=    Split String    ${rp}    :    
            ${rp}=    Get From List    ${rp}    1
            ${rp}=    Split String    ${rp}    +
            ${rp1}=    Get From List    ${rp}    0
            ${rp2}=    Get From List    ${rp}    1
            ${tp}=    Get Lines Containing String    ${tpkt1}    cd${i}:
            ${tp}=    Split String    ${tp}    :
            ${tp}=    Get From List    ${tp}    1
            ${tp}=    Split String    ${tp}    +
            ${tp1}=    Get From List    ${tp}    0
            ${tp2}=    Get From List    ${tp}    1
            Run Keyword If    '${rp1}' == '${tp1}'    log.debug    compair_cd${i} RP_first__value ${rp1}==TP_first__value ${tp1} result passed \n
            Run Keyword If    '${rp1}' != '${tp1}'    Snake_traffic_passflagset    ${i}    first_    ${rp1}    ${tp1}    
            Run Keyword If    '${rp2}' == '${tp2}'    log.debug    compair_cd${i} RP_second_value ${rp2}==TP_secone_value ${tp2} result passed \n
            Run Keyword If    '${rp2}' != '${tp2}'    Snake_traffic_passflagset    ${i}    second    ${rp2}    ${tp2}    
        END 

Diag_PCIE_FW_Update_Test
    ${console}=         SSH_Send_traffic    pciephy fw load ${PCIE_FW_Name}
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          PCIE firmware updated successfully
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Updated Not Successfully
    ${console}=         SSH_Send_traffic    pciephy fw version
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          ${Firmware_Version.PCIE1_FW_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect ${Firmware_Version.PCIE1_FW_Version}
    log.debug    \n*************** Version Firmware check ${Firmware_Version.PCIE1_FW_Version} PASSED ***************\r
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          ${Firmware_Version.PCIE2_FW_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect ${Firmware_Version.PCIE2_FW_Version}
    log.debug    \n*************** Version Firmware check ${Firmware_Version.PCIE2_FW_Version} PASSED ***************\r

Diag_TH3_Temperature_Test
    ${console}=    SSH_Send_traffic    show temp
    ${line0}=    GET_LINE_CUT    ${console}    maximum    1    is    1
    log.debug    ${line0} \n
    ${value}    Convert To Number    ${line0}
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Be True    ${value} <= 85
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Temperature Over High limit 85c : ====> ${value}c
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Be True    ${value} >= 40
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Temperature Over Low limit 40c : ====> ${value}c
    log.debug    Temp read ${value} in range 40-85C \n

Diag_TH3_Temperature_Test_BI
    ${console}=    SSH_Send_traffic    show temp
    ${line0}=    GET_LINE_CUT    ${console}    maximum    1    is    1
    log.debug    ${line0} \n
    ${value}    Convert To Number    ${line0}
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Be True    ${value} <= 92
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Temperature Over High limit 92c : ====> ${value}c
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Be True    ${value} >= 40
    Run Keyword If     '${status}' == 'FAIL'    FAIL    Temperature Over Low limit 40c : ====> ${value}c
    log.debug    Temp read ${value} in range 40-92C \n

Ber_Test
    [Arguments]    ${value}
    SSH_Send_traffic    phy diag cd prbs set p=3
    SSH_Send_traffic    phy diag cd prbsstat
    SSH_Send_traffic    phy diag cd prbsstat start i=30
    sleep    30s
    SSH_Send_traffic    phy diag cd prbsstat ber
    SSH_Send_traffic    phy diag cd prbsstat clear
    sleep    30s
    ${console}=    SSH_Send_traffic    phy diag cd prbsstat ber
    SSH_Send_traffic    phy diag cd prbsstat stop
    SSH_Send_traffic    phy diag cd prbs clear     
    Should Contain X Times    ${console}    cd    256
    Ber_Verify    ${value}    ${console}  
    log.debug    ******* result of ber check is ${BER_passflag} ******** \n

Ber_Test_retry    
    [Arguments]    ${value}    ${loop}    
    Requires_User_Interaction    MtEcho_ber_retry    MtEcho_ber_retry    990min
    SSH_Send_traffic    phy diag cd prbs set p=3
    SSH_Send_traffic    phy diag cd prbsstat
    SSH_Send_traffic    phy diag cd prbsstat start i=30
    sleep    30s
    SSH_Send_traffic    phy diag cd prbsstat ber
    SSH_Send_traffic    phy diag cd prbsstat clear
    sleep    30s
    ${console}=    SSH_Send_traffic    phy diag cd prbsstat ber
    SSH_Send_traffic    phy diag cd prbsstat stop
    SSH_Send_traffic    phy diag cd prbs clear     
    Should Contain X Times    ${console}    cd    256
    log.debug    ******* Start to run ber re-check ${loop} ******************************************************* \n
    Ber_Verify    ${value}    ${console}  
    log.debug    ******* result of ber re-check is ${BER_passflag} ******** \n

Ber_Verify
    [Arguments]    ${value}    ${logresult}
        Set Global Variable    ${BER_passflag}    passed     
        FOR    ${i}    IN RANGE    0    32
            log.debug    ************* Start to check port cd${i} ************** \n
            Ber_Verify_loop    ${value}    ${logresult}    ${i}                        
        END  
             
Ber_Verify_loop
    [Arguments]    ${value}    ${logresult}    ${i}     
        FOR    ${j}    IN RANGE    0    8             
            ${result}=    GET_LINE_CUT    ${logresult}    cd${i}[${j}    1    :    2
            ${result}=    Strip String    ${result}
            Run Keyword If    ${result} <= ${value}    log.debug    cd${i}[${j} =${result} result passed \n
            Run Keyword If    ${result} > ${value}    Ber_passflagset    ${i}    ${j}    ${result}                
        END   
                
Ber_passflagset 
    [Arguments]    ${i}    ${j}    ${result}  
    Set Global Variable    ${BER_passflag}    failed
    log.debug    cd${i}[${j} =${result} result failed ****** failed ****** \n   

Diag_Port_Enable_Disable_Stress_Test
    FOR    ${i}    IN RANGE    0    32
            SSH_Send_traffic    port cd${i} en=0
    END   
            SSH_Send_traffic    port xe0 en=0
            SSH_Send_traffic    port xe1 en=0
    sleep    15s
    ${console}=    SSH_Send_traffic    ps
    Should Contain X Times    ${console}    !ena    34
    
    FOR    ${i}    IN RANGE    0    32
            SSH_Send_traffic    port cd${i} en=1
    END   
            SSH_Send_traffic    port xe0 en=1
            SSH_Send_traffic    port xe1 en=1
    sleep    15s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    35
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    log.debug    \n*************** Check link UP PASSED ***************\r


Diag_Loopback_Config_Test
    Set Global Variable    ${traffic_passflag}    passed
    SSH_Send_traffic    port cd lb=mac
    SSH_Send_traffic    vlan clear
    SSH_Send_traffic    vlan remove 1 pbm=all
    SSH_Send_traffic    for i=0,30 'expr $i+1; vlan create 4$i pbm=cd$i-cd$? ubm=cd$i-cd$?'
    SSH_Send_traffic    vlan create 431 pbm=cd31,cd0 ubm=cd31,cd0
    SSH_Send_traffic    for i=0,31 'pvlan set cd$i 4$i'
    SSH_Send_traffic    for i=0,30 'expr $i+1; l2 add Port=cd$? MACaddress=0x2 Vlanid=4$i'
    SSH_Send_traffic    l2 add Port=cd0 MACaddress=0x2 Vlanid=431
    SSH_Send_traffic    tx 10000 U=true PBM=cd0 UBM=cd L=295 SM=0x1 DM=0x2;
    SSH_Send_traffic    sleep 210s
    SSH_Send_traffic    port cd0 en=0
    SSH_Send_traffic    port cd0 en=1
    sleep    5s

    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug    RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset 
    Should Contain    ${traffic_passflag}    passed 
         
    SSH_Send_traffic    port cd lb=mac
    SSH_Send_traffic    clear c
    SSH_Send_traffic    ps cd
    SSH_Send_traffic    tx 10000 U=true PBM=cd0 UBM=cd L=295 SM=0x1 DM=0x2;
    SSH_Send_traffic    sleep 210s
    SSH_Send_traffic    port cd0 en=0
    SSH_Send_traffic    port cd0 en=1
    sleep    5s    
    ${rpkt}=    SSH_Send_traffic    show c CDMIB_RPKT.cd0-cd31
    ${tpkt}=    SSH_Send_traffic    show c CDMIB_TPKT.cd0-cd31
    ${rfcs}=    SSH_Send_traffic    show c CDMIB_RFCS
    Snake_traffic_check     ${rpkt}    ${tpkt}
    ${rfcs1}=    Replace String Using Regexp    ${rfcs}    (${space}|\t|\r|\n)    ${empty} 
    Run Keyword If    '${rfcs1}' == 'BCM.0>'    log.debug    RSCF CHECK *********************** result pass \n 
    Run Keyword If    '${rfcs1}' != 'BCM.0>'    Snake_rfcs_traffic_passflagset 
    Should Contain    ${traffic_passflag}    passed    

Diag_PCIE_DMA_Stress_Test
    SSH_Send_traffic    l2learn off
    SSH_Send_traffic    memscan off
    SSH_Send_traffic    sramscan off
    SSH_Send_traffic    l2mode off
    SSH_Send_traffic    counter off
    SSH_Send_traffic    tr 506 WrChanBitmap=0x1F0 RdChanBitmap=0xF Seconds=10
    sleep    10s
    SSH_Send_traffic    tr 506
    sleep    60s
    ${console}=    SSH_Send_traffic    tl 506
    ${runcount}=    GET_LINE_CUT    ${console}    SBUS    4    |    7
    ${passcount}=    GET_LINE_CUT    ${console}    SBUS    5    |    7
    ${failcount}=    GET_LINE_CUT    ${console}    SBUS    6    |    7      
    ${value}    Strip String    ${failcount}
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Be True    ${runcount} == ${passcount}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    SBUS DMA stress test Failed Run Count ${runcount} != Pass Count ${passcount}
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Be True    ${value} == 0
    Run Keyword If     '${status}' == 'FAIL'    FAIL    SBUS DMA stress test Fail Count != 0
    log.debug    *************runcount = passcount = ${passcount} result pass************* \n
    log.debug    *************failcount =${failcount} result pass*************** \n
    SSH_Send_Diag    exit
    SSH_Send_Diag    \r
    SSH_Send_Diag    cd /home/cel_diag/silverstone  
    
GET_LINE_CUT
    [Arguments]    ${string}    ${getstring}    ${index}    ${separator}    ${split}
    ${var1}=    Get Lines Containing String    ${string}    ${getstring}
    ${var2}=    Split String    ${var1}    ${separator}    ${split}
    ${var3}=    Get From List    ${var2}    ${index}
    [Return]    ${var3}

Diag_ONIE_MANAGEMENT_PORT_test
    Diag_Telnet_ONIE_Command            command=ifconfig eth0 ${SSH_IP} up
    Diag_Telnet_ONIE_Command            command=ping ${SSH_IP} -c 5
    ...                                 expect_string=5 packets received

Diag_ONIE_SSD_PARTITION_Test
    Diag_Telnet_ONIE_Command            command=parted /dev/sda
    ...                                 wait_for=(parted)
    Diag_Telnet_ONIE_Command            command=p
    ...                                 wait_for=(parted)
    Diag_Telnet_ONIE_Command            command=q

Diag_ONIE_Version_Check
    Diag_Telnet_ONIE_Command            command=onie-sysinfo -v
    ...                                 expect_string=${Firmware_Version.ONIE_Version}

Diag_ONIE_Boot_Order_Check
    Diag_Telnet_ONIE_Command            command=efibootmgr

Diag_ONIE_SSD_Version_Check
    Diag_Telnet_ONIE_Command            command=dmesg | grep 3IE4 | sed -n '1p' | cut -d ',' -f2 | sed "s/ //g"
    ...                                 expect_string=${Firmware_Version.SSD_FW_Version}

Diag_Verify_TLV_EEPROM_In_ONIE
    # [Arguments]
    # ${MAC}    Convert To List    ${Mac}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    # Power_Cyling_ONIE
    Diag_Telnet_ONIE_Command                command=onie-discovery-stop
    Diag_Telnet_ONIE_Command                command=onie-syseeprom
    # ...                                   expect_string=${SN},${PN},${MACADD}

##############################################################################################################
##############################################################################################################

Diag_SSH_Execute_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone
    ...            ${wait_for}=Diag#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=100s  ${return_out}=default
    START_SSH_unit     ${time_out}    ${USERNAME_SSH_unit}    ${PASSWORD_SSH_unit}
    sleep   ${wait_before_send}
    SSHLibrary.Write    su
    sleep     1s
    SSHLibrary.Write    onl
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    \# 
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    cd ${path}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    log.debug      SSH Sending command "${command}"
    ${output}=    SSHLibrary.Write    ${command}
    Save_to_logs       \nDiag#${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    Save_to_logs   ${output}\n
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${unparse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unparse_string}   default
    Run Keyword If  ${unparse_string_status}    Diag_Check_Unparse_string    ${unparse_string}    ${output}
    SSH_CLOSE
    [Return]   ${output}

Diag_Telnet_Execute_Command_12
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone
    ...            ${wait_for}=Diag#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=100s  ${return_out}=default
    TELNET_Set_Prompt    ${wait_for}
    TELNET_Set_Path    ${path}    ${wait_for}
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${unparse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unparse_string}   default
    Run Keyword If  ${unparse_string_status}    Diag_Check_Unparse_string    ${unparse_string}    ${output}
    # SSH_CLOSE
    [Return]   ${output}

Diag_Telnet_Execute_BMC_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone
    ...            ${wait_for}=BMC#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=100s  ${return_out}=default
    TELNET_Set_Prompt    ${wait_for}
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${unparse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unparse_string}   default
    Run Keyword If  ${unparse_string_status}    Diag_Check_Unparse_string    ${unparse_string}    ${output}
    # SSH_CLOSE
    [Return]   ${output}

Diag_Telnet_Execute_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default   ${unparse_string}=default
    ...            ${wait_for}=@localhost:   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${unparse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unparse_string}   default
    Run Keyword If  ${unparse_string_status}    Diag_Check_Unparse_string    ${unparse_string}    ${output}
    [Return]   ${output}

Diag_Telnet_Execute_Command_Password
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=root@localhost:~#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    [Return]   ${output}

Diag_Telnet_Execute_Command_2
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=@localhost:~#    ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    [Return]   ${output}

Diag_Telnet_Execute_BMC
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    [Return]   ${output}


Diag_Telnet_ONIE_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=ONIE:/ #   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=10s  ${return_out}=default
    ${output}    TELNET_Send_Command_expect_prompt_set_time    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    TELNET_CLOSE
    [Return]   ${output}

Diag_SSH_Dmesg_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone/bin
    ...            ${wait_for}=Diag#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=30s  ${return_out}=default
    SSH_to_Telnet     ${time_out}
    sleep   ${wait_before_send}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    cd ${path}
    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    ${command}
    ${output}=    SSHLibrary.Read Until    ${wait_for}
    SSH_CLOSE
    [Return]   ${output}

Diag_Check_Expect_string
    [Arguments]     ${expect_string}    ${output}
    @{expect_list}=   Split String    ${expect_string}    ,
    FOR   ${i}  IN  @{expect_list}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain    ${output}      ${i}
        Run Keyword If    '${status}' == 'FAIL'  log.debug      Did not find expected string "${i}", The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
        Run Keyword If    '${status}' == 'FAIL'    FAIL            Did not find expected string "${i}"
        log.newline
        log.debug      ----------------------------------------------------------------------------
        log.debug      Found expect string "${i}"
        log.debug      **** PASSED ****
        log.debug      ----------------------------------------------------------------------------\n
    END


Diag_Check_Unexpect_string
    [Arguments]     ${unexpect_string}    ${output}
    @{unexpect_list}=   Split String    ${unexpect_string}    ,
    FOR   ${i}  IN  @{unexpect_list}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${output}      ${i}
        Run Keyword If    '${status}' == 'FAIL'  log.debug      The string "${i}" was catch, The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
        Run Keyword If    '${status}' == 'FAIL'    FAIL            The string "${i}" was catch
        # log.debug      ----------------------------------------------------------------------------\n
        log.newline
        log.debug      ----------------------------------------------------------------------------
        log.debug      No unexpect string "${i}" found in LOG
        log.debug      **** PASSED ****
        log.debug      ----------------------------------------------------------------------------\n
    END

Diag_Check_Parse_string
    [Arguments]     ${parse_string}    ${output}
    @{message_list}=   Split String    ${parse_string}    ,
    FOR   ${i}  IN  @{message_list}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Match Regexp    ${output}      ${i}
        Run Keyword If    '${status}' == 'FAIL'  log.debug      Did not find expected Message string "${i}", The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
        Run Keyword If    '${status}' == 'FAIL'    FAIL            Did not find expected Message string "${i}"
        # log.debug      ----------------------------------------------------------------------------\n
        log.newline
        log.debug      ----------------------------------------------------------------------------
        log.debug      Found expect string "${i}"
        log.debug      **** PASSED ****
        log.debug      ----------------------------------------------------------------------------\n
    END

Diag_Check_Unparse_string
    [Arguments]     ${unparse_string}    ${output}
    @{unmessage_list}=   Split String    ${unparse_string}    ,
    FOR   ${i}  IN  @{unmessage_list}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Match Regexp    ${output}      ${i}
        Run Keyword If    '${status}' == 'FAIL'  log.debug      The string "${i}" was catch, The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
        Run Keyword If    '${status}' == 'FAIL'    FAIL            The string "${i}" was catch
        log.newline
        log.debug      ----------------------------------------------------------------------------
        log.debug      Found expect string "${i}"
        log.debug      **** PASSED ****
        log.debug      ----------------------------------------------------------------------------\n
    END

SSH_Send_Diag
    [Arguments]     ${Command}      ${Prompt}=Diag#    ${time_out}=100s
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_Send_Command_expect_prompt_set_time      ${Command}    ${Prompt}    ${time_out}
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-eeprom-test -r -t tlv -d 1
    Run Keyword If     '${status}' == 'FAIL'    Check_Mac    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-phy-test -r -d 1 -t mac
    Run Keyword If     '${status}' == 'FAIL'    Check_Mac    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-temp-test --all
    Run Keyword If     '${status}' == 'FAIL'    Check_Temp_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      cel-dcdc-test --all
    Run Keyword If     '${status}' == 'FAIL'    Check_dcdc_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-log-test -r -d 1
    Run Keyword If     '${status}' == 'FAIL'    Check_log_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-fan-test --all
    Run Keyword If     '${status}' == 'FAIL'    Check_Fan_Err    ${output}
    
SSH_Send_traffic
    [Arguments]     ${Command}      ${time_out}=100s    ${parse_string}=default    ${Prompt}=BCM.0>
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_Send_Command_expect_prompt_set_time      ${Command}    ${Prompt}    ${time_out}
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      filter nz
    Run Keyword If     '${status}' == 'FAIL'    Check_Traffic_RX_TX_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ifcs show devport
    Run Keyword If     '${status}' == 'FAIL'    Check_Link_Status    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      aux_traffic_test
    Run Keyword If     '${status}' == 'FAIL'    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      get_rx_prbs_check
    Run Keyword If     '${status}' == 'FAIL'    Check_PRBS_1_16_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      diagtest serdes prbs get
    Run Keyword If     '${status}' == 'FAIL'    Check_PRBS_17_32_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      ./bin/cel-temp-test --all
    Run Keyword If     '${status}' == 'FAIL'    Check_Temp_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      cel-dcdc-test --all
    Run Keyword If     '${status}' == 'FAIL'    Check_dcdc_Err    ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      snake gen_report
    Run Keyword If     '${status}' == 'FAIL'    Check_snake_rx_tx    ${output}
    [Return]   ${output}

Check_Fan_Err
    [Arguments]     ${output}
    Should Contain      ${output}    Fan test : Passed

Check_dcdc_Err
    [Arguments]     ${output}
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain    ${output}      DCDC test : Passed
    Run Keyword If     '${status}' == 'FAIL'    Diag_dc_dc_Check    ${output}

Check_Temp_Err
    [Arguments]     ${output}
    Should Contain      ${output}    Temp test : Passed

Check_snake_rx_tx
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    9    11
        ${Traffic_err}         Get Line             ${output}      ${i}
        ${Traffic_err}         Split String        ${Traffic_err}      :
        ${RX_Traffic_err}      Remove String       ${Traffic_err}[4]       ${SPACE}
        ${TX_Traffic_err}      Remove String       ${Traffic_err}[8]       ${SPACE}    |
        Should Be True            '${RX_Traffic_err}' == '0'
        Should Be True            '${TX_Traffic_err}' == '0'
    END

Check_Traffic_RX_TX_Err
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    5    68
        ${Traffic_err}         Get Line             ${output}      ${i}
        ${Traffic_err}         Split String        ${Traffic_err}      |
        ${RX_Traffic_err}      Remove String       ${Traffic_err}[4]       ${SPACE}
        ${TX_Traffic_err}      Remove String       ${Traffic_err}[9]       ${SPACE}
        Should Be True            '${RX_Traffic_err}' == '0'
        Should Be True            '${TX_Traffic_err}' == '0'
    END
    log.debug    \r
    log.debug    \r
    log.debug    Rx Frame Err = 0\r
    log.debug    Tx Frame Err = 0\r
    log.debug    ***** PASSED *****\r 
    log.debug    \r
    log.debug    \r


Check_Traffic_RX_TX_Err_10g
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    5    7
        ${Traffic_err}         Get Line             ${output}      ${i}
        ${Traffic_err}         Split String        ${Traffic_err}      |
        ${RX_Traffic_err}      Remove String       ${Traffic_err}[4]       ${SPACE}
        ${TX_Traffic_err}      Remove String       ${Traffic_err}[9]       ${SPACE}
        Should Be True            '${RX_Traffic_err}' == '0'
        Should Be True            '${TX_Traffic_err}' == '0'
    END
    log.debug    \r
    log.debug    \r
    log.debug    Rx Frame Err = 0\r
    log.debug    Tx Frame Err = 0\r
    log.debug    ***** PASSED *****\r 
    log.debug    \r
    log.debug    \r


Check_PRBS_1_16_Err
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    7    134
        ${Traffic_err}         Get Line             ${output}      ${i}
        ${Traffic_err}         Split String        ${Traffic_err}      :
        ${RX_Traffic_err}      Remove String       ${Traffic_err}[7]       ${SPACE}
        Should Contain      ${RX_Traffic_err}      PASS
    END

Check_PRBS_17_32_Err
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    6    262
        ${Traffic_err1}         Get Line             ${output}      ${i}
        ${Traffic_err}         Split String        ${Traffic_err1}      :
        # ${RX_Traffic_err}      Remove String       ${Traffic_err}[5]       ${SPACE}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain      ${Traffic_err}[5]      ${SPACE}0
        Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Message_Genfail}    PRBS-FAIL: ${Traffic_err1}
        Run Keyword If     '${status}' == 'FAIL'    FAIL   ${Message_Genfail}
        
    END
    log.debug    No Error Found, PRBS test ! ! ! P A S S E D ! ! !\n

Check_Link_Status
    [Arguments]     ${output}
    FOR     ${i}    IN RANGE    64
        ${Link_Status}      Get Lines Containing String     ${output}     ETH
        ${Link_Status1}      Get Line    ${Link_Status}    ${i}
        ${Link_Status}      Split String        ${Link_Status1}      |
        ${Link_Status}      Remove String       ${Link_Status}[8]           ${SPACE}
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain      ${Link_Status}      UP
        Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Message_Genfail}    LINK DOWN: ${Link_Status1}
        # Run Keyword If     '${status}' == 'FAIL'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${status}' == 'FAIL'    FAIL        ${Message_Genfail}
    END
    log.debug     ********************************************************************
    log.debug    \nAll ports status are up Check link test ! ! ! P A S S E D ! ! !\n
    log.debug     ********************************************************************

Check_Mac
    [Arguments]     ${output}
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    Should Contain    ${output}    ${MAC_ODC}[0]${MAC_ODC}[1]:${MAC_ODC}[2]${MAC_ODC}[3]:${MAC_ODC}[4]${MAC_ODC}[5]:${MAC_ODC}[6]${MAC_ODC}[7]:${MAC_ODC}[8]${MAC_ODC}[9]:${MAC_ODC}[10]${MAC_ODC}[11]

Swap_BMC_1
    [Arguments]     ${time_out}=200s
    log.debug                                   Logged in to BMC prompt.
    sleep    1s
    TELNET_Write_Bare_Command_ignore_prompt           exit\r
    TELNET_Write_Bare_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt           ${Uart_Comand}
    # sleep    1s
    # TELNET_Write_Bare_Command_ignore_prompt     \x12
    # sleep    1s
    # TELNET_Write_Bare_Command_ignore_prompt     \x14
    # sleep    0.5s
    TELNET_Write_Bare_Command_ignore_prompt           2\r
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    sleep    4s
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    sleep    1s
    TELNET_Write_Bare_Command_expect_prompt           sysadmin\r\n                Password:
    sleep    1s
    TELNET_Write_Bare_Command_expect_prompt           superuser\r\n               \#

Swap_BMC
    ${status}   ${output}=  Run Keyword And Ignore Error    Swap_BMC_1
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC_1

Swap_COME_1
    [Arguments]     ${time_out}=100s
    log.debug                                   Logged in to ComE prompt.
    TELNET_Write_Bare_Command_ignore_prompt           exit\r
    TELNET_Write_Bare_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt     ${Uart_Comand}
    # sleep    1s
    # TELNET_Write_Bare_Command_ignore_prompt     \x12
    # sleep    1s
    # TELNET_Write_Bare_Command_ignore_prompt     \x14
    # sleep    0.5s
    TELNET_Write_Bare_Command_ignore_prompt           1\r
    TELNET_Write_Bare_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    sleep    6s
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    TELNET_Write_Bare_Command_expect_prompt           \r                      login:
    Re_Login

Swap_COME
    ${status}   ${output}=  Run Keyword And Ignore Error    Swap_COME_1
    Run Keyword If    '${status}' == 'FAIL'    Swap_COME_1

Re_Login
    sleep    5s
    ${output1}    Diag_Telnet_Execute_Command    command=\r
                 ...                             wait_for=login:
                 ...                             wait_before_send=1
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    login:
    Run Keyword If    '${status}' == 'PASS'    Login_unit

Login_unit    
    log.debug    Login to Diag prompt.
    Diag_Telnet_Execute_Command    command=\r
    ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}

Re_Login_BMC
    sleep    5s
    ${output1}    Diag_Telnet_Execute_Command    command=\r
                 ...                            wait_for=:
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    login:
    Run Keyword If    '${status}' == 'PASS'    Login_BMC

Login_BMC   
    log.debug    Login to BMC prompt.
    Diag_Telnet_Execute_Command    command=\r
    ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=sysadmin
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=superuser

TG_Port_Start
    [Arguments]    ${time_out}=400s
    log.debug  ********************************\n
    log.debug  Login to Traffic generator\n
    Wait Until Created    /opt/Sync/Sync_TG.txt    60min
    Remove Files    /opt/Sync/Sync_TG.txt
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_OPEN_TG    ${time_out}
    Run Keyword If    '${status}' == 'FAIL'    Telnet.Close All Connections
    Run Keyword If    '${status}' == 'FAIL'    Create File    /opt/Sync/Sync_TG.txt    Done
    Run Keyword If    '${status}' == 'FAIL'    FAIL     Log-in TG
    TELNET_CLOSE
    log.debug  sending command ->${TG_Port}_clear\n
    TELNET_Send_Command_TG_prompt    ${TG_Port}_clear
    log.debug  sending command ->${TG_Port}_start\n
    TELNET_Send_Command_TG_prompt    ${TG_Port}_start
    Create File    /opt/Sync/Sync_TG.txt    Done
    log.debug  Log out to Traffic generator\n
    log.debug  ********************************\n

TG_Port_Stop
    [Arguments]    ${time_out}=400s
    Wait Until Created    /opt/Sync/Sync_TG.txt    60min
    Remove Files    /opt/Sync/Sync_TG.txt
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_OPEN_TG    ${time_out}
    Run Keyword If    '${status}' == 'FAIL'    Telnet.Close All Connections
    Run Keyword If    '${status}' == 'FAIL'    Create File    /opt/Sync/Sync_TG.txt    Done
    Run Keyword If    '${status}' == 'FAIL'    FAIL     Log-in TG
    TELNET_CLOSE
    log.debug  sending command ->${TG_Port}_stop\n
    TELNET_Send_Command_TG_prompt    ${TG_Port}_stop
    sleep    5s
    TELNET_Send_Command_TG_prompt    ${TG_Port}_show
    Create File    /opt/Sync/Sync_TG.txt    Done

Config_eBay
    log.debug      \r