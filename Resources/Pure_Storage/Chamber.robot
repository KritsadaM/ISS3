*** Keywords ***
Chamber_Ambient_Control
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    ${console}=    Telnet.Write Bare    stop program\r\n
    # Save_to_logs    msg=${console}\n
#    ${console}=    Telnet.Read Until    ok
#    Save_to_logs    msg=${console}\n
    sleep    3s
    ${console}=    Telnet.Write Bare    select program 1\r\n
    # Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    ${console}=    Telnet.Write Bare    start program\r\n
    # Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    TELNET_CLOSE
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    26>${console}>24
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        TELNET_CLOSE
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END

    # Wait Until Keyword Succeeds    35 minutes   5 seconds        SYNC_POINT

Chamber_Cold_Control
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write Bare    stop program\r\n
    # ${console}=    Telnet.Read Until    ok
    # Save_to_logs    msg=${console}\n
    sleep    3s
    Telnet.Write Bare    select program 2\r\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    Telnet.Write Bare    start program\r\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    TELNET_CLOSE
    # ${Time_exit} =    Evaluate    ${Timeout}-1
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    2>${console}>-2
        # ${status}   ${std_out}=  Run Keyword And Ignore Error    Telnet.Read Until Regexp    25.[0-9]{2}0000|26.[0-9]{2}0000|24.[0-9]{2}0000
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END
    # Wait Until Keyword Succeeds    35 minutes   5 seconds        SYNC_POINT

Chamber_Hot_Control
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    sleep    10s
    ${console}=    Telnet.Write Bare    stop program\r\n  
    Save_to_logs    msg=${console}\n        
    # ${console}=    Telnet.Read Until    ok
    # Save_to_logs    msg=${console}\n
    sleep    10s
    Save_to_logs       stop program\r
    ${console}=    Telnet.Write Bare    select program 4\r\n
    Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    10s
    Save_to_logs       select program 4\r
    ${console}=    Telnet.Write Bare    start program\r\n
    Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    Save_to_logs       start program
    TELNET_CLOSE
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    46>${console}>44
        # ${status}   ${std_out}=  Run Keyword And Ignore Error    Telnet.Read Until Regexp    25.[0-9]{2}0000|26.[0-9]{2}0000|24.[0-9]{2}0000^M
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END

    # Wait Until Keyword Succeeds    45 minutes   5 seconds        SYNC_POINT

Chamber_Hot_to_Cold
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    Telnet.Write Bare    stop program\r\n
    # ${console}=    Telnet.Read Until    ok
    # Save_to_logs    msg=${console}\n
    sleep    3s
    Telnet.Write Bare    select program 5\r\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    Telnet.Write Bare    start program\r\n
    ${console}=    Telnet.Read Until    ok
    Save_to_logs    msg=${console}\n
    sleep    3s
    TELNET_CLOSE
    # ${Time_exit} =    Evaluate    ${Timeout}-1
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    2>${console}>-2
        # ${status}   ${std_out}=  Run Keyword And Ignore Error    Telnet.Read Until Regexp    25.[0-9]{2}0000|26.[0-9]{2}0000|24.[0-9]{2}0000
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END

Chamber_Hot_Control_Final
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    sleep    10s
    ${console}=    Telnet.Write Bare    stop program\r\n  
    # ${console}=    Telnet.Read Until    ok
    sleep    10s
    ${console}=    Telnet.Write Bare    select program 4\r\n
    ${console}=    Telnet.Read Until    ok
    sleep    10s
    ${console}=    Telnet.Write Bare    start program\r\n
    ${console}=    Telnet.Read Until    ok
    sleep    3s
    TELNET_CLOSE
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    46>${console}>44
        # ${status}   ${std_out}=  Run Keyword And Ignore Error    Telnet.Read Until Regexp    25.[0-9]{2}0000|26.[0-9]{2}0000|24.[0-9]{2}0000^M
        TELNET_CLOSE
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END

