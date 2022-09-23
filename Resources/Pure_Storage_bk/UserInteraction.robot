*** Keywords ***
MtEcho_prepare_fct
    log.debug               Interaction Initialize prepare unit.
    USER_INTERACTION        title=Inserted QSFP, DAC cable and USB. Remove Left PSU and Left AC power cable then Connect Right PSU and AC power cable (only).
    ...             question_msg=Inserted QSFP, DAC cable and USB. Remove Left PSU and Left AC power cable then Connect Right PSU and AC power cable (only).
    ...             image_name=MtEcho_prepare_fct.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator interaction QSFP, DAC cable and USB. Remove Left PSU and Left AC power cable then Connect Right PSU and AC power cable Pass.
    ...             fail_msg=Operator interaction QSFP, DAC cable and USB. Remove Left PSU and Left AC power cable then Connect Right PSU and AC power cable Fail.
    Sleep      1  

MtEcho_prepare_BI
    log.debug               Interaction Initialize prepare unit.
    USER_INTERACTION        title=Inserted QSFP, DAC cable port 0 and Plug serial cable and power cable.
    ...             question_msg=Inserted QSFP, DAC cable port 0 and Plug serial cable and power cable.
    ...             image_name=MtEcho_prepare_burnin.jpg      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator interaction QSFP, Inserted QSFP, DAC cable port 0 and Plug serial cable and power cable Pass.
    ...             fail_msg=Operator interaction QSFP, Inserted QSFP, DAC cable port 0 and Plug serial cable and power cable Fail.
    Sleep      1  

MtEcho_usb_plug
    log.debug               Interaction Plug USB.
    USER_INTERACTION        title=PLUG USB FLASH DRIVE.
    ...             question_msg=PLEASE PLUG USB FLASH DRIVE.
    ...             image_name=MtEcho_usb_plug.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator PLUG USB FLASH DRIVE Pass.
    ...             fail_msg=Operator PLUG USB FLASH DRIVE Fail.
    Sleep      1   
    log.debug    \n*************** USB has been pluged ***************\r
    
MtEcho_usb_remove
    log.debug               Interaction Unplug USB.
    USER_INTERACTION        title=REMOVE USB FLASH DRIVE.
    ...             question_msg=PLEASE REMOVE USB FLASH DRIVE.
    ...             image_name=MtEcho_usb_remove.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator REMOVE USB FLASH DRIVE Pass.
    ...             fail_msg=Operator REMOVE USB FLASH DRIVE Fail.
    Sleep      1   
    log.debug    \n*************** USB has been removed ***************\r

MtEcho_TGplug
    log.debug               Interaction Plug TG.
    USER_INTERACTION        title=Remove loopback port0 and plug TG DAC cable check all LED blue blink.
    ...             question_msg=Remove loopback port0 and plug TG DAC cable check all LED blue blink.
    ...             image_name=MtEcho_TGplug.GIF      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Remove loopback port0 and plug TG DAC cable check all LED blue blink Pass.
    ...             fail_msg=Operator Remove loopback port0 and plug TG DAC cable check all LED blue blink Fail.
    Sleep      1   

MtEcho_TGremove
    log.debug               Interaction Unplug TG.
    USER_INTERACTION        title=Remove TG DAC cable and plug loopback in port0.
    ...             question_msg=Remove TG DAC cable and plug loopback in port0.
    ...             image_name=MtEcho_TGremove.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Remove TG DAC cable and plug loopback in port0 Pass.
    ...             fail_msg=Operator Remove TG DAC cable and plug loopback in port0 Fail.
    Sleep      1   

MtEcho_traffic_retry
    log.debug               Interaction Confirm traffic failed.
    USER_INTERACTION        title=traffic fail please ask technician confirm.
    ...             question_msg=traffic fail please ask technician confirm.
    ...             image_name=MtEcho_traffic_retry.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator traffic fail please ask technician confirm Pass.
    ...             fail_msg=Operator traffic fail please ask technician confirm Fail.
    Sleep      1   

