import requests
import sys
import re

try:
    print(sys.argv[1])
    sn = sys.argv[1].strip()

    url = "http://cthmes54/des/f5/getparameter.asp?profile=F5_DATA&sn={}".format(sn)
    r = requests.get(url)
    print(r.text)
    response = r.text
    tags={"PRODUCT_PART_NUMBER" : "odc_pro_pn",
          "PRODUCTION_STATE" : "odc_pro_state",
          "PRODUCT_VERSION" : "odc_pro_version",
          "PCB_MANUFACTURE" : "odc_pcb_mfg",
         "SCM_PCBA_SN" : "odc_scm_pcba_sn",
         "FAN_1" : "odc_fan1",
         "FAN_2" : "odc_fan2",
         "FAN_3" : "odc_fan3",
          "FAN_4" : "odc_fan4",
         "FCM" : "odc_fcm",
         "PDB1" : "odc_pdb1",
         "PDB2" : "odc_pdb2",
         "RACK_MON" : "odc_rack_mon",
         "SCM" : "odc_scm",
         "SMB" : "odc_smb",
         "SSD_1" : "odc_ssd1",
          "SSD_2" : "odc_ssd2",
         "MACID" : "odc_mac_id",
         "MAC_COM_E" : "odc_mac_com_e",
         "PRODUCT_ASSET_TAG" : "odc_pro_ass_tag"}

    if re.search("Not found Shop Order of", response):
        print("#" * 100)
        print("\nERROR ===> Please check the SN on ODC....!!!!!!!\n")
        print("#" * 100)
    else:
        with open("C:\\Robot\\ODC_Script\\BOM\\{}.py".format(sn), "a+") as save_data:
            odc_sn = re.search('SN=\"(.*)\"', response).group(1).strip()
            print(odc_sn)
            save_data.write('odc_sn = "{}"\n'.format(odc_sn))

            for key, val in tags.items():
                odc_data = re.search('\<{0}\>(.*)\<\/{0}\>'.format(key),
                                     response).group(1).strip()
                print(odc_data)
                save_data.write('{} = "{}"\n'.format(val, odc_data))

        print("#" * 100)
        print("\nGenerate data from ODC to C:\\Robot\\ODC_Script\\BOM\\{}.py is Successful\n".format(sn))
        print("#" * 100)
except Exception as error:
    print("#" * 100)
    print("\nERROR ===> Cannot Generate data from ODC.......!!!!!!\n")
    print("#" * 100)

    print(error)