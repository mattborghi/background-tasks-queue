# TODO: Fix docker so we can use it in dev mode
# Expose the ports with -p ... etc.
# docker build -t worker . -f buster.Dockerfile
# docker run -it worker
FROM julia:latest

COPY . ./app
WORKDIR /app

# ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

# RUN useradd -ms /bin/bash borghi
# USER borghi

# Run our file
CMD julia --project='.' run_worker.jl