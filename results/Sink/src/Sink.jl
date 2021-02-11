#!/usr/bin/env julia

module Sink

# Load packages
using DotEnv
using Diana
using JSON
using PyCall

include("graphql.jl")
include("utils.jl")


SINK_CHANNEL = "sink"

abstract type CustomConnection end

struct Connection <: CustomConnection
    pika
    connection
    channel
    backend_url
end

function connect()
    # Establish the connection to the RabbitMQ Server
    pika = pyimport("pika")
    
    parameters = haskey(ENV, "CLOUD_AMQP_URL") ? 
                pika.URLParameters(ENV["CLOUD_AMQP_URL"]) : 
                pika.ConnectionParameters(host="0.0.0.0")

    @show parameters

    printstyledln("[🔌] Sink stablishing connection.";bold=true,color=:green)
    
    connection = pika.BlockingConnection(parameters)

    channel = connection.channel()


    # TODO: Use path relative to this file
    DotEnv.config(path="./.ENV")

    GRAPHQL_URL = haskey(ENV, "GRAPHQL_URL") ? ENV["GRAPHQL_URL"] : """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

    @show GRAPHQL_URL
    
    return Connection(pika, connection, channel, GRAPHQL_URL)
end

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

function run_sink(connection::CustomConnection)
    # TODO: Use Parameters.jl's @unpack?
    channel = connection.channel
    GRAPHQL_URL = connection.backend_url
    
    # Declare queue to receive results from client
    channel.queue_declare(queue=SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true,color=:green)

    callback = (ch, method, properties, body) -> begin
        message = JSON.parse(String(body))
        
        printstyledln("[📦] Received from Worker:";bold=true,color=:green) 
        tabulate_and_pretty(JSON.json(message, 4))

        id = message["id"]
        
        if message["status"] == "FINISHED"
            value = message["result"]
            _ = Queryclient(GRAPHQL_URL, UPDATE_RESULT; vars=create_vars(id, value))
        elseif message["status"] == "FAILED"
            _ = Queryclient(GRAPHQL_URL, UPDATE_RESULT_STATUS; vars=create_status(id, "FAILED"))
        else
            error("Status not handled")
        end
        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        ch.basic_ack(delivery_tag=method.delivery_tag)
    end
    
    channel.basic_consume(queue=SINK_CHANNEL, on_message_callback=callback)
    
    channel.start_consuming()            
end

export connect, run_sink, printstyledln

end