MtEcho_rpsu_on
    log.debug               Interaction RPSU LED check.
    USER_INTERACTION        title=Are all the steps shown on picture meets the expected criteria?
    ...             question_msg=Are all the steps shown on picture meets the expected criteria?
    ...             image_name=MtEcho_rpsu_on.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator the steps shown on picture meets the expected criteria Pass.
    ...             fail_msg=Operator the steps shown on picture meets the expected criteria Fail.
    Sleep      1   

MtEcho_lpsu_on
    log.debug               Interaction LPSU LED check
    USER_INTERACTION        title=Are all the steps shown on picture meets the expected criteria?
    ...             question_msg=Are all the steps shown on picture meets the expected criteria?
    ...             image_name=MtEcho_lpsu_on.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator the steps shown on picture meets the expected criteria Pass.
    ...             fail_msg=Operator the steps shown on picture meets the expected criteria Fail.
    Sleep      1   

MtEcho_port_blue
    log.debug               Interaction Blue LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t sff -D blue
    ...                                 expect_string=Passed
    USER_INTERACTION        title=PORT LED BLUE ?
    ...             question_msg=Are all PORT LED is BLUE ?
    ...             image_name=MtEcho_port_blue.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all PORT LED is BLUE Pass.
    ...             fail_msg=Operator all PORT LED is BLUE Fail.
    Sleep      1   

MtEcho_port_red
    log.debug               Interaction Red LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t sff -D red
    ...                                 expect_string=Passed
    USER_INTERACTION        title=PORT LED RED ?
    ...             question_msg=Are all PORT LED is RED ?
    ...             image_name=MtEcho_port_red.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all PORT LED is RED Pass.
    ...             fail_msg=Operator all PORT LED is RED Fail.
    Sleep      1   

MtEcho_port_off
    log.debug               Interaction Off LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t sff -D off
    ...                                 expect_string=Passed
    USER_INTERACTION        title=PORT LED OFF ?
    ...             question_msg=Are all PORT LED is OFF ?
    ...             image_name=MtEcho_port_off.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all PORT LED is OFF Pass.
    ...             fail_msg=Operator all PORT LED is OFF Fail.
    Sleep      1   

MtEcho_port_green
    log.debug               Interaction Green LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t sff -D green
    ...                                 expect_string=Passed
    USER_INTERACTION        title=PORT LED GREEN ?
    ...             question_msg=Are all PORT LED is GREEN ?
    ...             image_name=MtEcho_port_green.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all PORT LED is GREEN Pass.
    ...             fail_msg=Operator all PORT LED is GREEN Fail.
    Sleep      1   

MtEcho_front_led_alm_blink
    log.debug               Interaction Blink LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t led -d 1 -D 0xff
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 2 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 3 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 1 -D 0x03
    ...                                 expect_string=Passed
    USER_INTERACTION        title=Case1 CHECK STA-off, FAN-off, PWR-off, ALM-amber-fast-blink
    ...             question_msg=Case1 CHECK STA-off, FAN-off, PWR-off, ALM-amber-fast-blink
    ...             image_name=MtEcho_front_led_alm_blink.GIF      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Case1 CHECK STA-off, FAN-off, PWR-off, ALM-amber-fast-blink Pass.
    ...             fail_msg=Operator Case1 CHECK STA-off, FAN-off, PWR-off, ALM-amber-fast-blink Fail.
    Sleep      1   

MtEcho_front_led_all_green
    log.debug               Interaction Front green LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t led -d 1 -D 0xdc
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 2 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 3 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 1 -D 0x00
    ...                                 expect_string=Passed
    USER_INTERACTION        title=Case2 CHECK STA-green, FAN-green, PWR-green, ALM-green
    ...             question_msg=Case2 CHECK STA-green, FAN-green, PWR-green, ALM-green
    ...             image_name=MtEcho_front_led_all_green.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Case2 CHECK STA-green, FAN-green, PWR-green, ALM-green Pass.
    ...             fail_msg=Operator Case2 CHECK STA-green, FAN-green, PWR-green, ALM-green Fail.
    Sleep      1   

