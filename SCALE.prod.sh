#!/bin/bash

source ./deploy/utils.sh

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

# Parse input variables from the ENV files
eval $(parse_yaml ./deploy/ENV.deploy.yml)

# BACKEND was set?
if [[ "$BACKEND" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying backend\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    up_to_heroku $backend_APP_TYPE $STATUS $backend_GIT_HEROKU_REMOTE
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying workers\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    up_to_heroku $workers_APP_TYPE $STATUS $workers_GIT_HEROKU_REMOTE
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying sink\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    up_to_heroku $sink_APP_TYPE $STATUS $sink_GIT_HEROKU_REMOTE
fi