Chamber_Ambient_Control_Final
    [Arguments]
    Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r
    Telnet.Set Encoding    ISO-8859-1
    Telnet.Set Telnetlib Log Level    DEBUG
    Telnet.Set Timeout    ${timeout}
    ${console}=    Telnet.Write Bare    stop program\r\n
    # Save_to_logs    msg=${console}\n
#    ${console}=    Telnet.Read Until    ok
#    Save_to_logs    msg=${console}\n
    sleep    3s
    ${console}=    Telnet.Write Bare    select program 1\r\n
    # Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    sleep    3s
    ${console}=    Telnet.Write Bare    start program\r\n
    # Save_to_logs    msg=${console}\n
    ${console}=    Telnet.Read Until    ok
    sleep    3s
    TELNET_CLOSE
    FOR     ${i}    IN RANGE       60
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
    # Save_to_logs       Telnet Open\r^M
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        ${console}    Convert To Number     ${console}
        ${status}   Evaluate    26>${console}>24
        # ${status}   ${std_out}=  Run Keyword And Ignore Error    Telnet.Read Until Regexp    25.[0-9]{2}0000|26.[0-9]{2}0000|24.[0-9]{2}0000^M
        TELNET_CLOSE
        Exit For Loop If     '${status}' == 'True'
        Run Keyword If    '${i}' == '59'     FAIL
        Sleep     60s
    END

Read_Temp_Ambient
    [Arguments]
    FOR     ${i}    IN RANGE    250
        Count_Sync_File
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        ${Sync_count}   Convert To Number   ${Sync_count}
        ${Sync_count_unit}   Convert To Number   ${Sync_count_unit}
        ${Checksum}   Evaluate    ${Sync_count}+${Sync_count_unit}
        ${status}    Evaluate    ${Checksum}<1
        Run Keyword If     '${status}' == 'True'    FAIL
        Run Keyword If     '${i}' == '249'    FAIL
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Exit For Loop If    '${Sync_count}' == '${Sync_count_unit}'
        sleep    60s
    END

Read_Temp_Cold
    [Arguments]
    FOR     ${i}    IN RANGE    250
        Count_Sync_File
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        ${Sync_count}   Convert To Number   ${Sync_count}
        ${Sync_count_unit}   Convert To Number   ${Sync_count_unit}
        ${Checksum}   Evaluate    ${Sync_count}+${Sync_count_unit}
        ${status}    Evaluate    ${Checksum}<1
        Run Keyword If     '${status}' == 'True'    FAIL
        Run Keyword If     '${i}' == '249'    FAIL
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Exit For Loop If    '${Sync_count}' == '${Sync_count_unit}'
        sleep    60s
    END

Read_Temp_Hot
    [Arguments]
    FOR     ${i}    IN RANGE    250
        Count_Sync_File
        Telnet.Open Connection    ${IP_Server}    port=${Port_Telnet}
        Telnet.Set Encoding    ISO-8859-1
        Telnet.Set Telnetlib Log Level    DEBUG
        Telnet.Set Timeout    ${timeout}
        Telnet.Write Bare   read pv 3\r\n
        ${console}    Telnet.Read Until Regexp    [0-9]{2}.[0-9]{2}|[0-9].[0-9]{2}
        TELNET_CLOSE
        ${date_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
        Save_to_logs              Read Current Temp = ${console} ${SPACE*10} ${date_time}\n
        ${Sync_count}   Convert To Number   ${Sync_count}
        ${Sync_count_unit}   Convert To Number   ${Sync_count_unit}
        ${Checksum}   Evaluate    ${Sync_count}+${Sync_count_unit}
        ${status}    Evaluate    ${Checksum}<1
        Run Keyword If     '${status}' == 'True'    Last_Loop_Verify
        Run Keyword If     '${i}' == '249'    FAIL
        ${status}   ${std_out}=  Run Keyword And Ignore Error    Exit For Loop If    '${Sync_count}' == '${Sync_count_unit}'
        sleep    60s
    END

Last_Loop_Verify
    [Arguments]
    Run Keyword If     '${TEST NAME}' != '9.Chamber Hot Corner'    FAIL
    Run Keyword If     '${TEST NAME}' == '9.Chamber Hot Corner'    Save_to_logs    Passed\n