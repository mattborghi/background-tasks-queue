import pika
import random
import json


def run_client(id, name):
    connection = pika.BlockingConnection(
        pika.ConnectionParameters(host='localhost'))
    channel = connection.channel()

    CLIENT_CHANNEL = 'task_queue'

    channel.queue_declare(queue=CLIENT_CHANNEL, durable=True)

    payload = {"number1": random.randint(
        1, 100), "number2": random.randint(1, 100)}
    message = {"id": id,
               "name": name,
               "payload": payload,
               }

    channel.basic_publish(
        exchange='',
        routing_key=CLIENT_CHANNEL,
        body=json.dumps(message),
        properties=pika.BasicProperties(
            delivery_mode=2,  # make message persistent
        ))
    print(" [x] Sent %r" % message)


if __name__ == "__main__":
    run_client(1, "Task #1")
