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
using ZMQ

# Here we will load heavy packages
println("Loading packages...")

include("graphql.jl")

DotEnv.config(path="../.ENV")

abstract type CustomConnection end

struct Connection <: CustomConnection
    socket
    context
end

function connect()
    context = Context()
    HOST = "127.0.0.1"
    PORT = 5755
    println("Connecting to servers..")
    # Socket to receive messages from ventilator
    socket = Socket(context, DEALER)
    ZMQ.connect(socket, "tcp://$HOST:$PORT")
    uuid_name = string(UUIDs.uuid4())[1:4]
    setproperty!(socket, :routing_id, uuid_name)

    println("Worker $(uuid_name) connected")

    return Connection(socket, context)
end

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

function send_status(socket, status)

    socket_id = getproperty(socket, :routing_id)

    send(socket, JSON.json(Dict("worker_id" => socket_id, "message" => status)))
end

function disconnect(connection::CustomConnection)
    println("\n")
    @info "Worker shut down"

    socket = connection.socket
    context = connection.context
    
    send_status(socket, "disconnect")


    close(socket)
    close(context)

end

function process_result(job)
    # Sleep between 10 and 30 sec
    sleep(rand(10:30))
    
    rand() < 0.4 && error("Random failure")
    
    number1 = job["number1"]
    number2 = job["number2"]

    return  number1^2 + number2
end


function main(connection::CustomConnection)
    socket = connection.socket
    context = connection.context

    send_status(socket, "connect")
    while true
        try
            # Parse input to JSON
            global job = ZMQ.recv(socket) |> unsafe_string |> JSON.parse
        
            println("Received job: ", job)
    
            STATUS = "RUNNING"
            result = Queryclient(URL, UPDATE_RESULT_STATUS; vars=Dict("resultId" => job["id"], "status" => STATUS))

            # Do the work
            result = process_result(job)
            println("result: ", result)
            # Append result to message 
            job["result"] = result
            job["status"] = STATUS
        # Send results to sink
            data = Dict(
                        "worker_id" => getproperty(socket, :routing_id),
                        "message" => "job_done", 
                        "job" => job,
                        )
            send(socket, JSON.json(data))

        catch e
            if e isa InterruptException
                disconnect(connection)
                break
            elseif e isa ErrorException
                # Maybe there was an error processing the result so go here
                println(e)
                job["status"] = "FAILED"
                data = Dict(
                        "worker_id" => getproperty(socket, :routing_id),
                        "message" => "job_failed", 
                        "job" => job, 
                        )
                send(socket, JSON.json(data))
            else
                println(e)
                disconnect(connection)
            end
        end
    end

    return nothing

end

export connection, main

end