#!/usr/bin/env julia

module Worker

# Load packages
using DotEnv
using Diana
using UUIDs
using JSON
using PyCall

include("utils.jl")
include("graphql.jl")

# Here we will load heavy packages
printstyledln("[👷] Loading packages..."; bold=true, color=:green)

# Load high consuming time package here
# include("...")

CLIENT_CHANNEL = "task_queue"
SINK_CHANNEL = "sink"

DotEnv.config(path="./.ENV")

GRAPHQL_URL = haskey(ENV, "GRAPHQL_URL") ? ENV["GRAPHQL_URL"] : """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

@show GRAPHQL_URL

abstract type CustomConnection end

struct Connection <: CustomConnection
    pika
    connection
    channel
end

function connect()
    # Establish the connection to the RabbitMQ Server
    pika = pyimport("pika")
    @show pika
    parameters = haskey(ENV, "CLOUD_AMQP_URL") ? 
                pika.URLParameters(ENV["CLOUD_AMQP_URL"]) : 
                pika.ConnectionParameters(host="0.0.0.0")

    @show parameters

    printstyledln("[🔌] Worker stablishing connection.";bold=true, color=:green)

    connection = pika.BlockingConnection(parameters)

    channel = connection.channel()
    
    return Connection(pika, connection, channel)
end

function process_result(job)
    # Sleep between 10 and 30 sec
    sleeping_time = rand(10:30)
    sleep(sleeping_time)

    rand() < 0.4 && return nothing
    
    printstyledln("[👉] Done $sleeping_time seconds";bold=true, color=:green)

    number1 = job["number1"]
    number2 = job["number2"]

    return  number1^2 + number2
end


function run_worker(connection::CustomConnection)
    channel = connection.channel
    
    # Declare queue to receive results from client
    channel.queue_declare(queue=CLIENT_CHANNEL, durable=true)
    
    # Declare queue to send results to sink
    channel.queue_declare(queue=SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true, color=:green)

    callback = (ch, method, properties, body) -> begin
        message = JSON.parse(String(body))

        printstyledln("[📦] Received from Client:";bold=true, color=:green) 
        tabulate_and_pretty(JSON.json(message, 4))

        # Change job status to running 
        STATUS = "RUNNING"
        _ = Queryclient(GRAPHQL_URL, UPDATE_RESULT_STATUS; vars=Dict("resultId" => message["id"], "status" => STATUS))

        result = process_result(message["payload"])
        
        if !isnothing(result)
            # Append result to message 
            message["result"] = result
            message["status"] = "FINISHED"
            message["message"] = "job_done"
        else
            message["status"] = "FAILED"
            message["message"] = "job_failed"     
        end

        # Send results to sink
        message_sent = JSON.json(message, 4)
        channel.basic_publish(exchange="", routing_key=SINK_CHANNEL, body=message_sent)
    
        printstyledln("[📨] Sent to Sink:";bold=true, color=:green)
        tabulate_and_pretty(message_sent)

        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        ch.basic_ack(delivery_tag=method.delivery_tag)
    end
    
    # Define qos parameters
    channel.basic_qos(prefetch_count=1)
    
    channel.basic_consume(queue=CLIENT_CHANNEL, on_message_callback=callback)
    
    channel.start_consuming()            
end

export connection, run_worker, printstyledln

end