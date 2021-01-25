# Task ventilator
# Binds PUSH socket to tcp://localhost:5557
# Sends batch of tasks to workers via that socket

from LoadBalancer.client import Client
from LoadBalancer.job import Job

# import zmq
import random
# import time


def run_client(id, name):
    data = {"number1": random.randint(
        1, 100), "number2": random.randint(1, 100)}
    print("Sending %s" % data)
    Client(data=Job(data, name, id=id))
# def ventilator(id, name):

#     context = zmq.Context()

#     # Socket to send messages on
#     sender = context.socket(zmq.PUSH)
#     sender.bind("tcp://*:5557")

#     print("Sending task to workers...")

#     workload = random.randint(1, 100)

#     sender.send_json({'id': id, 'name': name, 'file': workload})
#     sender.close()
#     context.term()


if __name__ == "__main__":
    run_client(1, "Task #1")
#     ventilator(1, "Task #1")
