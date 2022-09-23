*** Keywords ***
Viewver_ssh
    [Arguments]    ${timeout}
    SSHLibrary.Open Connection  ${Machine_IP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     kapok-tech    changeme    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}

TELNET_CLOSE
    # log.debug           Logged out from telnet session.
    Telnet.Close Connection
    # Save_to_logs      Telnet Close\r
    sleep    0.5s

TELNET_uboot
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    thermal_init
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    sleep    1s
    Telnet.Write    123
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    run bootupdy
    ${console}=    Telnet_Read_Until_Prompt    CC
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_Boot
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    thermal_init
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    sleep    1s
    Telnet.Write    123
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_update_uC_FW
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write Bare    \r\n
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    loady
    ${console}=    Telnet_Read_Until_Prompt    CC
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_update_uC_bootloader
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    # Telnet.Write    \r
    # sleep    1s
    # Telnet.Write    \r
    # sleep    1s
    Telnet.Write Bare    \r\n
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    uc_update bootloader
    ${console}=    Telnet_Read_Until_Prompt    successful
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_update_uC_app
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    # Telnet.Write    \r
    # sleep 1s
    # Telnet.Write    \r
    # sleep 1s
    Telnet.Write Bare    \r\n
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    uc_update app
    ${console}=    Telnet_Read_Until_Prompt    successful
    # Save_to_logs    msg=${console}\n
    Telnet.Write    reset
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    uc_get_version
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_Power_cyling_Diag
    [Arguments]     ${Command}
    Run Keyword And Ignore Error     Run    /usr/bin/pkill -HUP -f "^telnet .*${Port_Telnet}"
    # ${status}   ${std_out}=  Run Keyword And Ignore Error    TELNET_CLOSE
    ${status}  ${stderr} =  Run Keyword And Ignore Error     Telnet.Close All Connections
    sleep    1s
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write Bare    \r\n
    sleep           1s
    Telnet.Write    ${Command}
    ${console}=    Telnet_Read_Until_Prompt    Type 123
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    run diagos_bootcmd
    ${console}=    Telnet_Read_Until_Prompt    login:
    # Save_to_logs    msg=${console}\n
    Telnet.Write    root
    ${console}=    Telnet_Read_Until_Prompt    Password:
    # Save_to_logs    msg=${console}\n
    Telnet.Write    root
    ${console}=    Telnet.Read Until    \#
    ${console}=    Telnet_Read_Until_Prompt    \#
    # Save_to_logs    msg=${console}\n
    sleep    1s
    ${console}=    Telnet_Set_command    \r    \#
    # ${console}=    Telnet.Read Until    \#
    Save_to_logs    msg=${console}\n
    # sleep    1s
    ${console}=    Telnet_Set_command    ./diag/cel-temp-test --all    \#
    Save_to_logs    msg=${console}\n
    FOR     ${i}    IN RANGE    3
        ${console}=    Telnet_Set_command    ifconfig eth0 ${SSH_IP} up    \#
        Save_to_logs    msg=${console}\n
        Sleep   3s
        ${console}=    Telnet_Set_command    ping 10.1.1.1 -c3    \#
        Save_to_logs    msg=${console}\n
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Should Contain    ${console}    3 received
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If     '${i}' == '2'    Telnet_dmesg
        Run Keyword If     '${i}' == '2'    TELNET_CLOSE
        Run Keyword If     '${i}' == '2'    FAIL
    END
    TELNET_CLOSE

Telnet_dmesg
    [Arguments]
    ${console}=    Telnet_Set_command    dmesg    DiagOS:~
    Save_to_logs    ${console}\n

TELNET_reboot_uboot
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    sleep    1s
    # ${console}=    Telnet.Read Until    ALPINE_DB>
    Telnet.Write    reset
    sleep    1s
    # Save_to_logs    msg=${console}\n
    Telnet.Write    reset
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    env default -a
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    saveenv
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    reset
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_reboot_uboot_Retry
    [Arguments]
    TELNET_CLOSE
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    sleep    1s
    # ${console}=    Telnet.Read Until    ALPINE_DB>
    Telnet.Write    reset
    sleep    1s
    # Save_to_logs    msg=${console}\n
    Telnet.Write    reset
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    env default -a
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    saveenv
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    reset
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_saveenv
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    # Telnet.Write    \r
    # ${console}=    Telnet.Read Until    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    saveenv
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE

TELNET_ONIE_uboot
    [Arguments]     ${time_out}=300s
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    setenv serverip ${Local_IP}
    ${console1}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console1}\n
    sleep    2s
    Telnet.Write    setenv ipaddr ${SSH_IP}
    ${console1}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console1}\n
    sleep    2s
    Telnet.Write    setenv onie_file ${onie_path}
    ${console1}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console1}\n
    sleep    2s
    Telnet.Write    run uploadonie
    ${console1}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console1}\n
    sleep    300s
    Telnet.Write    run onie_rescue
    ${console1}=    Telnet_Read_Until_Prompt    Please press Enter
    # Save_to_logs    msg=${console1}\n
    Telnet.Write    \r
    ${console1}=    Telnet_Read_Until_Prompt    ONIE:/ #
    # Save_to_logs    msg=${console1}\n
    TELNET_CLOSE

SSH_ONIE_Function_Test
    [Arguments]     ${time_out}=300s
    TELNET_OPEN     ${time_out}
    Telnet.Write    \r
    ${console1}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    ${console1}\n
    Telnet.Write    run onie_bootcmd
    ${console1}=    Telnet_Read_Until_Prompt    Please press Enter
    # Save_to_logs    ${console1}\n
    ${console1}=    Telnet_Set_command    \r       ONIE:/ #
    Save_to_logs    ${console1}
    ${console1}=    Telnet_Set_command    onie-discovery-stop       ONIE:/ #
    Save_to_logs    ${console1}
    Should Contain    ${console1}    done
    ${console1}=    Telnet_Set_command    get_versions       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    ${SOFTWARE_PACK.version_onie}
    ${console1}=    Telnet_Set_command    wget       ONIE:/ #
    Save_to_logs    ${console1}\n
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    Usage: wget
    ${console1}=    Telnet_Set_command    tftp       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    Usage: tftp
    ${console1}=    Telnet_Set_command    onie-syseeprom       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    ${SN_ODC}
    ${console1}=    Telnet_Set_command    sfp_detect_tool       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    P32:
    ${console1}=    Telnet_Set_command    qsfp       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    Port 32:
    ${console1}=    Telnet_Set_command    fw_printenv onie_platform       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    ${AMAZON_MODEL_NUMBER_ODC}
    Telnet_Set_command    ifconfig eth0 ${SSH_IP} up       ONIE:/ #
    ${console1}=    Telnet_Set_command    ifconfig eth0 ${SSH_IP} up       ONIE:/ #
    Save_to_logs    ${console1}
    ${console1}=    Telnet_Set_command    ping ${Local_IP} -c3       ONIE:/ #
    Save_to_logs    ${console1}\n
    Should Contain    ${console1}    3 packets received
    # Telnet_Set_command    ifconfig eth0 ${SSH_IP} up       ONIE:/ #
    TELNET_CLOSE
    # START_SSH_server
    # ${console1}=    SSHLibrary.Write    ssh root@${SSH_IP}
    # Save_to_logs    ${console1}
    # ${status}   ${std_out}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    no)    time_out=3s
    # Save_to_logs    ${std_out}
    # Run Keyword If     '${status}' == 'FAIL'    SSHLibrary.Write    \r
    # Run Keyword If     '${status}' == 'FAIL'    SSHLibrary.Read Until    ONIE:~ #
    # Run Keyword If     '${status}' == 'PASS'    SSHLibrary.Write    yes
    # sleep    1s
    # ${console1}=    SSHLibrary.Write    \r
    # Save_to_logs    ${console1}
    # ${console1}=    SSHLibrary.Read Until    ONIE:~ #
    # Save_to_logs    ${console1}
    # ${console1}=    SSHLibrary.Write    exit
    # Save_to_logs    ${console1}
    # ${console1}=    SSHLibrary.Read Until    \$
    # ${console1}=    SSHLibrary.Write    telnet ${SSH_IP}
    # Save_to_logs    ${console1}
    # ${console1}=    SSHLibrary.Read Until    ONIE:/ #
    # Save_to_logs    ${console1}
    # SSH_CLOSE

Telnet_Set_APC_command
    [Arguments]         ${Comamnd}      ${Prompt}
    ${stdout} =         Telnet.Write                    ${Comamnd}
    Save_to_logs        ${stdout}
    log.debug           Sending command "${Comamnd}"
    ${status}           ${output}=  Run Keyword And Ignore Error    Telnet.Read Until               ${Prompt}
    Run Keyword If	    '${status}' == 'FAIL'    log.debug           Can't expect prompt: "${Prompt}"
    Run Keyword If	    '${status}' == 'FAIL'    log.debug           ----------------------------------------------------------------------------
    Run Keyword If	    '${status}' == 'FAIL'    FAIL                Can't expect prompt: "${Prompt}"
    Save_to_logs        ${output}
    sleep    1s

Telnet_Set_command
    [Arguments]     ${Comamnd}      ${Prompt}
    Telnet.Write    ${Comamnd}
    Telnet.Read Until    ${Prompt}
    ${output}=    Telnet.Read Until    ${Prompt}
    sleep    1s
    [Return]   ${output}

