*** Keywords ***
TELNET_CLOSE
    Telnet.Close Connection

Telnet_dmesg
    [Arguments]
    ${console}=    Telnet_Set_command    dmesg    DiagOS:~
    Save_to_logs    ${console}\n

Telnet_Set_command
    [Arguments]     ${Comamnd}      ${Prompt}
    Telnet.Write    ${Comamnd}
    Telnet.Read Until    ${Prompt}
    ${output}=    Telnet.Read Until    ${Prompt}
    sleep    1s
    [Return]   ${output}

TELNET_Set_Prompt
    [Arguments]    ${wait_for}
    TELNET_OPEN    ${timeout}
    ${output}=    Telnet.Write    export PS1="${wait_for} "
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    TELNET_CLOSE

TELNET_Set_Path
    [Arguments]    ${path}    ${wait_for}
    TELNET_OPEN    ${timeout}
    ${output}=    Telnet.Write    cd ${path}
    ${status}   ${output}=  Run Keyword And Ignore Error    Telnet.Read Until    ${wait_for}
    TELNET_CLOSE

TELNET_Send_Command_expect_prompt_set_time
    [Arguments]    ${command}    ${wait_for}    ${time_out}
    TELNET_OPEN    ${timeout}
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
    TELNET_OPEN    ${timeout}
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
    TELNET_OPEN    ${timeout}
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
    TELNET_OPEN    ${timeout}
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
    TELNET_OPEN    ${timeout}
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
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}

TELNET_OPEN_TG
    [Arguments]    ${timeout}
    Telnet.Open Connection    ${TG_Telnet_IP}    port=${TG_telnet_Port}
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
    SSH_CLOSE

START_SSH_Get_UTC
    [Arguments] 
    START_SSH_server
    SSHLibrary.Write    date +'%m/%d/%Y %H:%M:%S'
    ${UTC_GET}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${UTC_GET}
    ${UTC_GET}=    Get Line    ${UTC_GET}    0
    Set Global Variable         ${UTC_GET}
    SSH_CLOSE

START_SSH_Get_Time_Stamp
    [Arguments] 
    START_SSH_server
    SSHLibrary.Write    date +'%Y-%m-%d %H:%M:00'
    ${Time_Stamp}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${Time_Stamp}
    ${Time_Stamp}=    Get Line    ${Time_Stamp}    0
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
    [Arguments]    ${USERNAME_SSH}    ${PASSWORD_SSH}
    SSHLibrary.Open Connection  ${ServerIP}    prompt=$    timeout=${timeout}   
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     ${USERNAME_SSH}    ${PASSWORD_SSH}    allow_agent=True
    SSHLibrary.Write Bare    \n   
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_logs     ${output}

START_SSH_unit
    [Arguments]    ${timeout}    ${USERNAME_SSH_unit}    ${PASSWORD_SSH_unit}
    SSHLibrary.Open Connection  ${SSH_IP}    timeout=${timeout}   
    SSHLibrary.Set Client Configuration	prompt=$
    ${status}    ${output}=    Run Keyword And Ignore Error    SSHLibrary.Login     admin    admin   #  allow_agent=True
    Run Keyword If    '${status}' == 'FAIL'    SSHLibrary.Login     ${USERNAME_SSH_unit}    ${PASSWORD_SSH_unit}
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
    SSHLibrary.Close Connection
    sleep    50ms

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

SYNC_POINT
    [Arguments]     ${timeout}
    Create Session      createcar       ${url}
    &{data}=  Create Dictionary    serial_number=${serial_number}     slot_location=${slot_location}      setup=False        timeout=${timeout}        batch_id=${batch_id}        allow_timeout=True
    &{header}=  Create Dictionary     Content-Type=application/json     Data-Type=application/json
    ${resp}=  Post Request      createcar       /sync_point     data=${data}       headers=${header}
    &{res_json}=    Evaluate    json.loads($resp.content)    json
    ${date_time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
    # Run keyword if    ${setup_config} == ${True} and &{res_json}[error] == ${False} and &{res_json}[data] == ${serial_number}    Setup Config
    Save_to_logs     ${date_time} - &{res_json}[data]${\n}
    Save_to_logs     ${date_time} - &{res_json}[error]${\n}
    Should Be Equal      &{res_json}[error]        ${None}
    # Wait Until Keyword Succeeds    2 minutes   2 seconds        SYNC_POINT    ${timeout}

# SYNC_POINT
#     Create Session      createcar       ${url}
#     &{data}=  Create Dictionary    serial_number=${serial_number}     slot_location=${slot_location}      setup=False        timeout=${time_out}        batch_id=${batch_id}        allow_timeout=True
#     log.debug      serial_number=${serial_number} ----- slot_location=${slot_location} ----- batch_id=${batch_id}\n
#     log.debug      url=${url}
#     log.debug      data=&{data}
#     &{header}=  Create Dictionary     Content-Type=application/json     Data-Type=application/json
#     log.debug      head=&{header}
#     ${resp}=  Post Request      createcar       /sync_point     data=${data}       headers=${header}
#     log.debug      resp=${resp}
#     &{res_json}=    Evaluate    json.loads($resp.content)    json
#     log.debug      json=&{res_json}
#     ${date_time}=    Get Current Date    result_format=%Y%m%d-%H%M%S
#     Save_to_logs     ${date_time} - &{res_json}[data]${\n}
#     Save_to_logs     ${date_time} - &{res_json}[error]${\n}
#     Should Be Equal      &{res_json}[error]        ${None}

Request_access_serial_port
    [Documentation]    Request to API for get permission on accessing serial port for using the Wti

    [Arguments]     ${queue_type}    ${hardware_name}
    Create Session      create_url      http://localhost:8080/api
    &{data}=  Create Dictionary         serial_number=${serial_number}        timeout=${time_out}          type=${queue_type}      hardware_name=${hardware_name}
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Post Request        create_url        /queue_hardware      data=${data}       headers=${header}
    &{resp_json}=    Evaluate     json.loads($resp.content)    json
    Save_to_logs    msg=${resp}\n
    Should Be Equal       &{resp_json}[error]      ${False}
    # Wait Until Keyword Succeeds    4 minutes   5 seconds        Request_access_serial_port    queue_type=request    hardware_name=sleep_try
    # sleep_try
    # Wait Until Keyword Succeeds    2 minutes   2 seconds        Request_access_serial_port    queue_type=release    hardware_name=sleep_try

sleep_try
    FOR     ${i}    IN RANGE    10
        log.debug      ${slot_location}\n
        sleep    1

    END

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

