*** Keywords ***
GET_BOM_ODC_DC
    [Arguments] 
    Run    /usr/bin/pkill -HUP -f "^telnet .*${Port_Telnet}"
    START_SSH_server
    SSHLibrary.Write    rm -rf /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    Test ODC\n
    # ${BOM}    Remove String    ${BOM}    <br>
    ${BOM}    Remove String    ${BOM}    ${SPACE}
    ${SN}    Remove String    ${SN}    <br>
    ${SN}    Remove String    ${SN}    ${SPACE}
    ${PN}    Remove String    ${PN}    <br>
    ${PN}    Remove String    ${PN}    ${SPACE}
    ${PRODUCT}    Remove String    ${PRODUCT}    <br>
    ${PRODUCT}    Remove String    ${PRODUCT}    ${SPACE}
    ${MAC}    Remove String    ${MAC}    <br>
    ${MAC}    Remove String    ${MAC}    ${SPACE}
    ${HE_VERSION}    Remove String    ${HE_VERSION}    <br>
    ${HE_VERSION}    Remove String    ${HE_VERSION}    ${SPACE}
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    <br>
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    ${SPACE}
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    <br>
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    ${SPACE}
    ${REV}    Remove String    ${REV}    <br>
    ${REV}    Remove String    ${REV}    ${SPACE}
    ${BOM}=      Split String    ${BOM}    <br>
    FOR     ${i}    IN RANGE    19
        # Save_to_logs        ${i}.${BOM}[${i}]\n
        Run    echo "${BOM}[${i}]" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    END
    ${output}=    OperatingSystem.Get File    /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    ${LBL_ASSET_ID}      Get Lines Containing String     ${output}     LBL_ASSET_ID,
    ${LBL_ASSET_ID}      Split String    ${LBL_ASSET_ID}    ,
    # ${PCA_I2C}      Get Lines Containing String     ${output}     PCA_I2C,
    # ${PCA_I2C}      Split String    ${PCA_I2C}    ,
    ${PCA_RISER}      Get Lines Containing String     ${output}     PCA_RISER,
    ${PCA_RISER}      Split String    ${PCA_RISER}    ,
    ${ASSY_RISER}      Get Lines Containing String     ${output}     ASSY_RISER,
    ${ASSY_RISER}      Split String    ${ASSY_RISER}    ,
    ${PCA_FAN}      Get Lines Containing String     ${output}     PCA_FAN,
    ${PCA_FAN}      Split String    ${PCA_FAN}    ,
    ${PCA_I2C_FPGA}      Get Lines Containing String     ${output}     PCA_I2C_FPGA,
    ${PCA_I2C_FPGA}      Split String    ${PCA_I2C_FPGA}    ,
    ${PCA_RISER}      Get Lines Containing String     ${output}     PCA_RISER,
    ${PCA_RISER}      Split String    ${PCA_RISER}    ,
    ${PCA_MB}      Get Lines Containing String     ${output}     PCA_MB,
    ${PCA_MB}      Split String    ${PCA_MB}    ,
    ${PCA_BB}      Get Lines Containing String     ${output}     PCA_BB,
    ${PCA_BB}      Split String    ${PCA_BB}    ,
    ${CPU}      Get Lines Containing String     ${output}     CPU,
    ${CPU}      Split String    ${CPU}    ,
    ${FAN1}      Get Lines Containing String     ${output}     FAN1,
    ${FAN1}      Split String    ${FAN1}    ,
    ${FAN2}      Get Lines Containing String     ${output}     FAN2,
    ${FAN2}      Split String    ${FAN2}    ,
    ${FAN3}      Get Lines Containing String     ${output}     FAN3,
    ${FAN3}      Split String    ${FAN3}    ,
    ${FAN4}      Get Lines Containing String     ${output}     FAN4,
    ${FAN4}      Split String    ${FAN4}    ,
    ${FAN5}      Get Lines Containing String     ${output}     FAN5,
    ${FAN5}      Split String    ${FAN5}    ,
    ${FAN6}      Get Lines Containing String     ${output}     FAN6,
    ${FAN6}      Split String    ${FAN6}    ,
    ${ticket_number_ODC}    Set Variable    ${ticket_number}
    ${SN_ODC}    Set Variable    ${SN}
    ${PN_ODC}    Set Variable    ${PN}
    ${AMAZON_MODEL_NUMBER_ODC}  Set Variable    ${AMAZON_MODEL_NUMBER}
    ${HE_VERSION_ODC}  Set Variable    ${HE_VERSION}
    ${PRODUCT_ODC}    Set Variable    ${PRODUCT}
    ${MAC_ODC}    Set Variable    ${MAC}
    ${DEVICE_VERSION_ODC}    Set Variable    ${DEVICE_VERSION}
    ${REV_ODC}    Set Variable    ${REV}
    ${PCA_MB_ODC}    Set Variable    ${PCA_MB}[1]
    ${LBL_ASSET_ID_ODC}    Set Variable    ${LBL_ASSET_ID}[1]
    ${CPU_SN_ODC}      Set Variable    ${CPU}[1]
    ${CPU_MODEL_ODC}      Set Variable    ${CPU}[4]
    ${CPU_MODEL_ODC}      Get Substring    0    4
    ${FAN1_SN_ODC}      Set Variable    ${FAN1}[1]
    ${FAN2_SN_ODC}      Set Variable    ${FAN2}[1]
    ${FAN3_SN_ODC}      Set Variable    ${FAN3}[1]
    ${FAN4_SN_ODC}      Set Variable    ${FAN4}[1]
    ${FAN5_SN_ODC}      Set Variable    ${FAN5}[1]
    ${FAN6_SN_ODC}      Set Variable    ${FAN6}[1]
    ${FAN_PN_ODC}      Set Variable    ${FAN1}[2]
    ${FAN_Vendor_ODC}      Set Variable    ${FAN1}[3]
    # ${PCA_I2C_SN_ODC}      Set Variable       ${PCA_I2C}[1]
    # ${PCA_I2C_PN_ODC}      Set Variable       ${PCA_I2C}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    ${ASSY_RISER_SN_ODC}      Set Variable       ${ASSY_RISER}[1]
    ${ASSY_RISER_PN_ODC}      Set Variable       ${ASSY_RISER}[2]
    ${PCA_FAN_SN_ODC}      Set Variable       ${PCA_FAN}[1]
    ${PCA_FAN_PN_ODC}      Set Variable       ${PCA_FAN}[2]
    ${PCA_I2C_FPGA_SN_ODC}      Set Variable       ${PCA_I2C_FPGA}[1]
    ${PCA_I2C_FPGA_PN_ODC}      Set Variable       ${PCA_I2C_FPGA}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    ${PCA_BB_SN_ODC}      Set Variable       ${PCA_BB}[1]
    ${PCA_BB_PN_ODC}      Set Variable       ${PCA_BB}[2]
    SSHLibrary.Write    rm /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Set Global Variable     ${ticket_number_ODC}
    Set Global Variable     ${SN_ODC}
    Set Global Variable     ${PRODUCT_ODC}
    Set Global Variable     ${MAC_ODC}
    Set Global Variable     ${HE_VERSION_ODC}
    Set Global Variable     ${AMAZON_MODEL_NUMBER_ODC}
    Set Global Variable     ${DEVICE_VERSION_ODC}
    Set Global Variable     ${REV_ODC}
    Set Global Variable     ${PN_ODC}
    Set Global Variable     ${PCA_MB_ODC}
    Set Global Variable     ${LBL_ASSET_ID_ODC}
    Set Global Variable     ${CPU_SN_ODC}
    Set Global Variable     ${CPU_MODEL_ODC}
    Set Global Variable     ${FAN1_SN_ODC}
    Set Global Variable     ${FAN2_SN_ODC}
    Set Global Variable     ${FAN3_SN_ODC}
    Set Global Variable     ${FAN4_SN_ODC}
    Set Global Variable     ${FAN5_SN_ODC}
    Set Global Variable     ${FAN6_SN_ODC}
    Set Global Variable     ${FAN_PN_ODC}
    Set Global Variable     ${FAN_Vendor_ODC}
    # Set Global Variable     ${PCA_I2C_SN_ODC}
    # Set Global Variable     ${PCA_I2C_PN_ODC}
    Set Global Variable     ${PCA_RISER_SN_ODC}
    Set Global Variable     ${PCA_RISER_PN_ODC}
    Set Global Variable     ${ASSY_RISER_SN_ODC}
    Set Global Variable     ${ASSY_RISER_PN_ODC}
    Set Global Variable     ${PCA_FAN_SN_ODC}
    Set Global Variable     ${PCA_FAN_PN_ODC}
    Set Global Variable     ${PCA_I2C_FPGA_SN_ODC}
    Set Global Variable     ${PCA_I2C_FPGA_PN_ODC}
    Set Global Variable     ${PCA_BB_SN_ODC}
    Set Global Variable     ${PCA_BB_PN_ODC}
    Run    echo "ticket_number = '${ticket_number_ODC}'" > /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Serial = '${SN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Part_Number = '${PN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Product = '${PRODUCT}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Mac_Address = '${MAC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "HW_Revision = '${HE_VERSION_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Model_Number = '${AMAZON_MODEL_NUMBER_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Device_Version = '${DEVICE_VERSION}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Revision = '${REV}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_BB = '${PCA_BB}[1], ${PCA_BB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Run    echo "PCA_I2C = '${PCA_I2C}[1], ${PCA_I2C}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_I2C_FPGA = '${PCA_I2C_FPGA}[1], ${PCA_I2C_FPGA}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    \n\n\n\n\n\n${SN}\n${PN}\n${PRODUCT}\n${MAC}\n${DEVICE_VERSION}\n${REV}\n
    Run    echo "${MAC}" > /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Run    echo "${slot_location}" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    # Save_to_logs    ${FAN1}\n
    Save_to_logs    ticket_number = '${ticket_number_ODC}'\n
    Save_to_logs    Serial = '${SN}'\n
    Save_to_logs    Part Number = '${PN}'\n
    Save_to_logs    Product = '${PRODUCT}'\n
    Save_to_logs    Mac Address = '${MAC}'\n
    Save_to_logs    HW Revision = '${HE_VERSION_ODC}'\n
    Save_to_logs    Model Number = '${AMAZON_MODEL_NUMBER_ODC}'\n
    Save_to_logs    Device Version = '${DEVICE_VERSION}'\n
    Save_to_logs    Revision = '${REV}'\n
    Save_to_logs    FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'\n
    Save_to_logs    FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'\n
    Save_to_logs    FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'\n
    Save_to_logs    FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'\n
    Save_to_logs    FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'\n
    Save_to_logs    FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'\n
    Save_to_logs    PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'\n
    Save_to_logs    PCA_BB = '${PCA_BB}[1], ${PCA_BB}[2]'\n
    Save_to_logs    LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'\n
    # Save_to_logs    PCA_I2C = '${PCA_I2C}[1], ${PCA_I2C}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'\n
    Save_to_logs    PCA_I2C_FPGA = '${PCA_I2C_FPGA}[1], ${PCA_I2C_FPGA}[2]'\n
    Save_to_logs    CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'\n
    SSHLibrary.Write    chmod 777 /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    SSH_CLOSE

GET_BOM_ODC_AC
    [Arguments] 
    Run    /usr/bin/pkill -HUP -f "^telnet .*${Port_Telnet}"
    START_SSH_server
    SSHLibrary.Write    rm -rf /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    Test ODC\n
    # ${BOM}    Remove String    ${BOM}    <br>
    ${BOM}    Remove String    ${BOM}    ${SPACE}
    ${SN}    Remove String    ${SN}    <br>
    ${SN}    Remove String    ${SN}    ${SPACE}
    ${PN}    Remove String    ${PN}    <br>
    ${PN}    Remove String    ${PN}    ${SPACE}
    ${PRODUCT}    Remove String    ${PRODUCT}    <br>
    ${PRODUCT}    Remove String    ${PRODUCT}    ${SPACE}
    ${MAC}    Remove String    ${MAC}    <br>
    ${MAC}    Remove String    ${MAC}    ${SPACE}
    ${HE_VERSION}    Remove String    ${HE_VERSION}    <br>
    ${HE_VERSION}    Remove String    ${HE_VERSION}    ${SPACE}
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    <br>
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    ${SPACE}
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    <br>
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    ${SPACE}
    ${REV}    Remove String    ${REV}    <br>
    ${REV}    Remove String    ${REV}    ${SPACE}
    ${BOM}=      Split String    ${BOM}    <br>
    FOR     ${i}    IN RANGE    22
        # Save_to_logs        ${i}.${BOM}[${i}]\n
        Run    echo "${BOM}[${i}]" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    END
    ${output}=    OperatingSystem.Get File    /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    ${LBL_ASSET_ID}      Get Lines Containing String     ${output}     LBL_ASSET_ID,
    ${LBL_ASSET_ID}      Split String    ${LBL_ASSET_ID}    ,
    ${ASSY_MB}      Get Lines Containing String     ${output}     ASSY_MB,
    ${ASSY_MB}      Split String    ${ASSY_MB}    ,
    ${PCA_RISER}      Get Lines Containing String     ${output}     PCA_RISER,
    ${PCA_RISER}      Split String    ${PCA_RISER}    ,
    ${ASSY_RISER}      Get Lines Containing String     ${output}     ASSY_RISER,
    ${ASSY_RISER}      Split String    ${ASSY_RISER}    ,
    ${PCA_FAN}      Get Lines Containing String     ${output}     PCA_FAN,
    ${PCA_FAN}      Split String    ${PCA_FAN}    ,
    ${PCA_I2C_FPGA}      Get Lines Containing String     ${output}     PCA_I2C_FPGA,
    ${PCA_I2C_FPGA}      Split String    ${PCA_I2C_FPGA}    ,
    ${PCA_RISER}      Get Lines Containing String     ${output}     PCA_RISER,
    ${PCA_RISER}      Split String    ${PCA_RISER}    ,
    ${PCA_MB}      Get Lines Containing String     ${output}     PCA_MB,
    ${PCA_MB}      Split String    ${PCA_MB}    ,
    ${CPU}      Get Lines Containing String     ${output}     CPU,
    ${CPU}      Split String    ${CPU}    ,
    ${PSU1}      Get Lines Containing String     ${output}     PSU1,
    ${PSU1}      Split String    ${PSU1}    ,
    ${PSU2}      Get Lines Containing String     ${output}     PSU2,
    ${PSU2}      Split String    ${PSU2}    ,
    ${FAN1}      Get Lines Containing String     ${output}     FAN1,
    ${FAN1}      Split String    ${FAN1}    ,
    ${FAN2}      Get Lines Containing String     ${output}     FAN2,
    ${FAN2}      Split String    ${FAN2}    ,
    ${FAN3}      Get Lines Containing String     ${output}     FAN3,
    ${FAN3}      Split String    ${FAN3}    ,
    ${FAN4}      Get Lines Containing String     ${output}     FAN4,
    ${FAN4}      Split String    ${FAN4}    ,
    ${FAN5}      Get Lines Containing String     ${output}     FAN5,
    ${FAN5}      Split String    ${FAN5}    ,
    ${FAN6}      Get Lines Containing String     ${output}     FAN6,
    ${FAN6}      Split String    ${FAN6}    ,
    ${FAN7}      Get Lines Containing String     ${output}     FAN7,
    ${FAN7}      Split String    ${FAN7}    ,
    ${ticket_number_ODC}    Set Variable    ${ticket_number}
    ${SN_ODC}    Set Variable    ${SN}
    ${PN_ODC}    Set Variable    ${PN}
    ${AMAZON_MODEL_NUMBER_ODC}  Set Variable    ${AMAZON_MODEL_NUMBER}
    ${HE_VERSION_ODC}  Set Variable    ${HE_VERSION}
    ${PRODUCT_ODC}    Set Variable    ${PRODUCT}
    ${MAC_ODC}    Set Variable    ${MAC}
    ${DEVICE_VERSION_ODC}    Set Variable    ${DEVICE_VERSION}
    ${REV_ODC}    Set Variable    ${REV}
    ${PCA_MB_ODC}    Set Variable    ${PCA_MB}[1]
    ${LBL_ASSET_ID_ODC}    Set Variable    ${LBL_ASSET_ID}[1]
    ${CPU_SN_ODC}      Set Variable    ${CPU}[1]
    ${CPU_MODEL_ODC}      Set Variable    ${CPU}[4]
    ${CPU_MODEL_ODC}      Get Substring    0    4
    ${PSU1_SN_ODC}      Set Variable    ${PSU1}[1]
    ${PSU2_SN_ODC}      Set Variable    ${PSU2}[1]
    ${FAN1_SN_ODC}      Set Variable    ${FAN1}[1]
    ${FAN2_SN_ODC}      Set Variable    ${FAN2}[1]
    ${FAN3_SN_ODC}      Set Variable    ${FAN3}[1]
    ${FAN4_SN_ODC}      Set Variable    ${FAN4}[1]
    ${FAN5_SN_ODC}      Set Variable    ${FAN5}[1]
    ${FAN6_SN_ODC}      Set Variable    ${FAN6}[1]
    ${FAN7_SN_ODC}      Set Variable    ${FAN7}[1]
    ${FAN_PN_ODC}      Set Variable    ${FAN1}[2]
    ${FAN_Vendor_ODC}      Set Variable    ${FAN1}[3]
    ${ASSY_MB_SN_ODC}      Set Variable       ${ASSY_MB}[1]
    ${ASSY_MB_PN_ODC}      Set Variable       ${ASSY_MB}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    ${ASSY_RISER_SN_ODC}      Set Variable       ${ASSY_RISER}[1]
    ${ASSY_RISER_PN_ODC}      Set Variable       ${ASSY_RISER}[2]
    ${PCA_FAN_SN_ODC}      Set Variable       ${PCA_FAN}[1]
    ${PCA_FAN_PN_ODC}      Set Variable       ${PCA_FAN}[2]
    ${PCA_I2C_FPGA_SN_ODC}      Set Variable       ${PCA_I2C_FPGA}[1]
    ${PCA_I2C_FPGA_PN_ODC}      Set Variable       ${PCA_I2C_FPGA}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    SSHLibrary.Write    rm /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Set Global Variable     ${ticket_number_ODC}
    Set Global Variable     ${SN_ODC}
    Set Global Variable     ${PRODUCT_ODC}
    Set Global Variable     ${MAC_ODC}
    Set Global Variable     ${HE_VERSION_ODC}
    Set Global Variable     ${AMAZON_MODEL_NUMBER_ODC}
    Set Global Variable     ${DEVICE_VERSION_ODC}
    Set Global Variable     ${REV_ODC}
    Set Global Variable     ${PN_ODC}
    Set Global Variable     ${PCA_MB_ODC}
    Set Global Variable     ${LBL_ASSET_ID_ODC}
    Set Global Variable     ${CPU_SN_ODC}
    Set Global Variable     ${CPU_MODEL_ODC}
    Set Global Variable     ${PSU1_SN_ODC}
    Set Global Variable     ${PSU2_SN_ODC}
    Set Global Variable     ${FAN1_SN_ODC}
    Set Global Variable     ${FAN2_SN_ODC}
    Set Global Variable     ${FAN3_SN_ODC}
    Set Global Variable     ${FAN4_SN_ODC}
    Set Global Variable     ${FAN5_SN_ODC}
    Set Global Variable     ${FAN6_SN_ODC}
    Set Global Variable     ${FAN7_SN_ODC}
    Set Global Variable     ${FAN_PN_ODC}
    Set Global Variable     ${FAN_Vendor_ODC}
    Set Global Variable     ${ASSY_MB_SN_ODC}
    Set Global Variable     ${ASSY_MB_PN_ODC}
    Set Global Variable     ${PCA_RISER_SN_ODC}
    Set Global Variable     ${PCA_RISER_PN_ODC}
    Set Global Variable     ${ASSY_RISER_SN_ODC}
    Set Global Variable     ${ASSY_RISER_PN_ODC}
    Set Global Variable     ${PCA_FAN_SN_ODC}
    Set Global Variable     ${PCA_FAN_PN_ODC}
    Set Global Variable     ${PCA_I2C_FPGA_SN_ODC}
    Set Global Variable     ${PCA_I2C_FPGA_PN_ODC}
    Run    echo "ticket_number = '${ticket_number_ODC}'" > /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Serial = '${SN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Part_Number = '${PN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Product = '${PRODUCT}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Mac_Address = '${MAC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "HW_Revision = '${HE_VERSION_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Model_Number = '${AMAZON_MODEL_NUMBER_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Device_Version = '${DEVICE_VERSION}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Revision = '${REV}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN7 = '${FAN7}[1], ${FAN7}[2], ${FAN7}[3], ${FAN7}[4], ${FAN7}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "ASSY_MB = '${ASSY_MB}[1], ${ASSY_MB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_I2C_FPGA = '${PCA_I2C_FPGA}[1], ${PCA_I2C_FPGA}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PSU1 = '${PSU1}[1], ${PSU1}[2], ${PSU1}[3], ${PSU1}[4], ${PSU1}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PSU2 = '${PSU2}[1], ${PSU2}[2], ${PSU2}[3], ${PSU2}[4], ${PSU2}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    \n\n\n\n\n\n${SN}\n${PN}\n${PRODUCT}\n${MAC}\n${DEVICE_VERSION}\n${REV}\n
    Run    echo "${MAC}" > /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Run    echo "${slot_location}" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    # Save_to_logs    ${FAN1}\n
    Save_to_logs    ticket_number = '${ticket_number_ODC}'\n
    Save_to_logs    Serial = '${SN}'\n
    Save_to_logs    Part Number = '${PN}'\n
    Save_to_logs    Product = '${PRODUCT}'\n
    Save_to_logs    Mac Address = '${MAC}'\n
    Save_to_logs    HW Revision = '${HE_VERSION_ODC}'\n
    Save_to_logs    Model Number = '${AMAZON_MODEL_NUMBER_ODC}'\n
    Save_to_logs    Device Version = '${DEVICE_VERSION}'\n
    Save_to_logs    Revision = '${REV}'\n
    Save_to_logs    FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'\n
    Save_to_logs    FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'\n
    Save_to_logs    FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'\n
    Save_to_logs    FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'\n
    Save_to_logs    FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'\n
    Save_to_logs    FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'\n
    Save_to_logs    FAN7 = '${FAN7}[1], ${FAN7}[2], ${FAN7}[3], ${FAN7}[4], ${FAN7}[5]'\n
    Save_to_logs    PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'\n
    Save_to_logs    LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'\n
    Save_to_logs    ASSY_MB = '${ASSY_MB}[1], ${ASSY_MB}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'\n
    Save_to_logs    PCA_I2C_FPGA = '${PCA_I2C_FPGA}[1], ${PCA_I2C_FPGA}[2]'\n
    Save_to_logs    CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'\n
    Save_to_logs    PSU1 = '${PSU1}[1], ${PSU1}[2], ${PSU1}[3], ${PSU1}[4], ${PSU1}[5]'\n
    Save_to_logs    PSU2 = '${PSU2}[1], ${PSU2}[2], ${PSU2}[3], ${PSU2}[4], ${PSU2}[5]'\n
    SSHLibrary.Write    chmod 777 /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    SSH_CLOSE

GET_BOM_ODC_SKU3
    [Arguments] 
    Run    /usr/bin/pkill -HUP -f "^telnet .*${Port_Telnet}"
    START_SSH_server
    SSHLibrary.Write    rm -rf /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    Test ODC\n
    # ${BOM}    Remove String    ${BOM}    <br>
    ${BOM}    Remove String    ${BOM}    ${SPACE}
    ${SN}    Remove String    ${SN}    <br>
    ${SN}    Remove String    ${SN}    ${SPACE}
    ${PN}    Remove String    ${PN}    <br>
    ${PN}    Remove String    ${PN}    ${SPACE}
    ${PRODUCT}    Remove String    ${PRODUCT}    <br>
    ${PRODUCT}    Remove String    ${PRODUCT}    ${SPACE}
    ${MAC}    Remove String    ${MAC}    <br>
    ${MAC}    Remove String    ${MAC}    ${SPACE}
    ${HE_VERSION}    Remove String    ${HE_VERSION}    <br>
    ${HE_VERSION}    Remove String    ${HE_VERSION}    ${SPACE}
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    <br>
    ${AMAZON_MODEL_NUMBER}    Remove String    ${AMAZON_MODEL_NUMBER}    ${SPACE}
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    <br>
    ${DEVICE_VERSION}    Remove String    ${DEVICE_VERSION}    ${SPACE}
    ${REV}    Remove String    ${REV}    <br>
    ${REV}    Remove String    ${REV}    ${SPACE}
    ${BOM}=      Split String    ${BOM}    <br>
    FOR     ${i}    IN RANGE    21
        # Save_to_logs        ${i}.${BOM}[${i}]\n
        Run    echo "${BOM}[${i}]" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    END
    ${output}=    OperatingSystem.Get File    /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    ${LBL_ASSET_ID}      Get Lines Containing String     ${output}     LBL_ASSET_ID,
    ${LBL_ASSET_ID}      Split String    ${LBL_ASSET_ID}    ,
    # ${PCA_I2C}      Get Lines Containing String     ${output}     PCA_I2C,
    # ${PCA_I2C}      Split String    ${PCA_I2C}    ,
    ${PCA_RISER}      Get Lines Containing String     ${output}     PCA_RISER,
    ${PCA_RISER}      Split String    ${PCA_RISER}    ,
    ${ASSY_RISER}      Get Lines Containing String     ${output}     ASSY_RISER,
    ${ASSY_RISER}      Split String    ${ASSY_RISER}    ,
    ${PCA_FAN}      Get Lines Containing String     ${output}     PCA_FAN,
    ${PCA_FAN}      Split String    ${PCA_FAN}    ,
    ${PCA_SFP}      Get Lines Containing String     ${output}     PCA_SFP,
    ${PCA_SFP}      Split String    ${PCA_SFP}    ,
    ${ASSY_1PPS}      Get Lines Containing String     ${output}     ASSY_1PPS,
    ${ASSY_1PPS}      Split String    ${ASSY_1PPS}    ,
    ${PCA_1PPS}      Get Lines Containing String     ${output}     PCA_1PPS,
    ${PCA_1PPS}      Split String    ${PCA_1PPS}    ,
    ${PCA_MB}      Get Lines Containing String     ${output}     PCA_MB,
    ${PCA_MB}      Split String    ${PCA_MB}    ,
    ${PCA_BB}      Get Lines Containing String     ${output}     PCA_BB,
    ${PCA_BB}      Split String    ${PCA_BB}    ,
    ${CPU}      Get Lines Containing String     ${output}     CPU,
    ${CPU}      Split String    ${CPU}    ,
    ${FAN1}      Get Lines Containing String     ${output}     FAN1,
    ${FAN1}      Split String    ${FAN1}    ,
    ${FAN2}      Get Lines Containing String     ${output}     FAN2,
    ${FAN2}      Split String    ${FAN2}    ,
    ${FAN3}      Get Lines Containing String     ${output}     FAN3,
    ${FAN3}      Split String    ${FAN3}    ,
    ${FAN4}      Get Lines Containing String     ${output}     FAN4,
    ${FAN4}      Split String    ${FAN4}    ,
    ${FAN5}      Get Lines Containing String     ${output}     FAN5,
    ${FAN5}      Split String    ${FAN5}    ,
    ${FAN6}      Get Lines Containing String     ${output}     FAN6,
    ${FAN6}      Split String    ${FAN6}    ,
    ${ticket_number_ODC}    Set Variable    ${ticket_number}
    ${SN_ODC}    Set Variable    ${SN}
    ${PN_ODC}    Set Variable    ${PN}
    ${AMAZON_MODEL_NUMBER_ODC}  Set Variable    ${AMAZON_MODEL_NUMBER}
    ${HE_VERSION_ODC}  Set Variable    ${HE_VERSION}
    ${PRODUCT_ODC}    Set Variable    ${PRODUCT}
    ${MAC_ODC}    Set Variable    ${MAC}
    ${DEVICE_VERSION_ODC}    Set Variable    ${DEVICE_VERSION}
    ${REV_ODC}    Set Variable    ${REV}
    ${PCA_MB_ODC}    Set Variable    ${PCA_MB}[1]
    ${LBL_ASSET_ID_ODC}    Set Variable    ${LBL_ASSET_ID}[1]
    ${CPU_SN_ODC}      Set Variable    ${CPU}[1]
    ${CPU_MODEL_ODC}      Set Variable    ${CPU}[4]
    ${CPU_MODEL_ODC}      Get Substring    0    4
    ${FAN1_SN_ODC}      Set Variable    ${FAN1}[1]
    ${FAN2_SN_ODC}      Set Variable    ${FAN2}[1]
    ${FAN3_SN_ODC}      Set Variable    ${FAN3}[1]
    ${FAN4_SN_ODC}      Set Variable    ${FAN4}[1]
    ${FAN5_SN_ODC}      Set Variable    ${FAN5}[1]
    ${FAN6_SN_ODC}      Set Variable    ${FAN6}[1]
    ${FAN_PN_ODC}      Set Variable    ${FAN1}[2]
    ${FAN_Vendor_ODC}      Set Variable    ${FAN1}[3]
    # ${PCA_I2C_SN_ODC}      Set Variable       ${PCA_I2C}[1]
    # ${PCA_I2C_PN_ODC}      Set Variable       ${PCA_I2C}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    ${ASSY_RISER_SN_ODC}      Set Variable       ${ASSY_RISER}[1]
    ${ASSY_RISER_PN_ODC}      Set Variable       ${ASSY_RISER}[2]
    ${PCA_FAN_SN_ODC}      Set Variable       ${PCA_FAN}[1]
    ${PCA_FAN_PN_ODC}      Set Variable       ${PCA_FAN}[2]
    ${PCA_SFP_SN_ODC}      Set Variable       ${PCA_SFP}[1]
    ${PCA_SFP_PN_ODC}      Set Variable       ${PCA_SFP}[2]
    ${ASSY_1PPS_SN_ODC}      Set Variable       ${ASSY_1PPS}[1]
    ${ASSY_1PPS_PN_ODC}      Set Variable       ${ASSY_1PPS}[2]
    ${PCA_1PPS_SN_ODC}      Set Variable       ${PCA_1PPS}[1]
    ${PCA_1PPS_PN_ODC}      Set Variable       ${PCA_1PPS}[2]
    ${PCA_RISER_SN_ODC}      Set Variable       ${PCA_RISER}[1]
    ${PCA_RISER_PN_ODC}      Set Variable       ${PCA_RISER}[2]
    ${PCA_BB_SN_ODC}      Set Variable       ${PCA_BB}[1]
    ${PCA_BB_PN_ODC}      Set Variable       ${PCA_BB}[2]
    SSHLibrary.Write    rm /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Set Global Variable     ${ticket_number_ODC}
    Set Global Variable     ${SN_ODC}
    Set Global Variable     ${PRODUCT_ODC}
    Set Global Variable     ${MAC_ODC}
    Set Global Variable     ${HE_VERSION_ODC}
    Set Global Variable     ${AMAZON_MODEL_NUMBER_ODC}
    Set Global Variable     ${DEVICE_VERSION_ODC}
    Set Global Variable     ${REV_ODC}
    Set Global Variable     ${PN_ODC}
    Set Global Variable     ${PCA_MB_ODC}
    Set Global Variable     ${LBL_ASSET_ID_ODC}
    Set Global Variable     ${CPU_SN_ODC}
    Set Global Variable     ${CPU_MODEL_ODC}
    Set Global Variable     ${FAN1_SN_ODC}
    Set Global Variable     ${FAN2_SN_ODC}
    Set Global Variable     ${FAN3_SN_ODC}
    Set Global Variable     ${FAN4_SN_ODC}
    Set Global Variable     ${FAN5_SN_ODC}
    Set Global Variable     ${FAN6_SN_ODC}
    Set Global Variable     ${FAN_PN_ODC}
    Set Global Variable     ${FAN_Vendor_ODC}
    # Set Global Variable     ${PCA_I2C_SN_ODC}
    # Set Global Variable     ${PCA_I2C_PN_ODC}
    Set Global Variable     ${PCA_RISER_SN_ODC}
    Set Global Variable     ${PCA_RISER_PN_ODC}
    Set Global Variable     ${ASSY_RISER_SN_ODC}
    Set Global Variable     ${ASSY_RISER_PN_ODC}
    Set Global Variable     ${PCA_FAN_SN_ODC}
    Set Global Variable     ${PCA_FAN_PN_ODC}
    Set Global Variable     ${PCA_SFP_SN_ODC}
    Set Global Variable     ${PCA_SFP_PN_ODC}
    Set Global Variable     ${ASSY_1PPS_SN_ODC}
    Set Global Variable     ${ASSY_1PPS_PN_ODC}
    Set Global Variable     ${PCA_1PPS_SN_ODC}
    Set Global Variable     ${PCA_1PPS_PN_ODC}
    Set Global Variable     ${PCA_BB_SN_ODC}
    Set Global Variable     ${PCA_BB_PN_ODC}
    Run    echo "ticket_number = '${ticket_number_ODC}'" > /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Serial = '${SN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Part_Number = '${PN}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Product = '${PRODUCT}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Mac_Address = '${MAC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "HW_Revision = '${HE_VERSION_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Model_Number = '${AMAZON_MODEL_NUMBER_ODC}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Device_Version = '${DEVICE_VERSION}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "Revision = '${REV}'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_BB = '${PCA_BB}[1], ${PCA_BB}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Run    echo "PCA_I2C = '${PCA_I2C}[1], ${PCA_I2C}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_SFP = '${PCA_SFP}[1], ${PCA_SFP}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "ASSY_1PPS = '${ASSY_1PPS}[1], ${ASSY_1PPS}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "PCA_1PPS = '${PCA_1PPS}[1], ${PCA_1PPS}[2]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    Run    echo "CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'" >> /opt/Robot/ODC_Script/BOM/${serial_number}.py
    # Save_to_logs    \n\n\n\n\n\n${SN}\n${PN}\n${PRODUCT}\n${MAC}\n${DEVICE_VERSION}\n${REV}\n
    Run    echo "${MAC}" > /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    Run    echo "${slot_location}" >> /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    # Save_to_logs    ${FAN1}\n
    Save_to_logs    ticket_number = '${ticket_number_ODC}'\n
    Save_to_logs    Serial = '${SN}'\n
    Save_to_logs    Part Number = '${PN}'\n
    Save_to_logs    Product = '${PRODUCT}'\n
    Save_to_logs    Mac Address = '${MAC}'\n
    Save_to_logs    HW Revision = '${HE_VERSION_ODC}'\n
    Save_to_logs    Model Number = '${AMAZON_MODEL_NUMBER_ODC}'\n
    Save_to_logs    Device Version = '${DEVICE_VERSION}'\n
    Save_to_logs    Revision = '${REV}'\n
    Save_to_logs    FAN1 = '${FAN1}[1], ${FAN1}[2], ${FAN1}[3], ${FAN1}[4], ${FAN1}[5]'\n
    Save_to_logs    FAN2 = '${FAN2}[1], ${FAN2}[2], ${FAN2}[3], ${FAN2}[4], ${FAN2}[5]'\n
    Save_to_logs    FAN3 = '${FAN3}[1], ${FAN3}[2], ${FAN3}[3], ${FAN3}[4], ${FAN3}[5]'\n
    Save_to_logs    FAN4 = '${FAN4}[1], ${FAN4}[2], ${FAN4}[3], ${FAN4}[4], ${FAN4}[5]'\n
    Save_to_logs    FAN5 = '${FAN5}[1], ${FAN5}[2], ${FAN5}[3], ${FAN5}[4], ${FAN5}[5]'\n
    Save_to_logs    FAN6 = '${FAN6}[1], ${FAN6}[2], ${FAN6}[3], ${FAN6}[4], ${FAN6}[5]'\n
    Save_to_logs    PCA_MB = '${PCA_MB}[1], ${PCA_MB}[2]'\n
    Save_to_logs    PCA_BB = '${PCA_BB}[1], ${PCA_BB}[2]'\n
    Save_to_logs    LBL_ASSET_ID = '${LBL_ASSET_ID}[1], ${LBL_ASSET_ID}[2], ${LBL_ASSET_ID}[3], ${LBL_ASSET_ID}[4], ${LBL_ASSET_ID}[5]'\n
    # Save_to_logs    PCA_I2C = '${PCA_I2C}[1], ${PCA_I2C}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    ASSY_RISER = '${ASSY_RISER}[1], ${ASSY_RISER}[2]'\n
    Save_to_logs    PCA_RISER = '${PCA_RISER}[1], ${PCA_RISER}[2]'\n
    Save_to_logs    PCA_FAN = '${PCA_FAN}[1], ${PCA_FAN}[2]'\n
    Save_to_logs    PCA_SFP = '${PCA_SFP}[1], ${PCA_SFP}[2]'\n
    Save_to_logs    ASSY_1PPS = '${ASSY_1PPS}[1], ${ASSY_1PPS}[2]'\n
    Save_to_logs    PCA_1PPS = '${PCA_1PPS}[1], ${PCA_1PPS}[2]'\n
    Save_to_logs    CPU = '${CPU}[1], ${CPU}[2], ${CPU}[3], ${CPU}[4], ${CPU}[5]'\n
    SSHLibrary.Write    chmod 777 /opt/Robot/ODC_Script/BOM/${serial_number}.txt
    SSH_CLOSE

Get_Parameter
    START_SSH_Try    ${time_out}
    ${output}    SSHLibrary.Write    ls
    Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    \$
    Save_to_log  ${output}
    ${output}    SSHLibrary.Write    sudo su
    Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    emadmin:
    Save_to_log  ${output}
    SSHLibrary.Write Bare    em4dmin\r\n
    # Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    \#
    Save_to_log  ${output}
    ${output}    SSHLibrary.Write    chmod 777 /opt/Scan_in/* -R
    Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    \#
    Save_to_log  ${output}
    ${output}    SSHLibrary.Write    cat ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    Save_to_log  ${output}
    ${output1}=    SSHLibrary.Read Until    \#
    Save_to_log  ${output1}    
    ${ticket_number}     Get Line      ${output1}    0
    ${ticket_number}    Split String    ${ticket_number}    "
    # Save_to_log    ${ticket_number}[0]-------${ticket_number}[1]--------${ticket_number}[2]
    ${output}    SSHLibrary.Write    rm ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    \#
    Save_to_log  ${output}        
    ${output}    SSHLibrary.Write    mv /opt/Scan_in/${serial_number}.properties ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    Save_to_log  ${output}
    ${output}=    SSHLibrary.Read Until    \#
    # Save_to_log  ${output}    
    # ${output}    SSHLibrary.Write    cat /opt/Scan_in/R3250B2F031916GD200037.properties
    # Save_to_log  ${output}
    # ${output}=    SSHLibrary.Read Until    \#
    Save_to_log  ${output}    
    Run    echo "${ticket_number}[0]\\"${ticket_number}[1]\\"" >> ${CURDIR}${/}../ODC_Script${/}BOM${/}${serial_number}.py
    # ${output}    SSHLibrary.Write    cat /opt/Robot_Debug/ODC_Script/BOM/R3250B2F031916GD200037.py
    # Save_to_log  ${output}
    # ${output1}=    SSHLibrary.Read Until    \#
    # Save_to_log  ${output1}   
    # ${Parameter}    Remove String    ${output1}   "
    # Save_to_log         ${Parameter}\n
    # FOR     ${i}    IN RANGE    0   44
    #     ${ticket_number}     Get Line      ${Parameter}    ${i}
    #     ${ticket_number}    Split String    ${ticket_number} 
    #     ${Parameter1}      Set Variable       ${ticket_number}[0] 
    #     Set Global Variable    ${Parameter1}    ${ticket_number}[2]
    # END
    # Save_to_log    ${MAC}${MAC}${MAC}${MAC}${MAC}\n${MAC}${MAC}${MAC}${MAC}\n
    SSH_CLOSE
