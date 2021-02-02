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
        printstyledln("[🚮] Exited Sink.";bold=true,color=:green)
        exit()
    else 
        printstyledln("[🚨] There was an error.";bold=true,color=:green)
        print(e)
    end
end