TELNET_Install_DiagOS
    [Arguments]     ${time_out}=300s
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    ${console1}=    Telnet_Read_Until_Prompt    ONIE:/ #
    # Save_to_logs    msg=${console1}\n
    Telnet.Write    ifconfig eth0 ${SSH_IP} up
    ${console1}=    Telnet_Read_Until_Prompt    ONIE:/ #
    # Save_to_logs    msg=${console1}\n
    Telnet.Write    cd /root/
    ${console1}=    Telnet_Read_Until_Prompt    ONIE:
    # Save_to_logs    msg=${console1}\n    
    Telnet.Write    tftp -g 10.1.1.1 -r ${diag_part}
    ${console1}=    Telnet_Read_Until_Prompt    ONIE:
    # Save_to_logs    msg=${console1}\n
    Telnet.Write    onie-nos-install /root/onie-diagos-installer-arm64-celestica_cs8210-r0.bin
    ${console1}=    Telnet_Read_Until_Prompt    Rebooting...
    # Save_to_logs    msg=${console1}\n
    # ${console1}=    Telnet.Read Until    ONIE: Starting ONIE
    # Save_to_logs    msg=${console1}\n
    # Telnet.Write    \r
    # ${console1}=    Telnet.Read Until    ONIE:/ #
    # Save_to_logs    msg=${console1}\n
    # Telnet.Write    reboot
    # ${console1}=    Telnet.Read Until    ONIE:/ #
    # Save_to_logs    msg=${console1}\n
    ${console}=    Telnet_Read_Until_Prompt    Type 123<ENTER> to STOP autoboot
    # Save_to_logs    msg=${console}\n
    Telnet.Write    123
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    TELNET_CLOSE
    # TELNET_Power_cyling_Diag            \r

TELNET_Boot_Diag
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    ALPINE_DB>
    # Save_to_logs    msg=${console}\n
    Telnet.Write    run diagos_bootcmd
    ${console}=    Telnet_Read_Until_Prompt    login:
    # Save_to_logs    msg=${console}\n
    Telnet.Write    root
    ${console}=    Telnet_Read_Until_Prompt    Password:
    # Save_to_logs    msg=${console}\n
    Telnet.Write    root
    ${console}=    Telnet_Read_Until_Prompt    \#
    # Save_to_logs    msg=${console}\n
    sleep    1s
    Telnet.Write    \r
    ${console}=    Telnet_Read_Until_Prompt    \#
    # Save_to_logs    msg=${console}\n
    sleep    1s
    Telnet.Write    ifconfig eth0 ${SSH_IP} up
    ${console}=    Telnet_Read_Until_Prompt    \#
    # Save_to_logs    msg=${console}\n
    sleep    5s
    TELNET_CLOSE


    # Diag_Telnet_Execute_Command         command=run diagos_bootcmd
    # ...                                 expect_string=CEL-DiagOS login:
    # ...                                 wait_for=login:
    # Diag_Telnet_Execute_Command         command=root
    # ...                                 expect_string=Password:
    # ...                                 wait_for=Password:
    # Diag_Telnet_Execute_Command         command=root
    # ...                                 wait_for=$
    # Diag_Telnet_Execute_Command         command=ifconfig eth0 ${SSH_IP} up

SSH_into_telnet
    [Arguments]
    START_SSH_server_1
    SSHLibrary.Write    telnet ${TelnetIP} ${Port_Telnet}
    sleep    1s
    SSHLibrary.Write    \r
    sleep    1s

START_SSH_server_1
    [Arguments]
    SSHLibrary.Open Connection  ${ServerIP}    prompt=$    timeout=120
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     emadmin    em4dmin    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}

TELNET_Set_Prompt
    [Arguments]    ${wait_for}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    ${output}=    Telnet.Write    export PS1="${wait_for} "
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    TELNET_CLOSE

TELNET_Set_Path
    [Arguments]    ${path}    ${wait_for}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    ${output}=    Telnet.Write    cd ${path}
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    TELNET_CLOSE

TELNET_Send_Command
    [Arguments]    ${command}    ${wait_for}    ${time_out}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Set Timeout    ${time_out}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write    ${command}
    Save_to_logs       ${wait_for}${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    FAIL    Did not find expected propmt "${wait_for}"
    [Return]   ${output}

TELNET_Send_Command_expect_prompt
    [Arguments]    ${command}    ${wait_for}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write    ${command}
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    FAIL    Did not find expected propmt "${wait_for}"
    [Return]   ${output}

TELNET_Send_Command_ignore_prompt
    [Arguments]    ${command}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write    ${command}
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    [Return]   ${output}

TELNET_Send_Command_TG_prompt
    [Arguments]    ${command}
    TELNET_OPEN_TG    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write    ${command}
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    [Return]   ${output}
    
TELNET_Write_Bare_Command_expect_prompt
    [Arguments]    ${command}    ${wait_for}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write Bare    ${command}
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    FAIL    Did not find expected propmt "${wait_for}"
    [Return]   ${output}

TELNET_Write_Bare_Command_ignore_prompt
    [Arguments]    ${command}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write Bare    ${command}
    Save_to_logs       ${output}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read
    Save_to_logs   ${output}\n
    TELNET_CLOSE
    [Return]   ${output}

TELNET_OPEN
    [Arguments]    ${timeout}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    # Telnet.Write Bare    \r\n

TELNET_OPEN_Password
    [Arguments]    ${timeout}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}

TELNET_OPEN_TG
    [Arguments]    ${timeout}
    Telnet.Open Connection    ${TG_Telnet_IP}    port=${TG_telnet_Port}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}

START_SSH_Get_RTC
    [Arguments] 
    START_SSH_server
    SSHLibrary.Write    date +'%Y%m%d %H%M%S'
    ${RTC_GET}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${RTC_GET}
    ${RTC_GET}=    Get Line    ${RTC_GET}    0
    Set Global Variable         ${RTC_GET}
    # ${RTC_GET}=    Set Variable    ${output}
    SSH_CLOSE
    # [Return]   ${output}

START_SSH_Get_UTC
    [Arguments] 
    START_SSH_server
    SSHLibrary.Write    date +'%m/%d/%Y %H:%M:%S'
    ${UTC_GET}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${UTC_GET}
    ${UTC_GET}=    Get Line    ${UTC_GET}    0
    Set Global Variable         ${UTC_GET}
    # ${RTC_GET}=    Set Variable    ${output}
    SSH_CLOSE
    # [Return]   ${output}

START_SSH_Get_Time_Stamp
    [Arguments] 
    START_SSH_server
    SSHLibrary.Write    date +'%Y-%m-%d %H:%M:00'
    ${Time_Stamp}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${Time_Stamp}
    ${Time_Stamp}=    Get Line    ${Time_Stamp}    0
    # Set Global Variable         ${UTC_GET}
    SSH_CLOSE
    ${convert}=       Convert Date      ${Time_Stamp}      epoch
    ${convert1}=      Convert Date      1996-01-01 00:00:00      epoch
    ${convert}=    Convert To Integer  ${convert}
    ${convert1}=   Convert To Integer  ${convert1}
    ${Time_Stamp_test_result}=  Evaluate       ${convert}-${convert1}
    ${Time_Stamp_test_result}=  Evaluate       ${Time_Stamp_test_result}/60
    ${Time_Stamp_test_result}    Convert to String    ${Time_Stamp_test_result}
    ${Time_Stamp_test_result}    Remove String   ${Time_Stamp_test_result}    .0
    Save_to_logs    ${Time_Stamp_test_result}
    Set Global Variable         ${Time_Stamp_test_result}

START_SSH_Compare_RTC
    [Arguments]
    START_SSH_server
    SSHLibrary.Write    date +'%Y-%m-%d %H:%M:%S'
    ${RTC_GET_Compare}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${RTC_GET_Compare}
    SSH_CLOSE
    # sleep   10s
    # SSH_to_Telnet     ${time_out}
    # sleep   5ms
    # SSHLibrary.Write    sudo su
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    root@sonic:
    # ${output}=    SSHLibrary.Write    export PS1="Diag# "
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSHLibrary.Read Until    Diag#
    # sleep   5ms
    # # ${output}=    SSHLibrary.Write    export PS1="Diag# "
    # # Save_to_logs       ${output}\r
    # # sleep   5ms
    # ${output}=    SSHLibrary.Write    cd /home/cel_diag/midstone100X/bin/
    # # Save_to_logs       ${output}\r
    # sleep   5ms
    ${output}=    Diag_Telnet_Execute_Command_12      command=./bin/cel-rtc-test -r
    # Save_to_logs       \n${output}\r
    # ${output}=    SSHLibrary.Read Until    Diag#
    # Save_to_logs       ${output}\r
    ${RTC_READ}=    Get Line    ${output}    2
    ${RTC_READ}=    Split String     ${RTC_READ}     
    ${RTC_READ}=    Set Variable    ${RTC_READ}[4] ${RTC_READ}[5]
    ${eval_time}=   Subtract Date From Date   ${RTC_READ}   ${RTC_GET_Compare}
    ${test_time}=   Convert To Integer  ${eval_time}
    ${rtc_test_result}=  Evaluate       100>${test_time}>-100
    Run Keyword If    '${rtc_test_result}' == 'False'  Fail    100>${test_time}>-100
    log.debug    RTC time compare with Host server time is ${test_time}, test limit is [100 second]\r

