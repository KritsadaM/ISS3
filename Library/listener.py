import os.path
import tempfile
import http.client
import urllib.parse
import json
import base64
import uuid
from datetime import datetime

ROBOT_LISTENER_API_VERSION = 2
STATUS_UPDATE_API_URL = '127.0.0.1:8080'

outpath = os.path.join('/opt/Robot_Debug/Logs', 'progress.txt')
outfile = open(outpath, 'w')
outfile.close()


def sending_status(status, message, test_location, test_id):
    conn = http.client.HTTPConnection(STATUS_UPDATE_API_URL)
    payload = {
        "test_id": test_id,
        "message": message,
        "status": status,
        "test_location": test_location}
    headers = {'content-type': "application/json"}
    conn.request("PUT", "/api/statuses", json.dumps(payload), headers)
    res = conn.getresponse()
    data = res.read()
    conn.close()

def get_a_uuid(MAC):
    # clock_seq = 4115

    node = "0x{}".format(MAC)
    node = int(node, 16)
    r_uuid = uuid.uuid1(node)
    return r_uuid
    # cc6255d4-fb67-11ec-bcdd-3d959e2fb9a3

def start_suite(name, attrs):
    outfile = open(outpath, 'a')
    outfile.write("%s Location:%s '%s' Total cases=%d\n" %
                  (name, attrs['metadata']['Location'], attrs['doc'], attrs['totaltests']))
    outfile.close()
    sending_status('start_suite',"%s Location:%s '%s' Total cases=%d" % (
        name, attrs['metadata']['Location'], attrs['doc'], attrs['totaltests']), attrs['metadata']['Location'], 0)


def start_test(name, attrs):
    outfile = open(outpath, 'a')
    tags = attrs['tags'][0]
    outfile.write("- %s '%s' [Location: %s ] :: " % (name, attrs['doc'], tags))
    outfile.close()
    print(attrs)
    sending_status('start_test', "%s" % (name), tags, 0)


def end_test(name, attrs):
    outfile = open(outpath, 'a')
    tags = attrs['tags'][0]
    if attrs['status'] == 'PASS':
        outfile.write('PASS\n')
        sending_status('end_test', "Result:%s" % attrs['status'], tags, 0)
    else:
        outfile.write('FAIL: %s\n' % attrs['message'])
        sending_status('end_test', "Result:%s %s " %
                       (attrs['status'], attrs['message']), tags, 0)
    outfile.close()
    print(attrs)


def end_suite(name, attrs):
    outfile = open(outpath, 'a')
    outfile.write('%s\n%s\n' % (attrs['status'], attrs['message']))
    outfile.close()
    sending_status('end_suite', "Result:%s %s " %
                   (attrs['status'], attrs['message']), attrs['metadata']['Location'], 0)

def line_num_for_phrase_in_file(phrase, filename):
    with open(filename,'r') as f:
        for (i, line) in enumerate(f):
            if phrase in line:
                return i
    return i

def add_one_to_int(n):
    return n + 1