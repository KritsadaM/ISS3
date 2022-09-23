*** Settings ***
Library         ${CURDIR}${/}..${/}Library${/}Custom_lib.py

*** Keywords ***
Initialize_Test_case
    Initial Test Case

Final_Test_case
    Finalize Test case

Initialize_Test_Suite
    [Arguments]
    Set Global Variable    ${Genfail_Test}    0
    Set Global Variable    ${Fan_fail}    0

Final_Test_Suite
    Set Global Variable    ${Genfail_Test1}    0

#==============================================================================================

SSH Test Ifconfig
    Ssh Open               hostname=localhost   username=miniphoton     password=Oboadmin
    # Ssh Open               hostname=localhost   username=miniphoton
    Ssh Cmd                command=ifconfig     prompt=:.+\$            expect=inet.+127.0.0.1, inet.+10.196.56.145, ether.+4c:cc:6a:ba:87:d2      unexpect=down       timeout=30
    # Ssh Cmd                command=ifconfig     prompt=:.+\$            expect=inet.+127.0.0.1      unexpect=fail       timeout=30
    # Ssh Cmd                command=ifconfig     prompt=:.+\$            expect=inet.+127.0.0.1      timeout=30
    # Ssh Cmd                command=ifconfig     prompt=:.+\$            expect=inet.+127.0.0.1          retry=3
    Ssh Cmd                command=df     prompt=:.+\$            expect=\/boot\/efi      unexpect=tmpfs       timeout=30   retry=3
    Ssh Close