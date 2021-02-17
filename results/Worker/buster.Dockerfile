# TODO: Fix docker so we can use it in dev mode
# Expose the ports with -p ... etc.
# docker build -t worker . -f buster.Dockerfile
# docker run -it worker
FROM julia:1.6-buster

COPY . ./app
WORKDIR /app

# Download latest listing of available packages:
RUN apt-get -y update
RUN apt-get install -y apt-utils dialog apt-utils
# Upgrade already installed packages:
RUN apt-get -y upgrade

ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

RUN useradd -ms /bin/bash borghi
USER borghi

# Run our file
CMD julia --project='.' run_worker.jl