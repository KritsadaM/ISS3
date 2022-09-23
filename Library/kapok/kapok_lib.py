import re
import sys
import time
from libs import lib
from robot.libraries.BuiltIn import BuiltIn


uut = lib.getconnections()['UUT']


def diag_bootup():
    uut.open()
    uut.send('telnet 192.168.1.248 3002\r', expectphrase='to STOP autoboot')
    uut.send('123\r', expectphrase='ALPINE_DB>')
    lib.PASS()


def diag_load_diag_os():
    uut.send('run diag_bootcmd\r', expectphrase='buildroot login:', timeout=60)
    uut.send('root\r', expectphrase='Password:')
    uut.send('root\r', expectphrase='#')
    uut.send('ifconfig 192.168.1.111 up\r', expectphrase='#')
    uut.send('export LD_LIBRARY_PATH=/root/diag/output\r', expectphrase='#')
    uut.send('export CEL_DIAG_PATH=/root/diag\r', expectphrase='#')
    uut.send('cd /root/diag\r', expectphrase='#')
    uut.send('ls\r', expectphrase='#')
    lib.PASS()


def diag_show_version():
    uut.send('uname -a\r', expectphrase='#')
    lib.PASS()


def diag_set_voltage_magin_high():
    uut.send('cd /root/diag\r', expectphrase='#')
    uut.send('./cel-dcdc-test --all\r', expectphrase='#')
    uut.send('/root/SDK_A/pwrmgn_ctl high && sleep 15\r', expectphrase='#')
    uut.send('./cel-dcdc-test --all\r', expectphrase='#')
    lib.PASS()


def diag_sysinfo_check():
    uut.send('./cel-system-test --all\r', expectphrase='#')
    lib.PASS()


def diag_cpld_access_test():
    uut.send('./cel-cpld-test --all\r', expectphrase='#')
    lib.PASS()


def diag_mainboard_version_check():
    uut.send('./cel-cpld-test -r --name cpld1 -i cpld_version --name cs8320_sy\r', expectphrase='#')
    lib.PASS()


def diag_i2c_test():
    uut.send('./cel-i2c-test --all\r', expectphrase='#')
    lib.PASS()


def diag_pcie_test():
    uut.send('./cel-pci-test --all\r', expectphrase='#')
    lib.PASS()


def diag_on_board_dc_controller_test():
    uut.send('./cel-dcdc-test --all\r', expectphrase='#')
    lib.PASS()


def diag_sata_access_Test():
    uut.send('./cel-storage-test --all\r', expectphrase='#')
    lib.PASS()


def diag_ssd_device_helth_status_test():
    uut.send('smartctl -t short /dev/sda\r', expectphrase='#')
    uut.send('smartctl -a /dev/sda\r', expectphrase='#')
    lib.PASS()


def diag_fdisk_check():
    uut.send('fdisk -l\r', expectphrase='#')
    lib.PASS()


def diag_sram_access_test():
    uut.send('i2cset -y -f 15 0x60 0x31 0x01;i2cset -y -f 15 0x60 0x34 0xaa;i2cset -y -f 15 0x60 0x30 0x01;i2cset -y -f 15 0x60 0x30 0x03\r', expectphrase='#')
    uut.send('i2cget -y -f 15 0x60 0x35\r', expectphrase='#')
    uut.send('i2cset -y -f 15 0x60 0x41 0x01;i2cset -y -f 15 0x60 0x44 0x55;i2cset -y -f 15 0x60 0x40 0x01;i2cset -y -f 15 0x60 0x40 0x03\r', expectphrase='#')
    uut.send('i2cget -y -f 15 0x60 0x45\r', expectphrase='#')
    lib.PASS()


def diag_psu_test():
    uut.send('./cel-psu-test --all\r', expectphrase='#')
    power_control('off', 4)
    uut.send('./cel-psu-test --read -d 1\r', expectphrase='#')
    power_control('on', 4)
    uut.send('./cel-psu-test --read -d 1\r', expectphrase='#')
    power_control('off', 3)
    uut.send('./cel-psu-test --read -d 2\r', expectphrase='#')
    power_control('on', 3)
    uut.send('./cel-psu-test --read -d 2\r', expectphrase='#')
    lib.PASS()


def diag_temp_sensor_test():
    uut.send('./cel-temp-test --all\r', expectphrase='#')
    lib.PASS()


def diag_fan_cpld_access_test():
    uut.send('./cel-cpld-test --dump -d 2\r', expectphrase='#')
    lib.PASS()


def diag_fan_present_test():
    uut.send('./cel-fan-test --show -t present\r', expectphrase='#')
    lib.PASS()


def diag_fan_tray_test():
    uut.send('./cel-fan-test --all\r', expectphrase='#')
    lib.PASS()


def diag_fru_eeprom_test():
    uut.send('./cel-eeprom-test -r -t tlv -d 1\r', expectphrase='#')
    [uut.send(f'./cel-eeprom-test --dump -t fru -d {i}\r', expectphrase='#') for i in range(1, 5)]
    lib.PASS()


def diag_rtc_read_date():
    uut.send('./cel-rtc-test  -r\r', expectphrase='#')
    lib.PASS()


def diag_qsfp_i2c_access_test():
    uut.send('./cel-sfp-test --all\r', expectphrase='#')
    lib.PASS()


def diag_pcie_uart_test():
    [uut.send(f'./cel-uart-test /dev/ttyS{i} 460800\r', expectphrase='#') for i in range(4)]
    lib.PASS()


def power_control(control):
    psu1 = BuiltIn().get_variable_value("${psu1_outlet}")
    psu2 = BuiltIn().get_variable_value("${psu2_outlet}")
    control = control.upper()
    if control not in ['ON', 'CYCLE', 'OFF']:
        raise Warning('Power Control Error, Please Check Input Keywords [ ON | OFF | CYCLE ]')
    wti = lib.getconnections()['WTI']
    wti.open()
    wti.send('telnet 192.168.1.245\r', expectphrase='IPS>', timeout=10)
    for i in ['OFF', 'ON']:
        wti.send(f'/{i} {psu1} {psu2},y\r', expectphrase='IPS>')
        if control in ['OFF']:
            break
        time.sleep(2)
    wti.close()
    lib.PASS()
