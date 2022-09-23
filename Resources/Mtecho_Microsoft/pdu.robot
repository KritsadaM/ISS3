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
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          off ${psu1_outlet}              APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_wti_1
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    WTI_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_wti_2
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    WTI_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Telnet_Set_APC_command                          ${psu2_outlet} off             >
    Telnet.Close Connection
    sleep   40

Power_Off_apc_2
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          off ${psu2_outlet}              APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu2_outlet} off             >
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
    # Save_to_logs       Telnet Open\r
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
    # TELNET_CLOSE
    Create File    /opt/Sync/Sync_Power.txt    Done
    log.debug  Logout to Power control Custom\n
    log.debug  ********************************\n

Power_Off_UUT_1
    [Documentation]   Power off UUT.
    log.debug    Power Off PSU : UUT.
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          off ${Power_Control}            APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu1_outlet} off             >
    Run Keyword If     '${WTI_port}' != 'none'    Telnet.Close Connection
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu2_outlet} off             >
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
    # SSHLibrary.Write    \r
    # sleep    1
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                                     wait_for=login:
                                                            ...                                     time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command     command=\r
                                               ...                                      wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    # Diag_SSH_Into_Telnet_Execute_Command    command=sudo su
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Retry_Set_IP
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    \nCan't SSH IP ${SSH_IP}\r
    # Run Keyword If     '${status}' == 'FAIL'    Can't SSH IP ${SSH_IP}
    # log.debug    Bios boot start: Done.

Power_Cyling_1
    Power_On_apc_1
    TELNET_OPEN     ${time_out}
    # SSHLibrary.Write    \r
    # sleep    1
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                                     wait_for=login:
                                                            ...                                     time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command     command=\r
                                               ...                                      wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    # Diag_SSH_Into_Telnet_Execute_Command    command=sudo su
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # # Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Retry_Set_IP
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    \nCan't SSH IP ${SSH_IP}\r
    # Run Keyword If     '${status}' == 'FAIL'    Can't SSH IP ${SSH_IP}

