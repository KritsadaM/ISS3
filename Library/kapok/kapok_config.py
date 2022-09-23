from libs import lib


def apollo_config():
    cont = lib.add_container(name='Cloudripper')
    cont.add_connection(name='uut',
                        host='cthcloudripper2',
                        user='CISCO15',
                        password='W400admin',
                        protocol='telnet',
                        port=2001)
    cont.add_connection(name='WTi',
                        host='10.1.1.10',
                        user='super',
                        password='super',
                        protocol='ssh',
                        port=23)

