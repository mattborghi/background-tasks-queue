# Task ventilator
# Binds PUSH socket to tcp://localhost:5557
# Sends batch of tasks to workers via that socket

import zmq
import random
import time


def ventilator(id, name):

    context = zmq.Context()

    # Socket to send messages on
    sender = context.socket(zmq.PUSH)
    sender.bind("tcp://*:5557")

    # Socket with direct access to the sink: used to synchronize start of batch
    # sink = context.socket(zmq.PUSH)
    # sink.connect("tcp://localhost:5558")

    # print("Press Enter when the workers are ready: ")
    # _ = raw_input()
    print("Sending task to workers...")

    # The first message is "0" and signals start of batch
    # sink.send(b'0')

    # Initialize random number generator
    # random.seed()

    # Send 100 tasks
    # total_msec = 0
    # for task_nbr in range(100):

    # Random workload from 1 to 100 msecs
    workload = random.randint(1, 100)
    # total_msec += workload

    sender.send_json({'id': id, 'name': name, 'file': workload})
    # sender.send_multipart([name.encode('utf-8'), b'%i' % workload])

    # print("Total expected cost: %s msec" % total_msec)

    # Give 0MQ time to deliver
    time.sleep(1)


if __name__ == "__main__":
    ventilator(1, "Task #1")
