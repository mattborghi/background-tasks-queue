# Load Sink module
using Sink

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

try
    # Connect Sink
    connection = Sink.connect()

# Run it
    Sink.run_sink(connection)
catch e
    if e isa InterruptException
        println("\n\n [🚮] Exited Sink.")
        exit()
    else 
        println("\n\n [🚨] There was an error.")
        print(e)
    end
end

