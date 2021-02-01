#!/usr/bin/env julia

#
# Task sink
# Binds PULL socket to tcp://localhost:5558
# Collects results from workers via that socket
#

module Sink

# Load packages
using DotEnv
using Diana
using JSON
using AMQPClient

include("graphql.jl")

# TODO: Use path relative to this file
DotEnv.config(path="../.ENV")

abstract type CustomConnection end

struct Connection <: CustomConnection
    port 
    login
    password
    conn
    chan
end

function connect()
    # Establish the connection to the RabbitMQ Server
    port = AMQPClient.AMQP_DEFAULT_PORT
    login = "guest"  # default is usually "guest"
    password = "guest"  # default is usually "guest"
    auth_params = Dict{String,Any}("MECHANISM" => "AMQPLAIN", "LOGIN" => login, "PASSWORD" => password)
    
    println("\n\n [🔌] Sink stablishing connection. ")
    
    conn = connection(; virtualhost="/", host="localhost", port=port, auth_params=auth_params, amqps=nothing)

    chan = channel(conn, AMQPClient.UNUSED_CHANNEL, true)
    
    return Connection(port, login, password, conn, chan)
end

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

function run_sink(connection::CustomConnection)
    chan = connection.chan

    SINK_CHANNEL = "sink"

    success, message_count, consumer_count = queue_declare(chan, SINK_CHANNEL, durable=true)
    
    println("\n\n [⏳] Waiting for messages. To exit press CTRL+C")

    callback = rcvd_msg -> begin
        msg_str = JSON.parse(String(rcvd_msg.data))
        println("\n\n [📦] Received $(JSON.json(msg_str, 4))")

        id = msg_str["id"]
        
        if msg_str["status"] == "RUNNING"
            value = msg_str["result"]
            result = Queryclient(URL, UPDATE_RESULT; vars=create_vars(id, value))
        elseif msg_str["status"] == "FAILED"
            result = Queryclient(URL, UPDATE_RESULT_STATUS; vars=create_status(id, "FAILED"))
        else
            error("Status not handled")
        end
        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        basic_ack(chan, rcvd_msg.delivery_tag)
    end
    
    success, consumer_tag = basic_consume(chan, SINK_CHANNEL, callback)
    
    @assert success
    # println("consumer registered with tag $consumer_tag")

    # go ahead with other stuff...
    # or wait for an indicator for shutdown

    while true
        sleep(1)
    end
    
    return nothing

end

export connect, run_sink

end