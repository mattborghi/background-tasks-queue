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
