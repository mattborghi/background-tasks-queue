#!/usr/bin/env julia

module Sink

# Load packages
using DotEnv
using Diana
using JSON
using AMQPClient

include("graphql.jl")
include("utils.jl")


SINK_CHANNEL = "sink"

abstract type CustomConnection end

struct Connection <: CustomConnection
    connection
    channel
    backend_url
end

function connect()
    # Establish the connection to the RabbitMQ Server
    host = haskey(ENV, "CLOUD_AMQP_HOST") ? ENV["CLOUD_AMQP_HOST"] : "0.0.0.0"
    port = haskey(ENV, "CLOUD_AMQP_PORT") ? ENV["CLOUD_AMQP_PORT"] : AMQPClient.AMQP_DEFAULT_PORT
    vhost = haskey(ENV, "CLOUD_AMQP_VHOST") ? ENV["CLOUD_AMQP_VHOST"] : "/"
    user = haskey(ENV, "CLOUD_AMQP_USER") ? ENV["CLOUD_AMQP_USER"] : "guest"
    pass = haskey(ENV, "CLOUD_AMQP_PASS") ? ENV["CLOUD_AMQP_PASS"] : "guest"
    
    parameters = Dict{String,Any}("host" => host, "port" => port, "vhost" => vhost, "user" => user, "pass" => pass)
    printstyledln(" [🗄️] RabbitMQ Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(parameters, 4))

    printstyledln(" [🔌] Sink establishing connection.";bold=true,color=:green)
    
    auth_params = Dict{String,Any}("MECHANISM" => "AMQPLAIN", "LOGIN" => user, "PASSWORD" => pass)
    connection = AMQPClient.connection(; virtualhost=vhost, host, port, auth_params=auth_params, amqps=nothing)

    channel = AMQPClient.channel(connection, AMQPClient.UNUSED_CHANNEL, true)


    # TODO: Use path relative to this file
    DotEnv.config(path="./.ENV")

    GRAPHQL_URL = haskey(ENV, "GRAPHQL_URL") ? ENV["GRAPHQL_URL"] : """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""
    
    graphql_params = haskey(ENV, "GRAPHQL_URL") ? Dict("url" => GRAPHQL_URL) : Dict("host" => ENV["HOST"], "port" => ENV["PORT"], "channel" => ENV["CHANNEL"])
    printstyledln(" [🐚] GRAPHQL Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(graphql_params, 4))
    
    return Connection(connection, channel, GRAPHQL_URL)
end

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

function run_sink(connection::CustomConnection)
    # TODO: Use Parameters.jl's @unpack?
    channel = connection.channel
    GRAPHQL_URL = connection.backend_url
    
    # Declare queue to receive results from client
    success, message_count, consumer_count = queue_declare(channel, SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true,color=:green)

    callback = rcvd_msg -> begin
        message = JSON.parse(String(rcvd_msg.data))
        
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
        basic_ack(channel, rcvd_msg.delivery_tag)
    end
    
    success, consumer_tag = basic_consume(channel, SINK_CHANNEL, callback)
    
    success || ErrorException("There was an error!")

    while true
        sleep(1)
    end
                

    return nothing
end

export connect, run_sink, printstyledln

end