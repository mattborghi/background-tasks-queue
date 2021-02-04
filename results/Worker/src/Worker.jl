#!/usr/bin/env julia

#
# Task worker
# Connects PULL socket to tcp://localhost:5557
# Collects workloads from ventilator via that socket
# Connects PUSH socket to tcp://localhost:5558
# Sends results to sink via that socket
#

module Worker

# Load packages
using DotEnv
using Diana
using UUIDs
using JSON
using AMQPClient

include("utils.jl")
include("graphql.jl")

# Here we will load heavy packages
printstyledln("[👷] Loading packages..."; bold=true, color=:green)

# Load high consuming time package here 
# include("...")

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

    printstyledln("[🔌] Worker stablishing connection.";bold=true, color=:green)

    conn = connection(; virtualhost="/", host="localhost", port=port, auth_params=auth_params, amqps=nothing)

    chan = channel(conn, AMQPClient.UNUSED_CHANNEL, true)
    
    return Connection(port, login, password, conn, chan)
end

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""


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
    chan = connection.chan
    
    CLIENT_CHANNEL = "task_queue"
    SINK_CHANNEL = "sink"

    # Declare queue to receive results from client
    success, message_count, consumer_count = queue_declare(chan, CLIENT_CHANNEL, durable=true)
    
    # Declare queue to send results to sink
    _ = queue_declare(chan, SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true, color=:green)

    callback = rcvd_msg -> begin
        message = JSON.parse(String(rcvd_msg.data))
        printstyledln("[📦] Received from Client:";bold=true, color=:green) 
        tabulate_and_pretty(JSON.json(message, 4))

        # Change job status to running 
        STATUS = "RUNNING"
        _ = Queryclient(URL, UPDATE_RESULT_STATUS; vars=Dict("resultId" => message["id"], "status" => STATUS))

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
        json_message = JSON.json(message, 4)
        M = Message(Vector{UInt8}(json_message), content_type="text/plain", delivery_mode=PERSISTENT)
        basic_publish(chan, M; exchange="", routing_key=SINK_CHANNEL)
    
        printstyledln("[📨] Sent to Sink:";bold=true, color=:green)
        tabulate_and_pretty(json_message)



        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        basic_ack(chan, rcvd_msg.delivery_tag)
    end
    
    # Define qos parameters
    prefetch_size = 0
    prefetch_count = 1
    global_qos = false
    basic_qos(chan, prefetch_size, prefetch_count, global_qos)
    
    success, consumer_tag = basic_consume(chan, CLIENT_CHANNEL, callback)
    
    success || ErrorException("There was an error!")
    # println("consumer registered with tag $consumer_tag")

    # go ahead with other stuff...
    # or wait for an indicator for shutdown

    while true
        sleep(1)
    end
                

    return nothing

end

export connection, run_worker, printstyledln

end