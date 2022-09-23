import fcntl
import time
import threading
import os
#
#
def lock(resource_name):
    name = open('/tmp/{}.lock'.format(resource_name), 'w')
    while True:
        try:
            fcntl.lockf(name, fcntl.LOCK_EX | fcntl.LOCK_NB)
            #time.sleep(15)
            break
        except IOError:
            print('Cannot Lock: {}'.format(resource_name))
            time.sleep(1)
    # print('Locked! Running Code...')
    # while True:
    #     if input('Press q to quit ') == 'q':
    #         print('Bye!')
    #         return True
#
#
# class ContainerLock(object):
#
#     def __init__(self, resource_name):
#         self.resource_name = resource_name
#         self.first_thread = threading.Thread(target=lock, args=self.resource_name)
#         # print(os.getpid())
#
#     def acquire(self):
#         self.first_thread.start()
#
#     def release(self):
#         self.first_thread.join()
#
#     def __enter__(self):
#         return self
#
#     def __exit__(self, exc_type, exc_val, exc_tb):
#         lock(self.resource_name)
#
#
# if __name__ == "__main__":
# #     # a = ContainerLock(resource_name='A', wait_timeout=5, release_timeout=5)
# #     # a.acquire()
# #     # a.release()
# #
#     with ContainerLock(resource_name='A'):
#         print('A')
#


class Lock(object):
    def __init__(self, resource_name):
        self.resource_name = '/tmp/{}.lock'.format(resource_name)

    def lock(self):
        if not os.path.isfile(self.resource_name):
            name = open(self.resource_name, 'w')
            fcntl.lockf(name, fcntl.LOCK_EX | fcntl.LOCK_NB)

    def unlock(self):
        os.remove(self.resource_name)