START_SSH_YModem
    [Arguments]    ${time_out}=600s
    SSHLibrary.Open Connection  ${TelnetIP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     kapok-tech    changeme    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}
    SSHLibrary.Write    sudo ${YModem_Path}${Mapping_YModem}
    ${output}=    SSHLibrary.Read Until    Terminal ready
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \x01
    sleep    0.5s
    SSHLibrary.Write Bare    \x13
    ${output}=    SSHLibrary.Read Until    *** file
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    ${uboot_path}\r\n
    # ${output}=    SSHLibrary.Read Until    0k
    # Save_to_logs     ${output}    
    ${output}=    SSHLibrary.Read Until    complete
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \r\n
    ${output}=    SSHLibrary.Read Until    ALPINE_DB>
    Save_to_logs     ${output}
    sleep    5s
    SSHLibrary.Write Bare    \x01    
    SSHLibrary.Write Bare    \x18
    SSH_CLOSE

# START_SSH_Get_Time_Stamp
#     [Arguments]
#     START_SSH_server    90
#     SSHLibrary.Write    date +'%Y-%m-%d %H:%M:00'
#     # SSHLibrary.Write    date +%c
#     ${Time_Stamp}=      SSHLibrary.Read Until    \$
#     ${Time_gett}=       Get Line    ${Time_Stamp}    0
#     ${Time_Stamp}=      Add Time To Date      ${Time_gett}       01:00:00
#     ${Time_Stamp}=      String.Remove String        ${Time_Stamp}       .000
#     Save_to_logs        ${Time_Stamp}\n
#     SSH_CLOSE
#     ${convert}=         Convert Date      ${Time_Stamp}      epoch
#     ${convert1}=        Convert Date      1996-01-01 00:00:00      epoch
#     ${convert}=         Convert To Integer  ${convert}
#     ${convert1}=        Convert To Integer  ${convert1}
#     ${Time_Stamp_test_result}=      Evaluate       ${convert}-${convert1}
#     ${Time_Stamp_test_result}=      Evaluate       ${Time_Stamp_test_result}/60
#     ${Time_Stamp_test_result}       Convert to String    ${Time_Stamp_test_result}
#     ${Time_Stamp_test_result}       Remove String   ${Time_Stamp_test_result}    .0
#     Save_to_logs     ${Time_Stamp_test_result}
#     Set Global Variable         ${Time_Stamp_test_result}
#     [Return]    ${Time_Stamp}       ${Time_Stamp_test_result}
    
START_SSH_server
    [Arguments]
    SSHLibrary.Open Connection  ${ServerIP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     emadmin    em4dmin    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}

START_SSH_server_2
    [Arguments]
    SSHLibrary.Open Connection  ${ServerIP}    prompt=$    timeout=${timeout}       newline=\n
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     emadmin    em4dmin    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}
    
SSH_to_Telnet
    [Arguments]     ${timeout}
    START_SSH_server_2 
    SSHLibrary.Write    telnet ${TelnetIP} ${Port_Telnet}
    SSHLibrary.Read Until    Escape character is
    SSHLibrary.Write     \r
    SSHLibrary.Read

START_SSH_uC_bl
    [Arguments]    ${time_out}=600s
    START_SSH_server
    SSHLibrary.Write    sudo ${YModem_Path}${Mapping_YModem}
    ${output}=    SSHLibrary.Read Until    Terminal ready
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \x01
    sleep    0.5s
    SSHLibrary.Write Bare    \x13
    ${output}=    SSHLibrary.Read Until    *** file
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    ${uC_bl_path}\r\n
    # ${output}=    SSHLibrary.Read Until    0k
    # Save_to_logs     ${output}    
    ${output}=    SSHLibrary.Read Until    complete
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \r\n
    ${output}=    SSHLibrary.Read Until    ALPINE_DB>
    Save_to_logs     ${output}
    sleep    5s
    SSHLibrary.Write Bare    \x01    
    SSHLibrary.Write Bare    \x18
    SSH_CLOSE

START_SSH_uC_app
    [Arguments]    ${time_out}=600s
    START_SSH_server
    SSHLibrary.Write    sudo ${YModem_Path}${Mapping_YModem}
    ${output}=    SSHLibrary.Read Until    Terminal ready
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \x01
    sleep    0.5s
    SSHLibrary.Write Bare    \x13
    ${output}=    SSHLibrary.Read Until    *** file
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    ${uC_app_path}\r\n
    # ${output}=    SSHLibrary.Read Until    0k
    # Save_to_logs     ${output}    
    ${output}=    SSHLibrary.Read Until    complete
    Save_to_logs     ${output}
    SSHLibrary.Write Bare    \r\n
    ${output}=    SSHLibrary.Read Until    ALPINE_DB>
    Save_to_logs     ${output}
    sleep    5s
    SSHLibrary.Write Bare    \x01    
    SSHLibrary.Write Bare    \x18
    SSH_CLOSE

START_SSH_ONIE_Tranfer_File
    [Arguments]    ${time_out}=600s
    SSHLibrary.Open Connection  ${TelnetIP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     kapok-tech    changeme    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}
    SSHLibrary.Write    yes | scp -r kapok-tech@10.1.1.1:/tftpboot/BSP_V_0_4/onie-diagos-installer-arm64-celestica_cs8210-r0.bin /root
    ${output}=    SSHLibrary.Read Until    password
    Save_to_logs     ${output}
    SSHLibrary.Write Bare     ${PASSWORD}\r\n
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs     ${output}

START_SSH_SDK_Tranfer_File
    [Arguments]    ${time_out}=600s
    SSHLibrary.Open Connection  ${TelnetIP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     kapok-tech    changeme    allow_agent=True
    # Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     kapok-tech    changeme
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}
    SSHLibrary.Write    yes | scp -r ${SDK_File} root@${SSH_IP}:/root/sdk
    ${output}=    SSHLibrary.Read Until    password
    Save_to_logs     ${output}
    SSHLibrary.Write Bare     ${PASSWORD}\r\n
    ${output}=    SSHLibrary.Read Until    ONIE:/ #
    Save_to_logs     ${output}

START_SSH
    [Arguments]    ${timeout}
    SSHLibrary.Open Connection  ${SSH_IP}    timeout=${timeout}   
    SSHLibrary.Set Client Configuration	prompt=$
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     admin    admin   #  allow_agent=True
    Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     admin    admin
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    # Save_to_logs     ${output}
    # SSHLibrary.Write    export PS1="Diag# "
    # ${output}=    SSHLibrary.Read Until    ${ROOT_PROMPT}
    # SSHLibrary.Write    export CEL_DIAG_PATH=/root/diag
    # ${output}=    SSHLibrary.Read Until    ${ROOT_PROMPT}
    # SSHLibrary.Write    export LD_LIBRARY_PATH=/root/diag/output
    # ${output}=    SSHLibrary.Read Until    ${ROOT_PROMPT}
    # SSHLibrary.Set Client Configuration    prompt=# 	# For root, the prompt is #    
    #SSHLibrary.Set Client Configuration    term_type=ansi	width=40

START_SSH_Try
    [Arguments]    ${timeout}
    SSHLibrary.Open Connection  10.196.59.180    timeout=${timeout}   
    SSHLibrary.Set Client Configuration	prompt=$
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     emadmin    em4dmin   #  allow_agent=True
    Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     emadmin    em4dmin
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    
Kill_Terminal
    SSH_to_Telnet    60
    SSHLibrary.Write    ps -elf | grep ${Port_Telnet}
    ${output}=    SSHLibrary.Read Until    ${ROOT_PROMPT}
    ${Kill_Port}      Get Lines Containing String     ${output}       telnet ${TelnetIP} ${Port_Telnet}
    ${Kill_Port}      Get Line         ${Kill_Port}     0
    ${Kill_Port}      Split String     ${Kill_Port}
    SSHLibrary.Write    kill ${Kill_Port}[3]
    SSH_CLOSE

SSH_CLOSE
    # log.debug           Logged out from ssh session.
    SSHLibrary.Close Connection
    sleep    50ms

SSH_HOST_DISCONNECT
    SSHLibrary.Switch Connection   CONSOLE_CONNECT
    SSHLibrary.Close Connection

SSH_UUT_CONNECT
    [Arguments]        ${timeout}=120 seconds
    SSHLibrary.Open Connection    host=${SSH_IP}    alias=SSH_CONNECT
    SSHLibrary.Login   username=${USERNAME}    password=${PASSWORD}
    SSHLibrary.Set Client Configuration	       timeout=${timeout}  prompt=${ROOT_PROMPT}
    SSHLibrary.Write Bare	\r
    ${stdout} =	    SSHLibrary.Read Until           ${ROOT_PROMPT}
    Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}

