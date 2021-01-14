#!/usr/bin/env julia

#
# Task sink
# Binds PULL socket to tcp://localhost:5558
# Collects results from workers via that socket
#

using Diana
using JSON
using ZMQ

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

context = Context()

# Socket to receive messages on
receiver = Socket(context, PULL)
bind(receiver, "tcp://*:5558")

URL = "http://127.0.0.1:8000/graphql/"

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

create_dict = (resultId, value) -> Dict("resultId"=>resultId, "value"=> value)

# Socket to send messages to backend
# sender = Socket(context, PUSH)
# connect(sender, "tcp://127.0.0.1:5559")

println("Sink online")
while true
    try
        println("Waiting for result...")
        s = recv(receiver) |> unsafe_string |> JSON.parse
        
        println("Received result #", s["id"], ": ", s["result"] , " from task: ", s["name"])

        # Send the result back to the backend
        println("Updating Result")
        id = s["id"]
        value = s["result"]

        result = Queryclient(URL, UPDATE_RESULT; vars = create_dict(id, value))
        # send(sender, s)
        # result.Info.status == "200"
    catch e
        if e isa InterruptException
            println("\nExited Worker")
        else
            println(e)
        end

        # Making a clean exit.
        close(receiver)
        close(context)
        break
    end
end