MtEcho_front_led_all_amber
    log.debug               Interaction Front amber LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t led -d 1 -D 0xec
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 2 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 3 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 1 -D 0x01
    ...                                 expect_string=Passed
    USER_INTERACTION        title=Case3 CHECK STA-amber, FAN-amber, PWR-amber, ALM-amber
    ...             question_msg=Case3 CHECK STA-amber, FAN-amber, PWR-amber, ALM-amber
    ...             image_name=MtEcho_front_led_all_amber.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Case3 CHECK STA-amber, FAN-amber, PWR-amber, ALM-amber Pass.
    ...             fail_msg=Operator Case3 CHECK STA-amber, FAN-amber, PWR-amber, ALM-amber Fail.
    Sleep      1   

MtEcho_front_led_alm_blink_sta_blink
    log.debug               Interaction Front blink LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-test -w -t led -d 1 -D 0xcd
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 2 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 3 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t led -d 1 -D 0x02
    ...                                 expect_string=Passed
    USER_INTERACTION        title=Case4 CHECK STA-green-amber-blink, FAN-off, PWR-off, ALM-amber-blink
    ...             question_msg=Case4 CHECK STA-green-amber-blink, FAN-off, PWR-off, ALM-amber-blink
    ...             image_name=MtEcho_front_led_alm_blink_sta_blink.GIF      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator Case4 CHECK STA-green-amber-blink, FAN-off, PWR-off, ALM-amber-blink Pass.
    ...             fail_msg=Operator Case4 CHECK STA-green-amber-blink, FAN-off, PWR-off, ALM-amber-blink Fail.
    Sleep      1   

MtEcho_fan_led_off
    log.debug               Interaction Fan off LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 1 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 2 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 3 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 4 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 5 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 6 -D 0x00
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 7 -D 0x00
    ...                                 expect_string=Passed
    USER_INTERACTION        title=FAN LED is OFF ?
    ...             question_msg=Are all FAN LED is OFF ?
    ...             image_name=MtEcho_fan_led_off.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all FAN LED is OFF Pass.
    ...             fail_msg=Operator all FAN LED is OFF Fail.
    Sleep      1   

MtEcho_fan_led_red
    log.debug               Interaction Fan red LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 1 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 2 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 3 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 4 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 5 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 6 -D 0x02
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 7 -D 0x02
    ...                                 expect_string=Passed
    USER_INTERACTION        title=FAN LED is RED ?
    ...             question_msg=Are all FAN LED is RED ?
    ...             image_name=MtEcho_fan_led_red.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all FAN LED is RED Pass.
    ...             fail_msg=Operator all FAN LED is RED Fail.
    Sleep      1   

MtEcho_fan_led_green
    log.debug               Interaction Fan green LED check.
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 1 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 2 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 3 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 4 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 5 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 6 -D 0x01
    ...                                 expect_string=Passed
    Diag_Telnet_Execute_Command_12            command=./bin/cel-led-ipmi-test -w -t fan_led -d 7 -D 0x01
    ...                                 expect_string=Passed
    USER_INTERACTION        title=FAN LED is GREEN ?
    ...             question_msg=Are all FAN LED is GREEN ?
    ...             image_name=MtEcho_fan_led_green.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator all FAN LED is GREEN Pass.
    ...             fail_msg=Operator all FAN LED is GREEN Fail.
    Sleep      1   

MtEcho_fan_hotswap_step1
    log.debug               Interaction Unplug fan 1 3 5 7.
    USER_INTERACTION        title=REMOVE FAN 1,3,5,7 !!
    ...             question_msg=PLEASE REMOVE FAN 1,3,5,7 !!
    ...             image_name=MtEcho_fan_hotswap_step1.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator REMOVE FAN 1,3,5,7 Pass.
    ...             fail_msg=Operator REMOVE FAN 1,3,5,7 Fail.
    Sleep      1   
    ${status}   ${output}=  Run Keyword And Ignore Error        Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Absent,Fan2_Status.+Present,Fan3_Status.+Absent,Fan4_Status.+Present,Fan5_Status.+Absent,Fan6_Status.+Present,Fan7_Status.+Absent
                                                                ...                                     wait_for=#
    Run Keyword If    '${status}' == 'FAIL'                     Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Absent,Fan2_Status.+Present,Fan3_Status.+Absent,Fan4_Status.+Present,Fan5_Status.+Absent,Fan6_Status.+Present,Fan7_Status.+Absent
                                                                ...                                     wait_for=#