Power_Cyling_SSH
    Power_Off_UUT
    Power_On_UUT
    SSH_into_telnet
    # SSHLibrary.Write    \r
    # sleep    1
    ${out1}=    SSHLibrary.Read Until    command-line
    Save_to_logs        ${out1}\r
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A_SSH
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B_SSH
    # Telnet.Write Bare    [B
    sleep    2s
    SSH_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_SSH_Into_Telnet_Execute_Command    command=\r
                                                            ...                                     wait_for=login:
                                                            ...                                     time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    SSH_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_SSH_Into_Telnet_Execute_Command     command=\r
                                               ...                                      wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
    Diag_SSH_Into_Telnet_Execute_Command    command=${USERNAME}
    ...                                     wait_for=Password:
    Diag_SSH_Into_Telnet_Execute_Command    command=${PASSWORD}
    Diag_SSH_Into_Telnet_Execute_Command    command=sudo su
    Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    Diag_SSH_Into_Telnet_Execute_Command    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    SSH_CLOSE
    Run Keyword If     '${status}' == 'FAIL'    Retry_Set_IP
    ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    SSH_CLOSE
    Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    \nCan't SSH IP ${SSH_IP}\r
    Run Keyword If     '${status}' == 'FAIL'    Can't SSH IP ${SSH_IP}

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
    # SSHLibrary.Write Bare    [A
    # sleep    2s
    # SSHLibrary.Write    \r

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
    Telnet.Write Bare    [B
    Telnet.Read
    sleep    2s
    Telnet.Write Bare    \r
    Telnet.Read
    # ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    # Save_to_logs        ${out1}\r
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    # Run Keyword If    '${status}' == 'FAIL'    Select_OS_A

Command_Power_Cyling_1
    [Arguments]     ${Command}    ${time_out}=240s
    # Run Keyword And Ignore Error    Re_Login
    Diag_Telnet_Execute_Command    command=${Command}
    ...                            wait_for=IOS boot sta
    TELNET_OPEN     ${time_out}
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    # Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Retry_Set_IP
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    \nCan't SSH IP ${SSH_IP}\r
    # Run Keyword If     '${status}' == 'FAIL'    Can't SSH IP ${SSH_IP}

Command_Power_Cyling_2
    [Arguments]     ${Command}    ${time_out}=240s
    log.debug                           Reboot to boot from Backup BIOS.
    # Run Keyword And Ignore Error    Re_Login
    ${out1}=    Diag_Telnet_Execute_Command    command=${Command}
                ...                            wait_for=The highlighted entry will be executed automatically
    # ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    Warning:Boot from Backup BIOS!
    Run Keyword If    '${status}' == 'PASS'    log.debug                    Expect: Warning:Boot from Backup BIOS! -------> PASSED    
    Run Keyword If    '${status}' == 'FAIL'    log.debug                    Expect: Warning:Boot from Backup BIOS! -------> FAILED    
    Run Keyword If    '${status}' == 'FAIL'    FAIL    The unit Can't boot with Backup Bios!
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    TELNET_OPEN     ${time_out}
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
    Diag_Telnet_Execute_Command    command=${USERNAME}
    ...                            wait_for=Password:
    Diag_Telnet_Execute_Command_Password    command=${PASSWORD}
    # Diag_Telnet_Execute_Command_2    command=sudo su
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    Diag_Telnet_Execute_Command_2    command=ping ${SSH_IP} -c5
    ...                              expect_string=5 received
    Diag_Telnet_Execute_Command_2    command=kill -9 `ps -ef | grep 'onlpd' | grep -v grep | awk '{print $2}'`
    Diag_Telnet_Execute_Command_2    command=ps -ef | grep onlpd
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Retry_Set_IP
    # ${status}   ${output}=  Run Keyword And Ignore Error    SSH_to_Telnet           30
    # SSH_CLOSE
    # Run Keyword If     '${status}' == 'FAIL'    Save_to_logs    \nCan't SSH IP ${SSH_IP}\r
    # Run Keyword If     '${status}' == 'FAIL'    Can't SSH IP ${SSH_IP}

Retry_Set_IP
    [Arguments]
    Re_Login
    Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    
Reset_button_switch
    TELNET_OPEN     ${time_out}
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
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
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
    sleep    2s
    TELNET_CLOSE
    ${status}   ${output}=  Run Keyword And Ignore Error    Diag_Telnet_Execute_Command    command=\r
                                                            ...                            wait_for=login:
                                                            ...                            time_out=300
    Run Keyword If    '${status}' == 'FAIL'    Run Keyword And Ignore Error    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    Diag_Telnet_Execute_Command    command=\r
                                               ...                            wait_for=login:
    # Should Contain    ${output}    2133MHz
    # Should Contain    ${output}    8GB
    # Should Contain    ${output}    CPLD_COMe version : 0.7
    # Should Contain    ${output}    CPLD_BaseBoard version : 1.6
    # Should Contain    ${output}    05/21/2021
    # Should Contain    ${output}    BWDCOMe100
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
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    TELNET_CLOSE
    sleep    1s
    # Telnet.Write Bare    [B
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
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    Diag OS
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    TELNET_CLOSE
    # TELNET_OPEN     20s
    # ${status}   ${output}=  Run Keyword And Ignore Error   Read_real_raw_log    Press any key to continue
    # TELNET_CLOSE
    Run Keyword If    '${status}' == 'PASS'    UUT_Boot_Into_Diag
    [Return]   ${status}

UUT_Boot_Into_Diag
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

UUT_Boot_Into_ONIE
    TELNET_OPEN     ${time_out}
    sleep    1s
    # Telnet.Write Bare    [B
    sleep    2s
    Telnet.Write    \r
    sleep    3s  
    Telnet.Write    \r
    sleep    60s  
    Telnet.Write    \r
    ${out1}=    Read_real_raw_log    ONIE:/ #
    TELNET_CLOSE
    sleep    60s
    Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #
    Diag_Telnet_Execute_Command_2    command=ifconfig eth0 ${SSH_IP} up
    ...                              wait_for=ONIE:/ #

Reboot_Install_ONIE
    [Arguments]    ${time_out}=400s
    TELNET_OPEN     ${time_out}
    ${out1}=    Telnet.Write    onie-nos-install ${ONL_file_name}
    Save_to_logs        ${out1}\r
    ${out1}=    Read_real_raw_log    ONIE: Rebooting...
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    Run Keyword If    '${status}' == 'FAIL'    Select_OS_A
    Run Keyword If    '${status}' == 'PASS'    Select_OS_B
    # Telnet.Write Bare    [B
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
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically

Uninstall_Select_OS_A
    sleep    1s
    Telnet.Write    \r
    
Power_Cyling_Uninstall_ONIE
    [Arguments]    ${time_out}=400s
    Power_Off_UUT
    Power_On_UUT
    TELNET_OPEN     ${time_out}
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    # Run Keyword If    '${status}' == 'PASS'    Uninstall_Select_OS_B
    # sleep    1s
    # # Telnet.Write Bare    [B
    # sleep    2s
    # Telnet.Write    \r
    sleep    1s
    Telnet.Write Bare    [B
    sleep    1s
    # Telnet.Write Bare    [B
    sleep    3s  
    Telnet.Write    \r
    # sleep    30s  
    ${out1}=    Read_real_raw_log    Please press Enter to activate this console.
    sleep    1s  
    TELNET_CLOSE
    Diag_Telnet_Execute_Command    command=\r
    ...                            wait_for=ONIE:/ #
    ...                            time_out=300
    Diag_Telnet_Execute_Command    command=ifconfig eth0 ${SSH_IP} up
    ...                            wait_for=ONIE:/ #
    ...                            time_out=300
    Diag_Telnet_Execute_Command    command=ifconfig eth0
    ...                            wait_for=ONIE:/ #
    ...                            time_out=300
    ...                            expect_string=${SSH_IP}
    START_SSH_server
    SSHLibrary.Write    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r /tftpboot/CLS_DIAG_OS_remove_script.sh root@${SSH_IP}:/
    ${getfile_remove_onie}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${getfile_remove_onie}
    Should Contain    ${getfile_remove_onie}    100%
    # ${RTC_GET}=    Set Variable    ${output}
    SSH_CLOSE
    # TELNET_OPEN     ${time_out}
    # ${output}=      Telnet.Write Bare    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/CLS_DIAG_OS_remove_script.sh /\r
    # Save_to_logs       ${output}\r
    # ${output}=      Read_real_raw_log    (y/n)
    # Telnet.Write Bare    y\r
    # ${output}=      Read_real_raw_log    password:
    # Telnet.Write Bare    em4dmin\r
    # ${output}=      Read_real_raw_log    ONIE:/ #
    # Save_to_logs       ${output}\r
    # Should Contain    ${output}    100%
    # TELNET_CLOSE
    # TELNET_Send_Command_expect_prompt    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r emadmin@192.168.1.230:/tftpboot/CLS_DIAG_OS_remove_script.sh /    (y/n)
    # TELNET_Send_Command_expect_prompt    y      password:
    # Diag_Telnet_Execute_Command          command=em4dmin    
    # ...                                  wait_for=ONIE:/ #
    # ...                                  expect_string=100%
    Diag_Telnet_Execute_Command          command=chmod +x CLS_DIAG_OS_remove_script.sh    
    ...                                  wait_for=ONIE:/ #
    TELNET_OPEN     ${time_out}
    ${output}=      Telnet.Write Bare    ./CLS_DIAG_OS_remove_script.sh\r
    Save_to_logs       ${output}\r
    ${output}=      Read_real_raw_log    (Y/N):
    Telnet.Write Bare    Y\r
    ${output}=      Read_real_raw_log    ONIE:/ #
    ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${output}    Uninstall process complete rebooting
    Run Keyword If    '${status}' == 'FAIL'    FAIL      *** Uninstall ONL is not Completed ***
    Run Keyword If    '${status}' == 'PASS'    log.debug     *** Uninstall ONL is Completed ***
    # Diag_Telnet_Execute_Command          command=./CLS_DIAG_OS_remove_script.sh
    # ...                                  wait_for=(Y/N):
    # Diag_Telnet_Execute_Command          command=Y
    # ...                                  wait_for=ONIE:/ #
    # TELNET_CLOSE
    # TELNET_OPEN     ${time_out}
    ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Contain    ${out1}    ONIE: Uninstall OS
    # Run Keyword If    '${status}' == 'PASS'    Uninstall_Select_OS_B
    # sleep    1s
    # # Telnet.Write Bare    [B
    # sleep    2s
    # Telnet.Write    \r
    sleep    1s
    Telnet.Write Bare    [B
    sleep    1s
    # Telnet.Write Bare    [B
    sleep    3s  
    Telnet.Write    \r
    # sleep    30s  
    ${out1}=    Read_real_raw_log    Please press Enter to activate this console.
    sleep    1s  
    TELNET_CLOSE

    # Telnet.Write    \r
    # ${out1}=    Read_real_raw_log    ONIE:/ #
    # Save_to_logs        ${out1}\r
    # ${out1}=    Telnet.Write    onie-uninstaller diag
    # Save_to_logs        ${out1}\r
    # ${out1}=    Read_real_raw_log    Erase complete.
    # Save_to_logs        ${out1}\r
    # ${out1}=    Read_real_raw_log    Uninstall complete.
    # Save_to_logs        ${out1}\r
    # ${out1}=    Read_real_raw_log    The highlighted entry will be executed automatically
    # ${status}   ${output}=  Run Keyword And Ignore Error    Should Not Contain    ${out1}    SONiC
    # Run Keyword If    '${status}' == 'FAIL'    Save_to_logs        ${out1}\r 
    # Run Keyword If    '${status}' == 'FAIL'    FAIL     Uninstall not complete.
    # TELNET_CLOSE
    # sleep    60s
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # ...                              wait_for=ONIE:/ #
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # ...                              wait_for=ONIE:/ #
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # ...                              wait_for=ONIE:/ #
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # ...                              wait_for=ONIE:/ #
    # Diag_Telnet_Execute_Command_2    command=ifconfig ma1 ${SSH_IP} up
    # ...                              wait_for=ONIE:/ #

Power_On_apc_1
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          on ${psu1_outlet}              APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu1_outlet} on             >
    Telnet.Close Connection
    sleep   5

Power_On_apc_2
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          on ${psu2_outlet}              APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu2_outlet} on             >
    Telnet.Close Connection
    sleep   5

Power_On_UUT_1
    [Documentation]   Power on UUT.
    log.debug    Power On PSU : UUT.
    Run Keyword If     '${WTI_port}' == 'none'    APC_TELNET_CONN_OPEN
    # Telnet_Set_APC_command                          \r                              APC>
    Run Keyword If     '${WTI_port}' == 'none'    Telnet_Set_APC_command                          on ${Power_Control}              APC>
    Run Keyword If     '${WTI_port}' == 'none'    log.debug                                       Sending command: "exit"
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Write                                    exit
    Run Keyword If     '${WTI_port}' == 'none'    Telnet.Read
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu1_outlet} on             >
    Run Keyword If     '${WTI_port}' != 'none'    Telnet.Close Connection
    Run Keyword If     '${WTI_port}' != 'none'    WTI_TELNET_CONN_OPEN
    Run Keyword If     '${WTI_port}' != 'none'    Telnet_Set_APC_command                          ${psu2_outlet} on             >
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