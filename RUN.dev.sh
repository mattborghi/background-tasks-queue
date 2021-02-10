#!/bin/bash

# PARSE INPUT ARGUMENTS

WORKERS=1 # set a default

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -w | --workers)
        WORKERS="$2"
        shift # past argument
        shift # past value
        ;;
    *)
        echo "Ignoring input argument: $key"
        shift # Shift removes from the list the argument
        shift # and value so we can continue with the next
        ;;
    esac
done

# RUN RABBITMQ SERVER
gnome-terminal --tab --title="RabbitMQ Server" -- bash -c "docker stop rabbitmq; docker run -it --rm --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management"

# Give time to Rabbit Server to load
sleep 5s

# RUN WORKERS
for ((i = 1; i <= $WORKERS; i++)); do
    gnome-terminal --tab --title="Worker $i" -- bash -c "cd results; julia --project='Worker' run_worker.jl"
done

# RUN SINK
gnome-terminal --tab --title="Sink" -- bash -c "cd results; julia --project='Sink' run_sink.jl"

# RUN BACKEND
gnome-terminal --tab --title="Backend" -- bash -c "cd backend; pipenv run python manage.py runserver"

# RUN FRONTEND
gnome-terminal --tab --title="Frontend" -- bash -c "cd frontend; npm run start"
