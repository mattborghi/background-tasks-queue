#!/usr/bin/env julia

#
# Task worker
# Connects PULL socket to tcp://localhost:5557
# Collects workloads from ventilator via that socket
# Connects PUSH socket to tcp://localhost:5558
# Sends results to sink via that socket
#

using ZMQ
using JSON
# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

println("Loading packages...")
# Here we will load heavy packages

context = Context()

println("Connecting to servers..")
# Socket to receive messages from ventilator
receiver = Socket(context, PULL)
connect(receiver, "tcp://localhost:5557")

# Socket to send messages to sink
sender = Socket(context, PUSH)
connect(sender, "tcp://localhost:5558")

# Process tasks forever
while true
    try
    # Parse input to JSON
        s = recv(receiver) |> unsafe_string |> JSON.parse
        # println("received message: ", s)
        println("name: ", s["name"])
        println("file: ", s["file"])
    # Simple progress indicator for the viewer
    # write(stdout, ".")
    # flush(stdout)
    
    # Do the work
        sleep(s["file"] * 0.001)
        result = rand()
        println("result: ", result)
        # Send results to sink
        data = Dict("name" => s["name"], "result" => string(result))
        send(sender, JSON.json(data))
        # send(sender, s["name"], more=true)
        # send(sender, string(result))

    catch e
        if e isa InterruptException
            println("\nExited Worker")
        else
            println(e)
        end
        close(sender)
        close(receiver)
        close(context)
        break
    end
end
