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
using ZMQ

include("graphql.jl")

# TODO: Use path relative to this file
DotEnv.config(path="../.ENV")

abstract type CustomConnection end

struct Connection <: CustomConnection
    receiver
    context
end

function connect()

    context = Context()
    HOST = "127.0.0.1"
    PORT = 5758
  # Socket to receive messages on
    receiver = Socket(context, PULL)
    bind(receiver, "tcp://$HOST:$PORT")

  
    println("Sink online")
  

    return Connection(receiver, context)

end

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

function main(connection::CustomConnection)
    receiver = connection.receiver
    context = connection.context
    while true
        try
            println("Waiting for result...")
            global s = recv(receiver) |> unsafe_string |> JSON.parse
            println("s: ", s)
            println("Received result #", s["id"], ": ", s["result"], " from task: ", s["name"])
            
            # Send the result back to the backend
            println("Updating Result")
            id = s["id"]
            value = s["result"]
            if s["status"] == "RUNNING"
                result = Queryclient(URL, UPDATE_RESULT; vars=create_vars(id, value))
            elseif s["status"] == "FAILED"
                result = Queryclient(URL, UPDATE_RESULT_STATUS; vars=create_status(id, "FAILED"))
            else
                error("Status not handled")
            end
          # send(sender, s)
          # result.Info.status == "200"
        catch e
            if e isa InterruptException
              # Making a clean exit.
                println("\n")
                @info "Sink shut down"
                close(receiver)
                close(context)
                break
            elseif e isa KeyError
                println("There is a key error")
            #     println(e)
            #   # If failed something
            #     id = s["id"]
            #     status = s["status"]
            else
                println(e)
            end
        end
    end

    return nothing

end

export connect, main

end