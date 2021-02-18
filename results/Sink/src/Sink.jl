#!/usr/bin/env julia

module Sink

# Load packages
using DotEnv
using Diana
using JSON
using AMQPClient

SINK_CHANNEL = "sink"

create_vars = (resultId, value) -> Dict("resultId" => resultId, "value" => value)
create_status = (resultId, status) -> Dict("resultId" => resultId, "status" => status)

export connect, run_sink, printstyledln

include("GraphQL.jl")
include("Utils.jl")
include("Types.jl")
include("Connection.jl")
include("Run.jl")

end