
function run_worker(connection::CustomConnection)
    channel = connection.channel
    GRAPHQL_URL = connection.backend_url
    
    # Declare queue to receive results from client
    success, message_count, consumer_count = queue_declare(channel, CLIENT_CHANNEL, durable=true)
    
    # Declare queue to send results to sink
    _ = queue_declare(channel, SINK_CHANNEL, durable=true)
    
    printstyledln("[⏳] Waiting for messages. To exit press CTRL+C";bold=true, color=:green)

    callback = rcvd_msg -> begin
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
        M = Message(Vector{UInt8}(message_sent), content_type="text/plain", delivery_mode=PERSISTENT)
        basic_publish(channel, M; exchange="", routing_key=SINK_CHANNEL)
    
        printstyledln("[📨] Sent to Sink:";bold=true, color=:green)
        tabulate_and_pretty(message_sent)

        # It's time to remove the auto_ack flag and 
        # send a proper acknowledgment from the worker, 
        # once we're done with a task.
        basic_ack(channel, rcvd_msg.delivery_tag)
    end
    
    # Define qos parameters
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