Read_UntilProm
    [Documentation]    SSHLibrary.Read Until Prompt (#)
    [Arguments]        ${command}
    ${stdout} =        SSHLibrary.Write               ${command}
    Append To File     ${dir_unit}/${TEST NAME}.txt   ${stdout}
    ${status}    ${stdout} =	Run Keyword And Ignore Error       SSHLibrary.Read Until    ${ROOT_PROMPT}
    Append To File     ${dir_unit}/${TEST NAME}.txt   ${stdout}
    Run Keyword If     $status == 'FAIL'              Fail         ${stdout}
    sleep    50ms

Read_UntilPrompt
    [Documentation]    SSHLibrary.Read Until Prompt (#)
    [Arguments]        ${command}
    ${stdout} =        SSHLibrary.Write                ${command}
    Append To File     ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${status}    ${stdout} =	Run Keyword And Ignore Error       SSHLibrary.Read Until Prompt
    Append To File     ${dir_unit}/${TEST NAME}.txt    ${stdout}
    Run Keyword If     $status == 'FAIL'               Fail         ${stdout}
    sleep    50ms

RUN_CMD_Read_Until
    [Documentation]    Read Until Prompt and Should Contain ${expect}
    [Arguments]        ${command}   ${expect}
    ${stdout} =        SSHLibrary.write    ${command}
    Append To File     ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${stdout} =        SSHLibrary.Read Until   ${expect}
    Append To File     ${dir_unit}/${TEST NAME}.txt    ${stdout}
    Should Contain         ${stdout}    ${expect}
    sleep    50ms
    Read_UntilProm     \r\n

Execute_HOST_CMD
    [Documentation]    Serial connection.
    [Arguments]        ${command}
    ${stdout} =       Telnet.Execute Command           ${command}
    Append To File    {dir_unit}/${TEST NAME}.txt      ${command}\n
    ${status}    ${stdout}=    Run Keyword And Ignore Error        Telnet.Read Until    ${ROOT_PROMPT}    #Read Until Regexp    \#(\\s\\Z|\\s\\n\\Z)
    Append To File    {dir_unit}/${TEST NAME}.txt      ${stdout}
    Run Keyword If     $status == 'FAIL'               Fail         ${stdout}


TELNET_HOST_CMD
    [Documentation]    Support CATS only. Require ser2net service.
    [Arguments]       ${command}
    ${console}=    Telnet.Execute Command    ${command}
    ${console}=    Telnet.Read Until    ${ROOT_PROMPT}
    Append To File    ${dir_unit}/${TEST NAME}.txt    ${command}\n
    Append To File    ${dir_unit}/${TEST NAME}.txt    ${console}\n

Execute_ONIE_CMD
    [Documentation]    Support CATS only. Require ser2net service.
    [Arguments]    ${command}
    ${console}=    Telnet.Execute Command    ${command}
    ${console}=    Telnet.Read Until    ${ONIE_PROMPT}
    Append To File    ${dir_unit}/${TEST NAME}.txt    ${command}\n
    Append To File    ${dir_unit}/${TEST NAME}.txt     ${console}

Execute_ALPINE_DB_Command
    [Arguments]    ${command}
    ${console}=    Telnet.Execute Command    ${command}
    Append To File    ${dir_unit}/${TEST NAME}.txt    ${console}
    ${console}=    Telnet.Read Until    ALPINE_DB>
    Append To File    ${dir_unit}/${TEST NAME}.txt    \n${console}
    ${console}=    Telnet.Read Until    ALPINE_DB>
    Append To File    ${dir_unit}/${TEST NAME}.txt    ${console}\r
    sleep    1s

Execute_ser_Append
    [Documentation]    Support CATS only. Require ser2net service.
    [Arguments]    ${command}
    ${console}=    Telnet.Execute Command    \r
    ${status}    ${console}=    Run Keyword And Ignore Error    Telnet.Read Until Regexp    \#(\\s\\Z|\\s\\n\\Z)
    ${console}=    Telnet.Execute Command    ${command}
    Append To File    ${dir_unit}/${TEST NAME}.txt    \n${command}\n


CONSOLE_CONNECTION_OPEN
    [Arguments]      ${prompt}=${NONE}       ${timeout}=120
    ${status}    ${stdout} =  Run Keyword And Ignore Error      CLEAR_CONSOLE_PORT_action
    Telnet.Open Connection    ${HOST}        port=${PORT_UUT}
    Telnet.Set Encoding       ISO-8859-1
    Telnet.Set Newline        CRLF
    Run Keyword If   '${prompt}' is not '${NONE}'    Telnet.Set Prompt  ${prompt}
    Telnet.Set Telnetlib Log Level  DEBUG
    Telnet.Set Timeout        ${timeout}
    Telnet.Write Bare         \r

CONSOLE_UUT_CONNECT
    [Arguments]     ${timeout}=120
    Wait Until Keyword Succeeds    3 times      ${timeout}      SSH_HOST_CONNECT   timeout=${timeout}
    SSHLibrary.Switch Connection   CONSOLE_CONNECT
    ${status}     ${stdout} =      Run Keyword And Ignore Error      CLEAR_CONSOLE_PORT_action
    ${stdout} =   SSHLibrary.Write                telnet ${HOST} ${PORT_UUT}
    # Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${stdout} =	  SSHLibrary.Read                 delay=0.5s
    # Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    SSHLibrary.Write Bare	\r
    ${stdout} =	  SSHLibrary.Read                 delay=1s
    # Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    sleep   1s

SSH_HOST_CONNECT
    [Arguments]        ${timeout}=120
    SSHLibrary.Open Connection    host=localhost    alias=CONSOLE_CONNECT
    SSHLibrary.Login   username=kapok-tech     password=changeme
    SSHLibrary.Set Client Configuration	       timeout=${timeout}  prompt=]$  escape_ansi=True
    SSHLibrary.Write Bare	\r
    ${stdout} =	    SSHLibrary.Read Until Prompt
    # Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}

CONFIG_DIAG_LIBRARY
    ${stdout} =     SSHLibrary.Write                export LD_LIBRARY_PATH=/root/diag/output
    Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${stdout} =	    SSHLibrary.Read Until           ${ROOT_PROMPT}
    Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${stdout} =     SSHLibrary.Write                export CEL_DIAG_PATH=/root/diag
    Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    ${stdout} =	    SSHLibrary.Read Until           ${ROOT_PROMPT}
    Append To File  ${dir_unit}/${TEST NAME}.txt    ${stdout}
    sleep           50ms

Count_Sync_File
    [Arguments]
    ${Sync_count}=    Count Files In Directory    /opt/Sync/Sync_unit/
    ${Sync_count_unit}=    Count Files In Directory    /opt/Sync/Sync_unit_count/
    Set Global Variable     ${Sync_count}
    Set Global Variable     ${Sync_count_unit}

    # Save_to_logs            "Wait Sync\n"
    # Exit For Loop If    '${List}' == '${List1}'
    # Run Keyword If      '${Time_exit}' == '${i}'     FAIL
    # sleep    60s
    # Continue For Loop If    '${List}' != '${List1}'


# START_SSH
#     [Documentation]    Support CATS only. Require SSH service.
#     [Arguments]     ${timeout}=120 seconds   ${diag_env}=True
#     Wait Until Keyword Succeeds    3 times      ${timeout}      SSH_UUT_CONNECT    timeout=${timeout}
#     SSHLibrary.Switch Connection   SSH_CONNECT
#     Run Keyword If  '${diag_env}' == 'True'     CONFIG_DIAG_LIBRARY

# STOP_SSH
#     [Documentation]    Support CATS only. Require SSH service.
#     SSHLibrary.Close Connection
#     sleep    1s

#============================= Setting keyword ====================#

Initialize_Test_Suite
    [Arguments]
    Set Global Variable    ${Genfail_Test}    0
    Set Global Variable    ${Fan_fail}    0
    Set Global Variable    ${SDK_PKT_Staus}    0
    Set Global Variable    ${Ber_Staus}    0
    # Run Keyword If    '${slot_location}' == 'chamber17'    Remove Files    /opt/Sync/Ramp_Done.txt
    # Run Keyword If    '${slot_location}' == 'chamber17'    Remove Files    /opt/Sync/Ramping.txt
    # Run Keyword If    '${slot_location}' == 'chamber17'    Clear_Log_Fail
    # Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit/${slot_location}.txt
    # Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit_count/${slot_location}.txt
    # Run Keyword If    '${slot_location}' != 'chamber17'    Create File    /opt/Sync/Sync_unit_count/${slot_location}.txt    Done
    # ${Raw_logs}    Split String    ${Raw_logs_path}    /
    # Set Global Variable     ${Raw_logs}    
    # OperatingSystem.Run     mkdir /${Raw_logs}[1]/${Raw_logs}[2]/${Raw_logs}[3]/${Raw_logs}[4]/${Raw_logs}[5]/DMESG


Final_Test_Suite
    Set Global Variable    ${Genfail_Test1}    0
    # Get_TLV_List
    # Run Keyword And Ignore Error    YamL_Create_file    2
    # [Arguments]
    # Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit/${slot_location}.txt
    # Run Keyword If    '${slot_location}' != 'chamber17'    Remove Files    /opt/Sync/Sync_unit_count/${slot_location}.txt
    # Run Keyword If    '${slot_location}' != 'chamber17'    START_SSH_chmod_file
    # Run Keyword If    '${slot_location}' == 'chamber17'    Chamber_Hot_Control_Final
    # Run Keyword If    '${slot_location}' == 'chamber17'    Chamber_Ambient_Control_Final
    # ${date_time}=    Get Current Date    result_format=%Y%m%d%H%M%S
    # Run Keyword If    '${slot_location}' != 'chamber17'    OperatingSystem.Run     cp -r /${Raw_logs_path}${/}${serial_number}.txt /var/www/html/sendlog/${serial_number}_ESS_${SUITE STATUS}_${date_time}_${AMAZON_MODEL_NUMBER_ODC}_ESS01_${slot_location}.txt

Initialize_Test_case
    [Documentation]    Initialize of all Test case.

    [Arguments]         ${set_abort}=unlock

    Set Suite Variable    ${dash}    \-

    ${flag} =  CHECK_ABORT
    ${Time_start}=    Get Current Date    result_format=%H:%M:%S
    Set Global Variable    ${Time_start}
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Global Variable    ${Genfail_Test}    1
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Append To List    ${TestFail}    ${PREV TEST NAME}
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Suite Variable    ${TestFail}
    Run Keyword If    '${slot_location}' == 'chamber17'    Check_Status_Chamber
    Run Keyword If    "${flag}" == "abort"    Fail    Skipping Testcase because the User aborted.
    SET_UNSENSITIVE_FLAG
    Run Keyword If    "${Genfail_Test}" == "0"    SET_UNSENSITIVE_FLAG

    #Chaiwat Skip for 10 unit test
    Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=${dash * 109}\n
    Save_to_log    msg=SERIAL NUMBER : ${serial_number}\n
    # Save_to_logs    msg=SCRIPT VERSION : ${scrip_version}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=START TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n\n

Initialize_Test_case_BI
    [Documentation]    Initialize of all Test case.

    [Arguments]         ${set_abort}=unlock

    Set Suite Variable    ${dash}    \-

    ${flag} =  CHECK_ABORT

    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Global Variable    ${Genfail_Test}    1
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Append To List    ${TestFail}    ${PREV TEST NAME}
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Suite Variable    ${TestFail}
    Run Keyword If    '${slot_location}' == 'chamber17'    Check_Status_Chamber
    Run Keyword If    "${flag}" == "abort"    Fail    Skipping Testcase because the User aborted.
    SET_UNSENSITIVE_FLAG
    # Run Keyword If    "${Genfail_Test}" == "0"    SET_UNSENSITIVE_FLAG

    #Chaiwat Skip for 10 unit test
    Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=${dash * 109}\n
    Save_to_log    msg=SERIAL NUMBER : ${serial_number}\n
    # Save_to_logs    msg=SCRIPT VERSION : ${scrip_version}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=START TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n\n

Initialize_Test_case_Monitor
    [Documentation]    Initialize of all Test case.

    [Arguments]         ${set_abort}=unlock

    Set Suite Variable    ${dash}    \-

    ${flag} =  CHECK_ABORT

    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Global Variable    ${Genfail_Test}    1
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Append To List    ${TestFail}    ${PREV TEST NAME}
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Set Suite Variable    ${TestFail}
    Run Keyword If    '${slot_location}' == 'chamber17'    Check_Status_Chamber
    Run Keyword If    "${flag}" == "abort"    Fail    Skipping Testcase because the User aborted.
    SET_UNSENSITIVE_FLAG
    # Run Keyword If    "${Genfail_Test}" == "0"    SET_UNSENSITIVE_FLAG

    #Chaiwat Skip for 10 unit test
    # Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=${dash * 109}\n
    Save_to_log    msg=SERIAL NUMBER : ${serial_number}\n
    # Save_to_logs    msg=SCRIPT VERSION : ${scrip_version}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=START TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n\n

Final_Test_case
    [Documentation]   End process of all Test case.
    [Arguments]
    Set Suite Variable    ${dash}    \-
    ${date_time1}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${STATUS}    Set Variable    ${TEST STATUS}
    # Run Keyword If    '${TEST NAME}' == '100G_QSFP28_Loopback_Traffic_Test'    
    # ${value}   ${output}=  Run Keyword And Ignore Error    Diag_SSH_Dmesg_Command    command=dmesg
    # Run Keyword If    '${value}' == 'PASS'    Append To File      /${Raw_logs}[1]/${Raw_logs}[2]/${Raw_logs}[3]/${Raw_logs}[4]/${Raw_logs}[5]/DMESG/${date_time1}.txt    ${output}
    ${Time_stop}=    Get Current Date    result_format=%H:%M:%S
    Set Global Variable    ${Time_stop}
    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=\n\n\n${dash * 109}\n
    Save_to_log    msg=TEST CASE STATUS : ${TEST STATUS}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=END TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n
    # LOG    ${fail_msg_step}\n
    # OperatingSystem.Run     ln -s ${Raw_logs_path}${/}${TEST NAME}.txt ${Raw_logs_path}${/}../Step_logs/${TEST NAME}_${STATUS}.txt
    # Run Keyword And Ignore Error    Get_Test_list_Status


Get_file_tlv
    Should Contain    ${TEST NAME}    TLV

1000_Tried
    ${Log_QSFP}=  OperatingSystem.Get File    ${Raw_logs_path}${/}${TEST NAME}.txt
    ${a}   Set Variable        0
    ${b}   Set Variable        0
    ${c}   Set Variable        0
    ${c}     Convert To Integer    ${c}
    ${a}     Convert To Integer    ${a}
    ${status1}   ${port1}=  Run Keyword And Ignore Error    Get Regexp Matches     ${Log_QSFP}     \\s+(\\d+)\\s+\\|.*\\|.*\\|\\s+(\\w+)\\s+\\|.*\\|.*\\|.*\\|.*\\|.*    1    2
    ${status2}   ${port2}=  Run Keyword And Ignore Error    Get Regexp Matches     ${Log_QSFP}     \\s+Vendor Name.*:\\s+(\\w+).*Medium Type :\\s+(.*)    1    2
    ${status3}   ${port3}=  Run Keyword And Ignore Error    Get Regexp Matches     ${Log_QSFP}     \\s+Vendor Part Num.*:\\s+(\\w+).*Temperature :\\s+(.*)    1    2
    ${status4}   ${port4}=  Run Keyword And Ignore Error    Get Regexp Matches     ${Log_QSFP}     \\s+Vendor Rev.*:\\s+.*Voltage.*:\\s+(.*)    1    
    ${status5}   ${port5}=  Run Keyword And Ignore Error    Get Regexp Matches     ${Log_QSFP}     \\s+Vendor Serial Num.*:\\s+(\\w+).*Powerclass.*:\\s+(.*)    1    2
    FOR    ${i}    IN RANGE     32
        ${c}    Run Keyword If   '${port1}[${a}][1]' == 'Absent'    Evaluate        ${c}+1
                ...                 ELSE       Evaluate        ${c}+0
        ${b}    Run Keyword If   '${port1}[${a}][1]' == 'Absent'    Evaluate        ${a}-${c}
                ...                 ELSE        Evaluate       ${a}-${c}
        Save_to_logs     Port-${port1}[${a}][0] : ${port1}[${a}][1]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Vendor Name : ${port2}[${b}][0]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Vendor Part Num : ${port3}[${b}][0]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Vendor Vendor Serial Num : ${port5}[${b}][0]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Medium Type : ${port2}[${b}][1]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Temperature : ${port3}[${b}][1]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Voltage : ${port4}[${b}]\n
        Run Keyword If   '${port1}[${a}][1]' == 'Present'    Save_to_logs     Powerclass : ${port5}[${b}][1]\n\n
        ${a}    Evaluate        ${a}+1
    END

Get_TLV_List
    [Arguments]
    Remove Files            ${Raw_logs_path}${/}TLV.txt
    ${output}=              OperatingSystem.Get File    ${Raw_logs_path}${/}${TEST NAME}.txt
    ${Product_Name}         Get Lines Containing String      ${output}      0x21${SPACE*2}16
    ${Part_Number}          Get Lines Containing String      ${output}      0x22${SPACE*2}14
    ${Serial_Number}        Get Lines Containing String      ${output}      0x23${SPACE*2}21
    ${Manufacture_Date}     Get Lines Containing String      ${output}      0x25${SPACE*2}19
    ${Device_Version}       Get Lines Containing String      ${output}      0x26${SPACE*3}1
    ${Label_Revision}       Get Lines Containing String      ${output}      0x27${SPACE*3}3
    ${Platform_Name}        Get Lines Containing String      ${output}      0x28${SPACE*2}20
    ${ONIE_Version}         Get Lines Containing String      ${output}      0x29${SPACE*2}11
    ${MAC_Addresses}        Get Lines Containing String      ${output}      0x2A${SPACE*3}2
    ${Manufacturer}         Get Lines Containing String      ${output}      0x2B${SPACE*3}9
    ${Country_Code}         Get Lines Containing String      ${output}      0x2C${SPACE*3}2
    ${Vendor_Name}          Get Lines Containing String      ${output}      0x2D${SPACE*3}9
    ${Diag_Version}         Get Lines Containing String      ${output}      0x2E${SPACE*3}5
    ${Vendor_Extension1}    Get Lines Containing String      ${output}      0xFD${SPACE*2}34
    ${Vendor_Extension2}    Get Lines Containing String      ${output}      0xFD${SPACE*2}18
    ${Base_MAC_Address}     Get Lines Containing String      ${output}      0x24${SPACE*3}6
    ${CRC_32}               Get Lines Containing String      ${output}      0xFE${SPACE*3}4

    ${Product_Name}         Get Line        ${Product_Name}            0
    ${Part_Number}          Get Line        ${Part_Number}             0
    ${Serial_Number}        Get Line        ${Serial_Number}           0
    ${Manufacture_Date}     Get Line        ${Manufacture_Date}        0
    ${Device_Version}       Get Line        ${Device_Version}          0
    ${Label_Revision}       Get Line        ${Label_Revision}          0
    ${Platform_Name}        Get Line        ${Platform_Name}           0
    ${ONIE_Version}         Get Line        ${ONIE_Version}            0
    ${MAC_Addresses}        Get Line        ${MAC_Addresses}           0
    ${Manufacturer}         Get Line        ${Manufacturer}            0
    ${Country_Code}         Get Line        ${Country_Code}            0
    ${Vendor_Name}          Get Line        ${Vendor_Name}             0
    ${Diag_Version}         Get Line        ${Diag_Version}            0
    ${Vendor_Extension1}    Get Line        ${Vendor_Extension1}       0
    ${Vendor_Extension2}    Get Line        ${Vendor_Extension2}       0
    ${Base_MAC_Address}     Get Line        ${Base_MAC_Address}        0
    ${CRC_32}               Get Line        ${CRC_32}                  0


    ${Product_Name}         Remove String        ${Product_Name}            ${SPACE}
    ${Part_Number}          Remove String        ${Part_Number}             ${SPACE}
    ${Serial_Number}        Remove String        ${Serial_Number}           ${SPACE}
    ${Manufacture_Date}     Remove String        ${Manufacture_Date}        ${SPACE}
    ${Device_Version}       Remove String        ${Device_Version}          ${SPACE}
    ${Label_Revision}       Remove String        ${Label_Revision}          ${SPACE}
    ${Platform_Name}        Remove String        ${Platform_Name}           ${SPACE}
    ${ONIE_Version}         Remove String        ${ONIE_Version}            ${SPACE}
    ${MAC_Addresses}        Remove String        ${MAC_Addresses}           ${SPACE}
    ${Manufacturer}         Remove String        ${Manufacturer}            ${SPACE}
    ${Country_Code}         Remove String        ${Country_Code}            ${SPACE}
    ${Vendor_Name}          Remove String        ${Vendor_Name}             ${SPACE}
    ${Diag_Version}         Remove String        ${Diag_Version}            ${SPACE}
    ${Vendor_Extension1}    Remove String        ${Vendor_Extension1}       ${SPACE}
    ${Vendor_Extension2}    Remove String        ${Vendor_Extension2}       ${SPACE}
    ${Base_MAC_Address}     Remove String        ${Base_MAC_Address}        ${SPACE}
    ${CRC_32}               Remove String        ${CRC_32}                  ${SPACE}
    
    ${Product_Name}         Split String    ${Product_Name}         0x2116
    ${Part_Number}          Split String    ${Part_Number}          0x2214
    ${Serial_Number}        Split String    ${Serial_Number}        0x2321
    ${Manufacture_Date}     Split String    ${Manufacture_Date}     0x2519
    ${Device_Version}       Split String    ${Device_Version}       0x261
    ${Label_Revision}       Split String    ${Label_Revision}       0x273
    ${Platform_Name}        Split String    ${Platform_Name}        0x2820
    ${ONIE_Version}         Split String    ${ONIE_Version}         0x2911
    ${MAC_Addresses}        Split String    ${MAC_Addresses}        0x2A2
    ${Manufacturer}         Split String    ${Manufacturer}         0x2B9
    ${Country_Code}         Split String    ${Country_Code}         0x2C2
    ${Vendor_Name}          Split String    ${Vendor_Name}          0x2D9
    ${Diag_Version}         Split String    ${Diag_Version}         0x2E5
    ${Vendor_Extension1}    Split String    ${Vendor_Extension1}    0xFD34
    ${Vendor_Extension2}    Split String    ${Vendor_Extension2}    0xFD18
    ${Base_MAC_Address}     Split String    ${Base_MAC_Address}     0x246
    ${CRC_32}               Split String    ${CRC_32}               0xFE4

    log.yaml_tlv            ${SPACE*2}${Product_Name}[0]: ${Product_Name}[1]
    log.yaml_tlv            ${SPACE*2}${Part_Number}[0]: ${Part_Number}[1]
    log.yaml_tlv            ${SPACE*2}${Serial_Number}[0]: ${Serial_Number}[1]
    log.yaml_tlv            ${SPACE*2}${Manufacture_Date}[0]: ${Manufacture_Date}[1]
    log.yaml_tlv            ${SPACE*2}${Device_Version}[0]: ${Device_Version}[1]
    log.yaml_tlv            ${SPACE*2}${Label_Revision}[0]: ${Label_Revision}[1]
    log.yaml_tlv            ${SPACE*2}${Platform_Name}[0]: ${Platform_Name}[1]
    log.yaml_tlv            ${SPACE*2}${ONIE_Version}[0]: ${ONIE_Version}[1]
    log.yaml_tlv            ${SPACE*2}${MAC_Addresses}[0]: ${MAC_Addresses}[1]
    log.yaml_tlv            ${SPACE*2}${Manufacturer}[0]: ${Manufacturer}[1]
    log.yaml_tlv            ${SPACE*2}${Country_Code}[0]: ${Country_Code}[1]
    log.yaml_tlv            ${SPACE*2}${Vendor_Name}[0]: ${Vendor_Name}[1]
    log.yaml_tlv            ${SPACE*2}${Diag_Version}[0]: ${Diag_Version}[1]
    log.yaml_tlv            ${SPACE*2}${Vendor_Extension1}[0]1: ${Vendor_Extension1}[1]
    log.yaml_tlv            ${SPACE*2}${Vendor_Extension2}[0]2: ${Vendor_Extension2}[1]
    log.yaml_tlv            ${SPACE*2}${Base_MAC_Address}[0]: ${Base_MAC_Address}[1]
    log.yaml_tlv            ${SPACE*2}${CRC_32}[0]: ${CRC_32}[1]




log.yaml_tlv
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False
    Append To File      ${Raw_logs_path}${/}TLV.txt    ${msg}\n


# Final_Test_case
#     [Documentation]   End process of all Test case.
#     Set Suite Variable    ${dash}    \-
#     ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
#     Save_to_logs    msg=\n\n\n${dash * 77}\n
#     Save_to_logs    msg=TEST CASE STATUS : ${TEST STATUS}\n
#     Save_to_logs    msg=STEP TEST NAME : ${TEST NAME}\n
#     Save_to_logs    msg=END TIME : ${date_time}\n
#     Save_to_logs    msg=${dash * 77}\n
#     SSHLibrary.Close All Connections
Create_Test_List
    [Arguments]     ${Loop_Count}=1
    # ${Get_Loop}    Get Substring    ${TEST NAME}    0    1
    # ${Loop_Count}    Convert To Number    ${Loop_Count}
    FOR    ${i}    IN RANGE    ${Loop_Count}
        ${Loop_Count_1}    Evaluate    ${i}+1
        ${Log_Status}=    OperatingSystem.Get File    ${Raw_logs_path}${/}list_status_${Loop_Count_1}.txt
        ${Log_item}=    OperatingSystem.Get File    ${Raw_logs_path}${/}list_item_${Loop_Count_1}.txt
        ${status}           ${output}=          Run Keyword And Ignore Error    Should Not Contain    ${Log_Status}    FAIL
        ${Result}   Set Variable If    '${status}' == 'PASS'     PASS    FAIL
        ${Result1}   Set Variable If    '${status}' == 'PASS'     PASS    INCOMPLETE
        log.yaml    ${SPACE*2}'${Loop_Count_1}':
        log.yaml    ${SPACE*4}name: null
        log.yaml    ${SPACE*4}cycle: ${Loop_Count_1}
        log.yaml    ${SPACE*4}start_line_num: 
        log.yaml    ${SPACE*4}end_line_num:
        log.yaml    ${SPACE*4}result: ${Result}
        log.yaml    ${SPACE*4}summary: 
        log.yaml    ${SPACE*4}- ============================================
        log.yaml    ${Log_Status}
        log.yaml    ${SPACE*4}item_list:
        log.yaml    ${Log_item}
        log.yaml_status_passFail    ${SPACE*2}Cycle ${Loop_Count_1}: ${Result1}
        # Set Global Variable    ${Result}${i}    ${Result}
        # ${Line_cut}      Convert To String   ${Loop_Count_1}
        # Save_to_logs    ${Line_cut}
    END

Get_Test_list_Status
    [Arguments]
    ${Line_start}     listener.line_num_for_phrase_in_file    : ${TEST NAME}      ${Raw_logs_path}${/}${serial_number}.txt
    ${Line_end}     listener.line_num_for_phrase_in_file    ${TEST NAME} END    ${Raw_logs_path}${/}${serial_number}.txt
    ${Test_num}     Split String     ${TEST NAME}    _
    ${Get_num}      Get Substring    ${TEST NAME}    2    4
    ${Get_num}    Convert To Number    ${Get_num}
    ${Get_num}=       Evaluate      ${Get_num}+1
    ${Get_num}      Convert To String   ${Get_num}
    ${Get_num}      Remove String    ${Get_num}    .0
    ${Get_Loop}     Get Substring    ${TEST NAME}    0    1
    ${status}   ${output}=  Run Keyword And Ignore Error    Get_file_tlv
    Run Keyword If    '${status}' == 'PASS'    Get_TLV_List
    # ${Test_name}    Remove String    ${TEST NAME}    ${Test_num}[0]_
    # ${Test_name}    Replace String   ${Test_name}    _    ${SPACE}
    Run Keyword If     '${TEST STATUS}' == 'FAIL'    log.yaml_get_Message_Fail    ${SPACE*2}- 'cycle${Get_Loop} Other Item: FAIL (${TEST NAME} time_start = ${Time_start})'
    log.yaml_status    ${SPACE*4}- '${TEST NAME}: ${TEST STATUS}'    ${Get_Loop}
    log.yaml_item      ${SPACE*6}${Get_num}-${TEST NAME}:    ${Get_Loop}
    log.yaml_item      ${SPACE*8}name: ${TEST NAME}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}index: '${Get_num}'    ${Get_Loop}
    log.yaml_item      ${SPACE*8}start_line_num: ${Line_start}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}end_line_num: ${Line_end}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}result: ${TEST STATUS}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}start_time: ${Time_start}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}end_time: ${Time_stop}    ${Get_Loop}
    log.yaml_item      ${SPACE*8}spend_time: null    ${Get_Loop}
    log.yaml_item      ${SPACE*8}boot_diag_fail_reason: null    ${Get_Loop}

