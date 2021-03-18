FROM julia:1.6-alpine

COPY . ./app
WORKDIR /app

# Install dependencies
RUN apk --no-cache update
RUN apk --no-cache add curl bash perl make gfortran g++ gcc tar automake autoconf libtool libgomp

# hwloc
RUN apk --no-cache add --repository http://dl-cdn.alpinelinux.org/alpine/edge/community/ hwloc hwloc-dev 

ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

RUN adduser -D borghi
USER borghi

# Run our file
CMD julia --project='.' run_worker.jl