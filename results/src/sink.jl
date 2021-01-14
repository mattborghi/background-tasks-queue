#!/usr/bin/env julia

#
# Task sink
# Binds PULL socket to tcp://localhost:5558
# Collects results from workers via that socket
#

using DotEnv
using Diana
using JSON
using ZMQ

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

DotEnv.config(path="../.ENV")

context = Context()

# Socket to receive messages on
receiver = Socket(context, PULL)
bind(receiver, "tcp://*:5558")

URL = """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""

UPDATE_RESULT = """
mutation(\$resultId: Int!, \$value: Float!) {
  updateResult(resultId: \$resultId, value: \$value) {
    result {
      id
      name
      value
      createdAt
      status
    }
  }
}
"""

UPDATE_RESULT_STATUS = """
mutation(\$resultId: Int!, \$status: String!) {
    updateResultStatus(resultId: \$resultId, status: \$status) {
      result {
        id
        name
        value
        createdAt
        status
      }
    }
  }
"""

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

# Socket to send messages to backend
# sender = Socket(context, PUSH)
# connect(sender, "tcp://127.0.0.1:5559")

println("Sink online")
while true
    println("Waiting for result...")
    s = recv(receiver) |> unsafe_string |> JSON.parse
    try
        
        println("Received result #", s["id"], ": ", s["result"], " from task: ", s["name"])

        # Send the result back to the backend
        println("Updating Result")
        id = s["id"]
        value = s["result"]

        result = Queryclient(URL, UPDATE_RESULT; vars=create_vars(id, value))
        # send(sender, s)
        # result.Info.status == "200"
    catch e
        if e isa InterruptException
            println("\nExited Worker")
            # Making a clean exit.
            close(receiver)
            close(context)
            break
        elseif e isa KeyError
            println(e)
            # If failed something
            id = s["id"]
            status = s["status"]
            result = Queryclient(URL, UPDATE_RESULT_STATUS; vars=create_status(id, status))
        else
            println(e)
        end
    end
end
