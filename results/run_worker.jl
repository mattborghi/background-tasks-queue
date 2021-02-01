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
        println("\n\n [🚮] Exited Worker.")
        exit()
    else 
        println("\n\n [🚨] There was an error.")
        print(e)
    end
end