MtEcho_fan_hotswap_step2
    log.debug               Interaction Plug fan 1 3 5 7 and unplug fan 2 4 6.
    USER_INTERACTION        title=PLUG FAN 1,3,5,7, WAIT FOR 5SECS AND REMOVE FAN 2,4,6 !!
    ...             question_msg=PLEASE PLUG FAN 1,3,5,7 AND REMOVE FAN 2,4,6 !!
    ...             image_name=MtEcho_fan_hotswap_step2.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator PLUG FAN 1,3,5,7 AND REMOVE FAN 2,4,6 Pass.
    ...             fail_msg=Operator PLUG FAN 1,3,5,7 AND REMOVE FAN 2,4,6 Fail.
    Sleep      1   
    ${status}   ${output}=  Run Keyword And Ignore Error        Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Present,Fan2_Status.+Absent,Fan3_Status.+Present,Fan4_Status.+Absent,Fan5_Status.+Present,Fan6_Status.+Absent,Fan7_Status.+Present
                                                                ...                                     wait_for=#
    Run Keyword If    '${status}' == 'FAIL'                     Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Present,Fan2_Status.+Absent,Fan3_Status.+Present,Fan4_Status.+Absent,Fan5_Status.+Present,Fan6_Status.+Absent,Fan7_Status.+Present
                                                                ...                                     wait_for=#

MtEcho_fan_hotswap_step3
    log.debug               Interaction Plug fan 2 4 6.
    USER_INTERACTION        title=PLUG FAN 2,4,6 !!
    ...             question_msg=PLEASE PLUG FAN 2,4,6 !!
    ...             image_name=MtEcho_fan_hotswap_step3.JPG      retry=12h      retry_interval=2s
    ...             html=user_interaction.html
    ...             pass_msg=Operator PLUG FAN 2,4,6 Pass.
    ...             fail_msg=Operator PLUG FAN 2,4,6 Fail.
    Sleep      1   
    ${status}   ${output}=  Run Keyword And Ignore Error        Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Present,Fan2_Status.+Present,Fan3_Status.+Present,Fan4_Status.+Present,Fan5_Status.+Present,Fan6_Status.+Present,Fan7_Status.+Present
                                                                ...                                     wait_for=#
    Run Keyword If    '${status}' == 'FAIL'                     Diag_Telnet_Execute_Command             command=ipmitest sdr elist | grep _Status
                                                                ...                                     parse_string=Fan1_Status.+Present,Fan2_Status.+Present,Fan3_Status.+Present,Fan4_Status.+Present,Fan5_Status.+Present,Fan6_Status.+Present,Fan7_Status.+Present
                                                                ...                                     wait_for=#

USER_INTERACTION
    [Documentation]    USER INTERACTION.

    [Arguments]     ${title}    ${question_msg}      ${image_name}      ${retry}      ${retry_interval}       ${html}
    ...             ${pass_msg}      ${fail_msg}

    CREATE_USER_INTERACTION     title=${title}    question_msg=${question_msg}      image_name=${image_name}      html=${html}
    Sleep      2

    ${answer}     ${reason} =     Wait Until Keyword Succeeds    ${retry}     ${retry_interval}        CHECK_USER_INTERACTION
    Run Keyword If    "${answer}" == "pass"    Set_Pass     ${pass_msg}
    ...    ELSE     Set_Fail_USER_INTERACTION     ${fail_msg}     ${reason}

CREATE_USER_INTERACTION
    [Documentation]    CREATE USER INTERACTION.

    [Arguments]     ${title}    ${question_msg}      ${image_name}       ${html}

    Create Session      create_url      http://localhost:${port_api}/api
    &{data}=  Create Dictionary         slot_location_no=${slot_location}        message=${question_msg}
    ...     timeout=100        picture=${image_name}        html=${html}        title=${title}
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Post Request        create_url        /user_interaction      data=${data}       headers=${header}
    Should Contain        ${resp.text}        interaction complete
    Delete All Sessions	

