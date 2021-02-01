# Load Worker module
using Worker

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

try
    # Connect Worker
    connection = Worker.connect()

    # Run it
    Worker.run_worker(connection)
 
catch e
    if e isa InterruptException
        printstyledln("[🚮] Exited Worker.";bold=true,color=:green)
        exit()
    else 
        printstyledln("[🚨] There was an error.";bold=true,color=:green)
        print(e)
    end
end