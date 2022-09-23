*** Variables ***

${apc_ip}                   ${CONFIG.${slot_location}.apc_ip}
${psu1_outlet}              ${CONFIG.${slot_location}.psu1_outlet}
${psu2_outlet}              ${CONFIG.${slot_location}.psu2_outlet}
${SSH_IP}                   ${CONFIG.${slot_location}.SSH_IP}
${BMC_IP}                   ${CONFIG.${slot_location}.BMC_IP}
${BMC_IP_2}                 ${CONFIG.${slot_location}.BMC_IP_2}
${Port_Telnet}              ${CONFIG.${slot_location}.Port_Telnet}
${Power_Control}            ${CONFIG.${slot_location}.Power_Control}
${Silver_Power_Control}     ${CONFIG.${slot_location}.Silver_Power_Control}
${TelnetIP}                 ${CONFIG.${slot_location}.TelnetIP}
${WTI_port}                 ${CONFIG.${slot_location}.WTI_port}
${ServerIP}                 ${CONFIG.${slot_location}.ServerIP}
${local_host_ip}            ${CONFIG.${slot_location}.LOCAL_IP}
${TF_Port_100G}             ${CONFIG.${slot_location}.TF_Port_100G}
${TF_Port_400G}             ${CONFIG.${slot_location}.TF_Port_400G}
${TG_Port_100G}             ${CONFIG.${slot_location}.TG_Port_100G}
${TG_Port_400G}             ${CONFIG.${slot_location}.TG_Port_400G}
${sharp}                    \#
${time_out}                 150
${test_time}                10
${USERNAME}                 root
${PASSWORD}                 onl
${ROOT_PROMPT}              $
${USERNAME_server}          emadmin
${PASSWORD_server}          em4dmin
