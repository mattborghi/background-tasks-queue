#!/bin/bash

source ./deploy/utils.sh

# COLORS
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PARSE INPUT ARGUMENTS

FRONTEND=false
BACKEND=false
WORKERS=false
SINK=false

while [[ $# -gt 0 ]]; do
    key="$1"
    case "${key,,}" in
    frontend)
        FRONTEND=true
        shift # past argument
        ;;
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

# FRONTEND was set?
if [[ "$FRONTEND" = true ]]; then
    print_header "Deploying Frontend"
    # deploy
    cd $frontend_SUBFOLDER
    npm run deploy
    cd ..
fi

# BACKEND was set?
if [[ "$BACKEND" = true ]]; then
    print_header "Deploying Backend"
    # push changes
    push_to_heroku $backend_GIT_HEROKU_REMOTE $backend_SUBFOLDER $backend_REMOTE_BRANCH
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    print_header "Deploying workers"
    # push changes
    push_to_heroku $workers_GIT_HEROKU_REMOTE $workers_SUBFOLDER $workers_REMOTE_BRANCH
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    print_header "Deploying Sink"
    # push changes
    push_to_heroku $sink_GIT_HEROKU_REMOTE $sink_SUBFOLDER $sink_REMOTE_BRANCH
fi
