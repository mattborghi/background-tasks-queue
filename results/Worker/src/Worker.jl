#!/usr/bin/env julia

module Worker


# Load packages
using DotEnv
using Diana
using JSON
using AMQPClient

include("Utils.jl")
include("GraphQL.jl")
include("Types.jl")
include("Connection.jl")
include("Workload.jl")
include("Run.jl")

printstyledln("[👷] Loading packages..."; bold=true, color=:green)

# Load high consuming time package here
# using "..."
using DifferentialEquations

CLIENT_CHANNEL = "task_queue"
SINK_CHANNEL = "sink"

export connection, run_worker, printstyledln

end