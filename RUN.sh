#!/bin/bash

# Get args
WORKERS=1 # set a default

while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
    -w | --workers)
        WORKERS="$2"
        shift # past argument
        shift # past value
        ;;
    esac
done

# RUN WORKERS AND SINK
for ((i = 1; i <= $WORKERS; i++)); do
    gnome-terminal --tab --title="Worker $i" -- bash -c "cd results; julia worker.jl"
done

gnome-terminal --tab --title="Sink" -- bash -c "cd results; julia ./sink.jl"

# RUN BACKEND
gnome-terminal --tab --title="Backend" -- bash -c "cd backend; pipenv shell --anyway 'python manage.py runserver'"

# RUN FRONTEND
# gnome-terminal --tab --title="Frontend" -- bash -c "cd frontend; npm run start"
