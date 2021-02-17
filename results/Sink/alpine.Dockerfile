FROM julia:alpine

COPY . ./app
WORKDIR /app

# Install dependencies
RUN apk --no-cache add curl bash

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apk add --update --no-cache python3 && ln -sf python3 /usr/bin/python
RUN python3 -m ensurepip
RUN pip3 install --no-cache --upgrade pip setuptools

# install pika 
RUN pip3 install -r requirements.txt

ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

RUN adduser -D borghi
USER borghi

# Run our file
CMD julia --project='.' run_sink.jl