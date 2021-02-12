#!/bin/bash

source ./deploy/utils.sh

# COLORS
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PARSE INPUT ARGUMENTS
BACKEND=false
WORKERS=false
SINK=false

while [[ $# -gt 0 ]]; do
    key="$1"
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
    # get log
    get_logs_from_heroku "BACKEND" $backend_GIT_HEROKU_REMOTE
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    # get log
    get_logs_from_heroku "WORKERS" $workers_GIT_HEROKU_REMOTE #$HEADER
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    # get log
    get_logs_from_heroku "SINK" $sink_GIT_HEROKU_REMOTE
fi
