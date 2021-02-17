#!/usr/bin/env julia

module Worker


# Load packages
using DotEnv
using Diana
using JSON
# using PyCall
using AMQPClient

include("utils.jl")
include("graphql.jl")

printstyledln("[👷] Loading packages..."; bold=true, color=:green)

# Load high consuming time package here
# using "..."
using DifferentialEquations

CLIENT_CHANNEL = "task_queue"
SINK_CHANNEL = "sink"

abstract type CustomConnection end

struct Connection <: CustomConnection
    # pika
    connection
    channel
    backend_url
end

function connect()
    # Establish the connection to the RabbitMQ Server
    # pika = pyimport("pika")
    
    # parameters = haskey(ENV, "CLOUD_AMQP_URL") ? 
    #             pika.URLParameters(ENV["CLOUD_AMQP_URL"]) : 
    #             pika.ConnectionParameters(host="0.0.0.0")
    
    host = haskey(ENV, "CLOUD_AMQP_HOST") ? ENV["CLOUD_AMQP_HOST"] : "0.0.0.0"
    port = haskey(ENV, "CLOUD_AMQP_PORT") ? ENV["CLOUD_AMQP_PORT"] : AMQPClient.AMQP_DEFAULT_PORT
    vhost = haskey(ENV, "CLOUD_AMQP_VHOST") ? ENV["CLOUD_AMQP_VHOST"] : "/"
    user = haskey(ENV, "CLOUD_AMQP_USER") ? ENV["CLOUD_AMQP_USER"] : "guest"
    pass = haskey(ENV, "CLOUD_AMQP_PASS") ? ENV["CLOUD_AMQP_PASS"] : "guest"
    
    parameters = Dict{String,Any}("host"=>host, "port"=>port, "vhost"=>vhost, "user"=>user, "pass"=>pass)
    printstyledln(" [🗄️] RabbitMQ Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(parameters, 4))

    printstyledln("[🔌] Worker establishing connection.";bold=true, color=:green)
    
    auth_params = Dict{String,Any}("MECHANISM" => "AMQPLAIN", "LOGIN" => user, "PASSWORD" => pass)
    connection = AMQPClient.connection(; virtualhost=vhost, host, port, auth_params=auth_params, amqps=nothing)
    # connection = pika.BlockingConnection(parameters)

    # channel = connection.channel()
    channel = AMQPClient.channel(connection, AMQPClient.UNUSED_CHANNEL, true)

    # TODO: This should not be in deployment
    DotEnv.config(path="./.ENV")

    GRAPHQL_URL = haskey(ENV, "GRAPHQL_URL") ? ENV["GRAPHQL_URL"] : """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""
    
    graphql_params = haskey(ENV, "GRAPHQL_URL") ? Dict("url" => GRAPHQL_URL) : Dict("host" => ENV["HOST"], "port" => ENV["PORT"], "channel" => ENV["CHANNEL"])
    printstyledln(" [🐚] GRAPHQL Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(graphql_params, 4))
    # @show GRAPHQL_URL

    # return Connection(pika, connection, channel,GRAPHQL_URL)
    return Connection(connection, channel, GRAPHQL_URL)
end

function process_result(job)
    try
        # TODO: When parsed check we dont have strange code
        result = @time eval.(parseall(job["code"]))[end]
        
        printstyledln("[👉] Done";bold=true, color=:green)

        return result
    catch error_message
        printstyledln("[❌] Failed with error:";bold=true, color=:red)
        # Just simply print if there is a failure with jsonify the error message
        try
            tabulate_and_pretty(JSON.json(error_message, 4))
        catch e
            println(e)
        end
        # Improved function output: better to be an struct of result + error
        return nothing
    end
end


function run_worker(connection::CustomConnection)
    channel = connection.channel
    GRAPHQL_URL = connection.backend_url
    
    # Declare queue to receive results from client
    # channel.queue_declare(queue=CLIENT_CHANNEL, durable=true)
    
    # Declare queue to send results to sink
    # channel.queue_declare(queue=SINK_CHANNEL, durable=true)
    success, message_count, consumer_count = queue_declare(channel, CLIENT_CHANNEL, durable=true)
    
    # Declare queue to send results to sink
    _ = queue_declare(channel, SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true, color=:green)

    # callback = (ch, method, properties, body) -> begin
    callback = rcvd_msg -> begin
        # message = JSON.parse(String(body))
        message = JSON.parse(String(rcvd_msg.data))

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
        # channel.basic_publish(exchange="", routing_key=SINK_CHANNEL, body=message_sent)
        M = Message(Vector{UInt8}(message_sent), content_type="text/plain", delivery_mode=PERSISTENT)
        basic_publish(channel, M; exchange="", routing_key=SINK_CHANNEL)
    
        printstyledln("[📨] Sent to Sink:";bold=true, color=:green)
        tabulate_and_pretty(message_sent)

        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        basic_ack(channel, rcvd_msg.delivery_tag)
        # ch.basic_ack(delivery_tag=method.delivery_tag)
    end
    
    # Define qos parameters
    # channel.basic_qos(prefetch_count=1)
    
    # channel.basic_consume(queue=CLIENT_CHANNEL, on_message_callback=callback)
    
    # channel.start_consuming()    
    prefetch_size = 0
    prefetch_count = 1
    global_qos = false
    basic_qos(channel, prefetch_size, prefetch_count, global_qos)
    
    success, consumer_tag = basic_consume(channel, CLIENT_CHANNEL, callback)
    
    success || ErrorException("There was an error!")

    while true
        sleep(1)
    end
                

    return nothing
end

export connection, run_worker, printstyledln

end