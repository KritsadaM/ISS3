*** Keywords ***
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
    ${Parameter}=  OperatingSystem.Get File    ${CURDIR}${/}../../ODC_Script${/}BOM${/}${serial_number}.py
    @{message_list}=    Split String           ${Parameter}               \n
    FOR    ${i}    IN       @{message_list}
        Save_to_logs    ${i}\n
        ${status}    ${std_out}=     Run Keyword And Ignore Error    Should Not Contain    ${i}     ""
        Run Keyword If          '${status}' == 'FAIL'    FAIL    Check empty ODC string: "${i}"
    END
    Save_to_logs    Cell = "${slot_location}"\n

Check_ODC_Patrameter_Robot
    [Arguments] 
    ${Parameter}=  OperatingSystem.Get File    ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    @{message_list}=    Split String           ${Parameter}               \n
    FOR    ${i}    IN       @{message_list}
        Save_to_logs    ${i}\n
        ${status}    ${std_out}=     Run Keyword And Ignore Error    Should Not Contain    ${i}     ""
        Run Keyword If          '${status}' == 'FAIL'    FAIL    Check empty ODC string: "${i}"
    END
    Save_to_logs    Cell = "${slot_location}"\n

Diag_Login_And_Connect
    Run    /usr/bin/pkill -HUP -f "^telnet ${TelnetIP}.+${Port_Telnet}"
    Util_Test_Execution         test_case=Power_Cyling
    ...                         retry_loop=5

Retey_to_Power_cycling
    # Run    /usr/bin/pkill -HUP -f "^telnet ${TelnetIP}.+${Port_Telnet}"
    Power_Cyling

Command_Power_Cyling
    [Arguments]   ${Comamnd}    ${retry_loop}=4      ${sleep_time}=5
    ${max_loop}=    Evaluate      ${retry_loop}-1
    
    FOR  ${loop}  IN RANGE   0    ${retry_loop}
        Run Keyword If     ${loop}>=${max_loop}      GEN_FAIL
        sleep     ${sleep_time}
        # Kill_telnet_port
        ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_CLOSE
        ${test_status}     ${std_out}=   
        ...                Run Keyword And Ignore Error       Command_Power_Cyling_1    ${Comamnd}
        Run Keyword If	   '${test_status}' == 'FAIL'    	  Continue For Loop
        Run Keyword If	   '${test_status}' == 'PASS'	      Exit For Loop

    END

Kill_telnet_port
    [Arguments] 
    START_SSH_server
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
        # Kill_telnet_port
        ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_CLOSE
        ${test_status}     ${std_out}=   
        ...                Run Keyword And Ignore Error       ${test_case}
        Run Keyword If	   '${test_status}' == 'FAIL'    	  Continue For Loop
        Run Keyword If	   '${test_status}' == 'PASS'	      Exit For Loop

    END

Util_Test_Execution_V2
    [Arguments]     ${test_case}    ${retry_loop}=2      ${sleep_time}=5
    ${max_loop}=    Evaluate      ${retry_loop}-1
    
    FOR  ${loop}  IN RANGE   0    ${retry_loop}
        Run Keyword If     ${loop}>=${max_loop}      GEN_FAIL
        Run Keyword If     ${loop}>0      Diag_Login_And_Connect
        sleep     ${sleep_time}
        ${test_status}     ${std_out}=   
        ...                Run Keyword And Ignore Error       ${test_case}
        Run Keyword If	   '${test_status}' == 'FAIL'    	  sleep    2s
        Run Keyword If	   '${test_status}' == 'FAIL'    	  Continue For Loop
        Run Keyword If	   '${test_status}' == 'PASS'	      Exit For Loop

    END

GEN_FAIL
    Save_to_logs   ${TEST NAME}= !!! ${space} F A I L E D ${space} !!!\r
    FAIL

Diag_FPGA_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 1 -f firmware/fpga/SILVERSTONE_FPGA_primary_V0001_0005.bin
    ...                                         expect_string=Upgrade Firmware --> Passed
    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 1
    ...                                         expect_string=10005

Diag_BIOS_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 2 -f firmware/bios/Silverstone_BIOS_2.0.0.BIN
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Sleep   20s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 3 -f firmware/bios/Silverstone_BIOS_2.0.0.BIN
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 2
    ...                                         expect_string=2.0.0

Diag_CPLD_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 4 -f firmware/cpld/Silverstone_V05_FAN_V03_BASE_V05_COME_V07_SW1_V00_SW2_V00.vme
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Diag_Login_And_Connect

Diag_BMC_Image_Upgrade
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 5 -f firmware/bmc/R4009-JF002-01_Silverstone_B2F_BMCV2.00.ima
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Sleep   60s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -d 6 -f firmware/bmc/R4009-JF002-01_Silverstone_B2F_BMCV2.00.ima
    ...                                         expect_string=Upgrade Firmware --> Passed
    ...                                         time_out=300
    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 5
    ...                                         expect_string=02 00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 6
    ...                                         expect_string=02 00

Firmware_Version_Check
    # Swap_BMC
    # log.debug    *************** CPLD Version Check ***************
    # Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x03 0 1 0
    # ...                                         expect_string=${Firmware_Version.CPLD_Base_Board}
    # Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x03 1 1 0
    # ...                                         expect_string=${Firmware_Version.CPLD_Fan_Board}
    # Diag_Telnet_Execute_BMC_Command            command=ipmitest raw 0x3a 0x01 1 0x1a 1 0xe0
    # ...                                         expect_string=${Firmware_Version.CPLD_ComE}
    # Swap_COME
    # Diag_Telnet_Execute_Command_12              command=i2cget -f -y 4 0x30 0x00
    # ...                                         expect_string=${Firmware_Version.CPLD_Switch1}
    # Diag_Telnet_Execute_Command_12              command=i2cget -f -y 4 0x31 0x00
    # ...                                         expect_string=${Firmware_Version.CPLD_Switch1}

    log.debug    *************** FPGA Version Check ***************
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 1
    ...                                         expect_string=10005

    log.debug    *************** BMC Version Check ***************
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 5
    ...                                         expect_string=02 00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 6
    ...                                         expect_string=02 00

    log.debug    *************** Diag Version Check ***************
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -v
    ...                                         expect_string=2.0.0

    log.debug    *************** Bios Version Check ***************
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 2
    ...                                         expect_string=2.0.0

BMC_check_upgrade_01
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x01 0x02  
    Diag_Telnet_Execute_Command_12              command=ipmitool mc reset cold
    sleep    260s
    Swap_BMC
    Swap_COME
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x07
    ...                                         expect_string=02
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x01 0x01
    Diag_Telnet_Execute_Command_12              command=ipmitool mc reset cold
    sleep    260s
    Swap_BMC
    Swap_COME
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x07
    ...                                         expect_string=01

BMC_check_upgrade_02
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x01 0x01
    Diag_Telnet_Execute_Command_12              command=ipmitool mc reset cold
    sleep    260s
    Swap_BMC
    Swap_COME
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x32 0x8f 0x07
    ...                                         expect_string=01

Diag_BIOS_CPLD_BMC_Image_Check
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 2
    ...                                         expect_string=2.03.00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 4
    ...                                         parse_string=Base_CPLD.+2.7,Switch_CPLD1.+1.2,Switch_CPLD2.+1.2,Switch_CPLD3.+1.2,Switch_CPLD4.+1.2,COMe_CPLD.+15
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 5
    ...                                         expect_string=3.0

Diag_BIOS_CPLD_BMC_Image_Upgrade_V2
    log.debug    Checking FW md5sum\n
    Diag_Telnet_Execute_Command_12              command=md5sum /home/cel_diag/midstone100X/firmware/bios/Midstone100X_hewittlake_BIOS_2.01.00.BIN
    ...                                         expect_string=${bios_chksum}
    Diag_Telnet_Execute_Command_12              command=md5sum /home/cel_diag/midstone100X/firmware/cpld/DVT_BDE_C_V13.vme
    ...                                         expect_string=${cpld_chksum}
    Diag_Telnet_Execute_Command_12              command=md5sum /home/cel_diag/midstone100X/firmware/bmc/R3250-JF024-01_Midstone100X_2.10.ima
    ...                                         expect_string=${bmc_chksum}

    # Download_Image
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -b --update -d 2 -f /home/cel_diag/midstone100X/firmware/bios/Midstone100X_hewittlake_BIOS_2.01.00.BIN
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -b --update -d 3 -f /home/cel_diag/midstone100X/firmware/bios/Midstone100X_hewittlake_BIOS_2.01.00.BIN
    # ...                                         expect_string=Passed
    ${status}   ${output}=  Run Keyword And Ignore Error    Upgrade_Bios_Image
    Run Keyword If    '${status}' == 'FAIL'    Upgrade_Bios_Image
    # Upgrade_Bios_Image
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x25 1
    
    sleep   60s
    # Upgrade_CPLD_Image
    ${status}   ${output}=  Run Keyword And Ignore Error    Upgrade_CPLD_Image
    Run Keyword If    '${status}' == 'FAIL'    Upgrade_CPLD_Image
    # Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test --update -b -d 4 -f /home/FW/CPLD/Midstone_100x_Broadwell_DE/EVT2_Broadwell_DE_B16_C11_S109_S209_S309_S409_20210702.vme
    #                                            ...                                         expect_string=Passed

    sleep   50s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -b --update -d 5 -f /home/cel_diag/midstone100X/firmware/bmc/R3250-JF024-01_Midstone100X_2.10.ima
    ...                                         expect_string=Passed
    ...                                 time_out=400
    sleep    50s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -b --update -d 6 -f /home/cel_diag/midstone100X/firmware/bmc/R3250-JF024-01_Midstone100X_2.10.ima
    ...                                         expect_string=Passed
    ...                                 time_out=400
    sleep    50s

    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 2
    ...                                         expect_string=2.01.00

    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 4
    ...                                         expect_string=0.9

    Diag_Telnet_Execute_Command_12              command=./bin/cel-upgrade-test -F -d 5
    ...                                         expect_string=2.10

Diag_Modify_CPU_MAC_address_check
    Diag_Telnet_Execute_Command_12              command=./tools/eeupdate64e /NIC=3 /MAC_DUMP
    ...                                         expect_string=${MAC}
    Diag_Telnet_Execute_Command_12              command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_12              command=ping ${SSH_IP} -c 5
    ...                                         expect_string=5 received, 0% packet loss
    Swap_BMC
    Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC             command=ifconfig
    ...                                 wait_for=${BMC_IP_2}
    Diag_Telnet_Execute_Command         command=ping ${BMC_IP_2} -c 5
    ...                                 wait_for=\#
    ...                                         expect_string=5 packets received, 0% packet loss
    Swap_COME

Diag_Modify_CPU_MAC_address_test
    Diag_Telnet_Execute_Command_12              command=./tools/eeupdate64e /nic=3 /mac=${MAC}
    ...                                         expect_string=Done
    Diag_Login_And_Connect
    Diag_Telnet_Execute_Command_12              command=./tools/eeupdate64e /NIC=3 /MAC_DUMP
    ...                                         expect_string=${MAC}
    Diag_Telnet_Execute_Command_12              command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_12              command=ping ${SSH_IP} -c 5
    ...                                         expect_string=5 received, 0% packet loss
    Swap_BMC
    Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC             command=ifconfig
    ...                                 wait_for=${BMC_IP_2}
    Diag_Telnet_Execute_Command         command=ping ${BMC_IP_2} -c 5
    ...                                 wait_for=\#
    ...                                         expect_string=5 packets received, 0% packet loss
    Swap_COME
    
    # [Arguments]
    # ${MACADDRESS}    Convert To Integer    ${Mac}    16 
    # ${loop_count}     Evaluate     ${MACADDRESS}+1
    # ${MACADDRESS1}    Convert To HEX    ${loop_count}
    # ${Maccount}      Get Length     ${MACADDRESS1}
    # ${MACADDRESS1}    Set Variable If    '12' != '${Maccount}'    0${MACADDRESS1}    none
    # ${loop_count}     Evaluate     ${MACADDRESS}+2
    # ${MACADDRESS2}    Convert To HEX    ${loop_count}
    # ${Maccount}      Get Length     ${MACADDRESS2}
    # ${MACADDRESS2}    Set Variable If    '12' != '${Maccount}'    0${MACADDRESS2}    none
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -w -d 1 -D ${MACADDRESS1}
    # ...                                         parse_string=${MACADDRESS1}.+Done,Checksum.+Done
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -w -d 2 -D ${MACADDRESS2}
    # ...                                         parse_string=${MACADDRESS2}.+Done,Checksum.+Done
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -w -d 3 -D ${Mac}
    # ...                                         parse_string=${Mac}.+Done,Checksum.+Done
    # Diag_Login_And_Connect
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 1
    # ...                                         expect_string=${MACADDRESS1}
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 2
    # ...                                         expect_string=${MACADDRESS2}
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 3
    # ...                                         expect_string=${Mac}
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test --all
    # ...                                         expect_string=MAC test : Passed

# Diag_Modify_CPU_MAC_address_Check
#     [Arguments]
#     ${MACADDRESS}    Convert To Integer    ${Mac}    16 
#     ${loop_count}     Evaluate     ${MACADDRESS}+1
#     ${MACADDRESS1}    Convert To HEX    ${loop_count}
#     ${Maccount}      Get Length     ${MACADDRESS1}
#     ${MACADDRESS1}    Set Variable If    '12' != '${Maccount}'    0${MACADDRESS1}    none
#     ${loop_count}     Evaluate     ${MACADDRESS}+2
#     ${MACADDRESS2}    Convert To HEX    ${loop_count}
#     ${Maccount}      Get Length     ${MACADDRESS2}
#     ${MACADDRESS2}    Set Variable If    '12' != '${Maccount}'    0${MACADDRESS2}    none
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 1
#     ...                                         expect_string=${MACADDRESS1}
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 2
#     ...                                         expect_string=${MACADDRESS2}
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test -r -d 3
#     ...                                         expect_string=${Mac}
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-mac-test --all
#     ...                                         expect_string=MAC test : Passed

Diag_SMBIOS_FRU_Burning
    [Arguments]
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${UUID}=  Convert To Uppercase  ${UUID}
    # ${MAC}    Convert To List    ${MAC}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru --all -t smbios -d 1
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Manufacturer" -D "${SMBios_Version.System_Manufacturer}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Product" -D "${SMBios_Version.System_Product}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Version" -D "${REV}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System UUID" -D "${UUID}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Serial Number" -D "${TLA_SN}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System SKU Number" -D "${TLA_PN}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "System Family Name" -D "${SMBios_Version.System_Product}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Manufacturer" -D "${SMBios_Version.System_Manufacturer}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Product" -D "${BASE_BOARD_PN}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Version" -D "${BASE_BOARD_REV}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Serial Number" -D "${BASE_BOARD_SN}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Asset Tag" -D "${COME_PN}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Board Location In Chassis" -D "${SMBios_Version.Chassis_Location}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Manufacturer" -D "${SMBios_Version.Chassis_Manufacturer}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Version" -D "${SMBios_Version.Chassis_Version}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Asset Tag" -D "${SMBios_Version.Chassis_Asset_Tag}"
    ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Asset Tag" -D "${SMBios_Version.Chassis_Asset_Tag}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t smbios -d 1 --item "Chassis Asset Tag" -D "${SMBios_Version.Chassis_Asset_Tag}"
    # ...                                         parse_string=Programming passed
    
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    Command_Power_Cyling                        ipmitool power cycle
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    ...                                         parse_string=System Manufacturer.+${SMBios_Version.System_Manufacturer},System Product.+${SMBios_Version.System_Product},System Version.+${REV},${UUID},${TLA_SN},${TLA_PN},System Family Name.+${SMBios_Version.System_Product},Board Manufacturer.+${SMBios_Version.System_Manufacturer},${BASE_BOARD_PN},Board Version.+${BASE_BOARD_REV},${BASE_BOARD_SN},${COME_PN},${SMBios_Version.Chassis_Location},Chassis Manufacturer.+${SMBios_Version.Chassis_Manufacturer},Chassis Version.+${SMBios_Version.Chassis_Version},${SMBios_Version.Chassis_Asset_Tag}
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System Manufacturer" -D "${SMBios_Version.System_Manufacturer}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System Product" -D "${SMBios_Version.System_Product}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System Version" -D "${SYSTEM_VERSION_from_ODC}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System UUID" -D "${UUID_from_ODC}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System Serial Number" -D "${SYSTEM_SN_from_ODC}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System SKU Number" -D "${SKU_Number_from_ODC}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "System Family Name" -D "${SMBios_Version.System_Family_Name}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Manufacturer" -D "${SMBios_Version.Board_Manufacturer}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Product" -D "${PN}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Version" -D "${REV}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Serial Number" -D "${MAC}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Asset Tag" -D "${SMBios_Version.Board_Asset_Tag}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Board Location In Chassis" -D "${SMBios_Version.Board_Location_Chassis}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Chassis Manufacturer" -D "${SMBios_Version.Chassis_Manufacturer}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Chassis Version" -D "${SMBios_Version.Chassis_Version}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -w -t system -d 1 --item "Chassis Asset Tag" -D "${SMBios_Version.Chassis_Asset_Tag}"
    # ...                                         parse_string=Programming passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -r -t system -d 1
    # ...                                         expect_string=${SMBios_Version.System_Manufacturer},${SMBios_Version.System_Product},${SYSTEM_VERSION_from_ODC},
    # ...                                 0X${UUID_from_ODC},${SYSTEM_SN_from_ODC},${SKU_Number_from_ODC},${SMBios_Version.System_Family_Name},${SMBios_Version.Board_Manufacturer},
    # ...                                 ${PN},${REV},${MAC},${SMBios_Version.Board_Asset_Tag},${SMBios_Version.Board_Location_Chassis},${SMBios_Version.Chassis_Manufacturer},
    # ...                                 ${SMBios_Version.Chassis_Version},${SMBios_Version.Chassis_Asset_Tag}

Diag_SMBIOS_Table_Burning_Check
    [Arguments]
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${UUID}=  Convert To Uppercase  ${UUID}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    ...                                         parse_string=System Manufacturer.+${SMBios_Version.System_Manufacturer},System Product.+${SMBios_Version.System_Product},System Version.+${REV},${UUID},${TLA_SN},${TLA_PN},System Family Name.+${SMBios_Version.System_Product},Board Manufacturer.+${SMBios_Version.System_Manufacturer},${BASE_BOARD_PN},Board Version.+${BASE_BOARD_REV},${BASE_BOARD_SN},${COME_PN},${SMBios_Version.Chassis_Location},Chassis Manufacturer.+${SMBios_Version.Chassis_Manufacturer},Chassis Version.+${SMBios_Version.Chassis_Version},${SMBios_Version.Chassis_Asset_Tag}

 
EEPROM_CHECK_TEST_FOR_TLV_testcase
    # Write_Script    \r    silverstone#
    # sleep    2s
    ${SERIAL}    Remove String    ${TLA_SN}    ${TLA_REV}
    ${MAC}    Convert To List    ${MAC}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --dump -t tlv -d 1
    ...                                         parse_string=${TLV_Version.Product_Name},${TLA_PN},${SERIAL},${MACADD},Device Version.+0x26.+1.+1,${TLA_REV},${TLV_Version.ONIE_Version},${TLV_Version.Manufacturer},Country Code.+${TLV_Version.Country_Code},${TLV_Version.Diag_Version},${TAGID}
    # ${SN_A}=    Get Substring    ${SN}    0    20
    # Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-test --dump -t tlv -d 1
    # ...                                         parse_string=${Platform_Name},Country Code.+${Country_Code},${Vender_Name},${Vendor_Extension},${Product_Name},${Part_Number},${SN_A},Device Version.+${Device_Version},${Label_Rivision},${ONIE_Version},${MAC_Addresses},${Manufacturer},${Diag_Version},${TAGID}
    #*******************check section ********************
    
    # ${console}=    Write_ScriptReturn    ./bin/cel-eeprom-test --dump -t tlv -d 1    silverstone#
    # Should Match Regexp    ${console}    Platform Name \ \ \ \ \ \ \ 0x28 \ 30 ${PlatName}
    # Should Match Regexp    ${console}    Country Code \ \ \ \ \ \ \ \ 0x2C \ \ 2 ${CountryCode}
    # Should Match Regexp    ${console}    Vendor Name \ \ \ \ \ \ \ \ \ 0x2D \ \ 8 ${Vendor}
    # Should Match Regexp    ${console}    Vendor Extension \ \ \ \ 0xFD \ \ 4 ${VendorExt}
    # Should Match Regexp    ${console}    Product Name \ \ \ \ \ \ \ \ 0x21 \ \ 9 ${ProdName}
    # Should Match Regexp    ${console}    Part Number \ \ \ \ \ \ \ \ \ 0x22 \ \ 6 ${PartNum}
    # Should Match Regexp    ${console}    Serial Number \ \ \ \ \ \ \ 0x23 \ 20 ${SN_A}
    # Should Match Regexp    ${console}    Device Version \ \ \ \ \ \ 0x26 \ \ 1 ${DeviceVer}
    # Should Match Regexp    ${console}    Label Revision \ \ \ \ \ \ 0x27 \ \ 3 ${LabelRev}
    # Should Match Regexp    ${console}    ONIE Version \ \ \ \ \ \ \ \ 0x29 \ \ 5 ${OnieVersion}
    # Should Match Regexp    ${console}    MAC Addresses \ \ \ \ \ \ \ 0x2A \ \ 2 ${TLVMac}
    # Should Match Regexp    ${console}    Manufacturer \ \ \ \ \ \ \ \ 0x2B \ \ 5 ${Manufacture}
    # Should Match Regexp    ${console}    Diag Version \ \ \ \ \ \ \ \ 0x2E \ \ 3 ${DiagVersion}
    # Should Match Regexp    ${console}    Service Tag \ \ \ \ \ \ \ \ \ 0x2F \ \ 7 ${TAGID}

EEPROM_CHECK_TEST_FOR_SMBIOS_FRU_testcase
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${UUID}=  Convert To Uppercase  ${UUID}
    # ${MAC}    Convert To List    ${MAC}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12      command=./bin/cel-eeprom-test --fru -r -t smbios -d 1
    ...                                         parse_string=Chassis Manufacturer.+Celestica,Chassis Version.+${SMBios_Version.Chassis_Version},${SMBios_Version.Chassis_Asset_Tag},Board Manufacturer.+Celestica,${BASE_BOARD_PN},${MAC},Board Version.+${BASE_BOARD_REV},${COME_PN},${SMBios_Version.Board_Location_Chassis},System Manufacturer.+Celestica,${TLV_Version.Product_Name},System Version.+${REV},${TLA_SN},0X${UUID}
    #*******************check section ********************
      
    # ${console}=    Write_ScriptReturn    ./bin/cel-eeprom-test --fru -r -t smbios -d 1    silverstone#
    # Should Match Regexp    ${console}    Chassis Manufacturer \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB11}
    # Should Match Regexp    ${console}    Chassis Version \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB12}
    # Should Match Regexp    ${console}    Chassis Asset Tag \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB13}
    # Should Match Regexp    ${console}    Board Manufacturer \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB6}
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB7}
    # Should Match Regexp    ${console}    Board Serial Number \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${MAC_ADD}
    # Should Match Regexp    ${console}    Board Version \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${BASE_BOARD_REV}
    # Should Match Regexp    ${console}    Board Asset Tag \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB9}
    # Should Match Regexp    ${console}    Board Location In Chassis \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB10}
    # Should Match Regexp    ${console}    System Manufacturer \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB1}
    # Should Match Regexp    ${console}    System Product \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB2}
    # Should Match Regexp    ${console}    System Version \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${REV}
    # Should Match Regexp    ${console}    System Serial Number \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SERIAL}
    # Should Match Regexp    ${console}    System UUID \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ 0X${UUID}
    # Should Match Regexp    ${console}    System SKU Number \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${PRODUCT_PN}
    # Should Match Regexp    ${console}    System Family Name \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ \ : \ \ \ \ \ ${SMB5} 
    #Write_Script    ./bin/cel-eeprom-test --fru --dump -t system -d 1    silverstone#