# Get_Number_Test_list
#     [Arguments]    ${Get_num_1}
#     Run Keyword If    '${Get_num_1}' == '0'    Remove String    ${Get_num}    0

        #   1-Early Collect:
        #     name: Early Collect
        #     index: '1'
        #     start_line_num: 3012
        #     end_line_num: 4262
        #     result: PASS
        #     start_time: 07:10:50
        #     end_time: 07:11:32
        #     spend_time: null
        #     boot_diag_fail_reason: null

Get_Line_number
    [Arguments]
    ${Line_start}     listener.line_num_for_phrase_in_file    : ${TEST NAME}      ${Raw_logs_path}${/}${serial_number}.txt
    ${Line_end}     listener.line_num_for_phrase_in_file    ${TEST NAME} END    ${Raw_logs_path}${/}${serial_number}.txt

log.yaml_get_Message_Fail
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${Loop_status}=0    ${verify}=False
    Append To File      ${Raw_logs_path}${/}message_Fail.txt    ${msg}\n

log.yaml_status_passFail
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${Loop_status}=0    ${verify}=False
    Append To File      ${Raw_logs_path}${/}status_PassFail.txt    ${msg}\n

log.yaml_status
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${Loop_status}=0    ${verify}=False
    Append To File      ${Raw_logs_path}${/}list_status_${Loop_status}.txt    ${msg}\n

