# Load Worker module
using Worker

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

# Connect Worker
connection = Worker.connect()

# Run it
Worker.main(connection)