CHECK_USER_INTERACTION
    Create Session      create_session      http://localhost:${port_api}/api
    &{data}=  Create Dictionary       slot_location_no=${slot_location}
    &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
    ${resp}=  Get Request        create_session        /user_interaction     params=${data}    headers=${header}
    Delete All Sessions	
    Log to console       ${resp.text}
    Should Contain       ${resp.text}       "answer":

    ${match}	${answer} =
    ...	    Should Match Regexp	    ${resp.text}	    \\"answer\\"\\:\\s+\\"(\\S+)\\"

    ${match}	${reason} =
    ...	    Should Match Regexp	    ${resp.text}	    \\"reason\\"\\:\\s+\\"(.*)\\"

    [Return]    ${answer}     ${reason}


Set_Fail_USER_INTERACTION
    [Documentation]    SET FAIL USER INTERACTION.

    [Arguments]     ${fail_msg}     ${reason}

    Save_to_logs    FAILED:${SPACE * 2}${fail_msg} : ${reason}     verify=True
    Fail    ${fail_msg} : ${reason}

# USER_INTERACTION
#     [Documentation]    USER INTERACTION.

#     [Arguments]     ${title}    ${question_msg}      ${image_name}      ${retry}      ${retry_interval}
#     ...             ${pass_msg}      ${fail_msg}

#     CREATE_USER_INTERACTION     title=${title}    question_msg=${question_msg}      image_name=${image_name}      html=${html}
#     Sleep      2

#     ${answer}     ${reason} =     Wait Until Keyword Succeeds    ${retry}     ${retry_interval}        CHECK_USER_INTERACTION
#     Run Keyword If    "${answer}" == "pass"    Set_Pass     ${pass_msg}
#     ...    ELSE     Set_Fail_USER_INTERACTION     ${fail_msg}     ${reason}

# CREATE_USER_INTERACTION
#     [Documentation]    CREATE USER INTERACTION.

#     [Arguments]     ${title}    ${question_msg}      ${image_name}

#     Create Session      create_url      http://localhost:${port_api}/api
#     &{data}=  Create Dictionary         slot_location_no=${slot_location}        message=${question_msg}
#     ...     timeout=100        picture=${image_name}        html=${html}        title=${title}
#     &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
#     ${resp}=  Post Request        create_url        /user_interaction      data=${data}       headers=${header}
#     Should Contain        ${resp.text}        interaction complete
#     Delete All Sessions	

# CHECK_USER_INTERACTION
#     Create Session      create_session      http://localhost:${port_api}/api
#     &{data}=  Create Dictionary       slot_location_no=${slot_location}
#     &{header}=  Create Dictionary       Content-Type=application/json         Data-Type=application/json
#     ${resp}=  Get Request        create_session        /user_interaction     params=${data}    headers=${header}
#     Delete All Sessions	
#     Log to console       ${resp.text}
#     Should Contain       ${resp.text}       "answer":

#     ${match}	${answer} =
#     ...	    Should Match Regexp	    ${resp.text}	    \\"answer\\"\\:\\s+\\"(\\S+)\\"

#     ${match}	${reason} =
#     ...	    Should Match Regexp	    ${resp.text}	    \\"reason\\"\\:\\s+\\"(.*)\\"

#     [Return]    ${answer}     ${reason}

# Set_Fail_USER_INTERACTION
#     [Documentation]    SET FAIL USER INTERACTION.

#     [Arguments]     ${fail_msg}     ${reason}

#     Save_to_logs    FAILED:${SPACE * 2}${fail_msg} : ${reason}     verify=True
#     Fail    ${fail_msg} : ${reason}

 
# Save_to_logs
#     [Documentation]   Save the message to the raw logs of test case.

#     [Arguments]     ${msg}      ${verify}=False

#     Set Suite Variable    ${step_logs_path}    ${Raw_logs_path}${/}${TEST NAME}.txt
#     Set Suite Variable    ${all_logs_path}    ${Raw_logs_path}${/}${serial_number}_All_Logs.txt

#     Run Keyword If    ${verify}    Verify_logs      ${msg}
#     ...    ELSE    Raw_logs     ${msg}
 