log.yaml_item
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${Loop_status}=0    ${verify}=False
    Append To File      ${Raw_logs_path}${/}list_item_${Loop_status}.txt    ${msg}\n

YamL_Create_file
    [Arguments]     ${Loops}
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    ${Timestamp}=    Get Current Date    result_format=%Y%m%d%H%M%S
    log.yaml    meta_version: 0.0.1
    log.yaml    test_result: null
    log.yaml    special_wavier: null
    log.yaml    log_name: 8060DC021520019_ESS_FAIL_20220106044402_AS8060-32X-DC-11_Chamber6L_Slot9_9_Y.txt
    log.yaml    header:
    log.yaml    ${SPACE*2}test_site: null
    log.yaml    ${SPACE*2}test_site: null
    log.yaml    ${SPACE*2}sn: ${serial_number}
    log.yaml    ${SPACE*2}test_type: null
    log.yaml    ${SPACE*2}result: ${SUITE STATUS}
    log.yaml    ${SPACE*2}date: '${date}'
    log.yaml    ${SPACE*2}time_stamp: '${Timestamp}'
    log.yaml    ${SPACE*2}platform: null
    log.yaml    ${SPACE*2}chamber: Chamber6L
    log.yaml    ${SPACE*2}slot: ${slot_location}
    log.yaml    ${SPACE*2}diag_version: 02.02.00.29
    log.yaml    ${SPACE*2}log_path: 220106-1//
    log.yaml    ${SPACE*2}s3_path: null
    log.yaml    test_list:
    Create_Test_List    ${Loops}
    ${Log_TLV}=    OperatingSystem.Get File    ${Raw_logs_path}${/}TLV.txt
    ${Log_Status}=    OperatingSystem.Get File    ${Raw_logs_path}${/}status_PassFail.txt
    ${status}           ${output}=          Run Keyword And Ignore Error    Should Not Contain    ${Log_Status}    INCOMPLETE
    ${Result}   Set Variable If    '${status}' == 'PASS'     PASS    FAIL
    ${Message_Fail}=    OperatingSystem.Get File    ${Raw_logs_path}${/}message_Fail.txt
    log.yaml    media:
    log.yaml    tlv:
    log.yaml    ${Log_TLV}
    log.yaml    test_summary:
    log.yaml    ${SPACE*2}total_cycle: ${Loops}
    log.yaml    ${SPACE*2}result: ${Result}
    log.yaml    ${SPACE*2}finished_cycle: ${Loops}
    log.yaml    ${Log_Status}
    log.yaml    test_failures:
    log.yaml    ${SPACE*2}incomplete:
    log.yaml    ${Message_Fail}
    log.yaml    key_parameters:



log.yaml
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False
    Append To File      ${Raw_logs_path}${/}${serial_number}.yaml    ${msg}\n

Check_Status_Chamber
    [Arguments]
    Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

SET_SENSITIVE_FLAG
    [Documentation]    SET SENSITIVE FLAG.
    Create Session      create_url      http://localhost:${port_api}/api
    &{data}=  Create Dictionary         slot_location_no=${slot_location}         flag=lock
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Post Request        create_url        /abort_flag      data=${data}       headers=${header}
    Should Contain        ${resp.text}        Set flag Successfully

SET_UNSENSITIVE_FLAG
    [Documentation]    SET SENSITIVE FLAG.
    Create Session      create_url      http://localhost:${port_api}/api
    &{data}=  Create Dictionary         slot_location_no=${slot_location}         flag=unlock
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Post Request        create_url        /abort_flag      data=${data}       headers=${header}
    LOG    ${resp}\n
    LOG    ${resp.text}\n
    Should Contain        ${resp.text}        Set flag Successfully

CHECK_ABORT
    Create Session      create_session      http://localhost:${port_api}/api
    &{data}=  Create Dictionary       slot_location_no=${slot_location}
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Get Request        create_session        /abort     params=${data}    headers=${header}
    Log to console       ${resp.text}
    Should Contain       ${resp.text}       "flag":
    ${match}	${flag} =
    ...	    Should Match Regexp	    ${resp.text}	    \\"flag\\"\\:\\s+\\"(\\S+)\\"
    [Return]    ${flag}


REQUEST_ACCESS_HARDWARE
    Create Session      create_url      http://localhost:8080/api
    &{data}=  Create Dictionary         serial_number=${serial_number}        timeout=${time_out}          type=${queue_type}
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Post Request        create_url        /queue_hardware      data=${data}       headers=${header}
    &{test1}=    Evaluate     json.loads($resp.json())    json
    Log to console        &{test1}[error]
    Should Be Equal       &{test1}[error]    ${False}

# SYNC_POINT
#     Create Session      createcar       ${url}
#     &{data}=  Create Dictionary    serial_number=${serial_number}     slot_location=${slot_location}      setup=False        timeout=3600        batch_id=${batch_id}        allow_timeout=True
#     &{header}=  Create Dictionary     Content-Type=application/json     Data-Type=application/json
#     ${resp}=  Post Request      createcar       /sync_point     data=${data}       headers=${header}
#     # LOG        ${resp.status_code}
#     # LOG        ${resp.content}
#     # LOG        ${resp.text}sync_point
#     &{res_json}=    Evaluate    json.loads($resp.content)    json
#     ${date_time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
#     Save_to_logs     ${date_time} - &{res_json}[data]${\n}
#     Save_to_logs     ${date_time} - &{res_json}[error]${\n}
#     # Run keyword if    ${setup_config} == ${True} and &{res_json}[error] == ${False} and &{res_json}[data] == ${serial_number}    Setup Config
#     Should Be Equal      &{res_json}[error]        ${None}

SYNC_POINT
    Create Session      createcar       ${url}
    &{data}=  Create Dictionary    serial_number=${serial_number}     slot_location=${slot_location}      setup=False        timeout=${time_out}        batch_id=${batch_id}        allow_timeout=True
    &{header}=  Create Dictionary     Content-Type=application/json     Data-Type=application/json
    ${resp}=  Post Request      createcar       /sync_point     data=${data}       headers=${header}
    &{res_json}=    Evaluate    json.loads($resp.content)    json
    ${date_time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    Save_to_logs     ${date_time} - &{res_json}[data]${\n}
    Save_to_logs     ${date_time} - &{res_json}[error]${\n}
    # Run keyword if    ${setup_config} == ${True} and &{res_json}[error] == ${False} and &{res_json}[data] == ${serial_number}    Setup Config

    Should Be Equal      &{res_json}[error]        ${None}

Save_to_log
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}

    Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    ${msg}

