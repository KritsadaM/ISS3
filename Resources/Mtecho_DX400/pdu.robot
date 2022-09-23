*** Keywords ***
Open_Connection
    [Documentation]   Open and login SSH Connection.
    SSHLibrary.Open Connection    ${wtp_ip}

Close_Connection
    [Documentation]   Close SSH Connection.
    SSHLibrary.Close Connection

Power_Off_apc_1
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          off ${psu1_outlet}              APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_wti_1
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    WTI_TELNET_CONN_OPEN
    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_wti_2
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    WTI_TELNET_CONN_OPEN
    Telnet_Set_APC_command                          ${psu2_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_apc_2
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          off ${psu2_outlet}              APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu2_outlet} off             >
    Telnet.Close Connection
    sleep   40

APC_TELNET_CONN_OPEN
    [Arguments]    ${apc_ip}=${apc_ip}    ${port}=23   ${prompt}=APC>   ${username}=apc    ${password}=apc-c
    Telnet.Open Connection                 host=${apc_ip}
    ...                                    port=${port}
    ...                                    prompt=${prompt}
    ...                                    timeout=30
    ...                                    newline=CRLF
    ...                                    encoding=ISO-8859-1
    ...                                    encoding_errors=IGNORE
    ...                                    default_log_level=TRACE
    ...                                    telnetlib_log_level=TRACE

    ${stdout} =    Telnet.Login            username=${username}
    ...                                    password=${password}
    ...                                    login_prompt=User Name
    ...                                    password_prompt=Password

WTI_TELNET_CONN
    [Arguments]
    Telnet.Open Connection    ${TelnetIP}    port=${WTI_port}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}

WTI_TELNET_CONN_OPEN
    log.debug  ********************************\n
    log.debug  Login to Power control Custom\n
    Wait Until Created    /opt/Sync/Sync_Power.txt    60min
    ${status}   ${output}=  Run Keyword And Ignore Error    WTI_TELNET_CONN
    Run Keyword If    '${status}' == 'FAIL'    Telnet.Close All Connections
    Run Keyword If    '${status}' == 'FAIL'    Create File    /opt/Sync/Sync_Power.txt    Done
    Run Keyword If    '${status}' == 'FAIL'    FAIL     Log-in Power Control Custom
    Create File    /opt/Sync/Sync_Power.txt    Done
    log.debug  Logout to Power control Custom\n
    log.debug  ********************************\n

Power_Off_UUT_1
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          off ${Power_Control}            APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet.Close Connection
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu2_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_UUT
    Util_Test_Execution         test_case=Power_Off_UUT_1
    ...                         retry_loop=3

Power_On_UUT
    Util_Test_Execution         test_case=Power_On_UUT_1
    ...                         retry_loop=3

Power_Cyling
    Power_Off_UUT
    Power_On_UUT
    log.debug    Bios boot start: UUT
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                                     wait_for=login:
                                                            ...                                     time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error                 TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command                  command=\r
                                               ...                                          wait_for=login:
    Diag_Telnet_Execute_Command                                                             command=${USERNAME}
    ...                                                                                     wait_for=Password:
    Diag_Telnet_Execute_Command_Password                                                    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2                                                           command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2                                                           command=ping ${SSH_IP} -c5
    ...                                                                                     expect_string=5 received
    Diag_Telnet_Execute_Command_2                                                           command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2                                                           command=ps -ef | grep onlpd

Power_Cyling_1
    Power_On_apc_1
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                                     wait_for=login:
                                                            ...                                     time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command     command=\r
                                               ...                                      wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd

