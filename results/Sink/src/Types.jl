
abstract type CustomConnection end

struct Connection <: CustomConnection
    connection
    channel
    backend_url
end