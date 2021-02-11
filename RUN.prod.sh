#!/bin/bash

source ./deploy/utils.sh

# COLORS
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PARSE INPUT ARGUMENTS

# WORKERS=1 # set a default
FRONTEND=false
BACKEND=false
WORKERS=false
SINK=false

while [[ $# -gt 0 ]]; do
    key="$1"
    # printf "Got : $key"
    case "${key,,}" in
    frontend)
        # WORKERS="$2"
        FRONTEND=true
        # printf "set FRONTEND: $FRONTEND"
        shift # past argument
        # shift # past value
        ;;
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

# FRONTEND was set?
if [[ "$FRONTEND" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying frontend\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # deploy
    cd $frontend_SUBFOLDER
    npm run deploy
    cd ..
fi

# BACKEND was set?
if [[ "$BACKEND" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying backend\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    push_to_heroku $backend_GIT_HEROKU_REMOTE $backend_SUBFOLDER $backend_REMOTE_BRANCH
fi

# WORKERS was set?
if [[ "$WORKERS" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying workers\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    push_to_heroku $workers_GIT_HEROKU_REMOTE $workers_SUBFOLDER $workers_REMOTE_BRANCH
fi

# SINK was set?
if [[ "$SINK" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying sink\n"
    printf "##################${NC}\n"
    printf "\n\n"
    # push changes
    push_to_heroku $sink_GIT_HEROKU_REMOTE $sink_SUBFOLDER $sink_REMOTE_BRANCH
fi
