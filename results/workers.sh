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

# Run Workers
for ((i = 1; i <= $WORKERS; i++)); do
    gnome-terminal --tab --title="Worker $i" -- bash -c "julia worker.jl"
done