EEPROM_CHECK_TEST_FOR_BMC_FRU_testcase
    # ${TIMESTAMP1}=    Evaluate    ${TIMESTAMP}
    # ${TIMESTAMP2}=    Evaluate    ${TIMESTAMP1}-820454400
    # ${Time_Stamp_test_result}=    Evaluate    ${TIMESTAMP2}/60
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${COME_REV}=    Get Substring    ${COME_REV}    0    2
    ${BMC_REV}=    Get Substring    ${BMC_REV}    0    2
    ${SWITCH_BOARD_REV}=    Get Substring    ${SWITCH_BOARD_REV}    0    2
    ${FAN_BOARD_REV}=    Get Substring    ${FAN_BOARD_REV}    0    2
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+261
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n
    Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         parse_string=Board Mfg .+: Celestica,Board Product.+: SilverstoneB2F,Board Serial.+: ${BMC_SN},Board Part Number.+${BMC_PN},Board Extra.+: ${BMC_REV},Board Extra.+: ${BMC_Mac},Board Extra.+: ${UUID},Board Extra.+: Silverstone B2F-BMC,Board Extra.+: ${PRODUCT_PN},Board Extra.+: ${REV}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         parse_string=Board Mfg.+: Celestica,Board Product.+: Base Board,Board Serial.+: ${BASE_BOARD_SN},Board Part Number.+: ${BASE_BOARD_PN},Board Extra.+: Silverstone B2F-baseboard,Board Extra.+: ${BASE_BOARD_REV},Product Manufacturer.+Celestica,Product Name.+: Silverstone B2F,Product Part Number.+: ${PRODUCT_PN},Product Version.+: ${REV},Product Serial.+: ${TLA_SN},Product Extra.+: B2F,Product Extra.+: ${MAC},Product Extra.+: 262
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         parse_string=Board Mfg.+Celestica,Board Product.+: COMe CPU Board,Board Serial.+: ${COME_SN},Board Part Number.+: ${COME_PN},Board Extra.+: Silverstone B2F COME,Board Extra.+: ${COME_REV}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         parse_string=Board Mfg.+: Celestica,Board Product.+: Switch Board,Board Serial.+: ${SWITCH_BOARD_SN},Board Part Number.+: ${SWITCH_BOARD_PN},Board Extra.+: ${SWITCH_BOARD_REV}
    ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan_board
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
    log.debug    **********************************

START_SSH_Get_TLV_TIME
    [Arguments] 
    START_SSH_server
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
    # ${TLV_TIME_GET}    Replace String    ${TLV_TIME_GET}    /    \\/
    # ${SN_A}=    Get Substring    ${SN}    0    20
    # ${SERIAL}    Remove String    ${TLA_SN}    ${TLA_REV}
    ${MAC}    Convert To List    ${MAC}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --all
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --dump -t tlv -d 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x21 -D "${TLV_Version.Product_Name}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x22 -D ${TLA_PN}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x23 -D ${TLA_SN}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x24 -D ${MACADD}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x25 -D "${TLV_TIME_GET}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x26 -D ${TLA_REV}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x27 -D "${TLV_Version.Product_Name}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x28 -D "${TLV_Version.Platform_Name}"
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x29 -D ${TLV_Version.ONIE_Version}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2A -D ${TLV_Version.MAC_Addresses}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2B -D ${TLV_Version.Manufacturer}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2C -D ${TLV_Version.Country_Code}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2D -D ${TLV_Version.Manufacturer}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2E -D ${TLV_Version.Diag_Version}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2F -D ${TLV_Version.Service_tag}
    ...                                         parse_string=Programming passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0xFD -D "${TLV_Version.Vendor_B2F}"
    ...                                         parse_string=Programming passed
    ${TLV_Version.Vendor_B2F}     Convert To Lower Case     ${TLV_Version.Vendor_B2F}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --dump -t tlv -d 1
    ...                                         parse_string=Product Name.+${TLV_Version.Product_Name},${TLA_PN},${TLA_SN},${MACADD},${TLV_TIME_GET},Device Version.+${TLA_REV},Label.+${TLV_Version.Product_Name},${TLV_Version.Platform_Name},${TLV_Version.ONIE_Version},MAC.+${TLV_Version.MAC_Addresses},Manufacturer.+${TLV_Version.Manufacturer},${TLV_Version.Country_Code},Vendor Name.+${TLV_Version.Manufacturer},${TLV_Version.Diag_Version},${TLV_Version.Service_tag},${TLV_Version.Vendor_B2F}

Diag_TLV_eeprom_Check
    [Arguments]
    START_SSH_Get_TLV_TIME
    sleep  1
    # ${TLV_TIME_GET}    Replace String    ${TLV_TIME_GET}    /    \\/
    # ${SN_A}=    Get Substring    ${SN}    0    20
    # ${SERIAL}    Remove String    ${TLA_SN}    ${TLA_REV}
    ${MAC}    Convert To List    ${MAC}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    ${TLV_Version.Vendor_B2F}     Convert To Lower Case     ${TLV_Version.Vendor_B2F}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --dump -t tlv -d 1
    ...                                         parse_string=Product Name.+${TLV_Version.Product_Name},${TLA_PN},${TLA_SN},${MACADD},Device Version.+${TLA_REV},Label.+${TLV_Version.Product_Name},${TLV_Version.Platform_Name},${TLV_Version.ONIE_Version},MAC.+${TLV_Version.MAC_Addresses},Manufacturer.+${TLV_Version.Manufacturer},${TLV_Version.Country_Code},Vendor Name.+${TLV_Version.Manufacturer},${TLV_Version.Diag_Version},${TLV_Version.Service_tag},${TLV_Version.Vendor_B2F}

