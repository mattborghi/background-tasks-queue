# Load Sink module
using Sink

# When pressed CTRL+C initiate an InterruptException
Base.exit_on_sigint(false)

# Connect Sink
connection = Sink.connect()

# Run it
Sink.run_sink(connection)


