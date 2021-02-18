
function connect()
    # Establish the connection to the RabbitMQ Server
    host = haskey(ENV, "CLOUD_AMQP_HOST") ? ENV["CLOUD_AMQP_HOST"] : "0.0.0.0"
    port = haskey(ENV, "CLOUD_AMQP_PORT") ? ENV["CLOUD_AMQP_PORT"] : AMQPClient.AMQP_DEFAULT_PORT
    vhost = haskey(ENV, "CLOUD_AMQP_VHOST") ? ENV["CLOUD_AMQP_VHOST"] : "/"
    user = haskey(ENV, "CLOUD_AMQP_USER") ? ENV["CLOUD_AMQP_USER"] : "guest"
    pass = haskey(ENV, "CLOUD_AMQP_PASS") ? ENV["CLOUD_AMQP_PASS"] : "guest"
    
    parameters = Dict{String,Any}("host"=>host, "port"=>port, "vhost"=>vhost, "user"=>user, "pass"=>pass)
    printstyledln(" [🗄️] RabbitMQ Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(parameters, 4))

    printstyledln("[🔌] Worker establishing connection.";bold=true, color=:green)
    
    auth_params = Dict{String,Any}("MECHANISM" => "AMQPLAIN", "LOGIN" => user, "PASSWORD" => pass)
    connection = AMQPClient.connection(; virtualhost=vhost, host, port, auth_params=auth_params, amqps=nothing)

    channel = AMQPClient.channel(connection, AMQPClient.UNUSED_CHANNEL, true)

    # TODO: This should not be in deployment
    DotEnv.config(path="./.ENV")

    GRAPHQL_URL = haskey(ENV, "GRAPHQL_URL") ? ENV["GRAPHQL_URL"] : """http://$(ENV["HOST"]):$(ENV["PORT"])/$(ENV["CHANNEL"])"""
    
    graphql_params = haskey(ENV, "GRAPHQL_URL") ? Dict("url" => GRAPHQL_URL) : Dict("host" => ENV["HOST"], "port" => ENV["PORT"], "channel" => ENV["CHANNEL"])
    printstyledln(" [🐚] GRAPHQL Parameters"; bold=true, color=:cyan)
    tabulate_and_pretty(JSON.json(graphql_params, 4))

    return Connection(connection, channel, GRAPHQL_URL)
end