Diag_Eeprom_BMC_FRU_Test
    # ${TIMESTAMP1}=    Evaluate    ${TIMESTAMP}
    # ${TIMESTAMP2}=    Evaluate    ${TIMESTAMP1}-820454400
    # ${Time_Stamp_test_result}=    Evaluate    ${TIMESTAMP2}/60
    ${BASE_BOARD_REV}=    Get Substring    ${BASE_BOARD_REV}    0    2
    ${COME_REV}=    Get Substring    ${COME_REV}    0    2
    ${BMC_REV}=    Get Substring    ${BMC_REV}    0    2
    ${SWITCH_BOARD_REV}=    Get Substring    ${SWITCH_BOARD_REV}    0    2
    ${FAN_BOARD_REV}=    Get Substring    ${FAN_BOARD_REV}    0    2
    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+261
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n
    Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.
    ${BMC_config}               Diag_Telnet_Execute_Command_12              command=cat bmc.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${ComE_config}              Diag_Telnet_Execute_Command_12              command=cat come.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${Switch_config}            Diag_Telnet_Execute_Command_12              command=cat switch.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${System_config}            Diag_Telnet_Execute_Command_12              command=cat system.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${Fanboard_config}          Diag_Telnet_Execute_Command_12              command=cat fan_board.cfg
                                ...                                         path=/home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg
    ${BMC_config}               Get Lines Containing String     ${BMC_config}       =
    # log.debug    ${BMC_config}\n
    # ${BMC_config}               Remove String Using Regexp     ${BMC_config}       .*=
    # log.debug    ${BMC_config}\n
    ${BMC_config}               Split String                    ${BMC_config}       \n
    log.debug    ${BMC_config}\n
    ${ComE_config}               Get Lines Containing String     ${ComE_config}       =
    # log.debug    ${ComE_config}\n
    # ${ComE_config}               Remove String Using Regexp     ${ComE_config}       .*=
    # log.debug    ${ComE_config}\n
    ${ComE_config}               Split String                    ${ComE_config}       \n
    log.debug    ${ComE_config}\n
    ${Switch_config}               Get Lines Containing String     ${Switch_config}       =
    # log.debug    ${Switch_config}\n
    # ${Switch_config}               Remove String Using Regexp     ${Switch_config}       .*=
    # log.debug    ${Switch_config}\n
    ${Switch_config}               Split String                    ${Switch_config}       \n
    log.debug    ${Switch_config}\n
    ${System_config}               Get Lines Containing String     ${System_config}       =
    # log.debug    ${System_config}\n
    # ${System_config}               Remove String Using Regexp     ${System_config}       .*=
    # log.debug    ${System_config}\n
    ${System_config}               Split String                    ${System_config}       \n
    log.debug    ${System_config}\n
    ${Fanboard_config}               Get Lines Containing String     ${Fanboard_config}       =
    # log.debug    ${Fanboard_config}\n
    # ${Fanboard_config}               Remove String Using Regexp     ${Fanboard_config}       .*=
    # log.debug    ${Fanboard_config}\n
    ${Fanboard_config}               Split String                    ${Fanboard_config}       \n
    log.debug    ${Fanboard_config}\n
    Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/*.bin
    # Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_fan_board.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    # Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_bmc.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    # Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_system.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    # Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_come.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    # Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_switch.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[2]/product_name=Fan control Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[3]/serial_number=${FAN_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[4]/part_number=${FAN_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Fanboard_config}[5]/board_custom_1=${FAN_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan_board.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[2]/serial_number=${BMC_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[3]/part_number=${BMC_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[4]/customer_1=${BMC_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[5]/customer_2=${BMC_Mac}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[6]/customer_3=${UUID}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[7]/customer_4=NA/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[8]/product_mfg=Silverstone B2F-BMC/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[9]/product_name=SilverstoneB2F/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[10]/product_part_num=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${BMC_config}[11]/product_ver=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg    
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[2]/product_name=Base Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[3]/serial_number=${BASE_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[4]/part_number=${BASE_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[5]/customer_1=Silverstone B2F-baseboard/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[6]/customer_2=${BASE_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[7]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[8]/product_name=Silverstone B2F/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[9]/part_number=${PRODUCT_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[10]/version=${REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[11]/serial_number=${TLA_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[12]/customer_3=B2F/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[13]/customer_4=${MAC}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${System_config}[14]/customer_5=262/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[2]/product_name=COMe CPU Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[3]/serial_number=${COME_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[4]/part_number=${COME_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[5]/customer_1=Silverstone B2F COME/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${ComE_config}[6]/customer_2=${COME_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[0]/mfg_datetime=${Time_Stamp_test_result}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[1]/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[2]/product_name=Switch Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[3]/serial_number=${SWITCH_BOARD_SN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[4]/part_number=${SWITCH_BOARD_PN}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/${Switch_config}[5]/customer_1=${SWITCH_BOARD_REV}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg
    # CONVERT_FAN_PN
    # EEPROM_FAN    1    ${FAN1}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    2    ${FAN2}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    3    ${FAN3}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    4    ${FAN4}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    5    ${FAN5}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    6    ${FAN6}    ${Fan_PN}    ${Time_Stamp_test_result}
    # EEPROM_FAN    7    ${FAN7}    ${Fan_PN}    ${Time_Stamp_test_result}
    # sleep    1s
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan1.cfg -s 8192 -a -o bin/fan1.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan2.cfg -s 8192 -a -o bin/fan2.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan3.cfg -s 8192 -a -o bin/fan3.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan4.cfg -s 8192 -a -o bin/fan4.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan5.cfg -s 8192 -a -o bin/fan5.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan6.cfg -s 8192 -a -o bin/fan6.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    # Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan7.cfg -s 8192 -a -o bin/fan7.bin
    # ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=mkdir bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/fan_board.cfg -s 8192 -a -o bin/fan_board.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/come.cfg -s 4096 -a -o bin/come.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/bmc.cfg -s 8192 -a -o bin/bmc.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/switch.cfg -s 8192 -a -o bin/switch.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=./ipmi-fru-it -c fru_cfg/system.cfg -s 8192 -a -o bin/system.bin
    ...                                 path=/home/cel_diag/silverstone/firmware/fru_eeprom/
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 0 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 1 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 2 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 3 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 4 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 5 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 6 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 7 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 8 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 9 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 10 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 11 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 12 0
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x10 13 0
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t bmc
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t system
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t come
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan_board
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t switch
    ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan1
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan2
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan3
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan4
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan5
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan6
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan7
    # ...                                         expect_string=Passed
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/bin/*.bin
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan*.cfg
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/bmc.cfg
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/system.cfg
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/come.cfg
    # Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/switch.cfg


    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         parse_string=Board Mfg .+: Celestica,Board Product.+: SilverstoneB2F,Board Serial.+: ${BMC_SN},Board Part Number.+${BMC_PN},Board Extra.+: ${BMC_REV},Board Extra.+: ${BMC_Mac},Board Extra.+: ${UUID},Board Extra.+: Silverstone B2F-BMC,Board Extra.+: ${PRODUCT_PN},Board Extra.+: ${REV}
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : SilverstoneB2F
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${BMC_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${BMC_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${BMC_REV}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${BMC_Mac}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${UUID}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : Silverstone B2F-BMC
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${SERIAL}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         parse_string=Board Mfg.+: Celestica,Board Product.+: Base Board,Board Serial.+: ${BASE_BOARD_SN},Board Part Number.+: ${BASE_BOARD_PN},Board Extra.+: Silverstone B2F-baseboard,Board Extra.+: ${BASE_BOARD_REV},Product Manufacturer.+Celestica,Product Name.+: Silverstone B2F,Product Part Number.+: ${PRODUCT_PN},Product Version.+: ${REV},Product Serial.+: ${TLA_SN},Product Extra.+: B2F,Product Extra.+: ${MAC},Product Extra.+: 262
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Base Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${BASE_BOARD_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${BASE_BOARD_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : Silverstone B2F-baseboard
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${BASE_BOARD_REV}
    # Should Match Regexp    ${console}    Product Manufacturer \ : Celestica
    # Should Match Regexp    ${console}    Product Name \ \ \ \ \ \ \ \ \ : Silverstone B2F
    # Should Match Regexp    ${console}    Product Part Number \ \ : ${SERIAL}
    # Should Match Regexp    ${console}    Product Version \ \ \ \ \ \ : ${PRODUCT_PN}
    # Should Match Regexp    ${console}    Product Serial \ \ \ \ \ \ \ : ${SERIAL}
    # Should Match Regexp    ${console}    Product Extra \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Product Extra \ \ \ \ \ \ \ \ : ${MAC_ADD}
    # Should Match Regexp    ${console}    Product Extra \ \ \ \ \ \ \ \ : ${ODC_TLVMAC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         parse_string=Board Mfg.+Celestica,Board Product.+: COMe CPU Board,Board Serial.+: ${COME_SN},Board Part Number.+: ${COME_PN},Board Extra.+: Silverstone B2F COME,Board Extra.+: ${COME_REV}
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : COMe CPU Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${COME_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${COME_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : Silverstone B2F COME
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${COME_REV}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         parse_string=Board Mfg.+: Celestica,Board Product.+: Switch Board,Board Serial.+: ${SWITCH_BOARD_SN},Board Part Number.+: ${SWITCH_BOARD_PN},Board Extra.+: ${SWITCH_BOARD_REV}
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Switch Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${SWITCH_BOARD_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${SWITCH_BOARD_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${SWITCH_BOARD_REV}
    ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan_board
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan control Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_SN}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${FAN_BOARD_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${FAN_BOARD_REV}
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN1}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN2}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN3}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN4}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan5
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN5}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan6
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN6}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
    # ${console}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan7
    # Should Match Regexp    ${console}    Board Mfg \ \ \ \ \ \ \ \ \ \ \ \ : Celestica
    # Should Match Regexp    ${console}    Board Product \ \ \ \ \ \ \ \ : Fan Board
    # Should Match Regexp    ${console}    Board Serial \ \ \ \ \ \ \ \ \ : ${FAN7}
    # Should Match Regexp    ${console}    Board Part Number \ \ \ \ : ${Fan_PN}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : ${Fan_Rev}
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : F2B
    # Should Match Regexp    ${console}    Board Extra \ \ \ \ \ \ \ \ \ \ : A00
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
    log.debug    **********************************
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # Should Contain    ${Fan_PN}    ${Fan_PN}
    # log.debug    ***** COMPARE P/N FAN1 - FAN7 *****
    # log.debug    P/N FAN1 - FAN7 : ${Fan_PN} \ \IS MATCH
    # log.debug    **********************************

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

EEPROM_FAN
    [Arguments]    ${command1}    ${command2}    ${command3}    ${command4}
    sleep    2s
    Diag_Telnet_Execute_Command_12              command=rm /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=cp /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/Master_fan.cfg /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE1/mfg_datetime=${command4}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE2/manufacturer=Celestica/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE3/product_name=Fan Board/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE4/serial_number=${command2}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE5/part_number=${command3}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE6/customer_1=${Fan_Rev}/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE7/customer_2=F2B/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg
    Diag_Telnet_Execute_Command_12              command=sed 's/LINE8/customer_3=A00/g' -i /home/cel_diag/silverstone/firmware/fru_eeprom/fru_cfg/fan${command1}.cfg

Diag_Component_EEPROM_Programing
    [Arguments]
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${PN}    R3250-F9004
    Run Keyword If     '${status}' == 'PASS'    Set Global Variable    ${Type_Board}    B2F
    Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Type_Board}    F2B

    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+261
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n
    Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.

    ${MAC}    Convert To List    ${Mac}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]

    

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t bmc
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t come
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t system
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t switch
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan2
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan3
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan4
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test --dump
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-2 -D ${BMC_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-3 -D ${BMC_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-5 -D ${BMC_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-6 -D ${BMC_Mac}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-7 -D ${UUID}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A p-8 -D ${PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A p-9 -D ${Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         parse_string=Passed,${BMC_SN},${BMC_PN},${BMC_Mac},${UUID},${PN},Product Extra.+${Rev},Board Extra.+${BMC_Rev}

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-2 -D ${COME_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-3 -D ${COME_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-6 -D ${COME_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         parse_string=Passed,${COME_SN},${COME_PN},Board Extra.+${COME_Rev}

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-2 -D ${Board_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-3 -D ${Board_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-6 -D ${Board_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-2 -D ${PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-3 -D ${Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-4 -D ${SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-8 -D ${MACADD}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         parse_string=Passed,${Board_SN},${Board_PN},Board Extra.+${Board_Rev},${PN},Product Version.+${Rev},${SN},${Type_Board},${MACADD}

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-2 -D ${SWITCH_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-3 -D ${SWITCH_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-5 -D ${SWITCH_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         parse_string=Passed,${SWITCH_SN},${SWITCH_PN}, Board Extra.+${SWITCH_Rev}

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-1 -D 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-2 -D ${FAN1_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-3 -D ${FAN1_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-6 -D ${FAN1_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
    ...                                         parse_string=Passed,${FAN1_BD_SN},${FAN1_BD_PN},Board Extra.+${FAN1_BD_Rev},${Type_Board},Board Product : 1

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-1 -D 2
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-2 -D ${FAN2_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-3 -D ${FAN2_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-6 -D ${FAN2_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
    ...                                         parse_string=Passed,${FAN2_BD_SN},${FAN2_BD_PN},Board Extra.+${FAN2_BD_Rev},${Type_Board},Board Product : 2

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-1 -D 3
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-2 -D ${FAN3_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-3 -D ${FAN3_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-6 -D ${FAN3_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
    ...                                         parse_string=Passed,${FAN3_BD_SN},${FAN3_BD_PN},Board Extra.+${FAN3_BD_Rev},${Type_Board},Board Product : 3

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-1 -D 4
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-2 -D ${FAN4_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-3 -D ${FAN4_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-6 -D ${FAN4_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
    ...                                         parse_string=Passed,${FAN4_BD_SN},${FAN4_BD_PN},Board Extra.+${FAN4_BD_Rev},${Type_Board},Board Product : 4

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test --dump
    ...                                         expect_string=Passed


Diag_Component_EEPROM_Programing_Audit
    [Arguments]
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${PN}    R3250-F9004
    Run Keyword If     '${status}' == 'PASS'    Set Global Variable    ${Type_Board}    B2F
    Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Type_Board}    F2B

    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+261
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n
    Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.

    ${MAC}    Convert To List    ${Mac}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]

    

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t bmc
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t come
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t system
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t switch
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan2
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan3
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -w -t fan4
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test --dump
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-2 -D ${BMC_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-3 -D ${BMC_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-5 -D ${BMC_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-6 -D ${BMC_Mac}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A b-7 -D ${UUID}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A p-8 -D ${PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t bmc -A p-9 -D ${Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         parse_string=Passed,${BMC_SN},${BMC_PN},${BMC_Mac},${UUID},${PN},Product Extra.+${Rev},Board Extra.+${BMC_Rev}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-2 -D ${COME_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-3 -D ${COME_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t come -A b-6 -D ${COME_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         parse_string=Passed,${COME_SN},${COME_PN},Board Extra.+${COME_Rev}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-2 -D ${Board_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-3 -D ${Board_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A b-6 -D ${Board_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-2 -D ${PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-3 -D ${Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-4 -D ${SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-7 -D ${Type_Board}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t system -A p-8 -D ${MACADD}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         parse_string=Passed,${Board_SN},${Board_PN},Board Extra.+${Board_Rev},${PN},Product Version.+${Rev},${SN},${Type_Board},${MACADD}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-2 -D ${SWITCH_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-3 -D ${SWITCH_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t switch -A b-5 -D ${SWITCH_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         parse_string=Passed,${SWITCH_SN},${SWITCH_PN}, Board Extra.+${SWITCH_Rev}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-1 -D 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-2 -D ${FAN1_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-3 -D ${FAN1_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-6 -D ${FAN1_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan1 -A b-7 -D ${Type_Board}
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
                    ...                                         parse_string=Passed,${FAN1_BD_SN},${FAN1_BD_PN},Board Extra.+${FAN1_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard1}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard1}      BoardProduct:1
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 1"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 1"\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-1 -D 2
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-2 -D ${FAN2_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-3 -D ${FAN2_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-6 -D ${FAN2_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan2 -A b-7 -D ${Type_Board}
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
                    ...                                         parse_string=Passed,${FAN2_BD_SN},${FAN2_BD_PN},Board Extra.+${FAN2_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard2}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard2}      BoardProduct:2
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 2"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 2"\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-1 -D 3
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-2 -D ${FAN3_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-3 -D ${FAN3_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-6 -D ${FAN3_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan3 -A b-7 -D ${Type_Board}
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
                    ...                                         parse_string=Passed,${FAN3_BD_SN},${FAN3_BD_PN},Board Extra.+${FAN3_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard3}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard3}      BoardProduct:3
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 3"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 3"\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-1 -D 4
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-2 -D ${FAN4_BD_SN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-3 -D ${FAN4_BD_PN}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-6 -D ${FAN4_BD_Rev}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -k -t fan4 -A b-7 -D ${Type_Board}
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
                    ...                                         parse_string=Passed,${FAN4_BD_SN},${FAN4_BD_PN},Board Extra.+${FAN4_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard4}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard4}      BoardProduct:4
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 4"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 4"\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test --dump
    ...                                         expect_string=Passed
    ...                                 unexpect_string=XXX


Diag_Component_EEPROM_Check
    [Arguments]
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${PN}    R3250-F9004
    Run Keyword If     '${status}' == 'PASS'    Set Global Variable    ${Type_Board}    B2F
    Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Type_Board}    F2B

    ${MACADDRESS}    Convert To Integer    ${MAC}    16 
    ${loop_count}     Evaluate     ${MACADDRESS}+261
    ${BMC_Mac}    Convert To HEX    ${loop_count}
    ${Maccount}      Get Length     ${BMC_Mac}
    ${BMC_Mac_count}    Evaluate    12-${Maccount}
    ${BMC_Mac_count}=    Get Substring    ${MAC}    0    ${BMC_Mac_count}
    ${BMC_Mac}    Set Variable If    '12' != '${Maccount}'    ${BMC_Mac_count}${BMC_Mac}    ${BMC_Mac}
    ${Maccount}      Get Length     ${BMC_Mac}
    log.debug    The last BMC mac is: ${BMC_Mac}\n
    Run Keyword If     '12' != '${Maccount}'    Fail    The last mac is invalid ${BMC_Mac}.

    ${MAC}    Convert To List    ${Mac}
    ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t bmc
    ...                                         parse_string=Passed,${BMC_SN},${BMC_PN},${BMC_Mac},${UUID},${PN},Product Extra.+${Rev},Board Extra.+${BMC_Rev}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t come
    ...                                         parse_string=Passed,${COME_SN},${COME_PN},Board Extra.+${COME_Rev}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t system
    ...                                         parse_string=Passed,${Board_SN},${Board_PN},Board Extra.+${Board_Rev},${PN},Product Version.+${Rev},${SN},${Type_Board},${MACADD}
    ...                                 unexpect_string=XXX
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t switch
    ...                                         parse_string=Passed,${SWITCH_SN},${SWITCH_PN}, Board Extra.+${SWITCH_Rev}
    ...                                 unexpect_string=XXX
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan1
                    ...                                         parse_string=Passed,${FAN1_BD_SN},${FAN1_BD_PN},Board Extra.+${FAN1_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard1}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard1}      BoardProduct:1
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 1"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 1"\r
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan2
                    ...                                         parse_string=Passed,${FAN2_BD_SN},${FAN2_BD_PN},Board Extra.+${FAN2_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard2}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard2}      BoardProduct:2
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 2"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 2"\r
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan3
                    ...                                         parse_string=Passed,${FAN3_BD_SN},${FAN3_BD_PN},Board Extra.+${FAN3_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard3}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard3}      BoardProduct:3
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 3"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 3"\r
    ${output}=      Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test -r -t fan4
                    ...                                         parse_string=Passed,${FAN4_BD_SN},${FAN4_BD_PN},Board Extra.+${FAN4_BD_Rev},${Type_Board}
                    ...                                 unexpect_string=XXX
    ${Fanboard4}    Remove String	    ${output}    ${SPACE}
    ${status}   ${output}=              Run Keyword And Ignore Error    Should Contain    ${Fanboard4}      BoardProduct:4
    Run Keyword If                      '${status}' == 'FAIL'    FAIL    Did not find Message "Board Product : 4"
    Run Keyword If                      '${status}' == 'PASS'    Save_to_logs    Found expect string "Board Product : 4"\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-bmc-test --dump
    ...                                         expect_string=Passed
    ...                                 unexpect_string=XXX

Diag_CPLD_and_FPGA_access_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test --all
    ...                                         expect_string=cpld test all: Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test -w -d 2 -R 1 -D 1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test -r -d 1 -R 1
    ...                                         expect_string=Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test -l

Diag_FAN_CPLD_access_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -w -R 2 -D 0x10
    ...                                         expect_string=write Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -r -R 1
    ...                                         expect_string=read Passed
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x01 0x00
    sleep    1s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test --all
    ...                                         expect_string=cpld test all: Passed
    ...                                         unexpect_string=Failed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -w -R 2 -D 0x01
    ...                                         expect_string=write Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -r -R 2
    ...                                         expect_string=read Passed
    sleep    1s
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x06 0x01 0x01
    sleep    5s

Diag_LED_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test --all
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x42 0x02 0x00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Off
    ...                                         expect_string=Set system_led Off
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Solid_Green_On
    ...                                         expect_string=Set system_led Solid_Green_On
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Solid_Amber_On
    ...                                         expect_string=Set system_led Solid_Amber_On
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Amber_Blink_1_Hz
    ...                                         expect_string=Set system_led Amber_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Amber_Blink_4_Hz
    ...                                         expect_string=Set system_led Amber_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Green_Blink_1_Hz
    ...                                         expect_string=Set system_led Green_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Green_Blink_4_Hz
    ...                                         expect_string=Set system_led Green_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Alternate_Blink_1_Hz
    ...                                         expect_string=Set system_led Alternate_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 1 -D Alternate_Blink_4_Hz
    ...                                         expect_string=Set system_led Alternate_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Off
    ...                                         expect_string=Set alarm_led Off
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Solid_Green_On
    ...                                         expect_string=Set alarm_led Solid_Green_On
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Solid_Amber_On
    ...                                         expect_string=Set alarm_led Solid_Amber_On
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Amber_Blink_1_Hz
    ...                                         expect_string=Set alarm_led Amber_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Amber_Blink_4_Hz
    ...                                         expect_string=Set alarm_led Amber_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Green_Blink_1_Hz
    ...                                         expect_string=Set alarm_led Green_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Green_Blink_4_Hz
    ...                                         expect_string=Set alarm_led Green_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Alternate_Blink_1_Hz
    ...                                         expect_string=Set alarm_led Alternate_Blink_1_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 2 -D Alternate_Blink_4_Hz
    ...                                         expect_string=Set alarm_led Alternate_Blink_4_Hz
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 3 -D Off
    ...                                         expect_string=Set psu_led Off
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 3 -D Green
    ...                                         expect_string=Set psu_led Green
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 3 -D Amber
    ...                                         expect_string=Set psu_led Amber
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 4 -D Off
    ...                                         expect_string=Set fan_led Off
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 4 -D Green
    ...                                         expect_string=Set fan_led Green
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t led -d 4 -D Amber
    ...                                         expect_string=Set fan_led Amber
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t fan -d 1/2/3/4 -D Off
    ...                                         expect_string=Set fan1_led Off
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t fan -d 1/2/3/4 -D Green
    ...                                         expect_string=Set fan1_led Green
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-ipmi-test -w -t fan -d 1/2/3/4 -D Amber
    ...                                         expect_string=Set fan1_led Amber
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x42 0x02 0x01

Diag_SFP_QSFP_port_LEDs_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-led-test --all
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-led-test -w -d 1 -D amber
    ...                                         expect_string=Set sfp_led amber
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-led-test -w -d 2 -D yellow
    ...                                         expect_string=Set port_led1 yellow
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-led-test -m -d 1 -D normal
    ...                                         expect_string=set normal mode passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-led-test -m -d 2 -D normal
    ...                                         expect_string=set normal mode passed

Diag_QSFP_Control_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sfp-test --all
    ...                                         expect_string=OPT testall: Passed

Diag_SFP_and_QSFP_EEPROM_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-qsfp-test --all
    ...                                 unexpect_string=absent,Absent
    ...                                         parse_string=qsfp 1.+Present,qsfp 2.+Present,qsfp 3.+Present,qsfp 4.+Present,qsfp 5.+Present,qsfp 6.+Present,qsfp 7.+Present,qsfp 8.+Present,qsfp 9.+Present,qsfp10.+Present,qsfp11.+Present,qsfp12.+Present,qsfp13.+Present,qsfp14.+Present,qsfp15.+Present,qsfp16.+Present,qsfp17.+Present,qsfp18.+Present,qsfp19.+Present,qsfp20.+Present,qsfp21.+Present,qsfp22.+Present,qsfp23.+Present,qsfp24.+Present,qsfp25.+Present,qsfp26.+Present,qsfp27.+Present,qsfp28.+Present,qsfp29.+Present,qsfp30.+Present,qsfp31.+Present,qsfp32.+Present

Diag_PSU_All_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --all
    ...                                         expect_string=Psu test : Passed

Diag_PSU_test
    # Diag_Telnet_Execute_Command         command=ipmitest power on
    # ...                                 wait_for=#
    Diag_Telnet_Execute_Command         command=ipmitest sdr elist | grep _Status
    ...                                         parse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected,PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                 wait_for=#
    Swap_COME
    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --all
    ...                                         expect_string=Psu test : Passed
    ${output1}                          Diag_Telnet_Execute_Command_12              command=ipmitool fru print 3
    ${output2}                          Diag_Telnet_Execute_Command_12              command=ipmitool fru print 4
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
    Diag_Telnet_Execute_Command         command=ipmitest sdr elist | grep _Status
    ...                                         parse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected,PSU2_Status.+39h.+ok.+10.2
    ...                                         unparse_string=PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                 wait_for=#

Diag_PSU_test_2
    # Diag_Telnet_Execute_Command         command=ipmitest power on
    # ...                                 wait_for=#
    Diag_Telnet_Execute_Command         command=ipmitest sdr elist | grep _Status
    ...                                         parse_string=PSU1_Status.+2Fh.+ok.+10.1,PSU2_Status.+39h.+ok.+10.2.+Presence detected
    ...                                         unparse_string=PSU1_Status.+2Fh.+ok.+10.1.+Presence detected
    ...                                 wait_for=#

Diag_PSU_Redundant_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
    ...                                         expect_string=PSU test : Passed
    ...                                 time_out=300
    Power_Off_apc_1
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
                                                            ...                                         parse_string=PSU1_CIn.+Failed,PSU1_COut.+Failed,PSU1_VIn.+Failed,PSU1_VOut.+Failed,PSU1_PIn.+Failed,PSU1_POut.+Failed
                                                            ...                                 time_out=300
    Run Keyword If    '${status}' == 'FAIL'     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
                                                ...                                         parse_string=PSU2_CIn.+Failed,PSU2_COut.+Failed,PSU2_VIn.+Failed,PSU2_VOut.+Failed,PSU2_PIn.+Failed,PSU2_POut.+Failed
                                                ...                                 time_out=300
    Power_On_apc_1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
    ...                                         expect_string=PSU test : Passed
    ...                                 time_out=300
    Power_Off_apc_2
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
                                                            ...                                         parse_string=PSU2_CIn.+Failed,PSU2_COut.+Failed,PSU2_VIn.+Failed,PSU2_VOut.+Failed,PSU2_PIn.+Failed,PSU2_POut.+Failed
                                                            ...                                 time_out=300
    Run Keyword If    '${status}' == 'FAIL'     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
                                                ...                                         parse_string=PSU1_CIn.+Failed,PSU1_COut.+Failed,PSU1_VIn.+Failed,PSU1_VOut.+Failed,PSU1_PIn.+Failed,PSU1_POut.+Failed
                                                ...                                 time_out=300
    Power_On_apc_2
    Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-ipmi-test --all
    ...                                         expect_string=PSU test : Passed
    ...                                 time_out=300

Diag_Temperature_CPU_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-temp-test --all
    ...                                         expect_string=Temp test all --> Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-temp-test -r -d 1

Diag_Temperature_BMC_test
    Sleep    3s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-temp-bmc-test -r --all
    ...                                         expect_string=Read sensor temp : Passed

Diag_RTC_Access_Test
    ## Get UTC Time## date +'%Y%m%d %H%M%S'
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test --all
    ...                                         expect_string=RTC test : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -r
    START_SSH_Get_RTC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -w -D '${RTC_GET}'
    ...                                         expect_string=successfully
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -r
    Diag_Login_And_Connect
    START_SSH_Compare_RTC

Diag_Memory_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --all
    ...                                         expect_string=MEM test: Passed

Diag_Fan_Speed_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --all
    ...                                         expect_string=Fan Test all Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -S -d 1 -D 20
    ...                                         expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -S -d 1 -D 50
    ...                                         expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -S -d 1 -D 100
    ...                                         expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -S -d 1 -D 50
    ...                                         expect_string=set fan type 1 Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 1
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 2
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 3
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 4
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 5
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 6
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 7
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 8
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 9
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 10
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 11
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 12
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 13
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 14
    ...                                         expect_string=Read \ fan \ Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 15
    ...                                         expect_string=Read \ fan \ Passed
    
Diag_PCIe_test 
    Diag_Telnet_Execute_Command_12              command=./bin/cel-pci-test --all
    ...                                         expect_string=PCIe test : Passed

Diag_edit_cpu_yaml
    ${CPU_Log}              Diag_Telnet_Execute_Command_12              command=cat /proc/cpuinfo
    ${version_cpu}          Get Lines Containing String                 ${CPU_Log}    model name
    ${version_cpu}          Get Line                                    ${version_cpu}     0
    ${version_cpu}          Fetch From Right                            ${version_cpu}     :${SPACE}
    ${version_cpu}          Remove String                               ${version_cpu}    ${SPACE}
    # Save_to_logs            ${version_cpu}\n
    ${CPU_Log}              Diag_Telnet_Execute_Command_12              command=cat /sys/devices/system/cpu/present
    ${core_cpu}             Get Line                                    ${CPU_Log}    0
    ${core_cpu}             Fetch From Right                            ${core_cpu}    -
    ${core_cpu}             Convert To Integer                          ${core_cpu}
    ${core_cpu}             Evaluate                                    ${core_cpu}+1
    # Save_to_logs            ${core_cpu}\n
    ${CPU_yaml}             Diag_Telnet_Execute_Command_12              command=cat /home/cel_diag/silverstone/diag_configs/cpu.yaml
    ${core_yaml}            Get Lines Containing String                 ${CPU_yaml}    cpu_cores:
    ${version_cpu__yaml}    Get Lines Containing String                 ${CPU_yaml}    Model_name:
    ${version_cpu__yaml}    Remove String                               ${version_cpu__yaml}    Diag#
    # ${version_cpu__yaml}    Remove String                               ${version_cpu__yaml}    ${SPACE}
    ${version_cpu__yaml}    Fetch From Right                            ${version_cpu__yaml}    :${SPACE}
    ${core_yaml}            Split String                                ${core_yaml}
    Diag_Telnet_Execute_Command_12              command=sed 's/${core_yaml}[0]${SPACE*2}${core_yaml}[1]/${core_yaml}[0]${SPACE*2}${core_cpu}/g' -i /home/cel_diag/silverstone/diag_configs/cpu.yaml
    Diag_Telnet_Execute_Command_12              command=sed 's/${version_cpu__yaml}/"${version_cpu}"/g' -i /home/cel_diag/silverstone/diag_configs/cpu.yaml
    Diag_Telnet_Execute_Command_12              command=cat /home/cel_diag/silverstone/diag_configs/cpu.yaml

Diag_CPU_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpu-test --all
    ...                                         expect_string=CPU test : Passed
    ...                                         unexpect_string=fail,failed,Fail,Failed,FAIL,FAILED

Diag_TPM_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-tpm-test -all
    ...                                         expect_string=TPM test all Passed

Diag_SOL_functional_test
    Swap_BMC
    sleep  5
    # Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    
    # sleep  1
    Diag_Telnet_Execute_BMC             command=ifconfig eth0 ${BMC_IP_2} up
    sleep  5
    Diag_Telnet_Execute_BMC             command=ifconfig
    ...                                 wait_for=${BMC_IP_2}
    
    # log.debug  send ping command
    # Telnet.Write    ping "${local_host_ip}" -c5
    # ${stdout} =      Telnet.Read Until               \#
    # ${stdout} =      Telnet.Read Until               \#
    # Save_to_logs      msg=${stdout}
    # Should Contain    ${stdout}     5 received

    sleep  20
    START_SSH_server



    # ${out1}=    write    ipmitool -I lanplus -H ${IPP2}${IPP} -U admin -P admin sol set volatile-bit-rate 9.6 
    # log.debug    ${out1}
    # sleep    2s
    # ${out1}=    write    ipmitool -I lanplus -H ${IPP2}${IPP} -U admin -P admin sol set non-volatile-bit-rate 9.6
    # log.debug    ${out1}
    # sleep    2s
    # ${out1}=    write    ipmitool -I lanplus -H ${IPP2}${IPP} -U admin -P admin sol activate



    log.debug    sending command --> ipmitool -I lanplus -H ${BMC_IP_2} -U admin -P admin sol activate
    # SSHLibrary.Write    ipmitool -I lanplus -H ${BMC_IP_2} -U admin -P admin sol activate
    ${output}=    SSHLibrary.Write    ipmitool -I lanplus -H ${BMC_IP_2} -U admin -P admin sol activate
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    SOL Session operational
    Save_to_logs       ${output}\r

    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Write    rm onie-installer-x86_64-cel_midstone-100x-r0.bin
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
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpu-test --all
    ...                                         expect_string=CPU test : Passed

Diag_Fan_BMC_test_F2B
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       /home/cel_diag/silverstone/bin
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/cel-fan-ipmi-test /home/cel_diag/silverstone/bin
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE
    Diag_Telnet_Execute_Command_12              command=chmod 777 cel-fan-ipmi-test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    ...                                         expect_string=Fan Test all Passed
    ...                                 time_out=900
    
    # Fan1_Front       | 5520
    # Fan1_Rear        | 5700


    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_100_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_100_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_100_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_100_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_100_max}    ${psu_fan_limit_100_min}

    END
    
    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_50_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_50_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_50_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_50_max}    ${psu_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_20_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_20_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_20_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_20_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_20_max}    ${psu_fan_limit_20_min}

    END

    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END
    Run Keyword If    '${Fan_fail}' == '1'    FAIL    !!!!! Fan speed test over Limit !!!!!

Diag_Fan_BMC_test_B2F
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       /home/cel_diag/silverstone/bin
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/cel-fan-ipmi-test /home/cel_diag/silverstone/bin
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE
    Diag_Telnet_Execute_Command_12              command=chmod 777 cel-fan-ipmi-test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    # ...                                         expect_string=Fan Test all Passed     #Script for DVT2 build
    ...                                 time_out=900
    
    # Fan1_Front       | 5520
    # Fan1_Rear        | 5700


    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_100_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_100_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_100_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_100_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_100_max}    ${psu_fan_limit_100_min}

    END
    
    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_50_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_50_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_50_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_50_max}    ${psu_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_20_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_20_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_20_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_20_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_20_max}    ${psu_fan_limit_20_min}

    END

    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END
    Run Keyword If    '${Fan_fail}' == '1'    FAIL    !!!!! Fan speed test over Limit !!!!!

Diag_Fan_BMC_test_F2B_BI
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       /home/cel_diag/silverstone/bin
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/cel-fan-ipmi-test /home/cel_diag/silverstone/bin
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE
    Diag_Telnet_Execute_Command_12              command=chmod 777 cel-fan-ipmi-test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    ...                                         expect_string=Fan Test all Passed
    ...                                 time_out=900
    
    # Fan1_Front       | 5520
    # Fan1_Rear        | 5700


    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_100_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_100_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_100_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_100_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_100_max}    ${psu_fan_limit_100_min}

    END
    
    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_50_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_50_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_50_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_50_max}    ${psu_fan_limit_50_min}

    END

    # FOR     ${i}    IN RANGE    1   5
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_F2B.front_fan_limit_20_max}    ${Fan_Speed_tpye_F2B.front_fan_limit_20_min}

    #     ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
  
    #     VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_F2B.rear_fan_limit_20_max}    ${Fan_Speed_tpye_F2B.rear_fan_limit_20_min}

    # END

    # FOR     ${i}    IN RANGE    5   7
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
    #     ${index}=    Evaluate    ${i} - 4
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_20_max}    ${psu_fan_limit_20_min}

    # END

    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END
    Run Keyword If    '${Fan_fail}' == '1'    FAIL    !!!!! Fan speed test over Limit !!!!!

Diag_Fan_BMC_test_B2F_BI
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       /home/cel_diag/silverstone/bin
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/cel-fan-ipmi-test /home/cel_diag/silverstone/bin
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE
    Diag_Telnet_Execute_Command_12              command=chmod 777 cel-fan-ipmi-test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    # ...                                         expect_string=Fan Test all Passed     #Script for DVT2 build
    ...                                 time_out=900
    
    # Fan1_Front       | 5520
    # Fan1_Rear        | 5700


    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_100_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_100_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_100_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_100_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_100_max}    ${psu_fan_limit_100_min}

    END
    
    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_50_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_50_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_50_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_50_min}

    END

    FOR     ${i}    IN RANGE    5   7
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${index}=    Evaluate    ${i} - 4
        ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_50_max}    ${psu_fan_limit_50_min}

    END

    # FOR     ${i}    IN RANGE    1   5
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${Fan_Speed_tpye_B2F.front_fan_limit_20_max}    ${Fan_Speed_tpye_B2F.front_fan_limit_20_min}

    #     ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
  
    #     VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${Fan_Speed_tpye_B2F.rear_fan_limit_20_max}    ${Fan_Speed_tpye_B2F.rear_fan_limit_20_min}

    # END

    # FOR     ${i}    IN RANGE    5   7
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
    #     ${index}=    Evaluate    ${i} - 4
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_20_max}    ${psu_fan_limit_20_min}

    # END

    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END
    Run Keyword If    '${Fan_fail}' == '1'    FAIL    !!!!! Fan speed test over Limit !!!!!

Diag_Fan_BMC_test_BI
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    # ...                                         expect_string=Fan Test all Passed
    # ...                                 time_out=900
    
    # Fan1_Front       | 5520
    # Fan1_Rear        | 5700

    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${front_fan_limit_20_max}    ${front_fan_limit_20_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${rear_fan_limit_20_max}    ${rear_fan_limit_20_min}

    END

    # FOR     ${i}    IN RANGE    5   7
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
    #     ${index}=    Evaluate    ${i} - 4
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_20_max}    ${psu_fan_limit_20_min}

    # END

    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${front_fan_limit_50_max}    ${front_fan_limit_50_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${rear_fan_limit_50_max}    ${rear_fan_limit_50_min}

    END

    # FOR     ${i}    IN RANGE    5   7
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
    #     ${index}=    Evaluate    ${i} - 4
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_50_max}    ${psu_fan_limit_50_min}

    # END

    FOR     ${i}    IN RANGE    1   5
        ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Front
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
 
        VERIFY NUMBER LIMIT     Fan${i}_Front   ${val}   ${front_fan_limit_100_max}    ${front_fan_limit_100_min}

        ${out_put1}=   Get Lines Containing String   ${std_out}   Fan${i}_Rear
        ${val}=  Split String   ${out_put1}  |
        ${val}=  Strip String   ${val}[-1]
  
        VERIFY NUMBER LIMIT     Fan${i}_Rear   ${val}   ${rear_fan_limit_100_max}    ${rear_fan_limit_100_min}

    END

    # FOR     ${i}    IN RANGE    5   7
    #     ${std_out}=    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
    #     ${index}=    Evaluate    ${i} - 4
    #     ${out_put1}=   Get Lines Containing String   ${std_out}   PSU${index}_Fan
    #     ${val}=  Split String   ${out_put1}  |
    #     ${val}=  Strip String   ${val}[-1]
 
    #     VERIFY NUMBER LIMIT     PSU${index}_Fan   ${val}   ${psu_fan_limit_100_max}    ${psu_fan_limit_100_min}

    # END
    
    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END

VERIFY NUMBER LIMIT
    [Arguments]   ${cap_val}   ${actual_val}   ${limit_max}   ${limit_min}
    log.debug   ********************************************************************\r
    log.debug   ------------------------- Verify limit------------------------------\r
    log.debug   ********************************************************************\r
    log.debug   Verify limit name = ${cap_val}\r
    log.debug   UUT actual value ${space}= ${actual_val}\r
    log.debug   Max limit is ${space}${space} ${space} = ${limit_max}\r
    log.debug   Min limit is ${space}${space} ${space} = ${limit_min}\r
    ${verify_result}=    Evaluate      ${limit_max}>${actual_val}>${limit_min}
    Run Keyword If    '${verify_result}' == 'False'    log.debug   !!!!!!!!!!!!!!!!!! Verify Limit Fail over limit !!!!!!!!!!!!!!!!\r
    Run Keyword If    '${verify_result}' == 'False'    log.debug   !!!!!!!!!!!!!!!!!! ${limit_max}>${actual_val}>${limit_min} !!!!!!!!!!!!!!!!\r
    Run Keyword If    '${verify_result}' == 'False'    Set Global Variable    ${Fan_fail}    1
    Run Keyword If    '${verify_result}' == 'True'    log.debug   Limit verify ${space}${space} ${space} = !!! ${space} P A S S E D ${space} !!!\r
    log.debug   ********************************************************************\r



Diag_Fan_BMC_test_bkk
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test --all 
    ...                                         expect_string=Fan Test all Passed
    ...                                 time_out=900
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d 1 -D 20
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 1 
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 2
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 3
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 4
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 5
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 6
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 7
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 8
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 9
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 10
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d 1 -D 50
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 1 
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 2
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 3
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 4
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 5
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 6
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 7
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 8
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 9
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 10
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d 1 -D 100
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 1 
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 2
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 3
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 4
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 5
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 6
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 7
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 8
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 9
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d 10
    FOR     ${i}    IN RANGE    1   5
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ...                                         parse_string=Fan${i}_Front.+[2-3][0-9]{3},Fan${i}_Rear.+[2-3][0-9]{3}
    END
    sleep    10s
    FOR     ${i}    IN RANGE    5   7
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 20
        ...                                         parse_string=[6-9][0-9]{3}|1[0-2][0-9]{3}
    END
    FOR     ${i}    IN RANGE    1   5
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ...                                         parse_string=Fan${i}_Front.+[5-7][0-9]{3},Fan${i}_Rear.+[5-7][0-9]{3}
    END
    sleep    10s
    FOR     ${i}    IN RANGE    5   7
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 50
        ...                                         parse_string=1[0-6][0-9]{3}
    END
    FOR     ${i}    IN RANGE    1   5
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ...                                         parse_string=Fan${i}_Front.+1[0-3][0-9]{3},Fan${i}_Rear.+1[0-3][0-9]{3}
    END
    sleep    10s
    FOR     ${i}    IN RANGE    5   7
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -S -d ${i} -D 100
        ...                                         parse_string=2[2-7][0-9]{3}
    END
    FOR     ${i}    IN RANGE    1   11
        Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-ipmi-test -r -d ${i}
    END

Diag_Uart_MUX_test
    Swap_BMC
    Swap_COME
    
Diag_Uart_internal_test
    Diag_SSH_Execute_Command            command=./bin/cel-uart-test --all
    ...                                         expect_string=Uart Test : PASSED
    Diag_SSH_Execute_Command            command=./bin/cel-uart-test -w -d 1 -t cfg -D "115200 8 0 e"
    ...                                         expect_string=Passed
    Diag_SSH_Execute_Command            command=./bin/cel-uart-test -r -d 1 -t cfg
    ...                                         expect_string=Passed
    Diag_Login_And_Connect

Diag_Sata_SSD_Test
    # MtEcho_usb_plug
    # log.debug    \n*************** USB has been pluged ***************\r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                         expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -t --all
    ...                                         expect_string=SSD test : Passed
    # Diag_Telnet_Execute_Command_12              command=smartctl -a /dev/sda
    # ...                                         expect_string=result: PASSED,${Firmware_Version.SSD_FW_Version}

Diag_Sata_SSD_Test_BI
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                         expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -t --all
    ...                                         expect_string=SSD test : Passed
    Diag_Telnet_Execute_Command_12              command=smartctl -a /dev/sda
    ...                                         expect_string=result: PASSED,${Firmware_Version.SSD_FW_Version}

Diag_cpld_test_with_bmc
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test --all
    ...                                         expect_string=cpld test all : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -r -t 1 -R 1 
    ...                                         parse_string=${CPLD_Version}
    ...                                         unparse_string=FAIL
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-ipmi-test -w -t 1 -R 27 -D 0
    ...                                         parse_string=software_scratch.*0x01.*0x00
    ...                                         unparse_string=FAIL

Diag_Storage_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test --all
    ...                                         expect_string=Storage test : Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -w -d 2 -C 2
    # ...                                         expect_string=Storage write data : Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -r -d 2 -C 2
    # ...                                         expect_string=Storage read data : Passed
    # MtEcho_usb_remove
    # log.debug    \n*************** USB has been removed ***************\r

Diag_Storage_test_BI
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test --all
    ...                                         expect_string=Storage test : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -w -d 1 -C 10
    ...                                         expect_string=Storage write data : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test -r -d 1 -C 10
    ...                                         expect_string=Storage read data : Passed

# Diag_USB_test

Diag_PHY_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-phy-test --all 
    ...                                         expect_string=PHY test : Passed
    # SSH_to_Telnet                   ${time_out}
    # # SSHLibrary.Write    sudo su
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    # ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    # SSH_Send_Diag       cd /home/FW/
    # ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/phy.yaml_1000_1 /home/cel_diag/midstone100X/diag_configs/phys.yaml
    # Save_to_logs        ${output}
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    # SSHLibrary.Write Bare    em4dmin\r\n
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    # SSH_CLOSE
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-phy-test --all
    # ...                                         expect_string=PHY test : Passed
    # SSH_to_Telnet                   ${time_out}
    # # SSHLibrary.Write    sudo su
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    # ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    # SSH_Send_Diag       cd /home/FW/
    # ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/phy.yaml_100_1 /home/cel_diag/midstone100X/diag_configs/phys.yaml
    # Save_to_logs        ${output}
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    # SSHLibrary.Write Bare    em4dmin\r\n
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    # SSH_CLOSE
    # Diag_Telnet_Execute_Command_12              command=cat /home/cel_diag/midstone100X/diag_configs/phys.yaml
    # ...                                         expect_string=speed:${SPACE*4}100 
    # Check_LED_ethernet_green_Interaction
    # Change_Lan_white_to_red_Interaction
    # sleep  5s
    # Re_Login
    # Diag_Telnet_Execute_Command_phy            command=./bin/cel-phy-test --all
    # ...                                        wait_for=PHY test : Passed
    # ...                                        expect_string=PHY test : Passed
    # Check_LED_ethernet_orange_Interaction
    # Change_Lan_red_to_white_Interaction
    # sleep  5s
    # SSH_to_Telnet                   ${time_out}
    # # SSHLibrary.Write    sudo su
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    # ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    # SSH_Send_Diag       cd /home/FW/
    # ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/phy.yaml_1000_1 /home/cel_diag/midstone100X/diag_configs/phys.yaml
    # Save_to_logs        ${output}
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    # SSHLibrary.Write Bare    em4dmin\r\n
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    # SSH_CLOSE
    # Diag_Telnet_Execute_Command_12              command=cat /home/cel_diag/midstone100X/diag_configs/phys.yaml
    # ...                                         expect_string=speed:${SPACE*4}1000 

Diag_Present_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-present-ipmi-test --all
    ...                                         expect_string=Fan Present test : Passed

Diag_BMC_I2C_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-i2c-bmc-test -s --all
    ...                                         expect_string=I2C BMC test : Passed
    ...                                         time_out=300
    Diag_Telnet_Execute_Command_12              command=./bin/cel-i2c-bmc-test -r -p /dev/i2c-8 -A 0x0d -R 0x32 -C 1
    ...                                         expect_string=I2C BMC read:Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-i2c-bmc-test -w -p /dev/i2c-8 -A 0x0d -R 0x32 -D 0x20 -C 1
    ...                                         expect_string=I2C BMC write:Passed

Diag_CPU_I2C_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-i2c-test --all
    ...                                         expect_string=I2C test : Passed
    Diag_Telnet_Execute_Command_12              command=cel-i2c-test -s --bus 0

Diag_Sysinfo_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test --all
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 1
    ...                                         expect_string=2.0.0
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 2
    ...                                         expect_string=10005
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 3
    ...                                         expect_string=0x05
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 4
    ...                                         expect_string=0x00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 5
    ...                                         expect_string=0x00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 6
    ...                                         expect_string=0x07
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 7
    ...                                         expect_string=0x3
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 8
    ...                                         expect_string=02 00
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sysinfo-test -d 9
    ...                                         expect_string=02 00
    
Diag_Sensor_test
    Diag_Telnet_Execute_Command_12              command=ipmitool sensor
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sensor-ipmi-test --all
    # ...                                         expect_string=Sensor test : Passed
    ...                                 time_out=600

Diag_Sensor_test_BI
    Diag_Telnet_Execute_Command_12              command=ipmitool sensor
    Diag_Telnet_Execute_Command_12              command=./bin/cel-sensor-ipmi-test --all
    # ...                                         expect_string=Sensor test : Passed
    ...                                 time_out=600

SDK_Load_SDK
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
    TELNET_Send_Command_expect_prompt           exit    \#

SDK_400G_QSFP-DD_Loopback_Traffic_Test
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
    SSH_Send_traffic                            sleep 90    120s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    SSH_Send_traffic                            rcload snake_loopback_32x400G.soc
    SSH_Send_traffic                            clear c 
    SSH_Send_traffic                            tx 1000 length=512 pbm=cd0 vlan=100
    SSH_Send_traffic                            sleep 180    240s
    SSH_Send_traffic                            port cd0 en=0
    SSH_Send_traffic                            ps
    SSH_Send_traffic                            port cd0 en=1
    ${CDMIB_TPKT}    SSH_Send_traffic           show c CDMIB_TPKT
    ${CDMIB_RPKT}    SSH_Send_traffic           show c CDMIB_RPKT
    TELNET_Send_Command_expect_prompt           exit    \#
    SDK_Package_check    ${CDMIB_TPKT}    ${CDMIB_RPKT}

SDK_400G_QSFP-DD_Loopback_Traffic_Test_BI
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
    SSH_Send_traffic                            sleep 90    120s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    SSH_Send_traffic                            rcload snake_loopback_32x400G.soc
    SSH_Send_traffic                            clear c 
    SSH_Send_traffic                            tx 1000 length=512 pbm=cd0 vlan=100
    SSH_Send_traffic                            sleep 600    660s
    SSH_Send_traffic                            sleep 600    660s
    SSH_Send_traffic                            sleep 600    660s
    SSH_Send_traffic                            sleep 600    660s
    SSH_Send_traffic                            port cd0 en=0
    SSH_Send_traffic                            ps
    SSH_Send_traffic                            port cd0 en=1
    ${CDMIB_TPKT}    SSH_Send_traffic           show c CDMIB_TPKT
    ${CDMIB_RPKT}    SSH_Send_traffic           show c CDMIB_RPKT
    TELNET_Send_Command_expect_prompt           exit    \#
    SDK_Package_check    ${CDMIB_TPKT}    ${CDMIB_RPKT}

Try_pkt
    ${CDMIB_TPKT}    Diag_Telnet_Execute_Command_12              command=cat tpkt.txt
    ...                                         path=/home/cel_sdk
    ${CDMIB_RPKT}    Diag_Telnet_Execute_Command_12              command=cat rpkt.txt
    ...                                         path=/home/cel_sdk
    SDK_Package_check    ${CDMIB_TPKT}    ${CDMIB_RPKT}

SDK_Package_check        
    [Arguments]    ${CDMIB_TPKT}    ${CDMIB_RPKT}       
    ${TPKT}=    Get Regexp Matches    ${CDMIB_TPKT}    \\s.+:\\s+(\\S+)\\s+(\\S+)    1   2
    ${RPKT}=    Get Regexp Matches    ${CDMIB_RPKT}    \\s.+:\\s+(\\S+)\\s+(\\S+)    1   2
        FOR    ${i}    IN RANGE    0    32      

            Run Keyword If    '${TPKT}[${i}][0]' == '${RPKT}[${i}][0]'    log.debug    CDMIB_TPKT.cd${i} == CDMIB_RPKT.cd${i} ----> ${TPKT}[${i}][0] == ${RPKT}[${i}][0]] Result Passed \n
            Run Keyword If    '${TPKT}[${i}][0]' != '${RPKT}[${i}][0]'    log.debug    CDMIB_TPKT.cd${i} != CDMIB_RPKT.cd${i} ----> ${TPKT}[${i}][0] != ${RPKT}[${i}][0] Result Failed \n
            Run Keyword If    '${TPKT}[${i}][0]' != '${RPKT}[${i}][0]'    Set Global Variable    ${SDK_PKT_Staus}    1  
        END 
        Run Keyword If    '${SDK_PKT_Staus}' == '1'    Fail    Check Package TC and RX Mismatch Failed !!!

SDK_PRBS_Test
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    SSH_Send_traffic                            phy diag cd prbs set p=3
    SSH_Send_traffic                            phy diag cd prbsstat
    SSH_Send_traffic                            phy diag cd prbsstat start i=120
    SSH_Send_traffic                            sleep 600    660s
    SSH_Send_traffic                            phy diag cd prbsstat ber
    SSH_Send_traffic                            sleep 600    660s
    ${PRBS_BER}         SSH_Send_traffic        phy diag cd prbsstat ber
    SSH_Send_traffic                            phy diag cd prbsstat clear
    SSH_Send_traffic                            phy diag cd prbsstat stop
    TELNET_Send_Command_expect_prompt           exit    \#
    PRBS_Ber_Check                              ${PRBS_BER}

SDK_PRBS_Test_BI
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If      '${i}' == '9'            MtEcho_Link_retry
        Run Keyword If      '${i}' == '10'           FAIL    !! Check Link down Fail !!
        SSH_Send_traffic    sleep 40
    END
    SSH_Send_traffic                            phy diag cd prbs set p=3
    SSH_Send_traffic                            phy diag cd prbsstat
    SSH_Send_traffic                            phy diag cd prbsstat start i=120
    SSH_Send_traffic                            sleep 120    180s
    SSH_Send_traffic                            phy diag cd prbsstat ber
    SSH_Send_traffic                            sleep 120    180s
    ${PRBS_BER}         SSH_Send_traffic        phy diag cd prbsstat ber
    SSH_Send_traffic                            phy diag cd prbsstat clear
    SSH_Send_traffic                            phy diag cd prbsstat stop
    TELNET_Send_Command_expect_prompt           exit    \#
    PRBS_Ber_Check                              ${PRBS_BER}

PRBS_Ber_Check
    [Arguments]    ${PRBS_BER}
    FOR    ${i}    IN RANGE    0    32
        ${BER_get}=             Get Lines Containing String    ${PRBS_BER}    cd${i}[
        ${BER_get_1}            Get Line            ${BER_get}    0
        ${BER_get_2}            Get Line            ${BER_get}    1
        ${BER_get_3}            Get Line            ${BER_get}    2
        ${BER_get_4}            Get Line            ${BER_get}    3
        ${BER_get_5}            Get Line            ${BER_get}    4
        ${BER_get_6}            Get Line            ${BER_get}    5
        ${BER_get_7}            Get Line            ${BER_get}    6
        ${BER_get_8}            Get Line            ${BER_get}    7
        ${BER_get_1}            Split String        ${BER_get_1}  
        ${BER_get_2}            Split String        ${BER_get_2}  
        ${BER_get_3}            Split String        ${BER_get_3}  
        ${BER_get_4}            Split String        ${BER_get_4}  
        ${BER_get_5}            Split String        ${BER_get_5}  
        ${BER_get_6}            Split String        ${BER_get_6}  
        ${BER_get_7}            Split String        ${BER_get_7}  
        ${BER_get_8}            Split String        ${BER_get_8}  
        Run Keyword If    ${BER_get_1}[2] <= 1e-6    log.debug    ${BER_get_1}[0] = ${BER_get_1}[2] Result Passed \n
        Run Keyword If    ${BER_get_1}[2] > 1e-6     log.debug    ${BER_get_1}[0] = ${BER_get_1}[2] Result Failed \n
        Run Keyword If    ${BER_get_1}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_2}[2] <= 1e-6    log.debug    ${BER_get_2}[0] = ${BER_get_2}[2] Result Passed \n
        Run Keyword If    ${BER_get_2}[2] > 1e-6     log.debug    ${BER_get_2}[0] = ${BER_get_2}[2] Result Failed \n
        Run Keyword If    ${BER_get_2}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_3}[2] <= 1e-6    log.debug    ${BER_get_3}[0] = ${BER_get_3}[2] Result Passed \n
        Run Keyword If    ${BER_get_3}[2] > 1e-6     log.debug    ${BER_get_3}[0] = ${BER_get_3}[2] Result Failed \n
        Run Keyword If    ${BER_get_3}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_4}[2] <= 1e-6    log.debug    ${BER_get_4}[0] = ${BER_get_4}[2] Result Passed \n
        Run Keyword If    ${BER_get_4}[2] > 1e-6     log.debug    ${BER_get_4}[0] = ${BER_get_4}[2] Result Failed \n
        Run Keyword If    ${BER_get_4}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_5}[2] <= 1e-6    log.debug    ${BER_get_5}[0] = ${BER_get_5}[2] Result Passed \n
        Run Keyword If    ${BER_get_5}[2] > 1e-6     log.debug    ${BER_get_5}[0] = ${BER_get_5}[2] Result Failed \n
        Run Keyword If    ${BER_get_5}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_6}[2] <= 1e-6    log.debug    ${BER_get_6}[0] = ${BER_get_6}[2] Result Passed \n
        Run Keyword If    ${BER_get_6}[2] > 1e-6     log.debug    ${BER_get_6}[0] = ${BER_get_6}[2] Result Failed \n
        Run Keyword If    ${BER_get_6}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_7}[2] <= 1e-6    log.debug    ${BER_get_7}[0] = ${BER_get_7}[2] Result Passed \n
        Run Keyword If    ${BER_get_7}[2] > 1e-6     log.debug    ${BER_get_7}[0] = ${BER_get_7}[2] Result Failed \n
        Run Keyword If    ${BER_get_7}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
        Run Keyword If    ${BER_get_8}[2] <= 1e-6    log.debug    ${BER_get_8}[0] = ${BER_get_8}[2] Result Passed \n
        Run Keyword If    ${BER_get_8}[2] > 1e-6     log.debug    ${BER_get_8}[0] = ${BER_get_8}[2] Result Failed \n
        Run Keyword If    ${BER_get_8}[2] > 1e-6     Set Global Variable    ${Ber_Staus}    1       
    END
    Run Keyword If    '${Ber_Staus}' == '1'    Fail    Check BER Value > 1e-6 Failed !!!

SDK_PCIE_FW_Update_Test
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/pcieg3fw.bin /home/cel_sdk/silverstone    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
    ${console}=         SSH_Send_traffic    pciephy fw load pcieg3fw.bin
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          PCIE firmware updated successfully
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Updated Not Successfully
    ${console}=         SSH_Send_traffic    pciephy fw version
    TELNET_Send_Command_expect_prompt           exit    \#
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          2.5
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect 2.5
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          D102_08
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect D102_08

SDK_PCIE_FW_Update_Test_BI
    # TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    # TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/pcieg3fw.bin /home/cel_sdk/silverstone    password
    # Diag_Telnet_Execute_Command          command=em4dmin    
    # ...                                  wait_for=#
    # ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt           cd /home/cel_sdk/silverstone/    \#
    TELNET_Send_Command_expect_prompt           ./auto_load_user.sh    BCM.0>
    # ${console}=         SSH_Send_traffic    pciephy fw load pcieg3fw.bin
    # ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          PCIE firmware updated successfully
    # Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Updated Not Successfully
    ${console}=         SSH_Send_traffic    pciephy fw version
    TELNET_Send_Command_expect_prompt           exit    \#
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          2.5
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect 2.5
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          D102_08
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect D102_08

Diag_Remote_Shell
    Diag_Telnet_Execute_Command_12                              command=./auto_load_user.sh -d
    ...                                                         path=/home/cel_sdk/silverstone/
    sleep     90
    ${output1}     TELNET_Send_Command_expect_prompt            command=cel_bcmshell ps
    ...                                                         wait_for=xe1(118)
    Should Contain X Times    ${output1}    up    34
    Diag_Telnet_Execute_Command_12                              command=cel_bcmshell exit
    ...                                                         path=/home/cel_sdk/silverstone/

Download_File_to_unit
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/cel-eeprom-test /home/cel_diag/silverstone/bin/    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/cel-mem-test /home/cel_diag/silverstone/bin/    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/cel-temp-test /home/cel_diag/silverstone/bin/    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/mem.yaml /home/cel_diag/silverstone/diag_configs    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/Pure_Storage/i2cs_ipmi.yaml /home/cel_diag/silverstone/diag_configs    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    
Diag_ETH_test 
    # Power_Cyling
    Diag_Telnet_Execute_Command_12              command=sed 's/"10.194.78.83"/"${SSH_IP}"/g' -i /home/cel_diag/midstone100X/diag_configs/eth.yaml
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eth-test --all
    ...                                         expect_string=ETH test : Passed
    Diag_Telnet_Execute_Command_12              command=sed 's/"${SSH_IP}"/"10.194.78.83"/g' -i /home/cel_diag/midstone100X/diag_configs/eth.yaml

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
    # Diag_Telnet_Execute_Command_12              command=ifconfig eth0 192.168.1.102 up
    # ...                                 wait_for=\#
    # Diag_Telnet_Execute_Command_12              command=ping 10.194.60.135 -c5
    # ...                                 wait_for=\#
    # ...                                         expect_string=5 received
    sleep  30
    Swap_COME
   
    Diag_Telnet_Execute_Command_12              command=cat eth.yaml
    ...                                 path=/home/cel_diag/midstone100X/diag_configs
    ...                                         expect_string=10.194.78.83

Diag_SPD_memory_test 
    # Need copie yam  /tftpboot/mem.yaml
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/FW/
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/mem.yaml/ /home/cel_diag/midstone100X/diag_configs
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE

    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --all
    ...                                         expect_string=Memory test: Passed
    

Diag_Power_control_test
    log.debug  ****************************************************\n
    log.debug  *************POWER TEST ON BMC PORT*****************\n
    log.debug  ****************************************************\n
    Swap_BMC
    Diag_Telnet_Execute_Command    command=ipmitest power off
    ...                            wait_for=--!!
    # Diag_Telnet_Execute_Command    command=ipmitest power on
    # ...                            wait_for=0x00
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power on
                                                            ...                            wait_for=0x00
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC

    sleep  30
    Diag_Telnet_Execute_Command    command=ipmitest power soft off
    ...                            wait_for=--!!
    # Diag_Telnet_Execute_Command    command=ipmitest power on
    # ...                            wait_for=0x00

    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power on
                                                            ...                            wait_for=0x00
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC

    sleep  30
    Diag_Telnet_Execute_Command    command=ipmitest mc reset warm
    ...                            wait_for=Starting lighttpd
    Diag_Telnet_Execute_Command    command=ipmitest mc reset cold
    ...                            wait_for=Session ID
    sleep  60
    log.debug  ****************************************************\n
    log.debug  *************POWER TEST ON COME PORT****************\n
    log.debug  ****************************************************\n
    Swap_BMC
    Swap_COME
    sleep  5
    Diag_Telnet_Execute_Command_12              command=cd /home/cel_diag/midstone100X
    Diag_Telnet_Execute_Command_12              command=./diag.sh
    sleep  5
  
    log.debug  sending command =>ipmitool power cycle
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitool power cycle
    ...                            wait_for=sonic login:
    ...                            time_out=360
    
    # log.debug    \nstatus is ----${status}\n 
    log.debug    \noutput is ----${output}\n
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    sleep  150
    Re_Login
    log.debug  sending command =>ipmitool power reset
    Diag_Telnet_Execute_Command    command=ipmitool power reset
    ...                            wait_for=sonic login:
    ...                            time_out=300
    Re_Login



    # Diag_Telnet_Execute_Command    command=ipmitool power cycle
    # ...                            wait_for=Loading SONiC-OS
    # ...                            time_out=500


Diag_BMC_Power_control_test
    log.debug  ****************************************************\n
    log.debug  *************POWER TEST ON BMC PORT*****************\n
    log.debug  ****************************************************\n
    Swap_BMC
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power off
                                                            ...                            wait_for=!!--PDK_PowerOffChassiss--!!
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest power off
                                               ...                            wait_for=!!--PDK_PowerOffChassiss--!!
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power on
                                                            ...                            wait_for=0xff
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest power on
                                               ...                            wait_for=0xff
    sleep  30
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power soft off
                                                            ...                            wait_for=--!!
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest power soft off
                                               ...                            wait_for=--!!
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest power on
                                                            ...                            wait_for=0xff
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest power on
                                               ...                            wait_for=0xff
    sleep  30
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest mc reset warm
                                                            ...                            wait_for=Starting lighttpd
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest mc reset warm
                                               ...                            wait_for=Starting lighttpd
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitest raw 6 2
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300s
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Swap_BMC
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=ipmitest raw 6 2
                                               ...                            wait_for=login:
                                               ...                            time_out=300s

Diag_COME_Power_control_test
    log.debug  ****************************************************\n
    log.debug  *************POWER TEST ON COME PORT****************\n
    log.debug  ****************************************************\n
    Swap_BMC
    Swap_COME
    sleep  5                               
    Diag_Telnet_Execute_Command_12              command=./diag.sh
    ...                                 path=/home/cel_diag/midstone100X
    sleep  5
  
    # ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitool power cycle
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Write    ipmitool power reset
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    log.debug       \r--------------------------- Execution output Start -------------------------\r
    log.debug       Diag# ${output}\n
    log.debug       \r--------------------------- Execution output End ---------------------------\r
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    sleep  150


    Re_Login

    # ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=ipmitool power reset
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Write    ipmitool power cycle
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    log.debug       \r--------------------------- Execution output Start -------------------------\r
    log.debug       Diag# ${output}\n
    log.debug       \r--------------------------- Execution output End ---------------------------\r
    Run Keyword If    '${status}' == 'FAIL'    FAIL

    Re_Login

Diag_Power_control_test_v2
    Diag_Login_And_Connect
    Diag_COME_Power_control_test
    Diag_BMC_Power_control_test

Diag_BACKUP_BIOS_BOOT_UP_testcase
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x05 0x01 0x04
    Command_Power_Cyling_2              ipmitool power cycle
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x0b 1
    Diag_Telnet_Execute_Command_12              command=ipmitool sensor | grep SW_VDD_CORE
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
    ...                                 PSU1_VIn  PSU1_CIn  PSU1_PIn  PSU1_Temp2  PSU1_VOut  PSU1_COut  PSU1_POut
    ...                                 PSU2_VIn  PSU2_CIn  PSU2_PIn  PSU2_Temp2  PSU2_VOut  PSU2_COut  PSU2_POut
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

Diag_Watchdog_test
    Re_Login
    Command_Power_Cyling_1    watchdogutil arm -s 10
    # ...                            wait_for=sonic login:
    ${status}   ${output}=  Run Keyword And Ignore Error    Re_Login
    Run Keyword If    '${status}' == 'FAIL'    sleep   10s
    Run Keyword If    '${status}' == 'FAIL'    Re_Login

CPU_Stress_test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/tools/
    ${output}     SSHLibrary.Write       ./CPU_test.sh
    Save_to_logs        ${output}
    sleep    330s
    SSHLibrary.Write    \r
    sleep    330s
    SSHLibrary.Write    \r
    sleep    330s
    SSHLibrary.Write    \r
    sleep    330s
    SSHLibrary.Write Bare   \x03
    SSH_CLOSE
    Diag_Telnet_Execute_Command_12              command=cat CPU_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                         expect_string=${SPACE}0 errors,${SPACE}0 warnings

CPU_Stress_test_Command
    Diag_Telnet_Execute_Command_12              command=./CPU_test.sh > /dev/null 2>&1 &
    ...                                 path=/home/cel_diag/midstone100X/tools/
    sleep    60s

CPU_Stress_test_Check
    ${output}                           Diag_Telnet_Execute_Command_12              command=pgrep mprime
                                        ...                                 path=/home/cel_diag/midstone100X/tools/
    ${Process_Stress}                   Get Line      ${output}    0
    Diag_Telnet_Execute_Command_12              command=kill -SIGINT ${Process_Stress}
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=cat CPU_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                         expect_string=${SPACE}0 errors,${SPACE}0 warnings

Diag_DDR_stress_test
    Diag_Telnet_Execute_Command_12              command=./DDR_test.sh 300 5 DDR_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                 time_out= 600
    Diag_Telnet_Execute_Command_12              command=cat DDR_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                         expect_string=Status: PASS,${SPACE}0 errors,Stats: Completed:,with 0 hardware

Diag_PCIE_stress_test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-pcie-stress-test --all
    ...                                         expect_string=PCIE stress test : Passed

Diag_SSD_stress_test
    Diag_Telnet_Execute_Command_12              command=./SSD_test.sh 300 SSD_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                 time_out= 600
    Diag_Telnet_Execute_Command_12              command=cat SSD_test.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                 time_out= 300
    ...                                 unexpect_string=fail,error
    ${output}                           Diag_Telnet_Execute_Command_12              command=fdisk -l
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Not Contain    ${output}    /dev/sda4
    Run Keyword If     '${status}' == 'FAIL'    Delete_sda4
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/tools/
    
    SSH_Send_Diag            fdisk /dev/sda
    ...                                 Prompt=:
    SSH_Send_Diag            n
    ...                                 Prompt=:
    SSH_Send_Diag            4
    ...                                 Prompt=:
    SSH_Send_Diag            \r
    ...                                 Prompt=:
    SSH_Send_Diag            \r
    ...                                 Prompt=:
    SSH_Send_Diag            Yes
    ...                                 Prompt=:
    SSH_Send_Diag            wq
    SSH_CLOSE

    Command_Power_Cyling                reboot
    Diag_Telnet_Execute_Command_12              command=mkfs.ext4 /dev/sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                         expect_string=: done
    Diag_Telnet_Execute_Command_12              command=mkdir test_sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=mount /dev/sda4 ./test_sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=./test_sda4.sh
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                 time_out= 600
    Diag_Telnet_Execute_Command_12              command=cat ./test_sda4/SSD_test_a4.log
    ...                                 path=/home/cel_diag/midstone100X/tools/
    ...                                 time_out= 300
    ...                                 unexpect_string=fail,error
    Diag_Telnet_Execute_Command_12              command=umount /dev/sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=rm -rf test_sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=sgdisk --zap /dev/sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Diag_Telnet_Execute_Command_12              command=wipefs -a /dev/sda4
    ...                                 path=/home/cel_diag/midstone100X/tools/
    Delete_sda4

Delete_sda4
    [Arguments]
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/tools/
    
    SSH_Send_Diag            fdisk /dev/sda
    ...                                 Prompt=:
    SSH_Send_Diag            d
    ...                                 Prompt=:
    SSH_Send_Diag            4
    ...                                 Prompt=:
    SSH_Send_Diag            wq
    SSH_CLOSE

Diag_RoV_function_test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    ${output}=     SSHLibrary.Write       cat /usr/lib/systemd/system/swss.service
    ${output}=     SSHLibrary.Read Until    Diag
    Save_to_logs    ${output}\n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    \#
    Run Keyword If     '${status}' == 'FAIL'    Stop_Docker_swss
    ${output}=     SSHLibrary.Write       cat /usr/lib/systemd/system/syncd.service
    ${output}=     SSHLibrary.Read Until    Diag
    Save_to_logs    ${output}\n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    \#
    Run Keyword If     '${status}' == 'FAIL'    Stop_Docker_syncd
    SSH_CLOSE
    Command_Power_Cyling                reboot
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_sdk/midstone100X/
    SSH_Send_traffic    ./auto_load_user.sh
    ${output}=    SSH_Send_traffic    pci readrov OLY_EFUSE_VID_READ2
    SSH_Send_Diag       exit
    SSH_CLOSE
    ${ROVdata}      Get Lines Containing String     ${output}       READ value
    ${ROVdata}    Split String    ${ROVdata}
    ${ROVdata_1}    set Variable    ${ROVdata}[8]
    ${ROVdata_1}    Remove String	    ${ROVdata_1}    V
    Set Global Variable    ${ROVdata_1}
    ${VDD_Data}    Diag_Telnet_Execute_Command_12              command=ipmitool sensor list | grep XP0R8V_VDD_V
    ${VDDdata}    Split String    ${VDD_Data}
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${VDDdata}[2]   ${ROVdata_1}
    Save_to_logs        ROV: ${ROVdata_1} == VDD: ${VDDdata}[2]
    Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    VDD to set Voltage to ${ROVdata_1}
    Run Keyword If     '${status}' == 'FAIL'    ROV_Set_Voltage

Stop_Docker_swss
    SSH_Send_Diag   sed -i -e '17 s/^/#/' /usr/lib/systemd/system/swss.service
    SSH_Send_Diag   sed -i -e '18 s/^/#/' /usr/lib/systemd/system/swss.service
    SSH_Send_Diag   sed -i -e '19 s/^/#/' /usr/lib/systemd/system/swss.service
    SSH_Send_Diag   sed -i -e '20 s/^/#/' /usr/lib/systemd/system/swss.service
    SSH_Send_Diag   sed -i -e '21 s/^/#/' /usr/lib/systemd/system/swss.service

Stop_Docker_syncd
    SSH_Send_Diag   sed -i -e '16 s/^/#/' /usr/lib/systemd/system/syncd.service
    SSH_Send_Diag   sed -i -e '17 s/^/#/' /usr/lib/systemd/system/syncd.service
    SSH_Send_Diag   sed -i -e '18 s/^/#/' /usr/lib/systemd/system/syncd.service

ROV_Set_Voltage
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x64 0 1 0x26
    ...                                         expect_string=01
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x64 0 2 0x26 0x00
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x64 0 1 0x26
    ...                                         expect_string=00
    Diag_Telnet_Execute_Command_12              command=ipmitool sensor list | grep SW
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 1 0x20
    ...                                         expect_string=16
    Run Keyword If      '${ROVdata_1}' == '0.78'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 0 0x21 0x1f 0x03
    Run Keyword If      '${ROVdata_1}' == '0.78'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 2 0x21
                                                    ...                                         expect_string=1f 03
    Run Keyword If      '${ROVdata_1}' == '0.80'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 0 0x21 0x34 0x03
    Run Keyword If      '${ROVdata_1}' == '0.80'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 2 0x21
                                                    ...                                         expect_string=34 03
    Run Keyword If      '${ROVdata_1}' == '0.82'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 0 0x21 0x48 0x03
    Run Keyword If      '${ROVdata_1}' == '0.82'    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 2 0x21
                                                    ...                                         expect_string=48 03
    Diag_Telnet_Execute_Command_12              command=ipmitool raw 0x3a 0x3e 3 0xd8 0 0x15
    Diag_Login_And_Connect
    ${VDD_Data}    Diag_Telnet_Execute_Command_12              command=ipmitool sensor list | grep XP0R8V_VDD_V
    ${VDDdata}    Split String    ${VDD_Data}
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${VDDdata}[2]   ${ROVdata_1}
    Save_to_logs        ROV: ${ROVdata_1} == VDD: ${VDDdata}[2]
    Run Keyword If     '${status}' == 'FAIL'    FAIL     ***ROV mismatch with VDD***

Diag_SDK_Function_Test_BI
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    Diag_Telnet_Execute_Command_12      command=md5sum pciefw-r5.bin
    ...                                 path=/home/cel_sdk/silverstone
    ...                                         expect_string=ef6f97c634d1501bf3927217bcdac3e7
    TELNET_Send_Command_expect_prompt    ./auto_load_user.sh    BCM.0>


Diag_SDK_Function_Test
    TELNET_Send_Command_expect_prompt    cd /home/cel_sdk/silverstone    \#
    TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/eBay/pciefw-r5.bin /home/cel_sdk/silverstone    password
    Diag_Telnet_Execute_Command          command=em4dmin    
    ...                                  wait_for=#
    ...                                  expect_string=100%
    Diag_Telnet_Execute_Command_12      command=md5sum pciefw-r5.bin
    ...                                 path=/home/cel_sdk/silverstone
    ...                                         expect_string=ef6f97c634d1501bf3927217bcdac3e7
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
    SSH_Send_traffic    phy control cd lt=1
    SSH_Send_traffic    sleep 60    100s
	FOR     ${i}    IN RANGE    11
        ${output1}=    SSH_Send_traffic    ps
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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

# Snake_traffic_check        
#     [Arguments]    ${rpkt}    ${tpkt}       
#     ${rpkt1}=    Replace String Using Regexp    ${rpkt}    (${space}|\t)    ${empty}
#     ${tpkt1}=    Replace String Using Regexp    ${tpkt}    (${space}|\t)    ${empty} 
#         FOR    ${i}    IN RANGE    0    32             
#             ${rp}=    Get Lines Containing String    ${rpkt1}    cd${i}:
#             ${rp}=    Split String    ${rp}    :    
#             ${rp}=    Get From List    ${rp}    1
#             ${rp}=    Split String    ${rp}    +
#             ${rp1}=    Get From List    ${rp}    0
#             ${rp2}=    Get From List    ${rp}    1
#             ${tp}=    Get Lines Containing String    ${tpkt1}    cd${i}:
#             ${tp}=    Split String    ${tp}    :
#             ${tp}=    Get From List    ${tp}    1
#             ${tp}=    Split String    ${tp}    +
#             ${tp1}=    Get From List    ${tp}    0
#             ${tp2}=    Get From List    ${tp}    1
#             Run Keyword If    '${rp1}' == '${tp1}'    log.debug    compair_cd${i} RP_first__value ${rp1}==TP_first__value ${tp1} result passed \n
#             Run Keyword If    '${rp1}' != '${tp1}'    Snake_traffic_passflagset    ${i}    first_    ${rp1}    ${tp1}    
#             Run Keyword If    '${rp2}' == '${tp2}'    log.debug    compair_cd${i} RP_second_value ${rp2}==TP_secone_value ${tp2} result passed \n
#             Run Keyword If    '${rp2}' != '${tp2}'    Snake_traffic_passflagset    ${i}    second    ${rp2}    ${tp2}    
#         END 

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
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Contain      ${console}          ${Firmware_Version.PCIE2_FW_Version}
    Run Keyword If     '${status}' == 'FAIL'    FAIL    PCIE Firmware Version Incorrect ${Firmware_Version.PCIE2_FW_Version}

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
        ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain X Times    ${output1}    up    34
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

Diag_Check_SDK_Version_Test_BI
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    ${output}=     SSHLibrary.Write       cat /usr/lib/systemd/system/swss.service
    ${output}=     SSHLibrary.Read Until    Diag
    Save_to_logs    ${output}\n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    \#
    Run Keyword If     '${status}' == 'FAIL'    Stop_Docker_swss
    ${output}=     SSHLibrary.Write       cat /usr/lib/systemd/system/syncd.service
    ${output}=     SSHLibrary.Read Until    Diag
    Save_to_logs    ${output}\n
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    \#
    Run Keyword If     '${status}' == 'FAIL'    Stop_Docker_syncd
    SSH_CLOSE
    Command_Power_Cyling                reboot
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_sdk/midstone100X/
    SSH_Send_traffic    ./auto_load_user.sh
    ${output}=    SSH_Send_traffic    shell cat ReadMe
    Should Contain    ${output}    ${SDK_Version}
    ${output}=    SSH_Send_traffic    ifcs show version
    Should Contain    ${output}    0.14.9
    
    SSH_Send_traffic    pci read OLY_EFUSE_VID_READ0
    SSH_Send_traffic    pci read OLY_EFUSE_VID_READ1
    ${rov_out}=         SSH_Send_traffic    pci read OLY_EFUSE_VID_READ2
    
    SSH_Send_traffic    pci read OLY_EFUSE_VID_READ3
    SSH_Send_traffic    ifcs show node
    SSH_Send_traffic    port disable 1
    SSH_Send_traffic    ifcs set devport 1 fec_mode 0
    SSH_Send_traffic    port enable 1-64 
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
    SSH_Send_Diag       exit
    SSH_CLOSE

Diag_100G_QSFP28_Loopback_Traffic_Test
    [Arguments]    ${time_out}=3600s
    ${time_out}=     Evaluate    ${traffic_100g_test_time}+400
    # TELNET_OPEN_TG    ${time_out}
    # Telnet.Write    cd /home/TG/100G
    # Telnet.Write    ./100G.sh
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_sdk/midstone100X/
    SSH_Send_traffic    ./auto_load_user.sh
    sleep  3
    SSH_Send_traffic    port disable 1
    sleep  3
    SSH_Send_traffic    ifcs set devport 1 fec_mode 0
    sleep  3
    SSH_Send_traffic    port enable 1-64 
    sleep  3
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
    sleep  3
    SSH_Send_traffic    ifcs clear counters devport
    sleep  3
    SSH_Send_traffic    ifcs clear counters hardware
    sleep  3
    SSH_Send_traffic    diagtest snake config -p 1-64 -lb 'NONE' -v
    # Telnet.Write    all_clear
    # Telnet.Write    all_start
    Util_Test_Execution         test_case=TG_Port_Start
    ...                         retry_loop=5
    sleep    5s
    SSH_Send_traffic    sleep 30
    SSH_Send_traffic    diagtest snake gen_report
    SSH_Send_traffic    sleep ${traffic_100g_test_time}
    Run Keyword If     '${traffic_100g_test_time}' == '300'     SSH_Send_traffic    sleep ${traffic_100g_test_time}
    Run Keyword If     '${traffic_100g_test_time}' == '300'     SSH_Send_traffic    sleep ${traffic_100g_test_time}
    Util_Test_Execution         test_case=TG_Port_Stop
    ...                         retry_loop=5
    # Telnet.Write    all_stop
    # sleep    5s
    # Telnet.Write    all_show
    # Telnet.Write    exit
    # TELNET_CLOSE
    sleep  3
    SSH_Send_traffic    ifcs show counters devport filter nz
    SSH_Send_traffic    diagtest snake unconfig
    SSH_Send_traffic    ifcs clear counters devport
    SSH_Send_traffic    ifcs clear counters hardware
    SSH_Send_Diag       exit
    Run Keyword If     '${status}' == 'FAIL'    FAIL    ${Message_Genfail}
    SSH_CLOSE

Diag_2x10G_SFP_Ports_Traffic_Test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_sdk/midstone100X/
    SSH_Send_traffic    ./auto_load_user.sh
    sleep   30
    SSH_Send_traffic    port enable 129-130
    ${output}=          SSH_Send_traffic    port info 129
    Should Match Regexp    ${output}    129.+LINK_UP
    ${output}=          SSH_Send_traffic    port info 130
    Should Match Regexp    ${output}    130.+LINK_UP
    SSH_Send_traffic    diagtest snake config -p 129-130 -lb 'NONE' -v
    SSH_Send_traffic    ifcs clear counters devport
    SSH_Send_traffic    ifcs clear counters hardware
    SSH_Send_traffic    diagtest snake start_traffic -n 300 -s 512
    SSH_Send_traffic    sleep 30
    SSH_Send_traffic    diagtest snake gen_report
    SSH_Send_traffic    sleep ${traffic_10g_test_time}
    Run Keyword If     '${traffic_10g_test_time}' == '300'     SSH_Send_traffic    sleep ${traffic_10g_test_time}
    Run Keyword If     '${traffic_10g_test_time}' == '300'     SSH_Send_traffic    sleep ${traffic_10g_test_time}
    SSH_Send_traffic    diagtest snake stop_traffic
    SSH_Send_traffic_10g    ifcs show counters devport filter nz
    SSH_Send_traffic    diagtest snake unconfig
    SSH_Send_traffic    ifcs clear counters devport
    SSH_Send_traffic    ifcs clear counters hardware
    SSH_Send_traffic    port info 129
    SSH_Send_traffic    port info  130
    SSH_Send_Diag       exit

Diag_PRBS_Test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
    SSH_Send_Diag       cd /home/cel_sdk/midstone100X/
    SSH_Send_traffic    ./auto_load_user.sh
    # SSH_Send_traffic    port disable 1
    # SSH_Send_traffic    ifcs set devport 1 fec_mode 0
    sleep  30
    SSH_Send_traffic    port enable 1-64 
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
    SSH_Send_traffic    diagtest serdes prbs mode-en 1-64 1
    SSH_Send_traffic    diagtest serdes prbs set 1-64 1 prbs31 1 40000
    SSH_Send_traffic    diagtest serdes prbs sync 1-64
    SSH_Send_traffic    sleep 40
    ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    diagtest serdes prbs get 1-64
    SSH_Send_traffic    diagtest serdes prbs clear 1-64
    SSH_Send_traffic    diagtest serdes prbs mode-en 1-64 0
    SSH_Send_Diag       exit
    Run Keyword If     '${status}' == 'FAIL'    FAIL    ${Message_Genfail}
    SSH_CLOSE

Diag_ONIE_Function_test
    [Arguments]
    # ${MAC}    Convert To List    ${Mac}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    # Power_Cyling_ONIE
    # Diag_Telnet_ONIE_Command      command=onie-discovery-stop
    Diag_Telnet_ONIE_Command              command=onie-syseeprom
    # ...                                   expect_string=${SN},${PN},${MACADD}
    # Diag_Telnet_ONIE_Command      command=onie-sysinfo -v
    # ...                                   expect_string=2019.02.01.2.0.1
    # Diag_Telnet_ONIE_Command      command=onie-sysinfo -p
    # ...                                   expect_string=x86_64-cel_midstone-100x-r0


Diag_ONIE_MANAGEMENT_PORT_test
    Diag_Telnet_ONIE_Command            command=ifconfig eth0 ${SSH_IP} up
    Diag_Telnet_ONIE_Command            command=ping ${SSH_IP} -c 5
    ...                                         expect_string=5 packets received

Diag_ONIE_SSD_PARTITION_Test
    Diag_Telnet_ONIE_Command            command=parted /dev/sda
    # ...                                 wait_for=(parted)
    # Diag_Telnet_ONIE_Command            command=p
    ...                                 wait_for=(parted)
    Diag_Telnet_ONIE_Command            command=q

Diag_ONIE_Version_Check
    Diag_Telnet_ONIE_Command            command=onie-sysinfo -v
    ...                                         expect_string=${Firmware_Version.ONIE_Version}

Diag_ONIE_Boot_Order_Check
    Diag_Telnet_ONIE_Command            command=efibootmgr

Diag_ONIE_SSD_Version_Check
    Diag_Telnet_ONIE_Command            command=dmesg | grep 3IE4 | sed -n '1p' | cut -d ',' -f2 | sed "s/ //g"
    ...                                         expect_string=${Firmware_Version.SSD_FW_Version}

Diag_Verify_TLV_EEPROM_In_ONIE
    # [Arguments]
    # ${MAC}    Convert To List    ${Mac}
    # ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
    # Power_Cyling_ONIE
    Diag_Telnet_ONIE_Command                command=onie-discovery-stop
    Diag_Telnet_ONIE_Command                command=onie-syseeprom
    # ...                                   expect_string=${SN},${PN},${MACADD}

# Diag_Verify_TLV_EEPROM_In_ONIE
#     [Arguments]
#     ${MAC}    Convert To List    ${Mac}
#     ${MACADD}    Set Variable    ${MAC}[0]${MAC}[1]:${MAC}[2]${MAC}[3]:${MAC}[4]${MAC}[5]:${MAC}[6]${MAC}[7]:${MAC}[8]${MAC}[9]:${MAC}[10]${MAC}[11]
#     Power_Cyling_ONIE
#     Diag_SSH_ONIE_Execute_Command      command=onie-discovery-stop
#     Diag_Telnet_ONIE_Command              command=onie-syseeprom
#     ...                                   expect_string=${SN},${PN},2.1.0,${MACADD},2.0.0

Diag_NOS_Install
    [Arguments]
    Power_Cyling_Install_ONIE
    Diag_SSH_ONIE_Execute_Command      command=onie-discovery-stop
    START_SSH_server
    SSHLibrary.Write    ssh root@${SSH_IP}
    ${output}=    SSHLibrary.Write    yes | scp -r emadmin@192.168.1.249:/tftpboot/New_Version/R3250-J0011-01_V2.0.1_Midstone100X_SONiC/onie-installer-x86_64-cel_midstone-100x-r0.bin /
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    (y/n)
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    y
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    Save_to_logs       ${output}\r
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    ${output}=    SSHLibrary.Write Bare    em4dmin\r\n
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:~ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    cd /
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    md5sum onie-installer-x86_64-cel_midstone-100x-r0.bin
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${output}    f8904219db6dbea4434aa031f2492e5a
    Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Write    rm onie-installer-x86_64-cel_midstone-100x-r0.bin
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    Run Keyword If    '${status}' == 'PASS'    Reboot_Install_ONIE
    # Run Keyword If    '${status}' == 'FAIL'    START_SSH_ONIE_Tranfer_File_1
    
Diag_NOS_Install2
    [Arguments]    ${time_out}=90s
    Power_Cyling_Install_ONIE
    Diag_SSH_ONIE_Execute_Command      command=onie-discovery-stop
    TELNET_OPEN     ${time_out}
    Telnet.Write    ssh root@${SSH_IP}
    ${output}=    Telnet.Write    ifconfig ma1 ${SSH_IP} up
    Save_to_logs       ${output}\r
    Telnet.Read Until    ONIE:/ #
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    Telnet.Write    yes | scp -r emadmin@192.168.1.249:/tftpboot/New_Version/R3250-J0011-01_V2.0.1_Midstone100X_SONiC/onie-installer-x86_64-cel_midstone-100x-r0.bin /
    Save_to_logs       ${output}\r
    Telnet.Read Until    ONIE:/ #
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    (y/n)
    Save_to_logs       ${output}\r
    ${output}=    Telnet.Write    y
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    password
    Save_to_logs       ${output}\r
    ${output}=    Telnet.Write Bare    em4dmin\r\n
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    Telnet.Write    cd /
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    Telnet.Write    md5sum onie-installer-x86_64-cel_midstone-100x-r0.bin
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${output}    f8904219db6dbea4434aa031f2492e5a
    Run Keyword If    '${status}' == 'FAIL'    Telnet.Write    rm onie-installer-x86_64-cel_midstone-100x-r0.bin
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    Run Keyword If    '${status}' == 'PASS'    Reboot_Install_ONIE
    # Run Keyword If    '${status}' == 'FAIL'    START_SSH_ONIE_Tranfer_File_1
    TELNET_CLOSE

Diag_NOS_Install1
    [Arguments]    ${time_out}=90s
    Power_Cyling_Install_ONIE
    # Diag_SSH_ONIE_Execute_Command      command=onie-discovery-stop
    Kill_telnet_port
    START_SSH_server
    SSHLibrary.Write    telnet ${TelnetIP} ${Port_Telnet}
    SSHLibrary.Write    \r
    ${output}=    SSHLibrary.Write    onie-discovery-stop
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    ifconfig ma1 ${SSH_IP} up
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    yes | scp -r emadmin@192.168.1.249:/tftpboot/New_Version/R3250-J0011-01_V2.0.1_Midstone100X_SONiC/onie-installer-x86_64-cel_midstone-100x-r0.bin /
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    (y/n)
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    y
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    password
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    em4dmin
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    cd /
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    md5sum onie-installer-x86_64-cel_midstone-100x-r0.bin
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain     ${output}    f8904219db6dbea4434aa031f2492e5a
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Write    rm onie-installer-x86_64-cel_midstone-100x-r0.bin
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    # ${RTC_GET}=    Set Variable    ${output}
    SSH_CLOSE


START_SSH_ONIE_Tranfer_File_1
    START_SSH_server
    SSHLibrary.Write    ssh root@${SSH_IP}
    SSHLibrary.Write    ifconfig ma1 ${SSH_IP} up
    ${output}=    SSHLibrary.Write    yes | scp -r emadmin@192.168.1.249:/tftpboot/New_Version/R3250-J0011-01_V2.0.1_Midstone100X_SONiC/onie-installer-x86_64-cel_midstone-100x-r0.bin /
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    (y/n)
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    y
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write Bare    em4dmin\r\n
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:~ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    cd /
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    md5sum onie-installer-x86_64-cel_midstone-100x-r0.bin
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs       ${output}\r






























# export LD_LIBRARY_PATH=/root/diag/output
# export CEL_DIAG_PATH=/root/diag
Diag_Update_uboot_image
    Kill_telnet_port
    Power_Off_UUT
    Power_On_UUT
    TELNET_uboot
    START_SSH_YModem
    ${status}   ${std_out}=  Run Keyword And Ignore Error    TELNET_reboot_uboot
    Run Keyword If     '${status}' == 'FAIL'    TELNET_reboot_uboot_Retry

Upload_ESS_traffic
    Diag_Telnet_Execute_Command_12              command=tftp -g 10.1.1.1 -r ess_traffic_test_debug.sh /root/sdk/R3181-J0001-01_V0.0.7_Briggs_SDK/
    ...                                 path=/root/sdk/${TF_TEST.tf_sdk}
    Diag_Telnet_Execute_Command_12              command=ls ess_traffic_test_debug.sh
    ...                                 path=/root/sdk/${TF_TEST.tf_sdk}
    ...                                         expect_string=ess_traffic_test_debug.sh
    Diag_Telnet_Execute_Command_12              command=chmod 777 ess_traffic_test_debug.sh
    ...                                 path=/root/sdk/${TF_TEST.tf_sdk}

Update_uC_FW
    TELNET_update_uC_FW
    START_SSH_uC_bl
    TELNET_update_uC_bootloader
    TELNET_update_uC_FW
    START_SSH_uC_app
    TELNET_update_uC_app

Install_ONIE_uboot
    TELNET_ONIE_uboot

Install_DiagOS
    TELNET_Install_DiagOS

Install_Diag_ONIE_rescue
    Diag_Telnet_Execute_Command         command=run onie_rescue
    ...                                         expect_string=Please press Enter
    Diag_Telnet_Execute_Command         command=\r
    ...                                 wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command         command=ifconfig ma1 ${SSH_IP} up
    ...                                 wait_for=ONIE:/ #
    START_SSH_ONIE_Tranfer_File
    Diag_Telnet_Execute_Command         command=onie-nos-install /root/onie-diagos-installer-arm64-celestica_cs8210-r0.bin
    ...                                         expect_string=checksum ... OK.,archive ... OK.,NOS install successful,Rebooting...
    ...                                 wait_for=ONIE: Starting ONIE
    Diag_Telnet_Execute_Command         command=\r
    ...                                 wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command         command=reboot
    ...                                 wait_for=Type 123<ENTER>
    Diag_Telnet_Execute_Command         command=123


Boot_to_DiagOs
    TELNET_Boot_Diag

Update_CPLD_FPGA_images
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -s ${CPLD_FPGA_Upgrade.SYSFPGA}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -l ${CPLD_FPGA_Upgrade.SWLED_CPLD}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -ml ${CPLD_FPGA_Upgrade.MACLED_CPLD}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=pkill cel-fan-test
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -f1 ${CPLD_FPGA_Upgrade.FAN_CPLD}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -f2 ${CPLD_FPGA_Upgrade.FAN_CPLD}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=vmetool_arm -md ${CPLD_FPGA_Upgrade.MDIOFPGA}
    ...                                 path=/root/fw/
    ...                                         expect_string=PASS!
    Diag_Telnet_Execute_Command_12              command=flashcp -v ${CPLD_FPGA_Upgrade.I2C_FPGA} /dev/mtd5
    ...                                 path=/root/fw/
    ...                                         parse_string=Erasing.+100%,Writing.+100%,Verifying.+100%
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r

Update_CPLD_ASC_images
    # Diag_Telnet_Execute_Command_12              command=rm -rf ${CPLD_FPGA_Upgrade.Phoenix_ASC0}
    # ...                                 path=/root/fw
    # Diag_Telnet_Execute_Command_12              command=tftp -g 10.1.1.1 -r /tftpboot/BSP_V_0_5/${CPLD_FPGA_Upgrade.Phoenix_ASC0} /root/fw/
    # ...                                 path=/root/fw
    ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x60
                                                            ...                                         expect_string=${SYSTEM_INFO.ACS0}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -w --bus 20 --addr 0x60 -f Phoenix_ASC0.hex --force
                                                ...                                         expect_string=Completed!
                                                ...                                 path=/root/fw
    ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x61
                                                            ...                                         expect_string=${SYSTEM_INFO.ACS1}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -w --bus 20 --addr 0x61 -f Phoenix_ASC1.hex --force
                                                ...                                         expect_string=Completed!
                                                ...                                 path=/root/fw
    ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x62
                                                            ...                                         expect_string=${SYSTEM_INFO.ACS2}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -w --bus 20 --addr 0x62 -f Phoenix_ASC2.hex --force
                                                ...                                         expect_string=Completed!
                                                ...                                 path=/root/fw
    ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x63
                                                            ...                                         expect_string=${SYSTEM_INFO.ACS3}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -w --bus 20 --addr 0x63 -f Phoenix_ASC3.hex --force
                                                ...                                         expect_string=Completed!
                                                ...                                 path=/root/fw
    Run Keyword If     '${status}' == 'FAIL'    Power_Off_UUT
    Run Keyword If     '${status}' == 'FAIL'    Power_On_UUT
    Run Keyword If     '${status}' == 'FAIL'    TELNET_Power_cyling_Diag            \r
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x60
                                                ...                                         expect_string=${SYSTEM_INFO.ACS0}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x61
                                                ...                                         expect_string=${SYSTEM_INFO.ACS1}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x62
                                                ...                                         expect_string=${SYSTEM_INFO.ACS2}
    Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command_12              command=asc_fwupd_arm -r --bus 20 --addr 0x63
                                                ...                                         expect_string=${SYSTEM_INFO.ACS3}

Diag_Program_FRU_EEPROM
    START_SSH_Get_UTC
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/8-0060/system_eeprom_wp
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0xFD
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test --erase -t tlv -d 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x21 -D ${AMAZON_MODEL_NUMBER_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x22 -D ${PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x23 -D ${SN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x24 -D ${MAC_ODC}[0]${MAC_ODC}[1]:${MAC_ODC}[2]${MAC_ODC}[3]:${MAC_ODC}[4]${MAC_ODC}[5]:${MAC_ODC}[6]${MAC_ODC}[7]:${MAC_ODC}[8]${MAC_ODC}[9]:${MAC_ODC}[10]${MAC_ODC}[11]
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x25 -D "${UTC_GET}"
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x26 -D ${DEVICE_VERSION_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x27 -D ${HE_VERSION_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x28 -D ${AMAZON_MODEL_NUMBER_ODC}-${HE_VERSION_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x29 -D ${ONIE_version}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2A -D 4
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2B -D Celestica
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2C -D TH
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2D -D Celestica
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x2E -D ${Diag_version}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0xFD -D BoardSN=${PCA_MB_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t tlv -d 1 -A 0xFD -D AssetID=${LBL_ASSET_ID_ODC}
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t tlv -d 1
    ...                                         expect_string=${AMAZON_MODEL_NUMBER_ODC},${PN_ODC},${SN_ODC},${UTC_GET},${DEVICE_VERSION_ODC},${HE_VERSION_ODC},${AMAZON_MODEL_NUMBER_ODC}-${HE_VERSION_ODC},${ONIE_version},${Diag_version},BoardSN=${PCA_MB_ODC},AssetID=${LBL_ASSET_ID_ODC},${MAC_ODC}[0]${MAC_ODC}[1]:${MAC_ODC}[2]${MAC_ODC}[3]:${MAC_ODC}[4]${MAC_ODC}[5]:${MAC_ODC}[6]${MAC_ODC}[7]:${MAC_ODC}[8]${MAC_ODC}[9]:${MAC_ODC}[10]${MAC_ODC}[11]
    Get_tlv_parameter

Diag_Check_FRU_EEPROM
    START_SSH_Get_UTC
    Get_Version
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t tlv -d 1
    ...                                         expect_string=${AMAZON_MODEL_NUMBER_ODC},${PN_ODC},${SN_ODC},${DEVICE_VERSION_ODC},${HE_VERSION_ODC},${AMAZON_MODEL_NUMBER_ODC}-${HE_VERSION_ODC},${ONIE_version},${Diag_version},BoardSN=${PCA_MB_ODC},AssetID=${LBL_ASSET_ID_ODC},${MAC_ODC}[0]${MAC_ODC}[1]:${MAC_ODC}[2]${MAC_ODC}[3]:${MAC_ODC}[4]${MAC_ODC}[5]:${MAC_ODC}[6]${MAC_ODC}[7]:${MAC_ODC}[8]${MAC_ODC}[9]:${MAC_ODC}[10]${MAC_ODC}[11]
    Get_tlv_parameter

Get_Version
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet     		${time_out}
    sleep   5ms
    ${output}=    		SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       	${output}\r
    sleep   5ms
    ${output}=    		SSHLibrary.Write    get_versions
    Save_to_logs       	${output}\r
    ${output}=    	    SSHLibrary.Read Until    Diag#
    Save_to_logs       	${output}\r
    ${ONIE_version}      Get Lines Containing String     ${output}       ONIE
    ${Diag_version}      Get Lines Containing String     ${output}       DIAGOS
    ${ONIE_version_Line}     Get Line      ${ONIE_version}    1
    ${Diag_version_Line}     Get Line      ${Diag_version}    0
    ${ONIE_version}    Split String    ${ONIE_version_Line}    
    ${Diag_version}    Split String    ${Diag_version_Line}    
    Set Suite Variable    ${ONIE_version}    ${ONIE_version}[1]
    Set Suite Variable    ${Diag_version}    ${Diag_version}[1]
    Save_to_logs            ${ONIE_version}\n
    Save_to_logs            ${Diag_version}\n

    
Diag_FRU_EEPROM_Burning
    START_SSH_Get_Time_Stamp
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/8-0060/i2cfpga_eeprom_write_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan_board_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan_board_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan1_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan3_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan5_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan7_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan9_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/40-0066/fan11_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan1_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan3_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan5_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan7_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan9_eeprom_protect
    Diag_Telnet_Execute_Command_12              command=echo 0 > /sys/bus/i2c/devices/31-0066/fan11_eeprom_protect
    #FAN1
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN1_SN_ODC}" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan1-eeprom
    #FAN2
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN2_SN_ODC}" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan2-eeprom
    #FAN3
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN3_SN_ODC}" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan3-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan3-eeprom
    #FAN4
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN4_SN_ODC}" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan4-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan4-eeprom
    #FAN5
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN5_SN_ODC}" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan5-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan5-eeprom
    #FAN6
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN6_SN_ODC}" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan6-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan6-eeprom
    #FAN7
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN7_SN_ODC}" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan7-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan7-eeprom
    #FAN8
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN8_SN_ODC}" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan8-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan8-eeprom
    #FAN9
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN9_SN_ODC}" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan9-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan9-eeprom
    #FAN10
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN10_SN_ODC}" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan10-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan10-eeprom
    #FAN11
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN11_SN_ODC}" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan11-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan11-eeprom
    #FAN12
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "[pia]" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = ${FAN_Vendor_ODC}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${FAN_PN_ODC}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${FAN12_SN_ODC}" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_1 = 0 RPM" >> /root/diag/configs/fru-fan12-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "product_custom_2 = ${Fan_Speed}" >> /root/diag/configs/fru-fan12-eeprom
    #Fan-board 1
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan-board1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan-board1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan-board1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN1_SN_ODC}" >> /root/diag/configs/fru-fan-board1-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN1_PN_ODC}" >> /root/diag/configs/fru-fan-board1-eeprom
    #Fan-board 2
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-fan-board2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-fan-board2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-fan-board2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_FAN2_SN_ODC}" >> /root/diag/configs/fru-fan-board2-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_FAN2_PN_ODC}" >> /root/diag/configs/fru-fan-board2-eeprom
    #I2C_FPGA board
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-i2c_fpga-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-i2c_fpga-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-i2c_fpga-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_I2C_SN_ODC}" >> /root/diag/configs/fru-i2c_fpga-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_I2C_PN_ODC}" >> /root/diag/configs/fru-i2c_fpga-eeprom
    #BusBar board
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-busbar-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-busbar-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-busbar-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_BUSBAR_SN_ODC}" >> /root/diag/configs/fru-busbar-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_BUSBAR_PN_ODC}" >> /root/diag/configs/fru-busbar-eeprom
    #Macsec board
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-macsec-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-macsec-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-macsec-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_MACSEC_SN_ODC}" >> /root/diag/configs/fru-macsec-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_MACSEC_PN_ODC}" >> /root/diag/configs/fru-macsec-eeprom
    #Riser card
    Diag_Telnet_Execute_Command_12              command=echo "[bia]" > /root/diag/configs/fru-risercard-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "mfg_datetime = ${Time_Stamp_test_result}" >> /root/diag/configs/fru-risercard-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "manufacturer = CELESTICA" >> /root/diag/configs/fru-risercard-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "serial_number = ${PCA_RISER_SN_ODC}" >> /root/diag/configs/fru-risercard-eeprom
    Diag_Telnet_Execute_Command_12              command=echo "part_number = ${PCA_RISER_PN_ODC}" >> /root/diag/configs/fru-risercard-eeprom

    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 1 -f configs/fru-i2c_fpga-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 2 -f configs/fru-busbar-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 3 -f configs/fru-macsec-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 4 -f configs/fru-fan-board2-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 5 -f configs/fru-fan1-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 6 -f configs/fru-fan2-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 7 -f configs/fru-fan3-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 8 -f configs/fru-fan4-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 9 -f configs/fru-fan5-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 10 -f configs/fru-fan6-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 12 -f configs/fru-fan-board1-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 13 -f configs/fru-fan7-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 14 -f configs/fru-fan8-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 15 -f configs/fru-fan9-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 16 -f configs/fru-fan10-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 17 -f configs/fru-fan11-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 18 -f configs/fru-fan12-eeprom
    ...                                         expect_string=Succeed to Write data
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -w -t fru -d 20 -f configs/fru-risercard-eeprom
    ...                                         expect_string=Succeed to Write data
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r

Diag_FRU_EEPROM_Access_Test_DC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 1
    ...                                         expect_string=${PCA_I2C_FPGA_SN_ODC},${PCA_I2C_FPGA_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 2
    ...                                         expect_string=${PCA_BB_SN_ODC},${PCA_BB_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 3
    ...                                         expect_string=${PCA_FAN_SN_ODC},${PCA_FAN_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 4
    ...                                         expect_string=${FAN1_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 5
    ...                                         expect_string=${FAN2_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 6
    ...                                         expect_string=${FAN3_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 7
    ...                                         expect_string=${FAN4_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 8
    ...                                         expect_string=${FAN5_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 9
    ...                                         expect_string=${FAN6_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 11
    ...                                         expect_string=${PCA_RISER_SN_ODC},${PCA_RISER_PN_ODC}
   
Diag_FRU_EEPROM_Access_Test_AC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 1
    ...                                         expect_string=${PCA_I2C_FPGA_SN_ODC},${PCA_I2C_FPGA_PN_ODC}
    #Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 2
    #...                                         expect_string=${PCA_BUSBAR_SN_ODC},${PCA_BUSBAR_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 3
    ...                                         expect_string=${PCA_FAN_SN_ODC},${PCA_FAN_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 4
    ...                                         expect_string=${FAN1_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 5
    ...                                         expect_string=${FAN2_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 6
    ...                                         expect_string=${FAN3_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 7
    ...                                         expect_string=${FAN4_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 8
    ...                                         expect_string=${FAN5_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 9
    ...                                         expect_string=${FAN6_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 10
    ...                                         expect_string=${FAN7_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 11
    ...                                         expect_string=${PCA_RISER_SN_ODC},${PCA_RISER_PN_ODC}

Diag_FRU_EEPROM_Access_Test_SKU3
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 1
    ...                                         expect_string=${PCA_1PPS_SN_ODC},${PCA_1PPS_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 2
     ...                                         expect_string=${PCA_BB_SN_ODC},${PCA_BB_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 3
    ...                                         expect_string=${PCA_FAN_SN_ODC},${PCA_FAN_PN_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 4
    ...                                         expect_string=${FAN1_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 5
    ...                                         expect_string=${FAN2_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 6
    ...                                         expect_string=${FAN3_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 7
    ...                                         expect_string=${FAN4_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 8
    ...                                         expect_string=${FAN5_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 9
    ...                                         expect_string=${FAN6_SN_ODC},${FAN_PN_ODC},${FAN_Vendor_ODC}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 11
    ...                                         expect_string=${PCA_RISER_SN_ODC},${PCA_RISER_PN_ODC}
    #Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 12
    #...                                         expect_string=${PCA_SFP_SN_ODC},${PCA_SFP_PN_ODC}

Diag_System_Information_Checking
    Diag_Telnet_Execute_Command_12              command=./bin/cel-system-test --all
    ...                                         expect_string=Sys test : Passed,${SOFTWARE_PACK.version_linux},${uc_update.uc_application_ver},${uc_update.uc_bootloader_ver},${SOFTWARE_PACK.version_cpld},${SOFTWARE_PACK.version_LEDCPLD1},${SOFTWARE_PACK.version_LEDCPLD2},${SOFTWARE_PACK.version_FANCPLD},${SOFTWARE_PACK.version_I2CFPGA},${BootUpd.BootUpd_uboot},${BootUpd.build_date},${SOFTWARE_PACK.crc_asc1},${SOFTWARE_PACK.crc_asc2}
    ...                                         parse_string=processors.+is: 16.*\n.*is :16.*,memory.+7712
    # Diag_Telnet_Execute_Command_12              command=tar -xvf ${TF_TEST.tf_sdk}.tar.xz
    # ...                                 path=/root/sdk/
    Diag_Telnet_Execute_Command_12              command=cat ReadMe
    ...                                 path=/root/sdk/${TF_TEST.tf_sdk}/
    ...                                         expect_string=${TF_TEST.tf_sdk}
    
Diag_CPLD_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test --all
    ...                                         expect_string=CPLD test : Passed

Diag_Mainboard_Version_Check
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test -r -d 1 -i board_version
    ...                                         expect_string=${SOFTWARE_PACK.brd_ver}

Diag_TPM_Device_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-tpm-test --all
    ...                                         expect_string=TPM test all Passed

Diag_CPU_DDR_Memory_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --all
    ...                                         expect_string=Mem test : Passed
    ...                                 time_out=2600
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t cores
    # ...                                         expect_string=multi-cores test : Passed
    # ...                                 time_out=2600
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t stress
    # ...                                         expect_string=Status: PASS,Finish the DDR stress test
    # ...                                 time_out=2600
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --all -C 512K
    # ...                                         expect_string=Mem test : Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t cores -C 16M
    # ...                                         expect_string=Mem test : Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t stress -T 30 -C 1G
    # ...                                         expect_string=Mem test : Passed
    # Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t edac
    # ...                                         expect_string=EDAC test : Passed

Diag_CPU_DDR_Memory_EDAC_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --all
    ...                                         expect_string=Mem test : Passed
    ...                                 time_out=2600
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t cores
    ...                                         expect_string=multi-cores test : Passed
    ...                                 time_out=2600
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t edac
    ...                                         expect_string=EDAC test : Passed    
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t stress
    ...                                         expect_string=Status: PASS,Finish the DDR stress test
    ...                                 time_out=2600
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mem-test --test -t edac
    ...                                         expect_string=EDAC test : Passed


Diag_I2C_Bus_Scan_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-i2c-test --all
    ...                                         expect_string=I2C test : Passed

Diag_PCIE_Scan_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-pci-test --all
    ...                                         expect_string=PCIe test : Passed

Diag_Switch_Device_Access_Test

Diag_Switch_SBus_Access_Test
    SSH_to_Telnet     ${time_out}
    sleep   5ms
    SSHLibrary.Write    export PS1="Diag# "
    sleep   5ms
    ${output}=    SSHLibrary.Write    cd /root/sdk/${TF_TEST.tf_sdk}
    sleep   5ms
    Save_to_logs       \n${output}\r
    ${output}=    SSHLibrary.Write      ./auto_load_user.sh
    Save_to_logs       \n${output}\r
    ${output}=    SSHLibrary.Read Until    IVM:0>
    Save_to_logs       ${output}\r
    #${output}=    SSHLibrary.Write      diagtest serdes aapl 1 0 'aapl serdes -display'
    #Save_to_logs       \n${output}\r
    #${output}=    SSHLibrary.Read Until    IVM:0>
    #Save_to_logs       ${output}\r
    #Should Contain    ${output}      ${SOFTWARE_PACK.version_pcie}
    ${output}=    SSHLibrary.Write      exit
    Save_to_logs       ${output}\r
    SSH_CLOSE

Diag_On-board_DC_DC_Controller_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --show -d 4
    ...                                         expect_string=SW-VDDCORE
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --show -d 5
    ...                                         expect_string=SW-3V3-R
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --show -d 6
    ...                                         expect_string=SW-AVDD-H
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 5
    # ...                                              V1MAX=${Voltage_Limit.max_5_0062_1}
    # ...                                              V1MIN=${Voltage_Limit.min_5_0062_1}
    # ...                                              V2MAX=${Voltage_Limit.max_5_0062_2}
    # ...                                              V2MIN=${Voltage_Limit.min_5_0062_2}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 6
    # ...                                              V1MAX=${Voltage_Limit.max_6_0066_1}
    # ...                                              V1MIN=${Voltage_Limit.min_6_0066_1}
    # ...                                              V2MAX=${Voltage_Limit.max_6_0066_2}
    # ...                                              V2MIN=${Voltage_Limit.min_6_0066_2}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 7
    # ...                                              V1MAX=${Voltage_Limit.max_7_0068_1}
    # ...                                              V1MIN=${Voltage_Limit.min_7_0068_1}
    # ...                                              V2MAX=${Voltage_Limit.max_7_0068_2}
    # ...                                              V2MIN=${Voltage_Limit.min_7_0068_2}
    # ...                                              V3MAX=${Voltage_Limit.max_7_0068_3}
    # ...                                              V3MIN=${Voltage_Limit.min_7_0068_3}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 8
    # ...                                              V1MAX=${Voltage_Limit.max_8_0068_1}
    # ...                                              V1MIN=${Voltage_Limit.min_8_0068_1}
    # ...                                              V2MAX=${Voltage_Limit.max_8_0068_2}
    # ...                                              V2MIN=${Voltage_Limit.min_8_0068_2}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 9
    # ...                                              V1MAX=${Voltage_Limit.max_9_0077_1}
    # ...                                              V1MIN=${Voltage_Limit.min_9_0077_1}
    # ...                                              V2MAX=${Voltage_Limit.max_9_0077_2}
    # ...                                              V2MIN=${Voltage_Limit.min_9_0077_2}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 10
    # ...                                              V1MAX=${Voltage_Limit.max_10_0071_1}
    # ...                                              V1MIN=${Voltage_Limit.min_10_0071_1}
    # ...                                              V2MAX=${Voltage_Limit.max_10_0071_2}
    # ...                                              V2MIN=${Voltage_Limit.min_10_0071_2}
    # ...                                              V3MAX=${Voltage_Limit.max_10_0071_3}
    # ...                                              V3MIN=${Voltage_Limit.min_10_0071_3}
    # Diag_SSH_DC_DC_Controller_Access_test            command=./bin/cel-dcdc-test --show -d 11
    # ...                                              V1MAX=${Voltage_Limit.max_11_0072_1}
    # ...                                              V1MIN=${Voltage_Limit.min_11_0072_1}
    # ...                                              V2MAX=${Voltage_Limit.max_11_0072_2}
    # ...                                              V2MIN=${Voltage_Limit.min_11_0072_2}
    # ...                                              V3MAX=${Voltage_Limit.max_11_0072_3}
    # ...                                              V3MIN=${Voltage_Limit.min_11_0072_3}
    

Diag_Power_Monitor_Functional_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --show
    Diag_dc_dc_Run                              ./bin/cel-dcdc-test --all
    # ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --all
    #                                                         ...                                         expect_string=DCDC test : Passed
    # Run Keyword If     '${status}' == 'FAIL'    Diag_dc_dc_Check

Diag_SSD_Device_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-storage-test --all
    ...                                         expect_string=Storage test : Passed

Diag_SSD_Device_Health_Status_Test
    Diag_Telnet_Execute_Command_12              command=fdisk -l
    ...                                         expect_string=sda1,sda2,sda3,sda5,sda6,sda7,sda8,sda9
    Diag_Telnet_Execute_Command_12              command=smartctl -t short /dev/sda
    ...                                         expect_string=successful
    Diag_Telnet_Execute_Command_12              command=smartctl -a /dev/sda
    ...                                         expect_string=No Errors Logged

Diag_ROV_Funcion_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rov-test --all
    ...                                         expect_string=rov test : Passed

Diag_System_Watchdog_Test
    Diag_Telnet_Execute_Command_12              command=echo 10 > /sys/bus/i2c/devices/8-0060/system_watchdog_seconds
    Diag_Telnet_Execute_Command_12              command=echo 1 > /sys/bus/i2c/devices/8-0060/system_watchdog_enable
    sleep    5s
    Diag_Telnet_Execute_Command_12              command=echo 1 > /sys/bus/i2c/devices/8-0060/system_watchdog_enable
    sleep    5s
    Diag_Telnet_Execute_Command_12              command=echo 1 > /sys/bus/i2c/devices/8-0060/system_watchdog_enable
    sleep    5s
    Diag_Telnet_Execute_Command_12              command=echo 1 > /sys/bus/i2c/devices/8-0060/system_watchdog_enable
    sleep    10s
    TELNET_Power_cyling_Diag            \r

Diag_Software_Reset_Test
    TELNET_Power_cyling_Diag            echo 1 > /sys/bus/i2c/devices/8-0060/warm_reset
    TELNET_Power_cyling_Diag            echo 1 > /sys/bus/i2c/devices/8-0060/cold_reset


Diag_SRAM_Acces_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-log-test -r -d 1
    #TELNET_Power_cyling_Diag            reboot
    #TELNET_Power_cyling_Diag            echo 1 > /sys/bus/i2c/devices/8-0060/warm_reset
    TELNET_Power_cyling_Diag            warm-reboot 
    Diag_Telnet_Execute_Command_12              command=./bin/cel-log-test -r -d 1
    ...                                         expect_string=Log test : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-log-test -w -d 2 -A 0 -D "1234567890ABCDEF"
    ...                                         expect_string=write done
    Diag_Telnet_Execute_Command_12              command=./bin/cel-log-test --dump -d 2
    ...                                         expect_string=1234567890ABCDEF
    Diag_Telnet_Execute_Command         command= \r
    ...                                 wait_for=DiagOS:
    Diag_Telnet_Execute_Command         command= cd /root/diag
    ...                                 wait_for=DiagOS:
    Diag_Telnet_Execute_Command         command= echo 1 > /sys/bus/i2c/devices/8-0060/console_logger_reset
    ...                                 wait_for=DiagOS:
    Diag_Telnet_Execute_Command         command= ./bin/cel-log-test --dump -d 2
    ...                                 wait_for=DiagOS:~/
    ...                                         expect_string=root

Diag_Present_Status_Test
    Diag_Telnet_Execute_Command_12              command=echo $((`i2cget -f -y 8 0x60 0x09` & 0x80))
    ...                                         expect_string=0

Diag_Temperature_Sensor_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-temp-test --all
    ...                                         expect_string=Temp test : Passed

Diag_CPU_SDR_Access_Test
    Diag_Telnet_Execute_Command_12              command=al_sdr_dump

Diag_FAN_board_CPLD_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-cpld-test -s -d 4
    ...                                         expect_string=CPLD Scan : Passed

Diag_FAN_Presence_Test_AC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --show -t present
    ...                                         parse_string=${Fan_Present.Fan1_Present},${Fan_Present.Fan2_Present},${Fan_Present.Fan3_Present},${Fan_Present.Fan4_Present},${Fan_Present.Fan5_Present},${Fan_Present.Fan6_Present},${Fan_Present.Fan7_Present}

Diag_FAN_Presence_Test_DC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --show -t present
    ...                                         parse_string=${Fan_Present.Fan1_Present},${Fan_Present.Fan2_Present},${Fan_Present.Fan3_Present},${Fan_Present.Fan4_Present},${Fan_Present.Fan5_Present},${Fan_Present.Fan6_Present}

Diag_FAN_Tray_Redundant_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_en -D 0
    ...                                         parse_string=fan_cpld1.+enable: 0
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t pwm -D 127
    Remove_Fan_Check_Interaction
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 1 -t speed
    ...                                         parse_string=fan-1 Front.+speed:${SPACE*2}0
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 2 -t speed
    ...                                         parse_string=fan-1 Panel.+speed:${SPACE*2}0
    Insert_Fan_Check_Interaction
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 1 -t speed
    ...                                         parse_string=fan-1 Front.+speed:${SPACE*2}1[0-9]{4}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -r -d 2 -t speed
    ...                                         parse_string=fan-1 Panel.+speed:${SPACE*2}1[0-9]{4}
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --all
    ...                                         expect_string=Fan test : Passed
    ...                                 time_out=300s 

Diag_Fan_Tray_LED_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-test --all
    ...                                         expect_string=Led test : Passed
    ...                                 time_out=300s
    Fan_LED_Check_Interaction

Diag_FAN_Tray_Speed_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --all
    ...                                         expect_string=Fan test : Passed
    ...                                 time_out=300s

Diag_FAN_Tray_Speed_Test_Ambient
    FOR     ${i}    IN RANGE    3
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test --all
                                                                 ...                                         expect_string=Fan test : Passed
                                                                 ...                                 time_out=300s
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If     '${i}' == '0'    Fan_Check_Interaction
        Run Keyword If     '${i}' == '1'    Fan_Check_Interaction
        Run Keyword If     '${i}' == '2'    FAIL
    END

Diag_FAN_WDT_Function_Test_AC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_en -D 0
    ...                                         parse_string=fan_cpld1.+fan_watchdog_enable: 0
    sleep    10s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t pwm -D 127
    Check_PWM_Fan_Status                127     14
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_sec -D 10
    ...                                         parse_string=fan_cpld1.+fan_watchdog_seconds: 10
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_en -D 1
    ...                                         parse_string=fan_cpld1.+fan_watchdog_enable: 1
    sleep    20s
    Check_PWM_Fan_Status                255     14

Diag_FAN_WDT_Function_Test_DC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_en -D 0
    ...                                         parse_string=fan_cpld1.+fan_watchdog_enable: 0
    sleep    10s
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t pwm -D 127
    Check_PWM_Fan_Status                127     12
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_sec -D 10
    ...                                         parse_string=fan_cpld1.+fan_watchdog_seconds: 10
    Diag_Telnet_Execute_Command_12              command=./bin/cel-fan-test -w -t wd_en -D 1
    ...                                         parse_string=fan_cpld1.+fan_watchdog_enable: 1
    sleep    20s
    Check_PWM_Fan_Status                255     12

# Diag_PSU_Redundant_Test
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --show
#     ...                                         unparse_string=vin :.+${SPACE}0.00
#     Power_Off_UUT_1
#     sleep    70s
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --show -d1
#     ...                                         parse_string=vin :.+${SPACE}0.00
#     # ...                                         parse_string=vin :.+${SPACE}0.[0-9]{2}
#     Power_On_UUT_1
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --show -d1
#     ...                                         unparse_string=vin :.+${SPACE}0.00
#     # ...                                         unparse_string=vin :.+${SPACE}0.[0-9]{2}
#     Power_Off_UUT_2
#     sleep    70s
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --show -d2
#     ...                                         parse_string=vin :.+${SPACE}0.00
#     # ...                                         parse_string=vin :.+${SPACE}0.[0-9]{2}
#     Power_On_UUT_2
#     Diag_Telnet_Execute_Command_12              command=./bin/cel-psu-test --show -d2
#     ...                                         unparse_string=vin :.+${SPACE}0.00
#     # ...                                         unparse_string=vin :.+${SPACE}0.[0-9]{2}


Diag_Indication_LED_Testing
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-test --all
    ...                                         expect_string=Led test : Passed
    ...                                 time_out=300s
    Front_Panel_LED_Check_Interaction

Diag_Management_Port_Ping_Test
    Diag_Telnet_Execute_Command_12              command=ifconfig eth0 up
    Diag_Telnet_Execute_Command_12              command=sed 's/"169.254.46.201"/"${Local_IP}"/g' -i /root/diag/configs/phys.yaml
    Diag_Telnet_Execute_Command_12              command=sed 's/"169.254.46.202"/"${SSH_IP}"/g' -i /root/diag/configs/phys.yaml
    Diag_Telnet_Execute_Command_12              command=./bin/cel-phy-test --all
    ...                                         expect_string=Phy test : Passed
    ...                                         parse_string=${SSH_IP} | Passed,wait 10s ... Passed,access ... Passed
    Diag_Telnet_Execute_Command_12              command=ethtool eth0 | grep Speed
    ...                                         expect_string=1000Mb/s
    Diag_Telnet_Execute_Command_12              command=sed 's/"${Local_IP}"/"169.254.46.201"/g' -i /root/diag/configs/phys.yaml
    Diag_Telnet_Execute_Command_12              command=sed 's/"${SSH_IP}"/"169.254.46.202"/g' -i /root/diag/configs/phys.yaml
    Diag_Telnet_Execute_Command_12              command=cat configs/phys.yaml
    ...                                         expect_string=169.254.46.201,169.254.46.202

Diag_RTC_Access_Test1
    ## Get UTC Time## date +'%Y%m%d %H%M%S'
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test --all
    ...                                         expect_string=Rtc test : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -r
    START_SSH_Get_RTC
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -w -D '${RTC_GET}'
    ...                                         expect_string=successfully
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -r
    Diag_Login_And_Connect
    START_SSH_Compare_RTC

Diag_RTC_Test_Check
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test --all
    ...                                         expect_string=test : Passed
    Diag_Telnet_Execute_Command_12              command=./bin/cel-rtc-test -r

Diag_MDIO_Access_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-mdio-test --all
    ...                                         expect_string=MDIO test : Passed
    
Diag_Ports_LED_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-led-test --all
    ...                                         expect_string=Led test : Passed
    ...                                 time_out=300s
    Port_LED_Test_Interaction

Diag_Ports_I2C_Access_Test
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --all
    ...                             expect_string=SFP test : Passed
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --show -t present
    ...                             parse_string=port-1.+Present,port-2.+Present,port-3.+Present,port-4.+Present,port-5.+Present,port-6.+Present,port-7.+Present,port-8.+Present,port-9.+Present,port-10.+Present,port-11.+Present,port-12.+Present,port-13.+Present,port-14.+Present,port-15.+Present,port-16.+Present,port-17.+Present,port-18.+Present,port-19.+Present,port-20.+Present,port-21.+Present,port-22.+Present,port-23.+Present,port-24.+Present,port-25.+Present,port-26.+Present,port-27.+Present,port-28.+Present,port-29.+Present,port-30.+Present,port-31.+Present,port-32.+Present
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t profile -D 1
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --all
    ...                             parse_string=port-1.+400K,port-2.+400K,port-3.+400K,port-4.+400K,port-5.+400K,port-6.+400K,port-7.+400K,port-8.+400K,port-9.+400K,port-10.+400K,port-11.+400K,port-12.+400K,port-13.+400K,port-14.+400K,port-15.+400K,port-16.+400K,port-17.+400K,port-18.+400K,port-19.+400K,port-20.+400K,port-21.+400K,port-22.+400K,port-23.+400K,port-24.+400K,port-25.+400K,port-26.+400K,port-27.+400K,port-28.+400K,port-29.+400K,port-30.+400K,port-31.+400K,port-32.+400K
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t profile -D 2
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --all
    ...                             parse_string=port-1.+1M,port-2.+1M,port-3.+1M,port-4.+1M,port-5.+1M,port-6.+1M,port-7.+1M,port-8.+1M,port-9.+1M,port-10.+1M,port-11.+1M,port-12.+1M,port-13.+1M,port-14.+1M,port-15.+1M,port-16.+1M,port-17.+1M,port-18.+1M,port-19.+1M,port-20.+1M,port-21.+1M,port-22.+1M,port-23.+1M,port-24.+1M,port-25.+1M,port-26.+1M,port-27.+1M,port-28.+1M,port-29.+1M,port-30.+1M,port-31.+1M,port-32.+1M

Diag_XE_Port_Loop_Back_Test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet     ${time_out}
    sleep   5ms
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Write    cd /root/sdk/${TF_TEST.tf_sdk}
    Save_to_logs       ${output}\r
    sleep   5ms
    SSH_Send_traffic        ./auto_load_user.sh -m "1-32:400G"
    SSH_Send_traffic        console
    ...                     Prompt=>>>
    SSH_Send_traffic        from aux_port_cel import *
    ...                     Prompt=>>>
    ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic        aux_traffic_test()
    ...                     Prompt=>>>
    ...                     parse_string=RX.+packets.+errors:0.+dropped:0.+overruns:0.+frame:0.*\n.*TX.+packets.+errors:0.+dropped:0.+overruns:0.+carrier:0
    SSH_Send_traffic        exit()
    SSH_Send_Diag           exit

Diag_Pre_screen_Traffic
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet     		${time_out}
    sleep   5ms
    ${output}=    		SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       	${output}\r
    sleep   5ms
    ${output}=    		SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    Save_to_logs       	${output}\r
    sleep   5ms
    ${output}=    		SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    Save_to_logs       	${output}\r
    ${output}=    		SSHLibrary.Write    cd /root/sdk/${TF_TEST.tf_sdk}
    Save_to_logs       	${output}\r
    sleep   5ms
	SSH_Send_traffic    ./auto_load_user.sh -m "1-32:copper_1x400G"
	SSH_Send_traffic    shell /root/sdk/${TF_TEST.tf_sdk}/c-phy/load_fw_init.sh -m
	SSH_Send_traffic    shell /root/sdk/${TF_TEST.tf_sdk}/c-phy/auto_load_user.sh -m 1-16:copper_1x400G
	SSH_Send_traffic    shell echo "Running pre-scan test with Loopback Module on port 1 - port 32"
	SSH_Send_traffic    port enable 1-32
	SSH_Send_traffic    shell sleep 15
	# SSH_Send_traffic    ifcs show devport
    FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   10s
        #Run Keyword If     '${i}' == '4'    Traffic_SFP_Check_Interaction
        #Run Keyword If     '${i}' == '6'    Traffic_SFP_Check_Interaction
        Run Keyword If     '${i}' == '9'    FAIL
    END
	SSH_Send_traffic    diagtest serdes prbs mode-en 17-32 1
	SSH_Send_traffic    diagtest serdes prbs set 17-32 1 prbs31 1593750 30000
	SSH_Send_traffic    diagtest serdes prbs sync 17-32
	SSH_Send_traffic    shell phy_shell set_tx_prbs slice_id=all lane_mask=0xff000 mode=PRBS31 enable=1
	SSH_Send_traffic    shell phy_shell set_rx_prbs slice_id=all lane_mask=0xff000 mode=PRBS31 enable=1
	${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    shell phy_shell get_rx_prbs_check slice_id=all lane_mask=0xff000 time_s=30 threshold=0.000001
    Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Gen_fail}    1
	SSH_Send_traffic    shell echo "innovium BER result"
	${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    diagtest serdes prbs get 17-32
    Run Keyword If     '${status}' == 'FAIL'    Set Global Variable    ${Gen_fail}    1
	SSH_Send_traffic    diagtest serdes prbs clear 17-32
	SSH_Send_traffic    diagtest serdes prbs mode-en 17-32 0
	SSH_Send_traffic    shell phy_shell set_tx_prbs slice_id=all lane_mask=0xff000 mode=PRBS31 enable=0
	SSH_Send_traffic    shell phy_shell set_rx_prbs slice_id=all lane_mask=0xff000 mode=PRBS31 enable=0
	SSH_Send_traffic    shell echo "dump credo serdes setting"
	SSH_Send_traffic    shell phy_shell display_firmware_info slice_id=all cmd=serdes_param
	SSH_Send_traffic    shell echo "dump innovium serdes setting"
	SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
    SSH_Send_traffic    shell phy_shell exit
    SSH_Send_Diag	    exit

Diag_Traffic_Test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet     		${time_out}
    ${output}=    		SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       	${output}\r
	SSH_Send_Diag       cd /root/sdk/${TF_TEST.tf_sdk}
	SSH_Send_traffic     ./auto_load_user.sh -m "1-32:copper_1x400G"
    SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
	SSH_Send_traffic    ifcs show version
	SSH_Send_traffic    diagtest serdes aapl 1 0 "aapl version"
	SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    diagtest snake config -p 1-32 -lb 'PCS' -v
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
	SSH_Send_traffic    pci read OLY_EFUSE_VID_READ0
	SSH_Send_traffic    pci read OLY_EFUSE_VID_READ1
	SSH_Send_traffic    pci read OLY_EFUSE_VID_READ2
	SSH_Send_traffic    pci read OLY_EFUSE_VID_READ3
	SSH_Send_traffic    ifcs clear counters devport
	SSH_Send_traffic    ifcs clear counters hardware
	SSH_Send_traffic    diagtest snake start_traffic -n 500 -s 1518
	SSH_Send_traffic    shell sleep 15
    SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
	SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    diagtest snake stop_traffic
	SSH_Send_traffic    diagtest snake gen_report
	SSH_Send_traffic    ifcs show counters devport filter nz
	SSH_Send_traffic    source cel_cmds/fecstats_show.cmd
	SSH_Send_traffic    diagtest snake unconfig
	SSH_Send_traffic    diagtest snake config -p 1-32 -lb 'PMA' -v
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
	SSH_Send_traffic    ifcs clear counters devport
	SSH_Send_traffic    ifcs clear counters hardware
	SSH_Send_traffic    diagtest snake start_traffic -n 500 -s 1518
	SSH_Send_traffic    shell sleep 15
    SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
	SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    diagtest snake stop_traffic
	SSH_Send_traffic    diagtest snake gen_report
	SSH_Send_traffic    ifcs show counters devport filter nz
	SSH_Send_traffic    source cel_cmds/fecstats_show.cmd
	SSH_Send_traffic    source cel_cmds/fecstats_show.cmd
	SSH_Send_traffic    diagtest snake unconfig
	SSH_Send_traffic    source cel_cmds/lt_enable.cmd
	SSH_Send_traffic    source cel_cmds/${TF_TEST.rx_gs_tf}
	SSH_Send_traffic    ifcs set debug devport event
	SSH_Send_traffic    diagtest snake config -p 1-32 -lb 'NONE' -v
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
	SSH_Send_traffic    shell sleep 10
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
    SSH_Send_traffic    source cel_cmds/print_eye.cmd
	SSH_Send_traffic    ifcs clear counters devport
	SSH_Send_traffic    ifcs clear counters hardware
    SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    diagtest snake start_traffic -n 500 -s 1518
	SSH_Send_traffic    shell sleep 300
	SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
    SSH_Send_traffic    shell /root/diag/cel-psu-test --all
    SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    shell sleep 300
	SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
    SSH_Send_traffic    shell /root/diag/cel-psu-test --all
    SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    shell sleep 300
    SSH_Send_traffic    shell /root/diag/cel-dcdc-test --all
    SSH_Send_traffic    shell /root/diag/cel-temp-test --all
    SSH_Send_traffic    shell /root/diag/cel-psu-test --all
    SSH_Send_traffic    ifcs show node
	SSH_Send_traffic    diagtest snake stop_traffic
	SSH_Send_traffic    diagtest snake gen_report
	SSH_Send_traffic    ifcs show counters devport filter nz
	SSH_Send_traffic    source cel_cmds/portstats_show.cmd
	SSH_Send_traffic    diagtest snake unconfig
	SSH_Send_traffic    source cel_cmds/lt_disable.cmd
    SSH_Send_traffic    ifcs show node
    Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
	SSH_Send_traffic    ifcs clear counters devport
	SSH_Send_traffic    ifcs clear counters hardware
	SSH_Send_Diag	    exit
	SSH_Send_Diag		export PS1="Diag# "
	SSH_Send_Diag	    cd /root/diag
    SSH_Send_Diag       tftp -p ${Local_IP} -pl /tmp/ii-root-0/log/cli_sh.log -r "${serial_number}_${TEST NAME}_Traffic_ifcs_show_log.txt"
    Run    mv /tftpboot/${serial_number}_${TEST NAME}_Traffic_ifcs_show_log.txt ${Raw_logs_path}/
    Run    chmod 777 ${Raw_logs_path}/ -R
    SSH_CLOSE

Diag_PRBS_Traffic_Test
    [Arguments]    ${time_out}=400s
    SSH_to_Telnet                   ${time_out}
    ${output}=                  SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}\r
        SSH_Send_Diag       cd /root/sdk/${TF_TEST.tf_sdk}
        SSH_Send_traffic    ./auto_load_user.sh -m "1-32:copper_1x400G"
    SSH_Send_traffic    source cel_cmds/lt_enable.cmd
    SSH_Send_traffic    source cel_cmds/rx_gs_ctle_PAM4to_load_user.sh -m "1-32:copper_1x400G"
    SSH_Send_traffic    source cel_cmds/lt_enable.cmd
    SSH_Send_traffic    source cel_cmds/rx_gs_ctle_PAM4_400G_32_LT_6db_LB_v2.txt
        SSH_Send_traffic    port enable 1-32
	SSH_Send_traffic    shell sleep 10
	FOR     ${i}    IN RANGE    10
        ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    ifcs show devport
        Exit For Loop If    '${status}' == 'PASS'
        sleep   20s
        Run Keyword If     '${i}' == '9'    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
        Run Keyword If     '${i}' == '9'    SSH_Send_Diag       exit
        Run Keyword If     '${i}' == '9'    FAIL    ${Message_Genfail}
    END
    SSH_Send_traffic    diagtest serdes prbs mode-en 1-32 1
    SSH_Send_traffic    diagtest serdes prbs set 1-32 1 prbs31 7968750 30000
    SSH_Send_traffic    diagtest serdes prbs sync 1-32
    SSH_Send_traffic    shell sleep 40
    ${status}   ${std_out}=  Run Keyword And Ignore Error    SSH_Send_traffic    diagtest serdes prbs get 1-32
    SSH_Send_traffic    diagtest serdes prbs clear 1-32
    SSH_Send_traffic    diagtest serdes prbs mode-en 1-32 0
    SSH_Send_traffic    source cel_cmds/serdes_parameter_dump_v1p1.txt
    SSH_Send_Diag       exit
    Run Keyword If     '${status}' == 'FAIL'    FAIL    ${Message_Genfail}

Diag_QSFP_Optical_Module_ModSelL_Signal_Test
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 10${i} 0x50 0x41
        ...                             expect_string=0xd2
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 1${i} 0x50 0x41
        ...                             expect_string=0xd2
    END

Diag_QSFP_Optical_Module_ModPrsL_Signal_Test
    Remove_SFP_Check_Interaction
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --show -t present
    ...                             parse_string=port-1.+Absent,port-2.+Absent,port-3.+Absent,port-4.+Absent,port-5.+Absent,port-6.+Absent,port-7.+Absent,port-8.+Absent,port-9.+Absent,port-10.+Absent,port-11.+Absent,port-12.+Absent,port-13.+Absent,port-14.+Absent,port-15.+Absent,port-16.+Absent,port-17.+Absent,port-18.+Absent,port-19.+Absent,port-20.+Absent,port-21.+Absent,port-22.+Absent,port-23.+Absent,port-24.+Absent,port-25.+Absent,port-26.+Absent,port-27.+Absent,port-28.+Absent,port-29.+Absent,port-30.+Absent,port-31.+Absent,port-32.+Absent
    Insert_SFP_Check_Interaction
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test --show -t present
    ...                             parse_string=port-1.+Present,port-2.+Present,port-3.+Present,port-4.+Present,port-5.+Present,port-6.+Present,port-7.+Present,port-8.+Present,port-9.+Present,port-10.+Present,port-11.+Present,port-12.+Present,port-13.+Present,port-14.+Present,port-15.+Present,port-16.+Present,port-17.+Present,port-18.+Present,port-19.+Present,port-20.+Present,port-21.+Present,port-22.+Present,port-23.+Present,port-24.+Present,port-25.+Present,port-26.+Present,port-27.+Present,port-28.+Present,port-29.+Present,port-30.+Present,port-31.+Present,port-32.+Present


Diag_QSFP_Optical_Module_IntL_Signal_Test
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 10${i} 0x50 0x41 0x02
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 1${i} 0x50 0x41 0x02
    END
    
    FOR     ${i}    IN RANGE    1   33
        Diag_Telnet_Execute_Command_12        command=cat /sys/devices/xilinx/accel-i2c/port${i}_module_interrupt
        ...                             expect_string=1
    END
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 10${i} 0x50 0x41 0x12
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 1${i} 0x50 0x41 0x12
    END
    FOR     ${i}    IN RANGE    1   33
        Diag_Telnet_Execute_Command_12        command=cat /sys/devices/xilinx/accel-i2c/port${i}_module_interrupt
        ...                             expect_string=0
    END

Diag_QSFP_Optical_Module_IntL_Signal_Test_SKU3
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 10${i} 0x50 0x41 0x02
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 1${i} 0x50 0x41 0x02
    END
    
    FOR     ${i}    IN RANGE    1   33
        Diag_Telnet_Execute_Command_12        command=cat /sys/devices/xilinx/pps-i2c/port${i}_module_interrupt
        ...                             expect_string=1
    END
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 10${i} 0x50 0x41 0x12
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cset -y -f 1${i} 0x50 0x41 0x12
    END
    FOR     ${i}    IN RANGE    1   33
        Diag_Telnet_Execute_Command_12        command=cat /sys/devices/xilinx/pps-i2c/port${i}_module_interrupt
        ...                             expect_string=0
    END

Diag_QSFP_Optical_Module_ResetL_Signal_Test
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t reset -D 1
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 10${i} 0x50 0x41
        ...                             expect_string=0xc0
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 1${i} 0x50 0x41
        ...                             expect_string=0xc0
    END
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t reset -D 0
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 10${i} 0x50 0x41
        ...                             expect_string=0xd2
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 1${i} 0x50 0x41
        ...                             expect_string=0xd2
    END

Diag_QSFP_Optical_Module_LPMode_Signal_Test
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t lpmod -D 1
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 10${i} 0x50 0x41
        ...                             expect_string=0xd6
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 1${i} 0x50 0x41
        ...                             expect_string=0xd6
    END
    Diag_Telnet_Execute_Command_12        command=./bin/cel-sfp-test -w -t lpmod -D 0
    FOR     ${i}    IN RANGE    1   10
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 10${i} 0x50 0x41
        ...                             expect_string=0xd2
    END
    FOR     ${i}    IN RANGE    10   33
        Diag_Telnet_Execute_Command_12        command=i2cget -y -f 1${i} 0x50 0x41
        ...                             expect_string=0xd2
    END

Diag_Push_Button_Test
    Reset_Button_Check_Interaction
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    sleep    120s
    sleep    30s
    Telnet.Write    \r
    sleep    5s
    Telnet.Write    \r
    ${output}=    Telnet.Read Until    ONIE:/ #
    Save_to_logs       \n${output}\r
    Should Contain    ${output}    ONIE:/ #
    # Run Keyword If     '${status}' == 'FAIL'    sleep    30s
    # ${status}   ${std_out}=  Run Keyword And Ignore Error   Diag_Telnet_Execute_Command            command=\r
    #                                                         ...                                         expect_string=ONIE:/ #
    # Run Keyword If     '${status}' == 'FAIL'    sleep    30s
    # Run Keyword If     '${status}' == 'FAIL'    Diag_Telnet_Execute_Command            command=\r
    #                                             ...                                         expect_string=ONIE:/ #
    TELNET_CLOSE
    Off_Button_Check_Interaction
    # Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # # Save_to_logs       Telnet Open\r
    # Telnet.Set Encoding    ISO-8859-1
    # Telnet.Set Telnetlib Log Level    DEBUG
    # Telnet.Set Timeout    ${timeout}
    # sleep    120s
    # sleep    30s
    # Telnet.Write    \r
    # sleep    5s
    # Telnet.Write    \r
    # ${output}=    Telnet.Read Until    ONIE:/ #
    # Save_to_logs       \n${output}\r
    # Should Not Contain    ${output}    ONIE:/ #
    # TELNET_CLOSE

Diag_Boot_to_DiagOS
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r


Diag_RTC_Get_Access_Test
    START_SSH_Get_RTC
    START_SSH_Compare_RTC

Diag_SSH_ONIE_Function_Test
    Power_Off_UUT
    Power_On_UUT
    TELNET_Boot
    SSH_ONIE_Function_Test
    Power_Off_UUT

# Diag_ONIE_Function_Test
#     Power_Off_UUT
#     Power_On_UUT
#     TELNET_Boot
#     SSH_ONIE_Function_Test

Diag_Sync_To_Ambient
    Kill_telnet_port
    Save_to_logs    Sync Ramp to Ambient\n
    Wait Until Created    /opt/Sync/Ramp_Done.txt    60min
    Save_to_logs    Sync Ramp Done\n

Diag_Sync_To_Cold_First
    Kill_telnet_port
    Save_to_logs    Sync Ramp to Cold\n
    Wait Until Created    /opt/Sync/Ramp_Done.txt    60min
    Save_to_logs    Sync Ramp Done\n

Diag_Sync_To_Cold
    Kill_telnet_port
    Save_to_logs    Sync Ramp to Cold\n
    Wait Until Created    /opt/Sync/Ramping.txt    250min
    Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit/${slot_location}.txt
    Wait Until Created    /opt/Sync/Ramp_Done.txt    250min
    Save_to_logs    Sync Ramp Done\n

Diag_Sync_To_Hot
    Kill_telnet_port
    Save_to_logs    Sync Ramp to Hot\n
    Wait Until Created    /opt/Sync/Ramping.txt    250min
    Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit/${slot_location}.txt
    Wait Until Created    /opt/Sync/Ramp_Done.txt    250min
    Save_to_logs    Sync Ramp Done\n
    
Diag_Power_Cycling
    FOR     ${i}    IN RANGE    3
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Power_Cycling
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If     '${i}' == '2'    FAIL
    END

Power_Cycling
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r

Diag_Traffic_Test_Final
    Diag_Traffic_Test_Vm
    # ${status}   ${std_out}=  Run Keyword And Ignore Error    Diag_Traffic_Test
    Power_Off_UUT

Diag_Create_Sync
    Run Keyword If    '${slot_location}' != 'chamber17'    Create File     /opt/Sync/Sync_unit/${slot_location}.txt    Done

Diag_Set_Voltage_Margin_High_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --all
    ...                                         expect_string=DCDC test : Passed
    Diag_Telnet_Execute_Command_12              command=./fhv2_vrm_high_sku1_sku2_i2c_card.sh
    ...					path=/root/diag/output/
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --all
    ...                                         expect_string=DCDC test : Passed
    Diag_Telnet_Execute_Command_12              command=cat /var/log/dmesg

Diag_Set_Voltage_Margin_Low_Test
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --all
    ...                                         expect_string=DCDC test : Passed
    Diag_Telnet_Execute_Command_12              command=./fhv2_vrm_low_sku1_sku2_i2c_card.sh
    ...                                 path=/root/diag/output/
    Diag_Telnet_Execute_Command_12              command=./bin/cel-dcdc-test --all
    ...                                         expect_string=DCDC test : Passed
    Diag_Telnet_Execute_Command_12              command=cat /var/log/dmesg

##############################################################################################################
##############################################################################################################

Diag_SSH_Execute_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone
    ...            ${wait_for}=Diag#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=100s  ${return_out}=default
    START_SSH     ${time_out}
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
    # log.debug       \r--------------------------- Execution output Start -------------------------\r
    Save_to_logs       \nDiag#${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    # Save_to_logs       ${output}\r
    Save_to_logs   ${output}\n
    # log.debug       \r--------------------------- Execution output End ---------------------------\r
    # log.debug      ----------------------------------------------------------------------------\n
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

Diag_SSH_ONIE_Execute_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone/bin
    ...            ${wait_for}=ONIE:~ #   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${unparse_string}=default    ${time_out}=100s  ${return_out}=default
    START_SSH_server
    sleep   ${wait_before_send}
    SSHLibrary.Write    ssh root@${SSH_IP}
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    # ${output}=    SSHLibrary.Write    export PS1="Diag# "
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    # sleep   ${wait_before_send}
    # ${output}=    SSHLibrary.Write    cd ${path}
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    log.debug      Sending command "${command}"
    ${output}=    SSHLibrary.Write    ${command}
    # log.debug       \r--------------------------- Execution output Start -------------------------\r
    Save_to_logs       \n${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    # Save_to_logs       ${output}\r
    
    Save_to_logs   ${output}\n
    # log.debug       \r--------------------------- Execution output End ---------------------------\r
    # log.debug      \n
    # log.debug      \n
    # log.debug      ----------------------------------------------------------------------------\n
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
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
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
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
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
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    ${unparse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unparse_string}   default
    Run Keyword If  ${unparse_string_status}    Diag_Check_Unparse_string    ${unparse_string}    ${output}
    [Return]   ${output}

Diag_SSH_Into_Telnet_Execute_Command
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=root@localhost:~#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    SSH_into_telnet
    sleep   ${wait_before_send}
    log.debug      Sending command "${command}"
    SSHLibrary.Write         ${command}
    # Telnet.Read Until    ${wait_for}
    ${output}=    SSHLibrary.Read Until    ${wait_for}
    # Save_to_logs  ${output}
    # log.debug       \r--------------------------- Execution output Start -------------------------\r
    Save_to_logs     ${command} ${output}\n
    # log.debug       \r--------------------------- Execution output End ---------------------------\r
    # log.debug      \n
    # log.debug      \n
    # log.debug      ----------------------------------------------------------------------------\n
    sleep     1
    SSH_CLOSE
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    # TELNET_CLOSE
    [Return]   ${output}

Diag_Telnet_Execute_Command_Password
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=root@localhost:~#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    [Return]   ${output}

Diag_Telnet_Execute_Command_phy
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/home/cel_diag/silverstone/bin
    ...            ${wait_for}=@localhost:~#    ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    TELNET_OPEN     ${time_out}
    sleep   ${wait_before_send}
    ${output}=    Telnet.Write    cd ${path}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    Telnet.Write         ${command}
    log.debug      sending command ${command}\n
    sleep   1ms
    # ${output}=    Telnet.Read Until    ${wait_for}
    # ${output}=    Telnet.Read Until    ${wait_for}
    # ${output}=    Telnet.Read Until    ${wait_for}
    ${output}=    Telnet.Read Until    ${wait_for}
    log.debug       \r--------------------------- Execution output Start -------------------------\r
    Save_to_logs  ${output}
    
    Save_to_logs   ${output}\n
    log.debug       \r--------------------------- Execution output End ---------------------------\r
    log.debug      \n
    log.debug      \n
    # log.debug      ----------------------------------------------------------------------------\n
    sleep     1
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    TELNET_CLOSE
    [Return]   ${output}

Diag_Telnet_Execute_Command_2
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=@localhost:~#    ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
    ${expect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${expect_string}   default
    Run Keyword If  ${expect_string_status}     Diag_Check_Expect_string     ${expect_string}   ${output}
    ${unexpect_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${unexpect_string}   default
    Run Keyword If  ${unexpect_string_status}    Diag_Check_Unexpect_string    ${unexpect_string}    ${output}
    ${parse_string_status}=    Run Keyword And Return status   Should Not Be Equal  ${parse_string}   default
    Run Keyword If  ${parse_string_status}    Diag_Check_Parse_string    ${parse_string}    ${output}
    [Return]   ${output}

Diag_Telnet_Execute_Command_3
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default
    ...            ${wait_for}=@localhost:~#    ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
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
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
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
    ${output}    TELNET_Send_Command    ${command}    ${wait_for}    ${time_out}
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
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    cd ${path}
    SSHLibrary.Read Until    ${wait_for}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    ${command}
    # Save_to_logs       \n${output}\r
    # Append To File      /opt/Robot_Debug/Logs/${Raw_logs}[4]/DMESG/    ${output}
    ${output}=    SSHLibrary.Read Until    ${wait_for}
    # Save_to_logs       ${output}\r
    # Append To File      /opt/Robot_Debug/Logs/${Raw_logs}[4]/DMESG/    ${output}
    SSH_CLOSE
    [Return]   ${output}

# Diag_Check_Expect_string
#     [Arguments]     ${expect_string}    ${output}
#     @{expect_list}=   Split String    ${expect_string}    ,
#     FOR   ${i}  IN  @{expect_list}
#         ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain    ${output}      ${i}
#         Run Keyword If    '${status}' == 'FAIL'  Save_to_logs      Did not find expected string "${i}", The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
#         Run Keyword If    '${status}' == 'FAIL'    FAIL
#     END

# Diag_Check_Unexpect_string
#     [Arguments]     ${unexpect_string}    ${output}
#     @{unexpect_list}=   Split String    ${unexpect_string}    ,
#     FOR   ${i}  IN  @{unexpect_list}
#         ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${output}      ${i}
#         Run Keyword If    '${status}' == 'FAIL'  Save_to_logs      The string "${i}" was catch, The check is ! ! ! ${SPACE} F A I L E D ${SPACE} ! ! !\r
#         Run Keyword If    '${status}' == 'FAIL'    FAIL
#     END

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

Diag_SSH_DC_DC_Controller_Access_test
    [Arguments]    ${wait_before_send}=5ms     ${open_conn}=False   ${close_con}=False    ${command}=default    ${path}=/root/diag/   ${V1MAX}=default    ${V2MAX}=default    ${V3MAX}=default    ${V1MIN}=default    ${V2MIN}=default    ${V3MIN}=default
    ...            ${wait_for}=Diag#   ${expect_string}=default    ${unexpect_string}=default    ${parse_string}=default    ${time_out}=100s  ${return_out}=default
    SSH_to_Telnet     ${time_out}
    sleep   ${wait_before_send}
    SSHLibrary.Write    export PS1="Diag# "
    sleep   ${wait_before_send}
    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    sleep   ${wait_before_send}
    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    SSHLibrary.Write    cd ${path}
    sleep   ${wait_before_send}
    ${output}=    SSHLibrary.Write    ${command}
    Save_to_logs       \n${output}\r
    ${output}=    SSHLibrary.Read Until    ${wait_for}
    Save_to_logs       ${output}\r
    ${voltage}    Get Lines Containing String      ${output}      voltage
    ${voltageLine}    Get Line Count    ${voltage}   
    FOR     ${i}    IN RANGE    ${voltageLine}
        Run Keyword If    '${i}' == '0'    Compare_voltage    ${voltage}    ${i}    ${V1MAX}    ${V1MIN}
        Run Keyword If    '${i}' == '1'    Compare_voltage    ${voltage}    ${i}    ${V2MAX}    ${V2MIN}
        Run Keyword If    '${i}' == '2'    Compare_voltage    ${voltage}    ${i}    ${V3MAX}    ${V3MIN}
    END
    SSH_CLOSE
    [Return]   ${output}

Compare_voltage
    [Arguments]     ${voltage}   ${i}   ${VMAX}    ${VMIN}
    ${voltage_result}      Get Line    ${voltage}    ${i}
    ${voltage_result}      Split String    ${voltage_result}    |
    ${voltage_result}      Remove String    ${voltage_result}[6]    ${SPACE}
    ${voltage_result}      Convert To Number    ${voltage_result}
    ${VMAX}                Convert To Number    ${VMAX}
    ${VMIN}                Convert To Number    ${VMIN}
    ${status}   Evaluate    ${VMAX}>${voltage_result}>${VMIN}
    Run Keyword If    '${status}' == 'False'  Save_to_logs    \nMAX Limit = ${VMAX}${SPACE*5}Value Limit = ${voltage_result}${SPACE*5}LOW Limit = ${VMIN}\r
    Run Keyword If    '${status}' == 'False'  Fail

SSH_Send_Diag
    [Arguments]     ${Command}      ${Prompt}=Diag#    ${time_out}=100s
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_Send_Command      ${Command}    ${Prompt}    ${time_out}
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
    ${status}   ${output}=  Run Keyword And Ignore Error    TELNET_Send_Command      ${Command}    ${Prompt}    ${time_out}
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

SSH_Send_traffic_10g
    [Arguments]     ${Command}      ${time_out}=100s    ${parse_string}=default    ${Prompt}=IVM:0>
    ${output}=    SSHLibrary.Write      ${Command}
    Save_to_logs       ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    ${Prompt}
    Save_to_logs       ${output}
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Not Contain    ${Command}      filter nz
    Run Keyword If     '${status}' == 'FAIL'    Check_Traffic_RX_TX_Err_10g    ${output}
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

Mac_Program_Check
    [Arguments]   
    SSH_to_Telnet     ${time_out}
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    sleep   5ms
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    cd /root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    SSH_Send_Diag   ifconfig ma1
    SSH_Send_Diag   ./bin/cel-eeprom-test -r -t tlv -d 1
    SSH_Send_Diag   ./bin/cel-phy-test -r -d 1 -t mac
    SSH_CLOSE

Mac_Program
    [Arguments]   
    SSH_to_Telnet     ${time_out}
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    sleep   5ms
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    cd /root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    SSH_Send_Diag   echo 0 > /sys/bus/i2c/devices/8-0060/system_eeprom_wp
    SSH_Send_Diag   ./bin/cel-eeprom-test -w -t tlv -d 1 -A 0x24 -D ${MAC_ODC}[0]${MAC_ODC}[1]:${MAC_ODC}[2]${MAC_ODC}[3]:${MAC_ODC}[4]${MAC_ODC}[5]:${MAC_ODC}[6]${MAC_ODC}[7]:${MAC_ODC}[8]${MAC_ODC}[9]:${MAC_ODC}[10]${MAC_ODC}[11]
    Save_to_logs    msg=${output}\n
    SSH_Send_Diag   rm /etc/udev/rules.d/70-persistent-net.rules
    SSH_CLOSE
    Power_Off_UUT
    Power_On_UUT
    TELNET_Power_cyling_Diag            \r
    SSH_to_Telnet     ${time_out}
    ${MAC_ODC}    Convert To List    ${MAC_ODC}
    sleep   5ms
    ${output}=    SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    ${output}=    SSHLibrary.Write    cd /root/diag
    Save_to_logs       ${output}\r
    sleep   5ms
    SSH_Send_Diag   ifconfig ma1
    SSH_Send_Diag   ./bin/cel-eeprom-test -r -t tlv -d 1
    SSH_Send_Diag   ./bin/cel-phy-test -r -d 1 -t mac
    SSH_CLOSE

Check_PWM_Fan_Status
    [Arguments]     ${Speed}     ${Fancount}
    SSH_to_Telnet     ${time_out}
    sleep   5ms
    SSHLibrary.Write    export PS1="Diag# "
    sleep   5ms
    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    sleep   5ms
    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    SSHLibrary.Write    cd /root/diag
    sleep   5ms
    ${output}=    SSHLibrary.Write    ./bin/cel-fan-test --show
    Save_to_logs       ${output}\r
    ${output}=    SSHLibrary.Read Until     Diag#
    Save_to_logs       ${output}\r
    FOR     ${i}    IN RANGE    ${Fancount}
        ${PWM_Status}      Get Lines Containing String     ${output}     PWM
        ${PWM_Status}      Get Line    ${PWM_Status}    ${i}
        ${PWM_Status}      Split String        ${PWM_Status}      |
        Should Contain      ${PWM_Status}[3]      ${Speed}
    END
    SSH_CLOSE

Diag_dc_dc_Run
    [Arguments]     ${Command}      ${Prompt}=Diag#    ${time_out}=100s
    SSH_to_Telnet     ${time_out}
    sleep   5ms
    SSHLibrary.Write    export PS1="Diag# "
    sleep   5ms
    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    sleep   5ms
    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    SSHLibrary.Write    cd /root/diag
    sleep   5ms
    ${output}=    SSHLibrary.Write      ${Command}
    Save_to_logs       \n${output}\r
    ${output}=    SSHLibrary.Read Until     ${Prompt}
    Save_to_logs       ${output}\r
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain    ${output}      DCDC test : Passed
    Run Keyword If     '${status}' == 'FAIL'    Diag_dc_dc_Check    ${output}
    SSH_CLOSE

Diag_dc_dc_Check
    [Arguments]   ${output}
    ${dcdc_Status}      Get Lines Containing String     ${output}     FAILED
    FOR     ${i}    IN RANGE    2
        ${dcdc_Status_line}      Get Line    ${dcdc_Status}    ${i}
        Run Keyword If     '${i}' == '0'    Should Contain      ${dcdc_Status_line}      VDD_CORE
        Run Keyword If     '${i}' == '1'    Should Contain      ${dcdc_Status_line}      DCDC test :
    END

Check_log_Err
    [Arguments]   ${output}
    Should Contain      ${output}    Log test : Passed

Get_tlv_parameter
    [Arguments]
    SSH_to_Telnet     		${time_out}
    sleep   5ms
    SSHLibrary.Write    export PS1="Diag# "
    sleep   5ms
    SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    sleep   5ms
    SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    SSHLibrary.Write    cd /root/diag/
    sleep   5ms
    SSHLibrary.Write      ./bin/cel-eeprom-test -r -t tlv -d 1
    ${output}=    SSHLibrary.Read Until     Diag#
    ${partnumber}      Get Lines Containing String     ${output}     Part Number
    ${partnumber}      Split String        ${partnumber}    
    Run    echo "${partnumber}[4]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    ${ONIEVersion}      Get Lines Containing String     ${output}    ONIE Version
    ${ONIEVersion}      Split String        ${ONIEVersion}    
    Run    echo "${ONIEVersion}[4]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    ${DiagVersion}      Get Lines Containing String     ${output}    Diag Version
    ${DiagVersion}      Split String        ${DiagVersion}    
    Run    echo "${DiagVersion}[4]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    ${LabelRevision}      Get Lines Containing String     ${output}     Label Revision
    ${LabelRevision}      Split String        ${LabelRevision}    
    Run    echo "${LabelRevision}[4]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    ${BaseMACAddress}      Get Lines Containing String     ${output}     Base MAC Address
    ${BaseMACAddress}      Split String        ${BaseMACAddress}    
    Run    echo "${BaseMACAddress}[5]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    ${DeviceVersion}      Get Lines Containing String     ${output}     Device Version
    ${DeviceVersion}      Split String        ${DeviceVersion}    
    Run    echo "${DeviceVersion}[4]" >> /opt/Robot_Debug/ODC_Script/BOM/${serial_number}.txt
    SSH_CLOSE

Diag_Voltage_Margin_High
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 8 0x60 0xf9 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x760c w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x1e0e w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x6a10 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x7612 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x35
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x740c w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x180e w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x7512 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x35
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf8 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfa 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfb 0x40
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf9 0xff
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf8 0x40
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 8 0x60 0xa1 0xd6
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfc 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfe 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xff 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfd 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfc 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 17 0x66 0x21 0x03ae w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x21 0x048a w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x21 0x0dc8 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x21 0x03b3 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x21 0x0785 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x21 0x03b3 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x21 0x0785 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 25 0x68 0x21 0x0dc8 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 25 0x77 0x21 0x0dc8 w
    Diag_dc_dc_Run                      ./bin/cel-dcdc-test --all

Diag_Voltage_Margin_Low
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 8 0x60 0xf9 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x920c w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x3e0e w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x8010 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x31 0x8012 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x60 0x35
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x800c w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x310e w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x31 0x8312 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 20 0x61 0x35
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf8 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfa 0x40
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfb 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf9 0xff
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xf8 0x40
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 8 0x60 0xa1 0xd6
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfc 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfe 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xff 0x00
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfd 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -f -y 8 0x60 0xfc 0x0f
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 17 0x66 0x21 0x0385 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x21 0x045c w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 18 0x68 0x21 0x0d0a w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x21 0x038a w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 26 0x71 0x21 0x074d w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x0 0
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x21 0x038a w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x0 1
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 27 0x72 0x21 0x074d w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 25 0x68 0x21 0x0d33 w
    Diag_Telnet_Execute_Command_12              command=i2cset -y -f 25 0x77 0x21 0x0d33 w
    Diag_dc_dc_Run                      ./bin/cel-dcdc-test --all
	
Diag_Voltage_Margin_Normal
    Diag_Telnet_Execute_Command_12              command=cd /root/diag
    Diag_dc_dc_Run                      ./bin/cel-dcdc-test --all

Diag_Dump_FRU_EEPROM
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t tlv -d 1

Diag_FRU_DUMP_EEPROM
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 1
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 2
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 3
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 4
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 5
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 6
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 7
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 8
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 9
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 10
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 12
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 13
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 14
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 15
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 16
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 17
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 18
    Diag_Telnet_Execute_Command_12              command=./bin/cel-eeprom-test -r -t fru -d 20	


Download_Image
    [Arguments]
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/FW/
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/New_FW_Midstone/BIOS/ /home/FW/
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/New_FW_Midstone/BMC/ /home/FW/
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/New_FW_Midstone/FPGA/ /home/FW/
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    ${output}=          SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.249:/tftpboot/New_FW_Midstone/CPLD/ /home/FW/
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    password
    SSHLibrary.Write Bare    em4dmin\r\n
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    SSH_CLOSE

Upgrade_Bios_Image
    [Arguments]
    SSH_to_Telnet                   ${time_out}
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/bin
    ${output}=          SSHLibrary.Write    ./bin/cel-upgrade-test -b --update -d 2 -f /home/cel_diag/midstone100X/firmware/bios/Midstone100X_hewittlake_BIOS_2.03.00.BIN
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Enter your Option :
    SSHLibrary.Write Bare    y\r\n
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    Save_to_logs        ${output}
    Should Contain    ${output}    Passed
    ${output}=          SSHLibrary.Write    ./bin/cel-upgrade-test -b --update -d 3 -f /home/cel_diag/midstone100X/firmware/bios/Midstone100X_hewittlake_BIOS_2.03.00.BIN
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Enter your Option :
    SSHLibrary.Write Bare    y\r\n
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    Save_to_logs        ${output}
    Should Contain    ${output}    Passed
    SSH_CLOSE

Upgrade_CPLD_Image
    [Arguments]
    SSH_to_Telnet                   300
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/bin
    ${output}=          SSHLibrary.Write    ./bin/cel-upgrade-test --update -b -d 4 -f /home/cel_diag/midstone100X/firmware/cpld/DVT_BDE_C_V13.vme
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Enter your Option :
    SSHLibrary.Write Bare    y\r\n
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    Save_to_logs        ${output}
    Should Contain    ${output}    Passed
    SSH_CLOSE

Upgrade_CPLD_Image_Audit
    [Arguments]
    SSH_to_Telnet                   900
    # SSHLibrary.Write    sudo su
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@localhost:~# 
    ${output}=          SSHLibrary.Write    export PS1="Diag# "
    # Save_to_logs        ${output}
    SSH_Send_Diag       cd /home/cel_diag/midstone100X/bin
    ${output}=          SSHLibrary.Write    ./bin/cel-upgrade-test --update -b -d 4 -f /home/cel_diag/midstone100X/firmware/cpld/PVT_HEW_D1627_B_V27_C_V15_Sw1_V12_Sw2_V12_Sw3_V12_Sw4_V12.vme
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Enter your Option :
    SSHLibrary.Write Bare    y\r\n
    Save_to_logs        ${output}
    ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    Save_to_logs        ${output}
    Should Contain    ${output}    Passed
    SSH_CLOSE

Swap_BMC
    [Arguments]     ${time_out}=200s
    log.debug                                   Logged in to BMC prompt.
    sleep    1s
    TELNET_Send_Command_ignore_prompt           exit
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt     \x15
    sleep    1s
    TELNET_Write_Bare_Command_ignore_prompt     \x12
    sleep    1s
    TELNET_Write_Bare_Command_ignore_prompt     \x14
    sleep    1s
    TELNET_Send_Command_ignore_prompt           2
    TELNET_Send_Command_expect_prompt           \r                      login:
    TELNET_Send_Command_expect_prompt           \r                      login:
    sleep    4s
    TELNET_Send_Command_expect_prompt           \r                      login:
    sleep    1s
    TELNET_Send_Command_expect_prompt           sysadmin                Password:
    sleep    1s
    TELNET_Write_Bare_Command_expect_prompt     superuser\r\n           \#

Swap_COME
    [Arguments]     ${time_out}=100s
    log.debug                                   Logged in to ComE prompt.
    TELNET_Send_Command_ignore_prompt           exit
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Write_Bare_Command_ignore_prompt     \x15
    sleep    1s
    TELNET_Write_Bare_Command_ignore_prompt     \x12
    sleep    1s
    TELNET_Write_Bare_Command_ignore_prompt     \x14
    sleep    1s
    TELNET_Send_Command_ignore_prompt           1
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Send_Command_ignore_prompt           \r
    sleep    6s
    TELNET_Send_Command_ignore_prompt           \r
    TELNET_Send_Command_expect_prompt           \r                      login:
    # ${stdout} =      Telnet.Read Until               login:
    # Save_to_logs    msg=${stdout}
    # Telnet.Write    admin
    # ${stdout} =      Telnet.Read Until               Password:
    # Save_to_logs    msg=${stdout}
    # Telnet.Write Bare    ${PASSWORD}\r\n
    # ${stdout} =      Telnet.Read Until               sonic:
    # Save_to_logs    msg=${stdout}
    # Telnet.Write Bare    sudo su\r\n
    # ${stdout} =      Telnet.Read Until               sonic:
    # Save_to_logs    msg=${stdout}
    Re_Login

Re_Login
    sleep    5s
    ${output1}    Diag_Telnet_Execute_Command    command=\r
                 ...                             wait_for=login:
                 ...                             wait_before_send=1
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    login:
    Run Keyword If    '${status}' == 'PASS'    Login_unit
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    \#
    # Run Keyword If    '${status}' == 'PASS'    Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up

Login_unit    
    log.debug    Login to Diag prompt.
    Diag_Telnet_Execute_Command    command=\r
    ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    # Diag_Telnet_Execute_Command_2    command=sudo su

Re_Login_BMC
    sleep    5s
    ${output1}    Diag_Telnet_Execute_Command    command=\r
                 ...                            wait_for=:
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    login:
    Run Keyword If    '${status}' == 'PASS'    Login_BMC
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output1}    admin
    # Run Keyword If    '${status}' == 'PASS'    Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up

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