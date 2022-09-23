*** Settings ***
Documentation     Anonymous
Metadata          Anonymous
Force Tags        ${slot_location}
Metadata          Location    ${slot_location}
Test Setup        Initialize_Test_case
Test Teardown     Final_Test_case
Suite Setup       Initialize_Test_Suite
Suite Teardown    Final_Test_Suite
Library           String
Library           OperatingSystem
Library           DateTime
Library           RequestsLibrary
Library           Collections
Library           Telnet
# Library           ASCII
Library           SSHLibrary    timeout=60 s    prompt=REGEXP:($\\s+\\Z)
# Library           ${CURDIR}${/}Library${/}
# Variables         ${CURDIR}${/}Config${/}EEPROM.py
# Variables         ${CURDIR}${/}Config${/}R3250B2F031916GD200037.py
# Variables         ${CURDIR}${/}ODC_Script${/}BOM${/}${serial_number}.py
# Variables         ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
# Variables         ${CURDIR}${/}Config${/}ConfigVariables.py   CONFIG    ${CURDIR}${/}Config${/}Test_Slot_Mapping.cfg
# Variables         ${CURDIR}${/}Config${/}ESS_Rev_01.yaml
# Resource          ${CURDIR}${/}Resources${/}Midstone_Keywords_Diag.robot
# Resource          ${CURDIR}${/}Resources${/}get_odc.robot
# Resource          ${CURDIR}${/}Resources${/}eBay${/}keywords.robot
Resource          ${CURDIR}${/}Resources${/}keywords.resource
# Resource          ${CURDIR}${/}Resources${/}variables.robot
# Resource          ${CURDIR}${/}Resources${/}pdu.robot
# Resource          ${CURDIR}${/}Resources${/}UserInteraction.robot
# Library           ${CURDIR}${/}Library${/}listener.py


***Variables

*** Test Cases ***
IFCONFIG_SERVER
    SSH Test Ifconfig