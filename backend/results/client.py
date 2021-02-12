import pika
import random
import json
import os


def run_client(id, name, code):
    url = os.environ.get('CLOUD_AMQP_URL')

    if url:
        parameters = pika.URLParameters(url)
    else:
        parameters = pika.ConnectionParameters(host='localhost')

    connection = pika.BlockingConnection(parameters)
    channel = connection.channel()

    CLIENT_CHANNEL = 'task_queue'

    channel.queue_declare(queue=CLIENT_CHANNEL, durable=True)

    payload = {"code": code}
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
