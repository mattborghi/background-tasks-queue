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

    print("Sending task to workers...")

    workload = random.randint(1, 100)

    sender.send_json({'id': id, 'name': name, 'file': workload})
    sender.close()
    context.term()


if __name__ == "__main__":
    ventilator(1, "Task #1")
