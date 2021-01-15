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
using JSON
using ZMQ

# Here we will load heavy packages
println("Loading packages...")

include("graphql.jl")

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

DotEnv.config(path="../.ENV")

abstract type CustomConnection end

struct Connection <: CustomConnection
    receiver
    sender
    context
end

function connect()
    context = Context()

    println("Connecting to servers..")
    # Socket to receive messages from ventilator
    receiver = Socket(context, PULL)
    ZMQ.connect(receiver, "tcp://localhost:5557")

    # Socket to send messages to sink
    sender = Socket(context, PUSH)
    ZMQ.connect(sender, "tcp://localhost:5558")

    return Connection(receiver, sender, context)
end

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

function main(connection::CustomConnection)
    receiver = connection.receiver
    sender = connection.sender
    context = connection.context
# Process tasks forever
    while true
    # Parse input to JSON
        s = ZMQ.recv(receiver) |> unsafe_string |> JSON.parse
        try
        # println("received message: ", s)
            println("id:   ", s["id"])
            println("name: ", s["name"])
            println("file: ", s["file"])
    # Simple progress indicator for the viewer
    # write(stdout, ".")
    # flush(stdout)
            STATUS = "RUNNING"
            result = Queryclient(URL, UPDATE_RESULT_STATUS; vars=Dict("resultId" => s["id"], "status" => STATUS))

    # Do the work
            rand() < 0.4 ? error("Random failure") : sleep(s["file"])
            result = rand()
            println("result: ", result)
        # Send results to sink
            data = Dict("id" => s["id"], "name" => s["name"], "result" => string(result))
            ZMQ.send(sender, JSON.json(data))
        # send(sender, s["name"], more=true)
        # send(sender, string(result))

        catch e
            if e isa InterruptException
                println("\nExited Worker")
                ZMQ.close(sender)
                ZMQ.close(receiver)
                ZMQ.close(context)
                break
            elseif e isa ErrorException
                println(e)
                data = Dict("id" => s["id"], "name" => s["name"], "status" => "FAILED")
                ZMQ.send(sender, JSON.json(data))
            else
                println(e)
            end
        end
    end

    return nothing

end

export connection, main

end