Select_OS_A_SSH
    sleep    1s
    SSHLibrary.Write Bare    [A
    sleep    2s
    SSHLibrary.Write    \r

Select_OS_B_SSH
    sleep    1s
    SSHLibrary.Write Bare    [B
    sleep    2s
    SSHLibrary.Write Bare    [B
    sleep    2s
    SSHLibrary.Write Bare    [B
    sleep    2s
    SSHLibrary.Write Bare    [B
    sleep    2s
    SSHLibrary.Write Bare    [B
    sleep    2s
    SSHLibrary.Write    \r
    sleep    3s

Select_OS_A
    sleep    1s
    Telnet.Write Bare    [A
    Telnet.Read
    sleep    2s
    Telnet.Write    \r
    Telnet.Read

Select_OS_B
    sleep    1s
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write    \r
    Telnet.Read

Command_Power_Cyling_1
    [Arguments]     ${Command}    ${time_out}=240s
    Diag_Telnet_Execute_Command    command=${Command}
    ...                            wait_for=IOS boot sta
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd


Command_Power_Cyling_2
    [Arguments]     ${Command}    ${time_out}=240s
    log.debug                           Reboot to boot from Backup BIOS.
    Diag_Telnet_Execute_Command    command=${Command}
    ...                            wait_for=IOS boot sta
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    Warning:Boot from Backup BIOS!
    Run Keyword If    '${status}' == 'FAIL'    FAIL    The unit Can't boot with Backup Bios!
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd

Retry_Set_IP
    [Arguments]
    Re_Login
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    
Reset_button_switch
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2    command=sudo su
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up

Warm_Cyling
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    Diag_Telnet_Execute_Command_2    command=sudo su
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up

Power_Cyling_ONIE
    [Arguments]    ${time_out}=400s
    Power_Off_UUT
    Power_On_UUT
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    TELNET_CLOSE
    sleep    1s
    sleep    2s
    TELNET_Send_Command_ignore_prompt    \r
    sleep    3s  
    TELNET_Send_Command_ignore_prompt    \r
    sleep    60s  
    TELNET_Send_Command_expect_prompt    \r     ONIE:/ #
    sleep    60s
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #

Power_Cyling_Install_ONIE
    [Arguments]    ${time_out}=400s
    Power_Off_UUT
    Power_On_UUT
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    sleep    1s
    sleep    2s
    sleep    3s  
    Telnet.Write    \r
    sleep    60s  
    Telnet.Write    \r
    ${out1}=    Telnet.Read Until    ONIE:/ #
    Save_to_logs        ${out1}\r
    TELNET_CLOSE
    sleep    60s
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #

Reboot_Install_ONIE
    [Arguments]    ${time_out}=400s
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Write    onie-nos-install onie-installer-x86_64-cel_midstone-100x-r0.bin
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    ONIE: Rebooting...
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    SONiC-OS
    Save_to_logs        ${out1}\r
    sleep    1s
    sleep    2s
    sleep    3s  
    Telnet.Write    \r
    sleep    60s  
    Telnet.Write    \r
    ${out1}=    Telnet.Read Until    ONIE:/ #
    Save_to_logs        ${out1}\r
    TELNET_CLOSE
    sleep    120s
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    sleep    60s
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    
Uninstall_Select_OS_B
    sleep    1s
    Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write    \r
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r

Uninstall_Select_OS_A
    sleep    1s
    Telnet.Write    \r
    
Power_Cyling_Uninstall_ONIE
    [Arguments]    ${time_out}=400s
    Power_Off_UUT
    Power_On_UUT
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'PASS'    Uninstall_Select_OS_B
    sleep    1s
    sleep    2s
    Telnet.Write    \r
    sleep    1s
    Telnet.Write Bare    [B
    sleep    1s
    sleep    3s  
    Telnet.Write    \r
    ${out1}=    Telnet.Read Until    Please press Enter to activate this console.
    Save_to_logs        ${out1}\r
    sleep    1s  
    Telnet.Write    \r
    ${out1}=    Telnet.Read Until    ONIE:/ #
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Write    onie-uninstaller diag
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    Erase complete.
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    Uninstall complete.
    Save_to_logs        ${out1}\r
    ${out1}=    Telnet.Read Until    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Not Contain    ${out1}    SONiC
    Run Keyword If    '${status}' == 'FAIL'    Save_to_logs        ${out1}\r 
    Run Keyword If    '${status}' == 'FAIL'    FAIL     Uninstall not complete.
    TELNET_CLOSE

Power_On_apc_1
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          on ${psu1_outlet}              APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu1_outlet} on             >
    Telnet.Close Connection
    sleep   5

Power_On_apc_2
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          on ${psu2_outlet}              APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu2_outlet} on             >
    Telnet.Close Connection
    sleep   5

Power_On_UUT_1
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    APC_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet_Set_APC_command                          on ${Power_Control}              APC>
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Write                                    exit
    Run Keyword If     '${logop}' == 'FCT' or '${logop}' == 'FCT_AUDIT'    Telnet.Read
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu1_outlet} on             >
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet.Close Connection
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${logop}' != 'FCT' and '${logop}' != 'FCT_AUDIT'    Telnet_Set_APC_command                          ${psu2_outlet} on             >
    Telnet.Close Connection
    sleep   5

Verify_Run_PSU
    [Arguments]    ${filetoccheck}
    ${status}    ${pdu_usage}=    Run Keyword And Ignore Error    OperatingSystem.File Should Not Exist    ${filetoccheck}
    Run Keyword If    '${status}' == 'FAIL'    Wait Until Removed    ${filetoccheck}    5min
    Create File    ${filetoccheck}    ${SERIAL}
    KILL_EXTERNAL_USER
    Append To File    ${dir_unit}/${TEST NAME}.txt    \rACTIVE_PDU_USAGE:${SERIAL}\r

KILL_EXTERNAL_USER
    ${PORT_CTH_OPTO} =    GET_CONFIG    ${SLOTID}   1   
    Run    sudo /usr/bin/pkill -HUP -f "^telnet .*${PORT_CTH_OPTO}"
    Append To File    ${dir_unit}/${TEST NAME}.txt    \r\r###_CLEARED_SERIAL_CONSOLE_####\r

ClearTestTeardown
    [Arguments]    ${filetoccheck}   
    ${pdustatus0}    ${output}=    Run Keyword And Ignore Error    OperatingSystem.File Should Not Exist    ${filetoccheck}
    Pass Execution If    '${pdustatus0}' == 'PASS'    SKIPPED_PDU_USAGE_CHECK
    ${stat1}    ${pdustatus} =    Run Keyword And Ignore Error    OperatingSystem.Grep File    ${filetoccheck}    ${SERIAL}
    Run Keyword If    '${pdustatus}' == '${SERIAL}'    Remove File    ${filetoccheck}