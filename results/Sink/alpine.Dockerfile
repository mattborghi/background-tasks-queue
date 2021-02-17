FROM julia:alpine

COPY . ./app
WORKDIR /app

# Install dependencies
RUN apk --no-cache add curl bash

ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

RUN adduser -D borghi
USER borghi

# Run our file
CMD julia --project='.' run_sink.jl