# Save_to_logs
#     [Documentation]     Save the message to the raw logs of test case.
#     [Arguments]         ${msg}

#     Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    ${msg}
#     Append To File      ${Raw_logs_path}${/}${TEST NAME}.raw    ${msg}
#     Append To File      ${Raw_logs_path}${/}${serial_number}.txt    ${msg}
#     ${status}   ${std_out}=  Run Keyword And Ignore Error   Append To File      ${Raw_logs_path}${/}${sequence}.txt    ${msg}
#     # Append To File      /opt/Log_For_Linecard/${slot_location}${/}${TEST NAME}.txt    ${msg}

Save_to_logs
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False

    # Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    ${msg}
    Append To File      ${Raw_logs_path}${/}${TEST NAME}.raw    ${msg}
    # Append To File      ${Raw_logs_path}${/}${serial_number}.txt    ${msg}
    Append To File      ${Raw_logs_path}${/}${serial_number}.raw    ${msg}
    # ${status}   ${std_out}=  Run Keyword And Ignore Error   Append To File      ${Raw_logs_path}${/}${sequence}.txt    ${msg}
    # Append To File      /opt/Log_For_Linecard/${slot_location}${/}${TEST NAME}.txt    ${msg}

log.debug
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False
    ${date_time}=       Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    ${date_time} : [DEBUG] : ${msg}\n

log.newline
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         
    ${date_time}=       Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    \n

log.info
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False
    Append To File      ${Raw_logs_path}${/}${TEST NAME}.raw    ${msg}


Test_Logs
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}
    Append To File      /opt/Log_For_Linecard/${slot_location}/${slot_location}${/}${TEST NAME}.txt    ${msg}

Setup Config
    [Documentation]    Setup config before testing on next case

    Save_to_logs    Setup config is in progress now.
    Sleep           10 seconds
    Save_to_logs    Setup config is complete.

Set_Pass
    [Documentation]     For save logs pass and set fail in robot.
    [Arguments]         ${pass_msg}

    Save_to_logs    PASSED:${SPACE * 2}${pass_msg}

Set_Fail
    [Documentation]     For save logs fail and set fail in robot.
    [Arguments]         ${fail_msg}

    Save_to_logs    FAILED:${SPACE * 2}${fail_msg}
    Fail            ${fail_msg}

# TELNET_CLOSE
#     Telnet.Close Connection
#     # Save_to_logs      Telnet Close\r
#     sleep    0.5s

# TELNET_OPEN
#     [Arguments]    ${timeout}
#     Telnet.Open Connection    ${ETLE}    port=${PORT_UUT}
#     # Save_to_logs       Telnet Open\r
#     Telnet.Set Encoding    ISO-8859-1
#     Telnet.Set Telnetlib Log Level    DEBUG
#     Telnet.Set Timeout    ${timeout}
#     Telnet.Write    cd /home/cel-tool/bin/
#     ${console}=    Telnet.Read Until    \#
#     # Save_to_logs       ${console}\r
#     sleep    1
Clear_Log_Fail
    [Arguments]
    Run Keyword And Ignore Error    Empty Directory	    /tftpboot/Log_Fail${/}
    Run Keyword And Ignore Error    Remove Directory    /tftpboot/Log_Fail${/}

    # Run Keyword And Ignore Error    Empty Directory	    /tftpboot/OAt
    # Run Keyword And Ignore Error    Remove Directory    /tftpboot/OAt
    # ${status}   ${console}=  Run Keyword And Ignore Error      OperatingSystem.Get File	${Raw_logs_path}${/}${TEST NAME}.txt
    # Append To File    /tftpboot/OAt${/}${serial_number}${/}${TEST NAME}.txt     ${console}
    # Append To File      ${Raw_logs_path}${/}${TEST NAME}.txt    ${msg}
    # Append To File      ${Raw_logs_path}${/}${serial_number}.txt    ${msg}
    # ${status}   ${std_out}=  Run Keyword And Ignore Error   Append To File      ${Raw_logs_path}${/}${sequence}.txt    ${msg}
Copy_Log_Verify
    [Arguments]
    ${status}   ${console}=  Run Keyword And Ignore Error    OperatingSystem.Get File    ${Raw_logs_path}${/}${sequence}.txt
    Run Keyword And Ignore Error    Append To File    /tftpboot/Log_Fail${/}${serial_number}${/}${sequence}.txt     ${console}
    # Run Keyword And Ignore Error     Run     cp -r ${Raw_logs_path}${/}${sequence}.txt /tftpboot/Log_Fail${/}${serial_number}${/}${sequence}.txt

Separate_Test_Case
    [Arguments]     ${Name_Sequence}    ${Test_Sequence}
    Set Global Variable    ${sequence}       ${Name_Sequence}
    Set Global Variable    ${Gen_fail}    0
    Head_Test_case
    ${status}   ${std_out}=  Run Keyword And Ignore Error    ${Test_Sequence}
    Run Keyword If    '${Gen_fail}' == '1'    set test variable    ${status}    FAIL
    Run Keyword If    '${status}' == 'FAIL'    Copy_Log_Verify
    Run Keyword If    '${status}' == 'FAIL'    Run    echo "${status} = ${sequence}" >> /tftpboot/Log_Fail${/}${serial_number}${/}Result_Status_${serial_number}.txt
    Run    echo "${status} = ${sequence}" >> ${Raw_logs_path}${/}Result_Status_${serial_number}.txt
    Run Keyword If    '${status}' == 'FAIL'    Set Global Variable    ${Genfail_Test}    1
    End_Test_case

Head_Test_case
    [Documentation]    Initialize of all Test case.
    [Arguments]
    Set Suite Variable    ${dash}    \-
    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    ${dash * 109}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    - SERIAL NUMBER : ${serial_number}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    - STEP TEST NAME : ${sequence}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    - START TIME : ${date_time}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    ${dash * 109}\n\n

End_Test_case
    [Documentation]   End process of all Test case.
    [Arguments]
    Set Suite Variable    ${dash}    \-
    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    \n\n\n${dash * 109}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    - STEP TEST NAME : ${sequence}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    - END TIME : ${date_time}\n
    Append To File          ${Raw_logs_path}${/}${sequence}.txt    ${dash * 109}\n

Get_ResultTest_Fail
    [Arguments]
    ${output}=    OperatingSystem.Get File    ${Raw_logs_path}${/}Result_Status_${serial_number}.txt
    ${Summary_Test_fail}      Get Lines Containing String     ${output}     FAIL
    ${Summary_Test_fail}      Get Line                        ${Summary_Test_fail}    0
    ${Summary_Test_fail}      Split String                    ${Summary_Test_fail}    =
    [Return]    ${Summary_Test_fail}[1]
    # Set Global Variable       ${Name_Test_fail}               ${Summary_Test_fail}[1]

Set_Test_Name_Fail
    [Arguments]
    ${status}   ${std_out}=  Run Keyword And Ignore Error    Get_ResultTest_Fail
    Run Keyword If    '${status}' == 'FAIL'    set test variable    ${Name_Test_fail}    END
    Run Keyword If    '${status}' == 'PASS'    set test variable    ${Name_Test_fail}    ${std_out}
    Set Global Variable    ${Name_Test_fail}

# Set_Name_fail
#     set test variable    ${status}    END

START_SSH_chmod_file
    [Arguments] 
    Run Keyword And Ignore Error    START_SSH_server
    SSHLibrary.Write    sudo chmod 777 ${Raw_logs_path} -R
    SSHLibrary.Read Until    \$
    SSH_CLOSE

Test11111
    Save_to_logs     djfkjkfdjfk\n
    Save_to_logs     djfkjkfdjfk\n

Test111112
    Save_to_logs     djfkjkfdjfkfgfdgfdg\n
    # FAIL

Test_Try
    Save_to_logs     djfkjkfdjfkfgfdgfdg\n
    FAIL

Telnet_Read_Until_Prompt
    [Arguments]    ${Command}
    ${status}   ${console}=  Run Keyword And Ignore Error    Telnet.Read Until    ${Command}
    Save_to_logs    ${console}\n
    Run Keyword If    '${status}' == 'FAIL'    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    FAIL
    [Return]   ${console}

chmod_test_log_file
    [Arguments]
    Run    chmod 777 ${Raw_logs_path}${/} -R

Retry_test_case
    [Arguments]    ${Command}    ${loop}=2
    ${loop_count}     Convert To Number     ${loop}
    ${loop_count}     Evaluate     ${loop_count}-1
    ${loop_count}     Convert to String    ${loop_count}
    ${loop_count}     Remove String    ${loop_count}    .0
    FOR     ${i}    IN RANGE    ${loop}
        Run Keyword And Ignore Error     Run    /usr/bin/pkill -HUP -f "^telnet .*${Port_Telnet}"
        ${status}  ${stderr} =  Run Keyword And Ignore Error     Telnet.Close All Connections
        ${status}   ${std_out}=  Run Keyword And Ignore Error    ${Command}
        Exit For Loop If    '${status}' == 'PASS'
        Run Keyword If     '${i}' == '${loop_count}'    FAIL
    END
