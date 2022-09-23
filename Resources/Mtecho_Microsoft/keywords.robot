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
    Telnet.Close Connection
    sleep    0.5s

Telnet_dmesg
    [Arguments]
    ${console}=    Telnet_Set_command    dmesg    DiagOS:~
    Save_to_logs    ${console}\n

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
    Save_to_logs       ${SPACE}${output}
    ${output}    Read_real_raw_log    ${wait_for}
    TELNET_CLOSE
    [Return]   ${output}

TELNET_Send_Command_expect_prompt
    [Arguments]    ${command}    ${wait_for}
    Telnet.Open Connection    ${TelnetIP}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    log.debug      Telnet Sending command "${command}"
    ${output}=    Telnet.Write    ${command}
    Save_to_logs       ${SPACE}${output}
    ${output}    Read_real_raw_log    ${wait_for}
    TELNET_CLOSE
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
    ${output}    Read_real_raw_log    ${wait_for}
    TELNET_CLOSE
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

Read_real_raw_log
    [Arguments]     ${wait_for}
    ${String_Check}     Create List     
    FOR     ${i}    IN RANGE    999999
        ${status}   ${output}=  Run Keyword And Ignore Error   Telnet.Read Until Regexp    \n\r|\r\n|\n|\r|${wait_for}
        Save_to_logs   ${output}
        Append To List    ${String_Check}     ${output}
        Exit For Loop If	'${status}' == 'FAIL'
        ${status}   ${output}=  Run Keyword And Ignore Error   Should Contain    ${output}    ${wait_for}
        Exit For Loop If	'${status}' == 'PASS'
    END
    ${String_Check}    Convert To String   ${String_Check}
    ${String_Check}    Remove String Using Regexp    ${String_Check}    \\['|'\\]|\\["|"\\]
    ${output}    Replace String Using Regexp   ${String_Check}    ', '|", "|", '|', "    \n
    Run Keyword If    '${status}' == 'FAIL'    FAIL    TELNET_CLOSE
    Run Keyword If    '${status}' == 'FAIL'    FAIL    Did not find expected propmt "${wait_for}"
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
    Telnet.Open Connection    ${TelnetIP}    port=${TG_Port_400G}
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
    ${output}=    Diag_Telnet_Execute_Command_12      command=./bin/cel-rtc-test -r
    ${RTC_READ}=    Get Line    ${output}    2
    ${RTC_READ}=    Split String     ${RTC_READ}     
    ${RTC_READ}=    Set Variable    ${RTC_READ}[4] ${RTC_READ}[5]
    ${eval_time}=   Subtract Date From Date   ${RTC_READ}   ${RTC_GET_Compare}
    ${test_time}=   Convert To Integer  ${eval_time}
    ${rtc_test_result}=  Evaluate       100>${test_time}>-100
    Run Keyword If    '${rtc_test_result}' == 'False'  Fail    100>${test_time}>-100
    log.debug    RTC time compare with Host server time is ${test_time}, test limit is [100 second]\r

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

START_SSH
    [Arguments]    ${timeout}
    SSHLibrary.Open Connection  ${SSH_IP}    timeout=${timeout}   
    SSHLibrary.Set Client Configuration	prompt=#
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     ${USERNAME}    ${PASSWORD}   #  allow_agent=True
    Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     ${USERNAME}    ${PASSWORD}
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \#

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
        50ms

Count_Sync_File
    [Arguments]
    ${Sync_count}=    Count Files In Directory    /opt/Sync/Sync_unit/
    ${Sync_count_unit}=    Count Files In Directory    /opt/Sync/Sync_unit_count/
    Set Global Variable     ${Sync_count}
    Set Global Variable     ${Sync_count_unit}

#============================= Setting keyword ====================#

Initialize_Test_Suite
    [Arguments]
    Set Global Variable    ${Genfail_Test}    0
    Set Global Variable    ${Fan_fail}    0
    Set Global Variable    ${SDK_PKT_Staus}    0
    Set Global Variable    ${Ber_Staus}    0
    Set Global Variable    ${Install_ONL}    0

Final_Test_Suite
    Set Global Variable    ${Genfail_Test1}    0
    Run Keyword If    '${Install_ONL}' == '1'    Create File    /opt/Sync/Sync_Install.txt    Done

Initialize_Test_case
    [Documentation]    Initialize of all Test case.

    [Arguments]         ${set_abort}=unlock

    Set Suite Variable    ${dash}    \-
    Run Keyword If    "${TEST NAME}" == "ONL_Install"    Set Global Variable    ${Install_ONL}    1
    ${flag} =  CHECK_ABORT
    ${Time_start}=    Get Current Date    result_format=%H:%M:%S
    Set Global Variable    ${Time_start}
    Run Keyword If    "${flag}" == "abort"    Fail    Skipping Testcase because the User aborted.
    SET_UNSENSITIVE_FLAG
    Run Keyword If    "${Genfail_Test}" == "0"    SET_UNSENSITIVE_FLAG
    Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=${dash * 109}\n
    Save_to_log    msg=SERIAL NUMBER : ${serial_number}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=START TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n\n

Initialize_Test_case_BI
    [Documentation]    Initialize of all Test case.

    [Arguments]         ${set_abort}=unlock

    Set Suite Variable    ${dash}    \-

    ${flag} =  CHECK_ABORT
    Run Keyword If    '${slot_location}' == 'chamber17'    Check_Status_Chamber
    Run Keyword If    "${flag}" == "abort"    Fail    Skipping Testcase because the User aborted.
    SET_UNSENSITIVE_FLAG

    Run Keyword If    "${PREV TEST STATUS}" == "FAIL"    Fail    Skipping Testcase because the status of the previous test case is FAILED.

    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=${dash * 109}\n
    Save_to_log    msg=SERIAL NUMBER : ${serial_number}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=START TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n\n
Final_Test_case
    [Documentation]   End process of all Test case.
    [Arguments]
    Run Keyword If    "${TEST NAME}" == "5.1.9.MODIFY_CPU_MAC_ADDRESS_TEST_testcase"    Set_Status_Install_ONL
    Set Suite Variable    ${dash}    \-
    ${date_time1}=    Get Current Date    result_format=%Y%m%d%H%M%S
    ${STATUS}    Set Variable    ${TEST STATUS}
    ${Time_stop}=    Get Current Date    result_format=%H:%M:%S
    Set Global Variable    ${Time_stop}
    ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Save_to_log    msg=\n\n\n${dash * 109}\n
    Save_to_log    msg=TEST CASE STATUS : ${TEST STATUS}\n
    Save_to_log    msg=STEP TEST NAME : ${TEST NAME}\n
    Save_to_log    msg=END TIME : ${date_time}\n
    Save_to_log    msg=${dash * 109}\n

Set_Status_Install_ONL
    Run Keyword If    "${TEST STATUS}" == "PASS"    Set Global Variable    ${Install_ONL}    0

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

Save_to_logs
    [Documentation]     Save the message to the raw logs of test case.
    [Arguments]         ${msg}      ${verify}=False
    Append To File      ${Raw_logs_path}${/}${TEST NAME}.raw    ${msg}
    Append To File      ${Raw_logs_path}${/}${serial_number}.raw    ${msg}

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

Setup Config
    [Documentation]    Setup config before testing on next case

    Save_to_logs    Setup config is in progress now.
    Sleep           10 seconds
    Save_to_logs    Setup config is complete.
