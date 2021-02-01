# Task ventilator
# Binds PUSH socket to tcp://localhost:5557
# Sends batch of tasks to workers via that socket

import pika
import random


def run_client(id, name):
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host='localhost'))
    channel = connection.channel()

    channel.queue_declare(queue='task_queue', durable=True)

    payload = {"number1": random.randint(
        1, 100), "number2": random.randint(1, 100)}
    message = {"id": id,
               "name": name,
               "payload": payload,
               }

    channel.basic_publish(
        exchange='',
        routing_key='task_queue',
        body=message,
        properties=pika.BasicProperties(
            delivery_mode=2,  # make message persistent
        ))
    print(" [x] Sent %r" % message)


if __name__ == "__main__":
    run_client(1, "Task #1")
