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

# Install python/pip
ENV PYTHONUNBUFFERED=1
RUN apt-get -y install python3-pip && ln -sf python3 /usr/bin/python
# RUN pip3 install --no-cache --upgrade pip setuptools

# install pika
RUN pip3 install -r requirements.txt

ENV JULIA_DEPOT_PATH "/app/.julia/packages/:$JULIA_DEPOT_PATH"

# Install PyJulia requirement PyCall
RUN julia -e 'import Pkg; Pkg.activate("."); Pkg.instantiate(); Pkg.precompile()'

RUN useradd -ms /bin/bash borghi
USER borghi

# Run our file
CMD julia --project='.' run_worker.jl