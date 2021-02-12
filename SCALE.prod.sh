#!/bin/bash

source ./deploy/utils.sh

# COLORS
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PARSE INPUT ARGUMENTS

STATUS=0 # UP OR DOWN
UPORDOWN=DOWN
BACKEND=false
WORKERS=false
SINK=false

# Parse first parameter
if [[ "$1" = UP ]]; then
    STATUS=1
    UPORDOWN=$1
    shift
elif [[ "$1" = DOWN ]]; then
    STATUS=0
    UPORDOWN=$1
    shift
else
    echo "Wrong parameter: $1"
    exit 1
fi

while [[ $# -gt 0 ]]; do
    # Parse subsequent parameters
    key="$1"
    # Exit if there are no additional parameters
    if [[ -z "$key" ]]; then
        echo "No additional parameters supplied. Exiting."
        exit 1
    fi
    case "${key,,}" in
    backend)
        BACKEND=true
        shift
        ;;
    workers)
        WORKERS=true
        shift
        ;;
    sink)
        SINK=true
        shift
        ;;
    *)
        printf "Ignoring input argument: $key \n"
        shift # Shift removes from the list the argument
        ;;
    esac
done

# Parse input variables from the ENV files
eval $(parse_yaml ./deploy/ENV.deploy.yml)

# BACKEND was set?
if [[ "$BACKEND" = true ]]; then
    print_header "$UPORDOWN Backend"
    # push changes
    up_to_heroku $backend_APP_TYPE $STATUS $backend_GIT_HEROKU_REMOTE
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    print_header "$UPORDOWN Workers"
    # push changes
    up_to_heroku $workers_APP_TYPE $STATUS $workers_GIT_HEROKU_REMOTE
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    print_header "$UPORDOWN Sink"
    # push changes
    up_to_heroku $sink_APP_TYPE $STATUS $sink_GIT_HEROKU_REMOTE
fi
