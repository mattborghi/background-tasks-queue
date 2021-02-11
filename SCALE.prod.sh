#!/bin/bash

# COLORS
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PARSE INPUT ARGUMENTS

STATUS=0
# WORKERS=1 # set a default
BACKEND=false
WORKERS=false
SINK=false

# Parse first parameter
if [[ "$1" = UP ]]; then
    # echo "UP"
    STATUS=1
    shift
elif [[ "$1" = DOWN ]]; then
    # echo "DOWN"
    STATUS=0
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
        # printf "set BACKEND: $BACKEND"
        shift
        ;;
    workers)
        WORKERS=true
        # printf "set WORKERS: $WORKERS"
        shift
        ;;
    sink)
        SINK=true
        # printf "set SINK: $true"
        shift
        ;;
    *)
        printf "Ignoring input argument: $key \n"
        shift # Shift removes from the list the argument
        # shift # and value so we can continue with the next
        ;;
    esac
done

# Define function to deploy on heroku
up_to_heroku() {
    heroku ps:scale $APP_TYPE=$STATUS --remote $GIT_HEROKU_REMOTE
}

# BACKEND was set?
if [[ "$BACKEND" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying backend\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # define vars
    APP_NAME=backend-django-task-queues
    APP_TYPE=web
    GIT_HEROKU_REMOTE=backend-django-task-queues
    REMOTE_BRANCH=main
    SUBFOLDER=backend
    # push changes
    up_to_heroku
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying workers\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # define vars
    APP_NAME=background-worker-julia-docker
    APP_TYPE=worker
    GIT_HEROKU_REMOTE=background-worker-julia-docker
    REMOTE_BRANCH=main
    SUBFOLDER=results/Worker
    # push changes
    up_to_heroku
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying sink\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # define vars
    APP_NAME=background-sink-julia-docker
    APP_TYPE=worker
    GIT_HEROKU_REMOTE=background-sink-julia-docker
    REMOTE_BRANCH=master
    SUBFOLDER=results/Sink
    # push changes
    up_to_heroku
fi
