#!/bin/bash

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

# Define function to deploy on heroku
push_to_heroku() {
    git push $GIT_HEROKU_REMOTE $(git subtree split --prefix $SUBFOLDER main):$REMOTE_BRANCH
}

# FRONTEND was set?
if [[ "$FRONTEND" = true ]]; then
    printf "\n\n"
    printf "${BLUE}##################\n"
    printf "Deploying frontend\n"
    printf "##################${NC}\n"
    printf "\n\n"
    #define vars
    SUBFOLDER=frontend
    # deploy
    cd $SUBFOLDER
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
    # define vars
    APP_NAME=backend-django-task-queues
    APP_TYPE=web
    GIT_HEROKU_REMOTE=backend-django-task-queues
    REMOTE_BRANCH=main
    SUBFOLDER=backend
    # push changes
    push_to_heroku
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
    push_to_heroku
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
    push_to_heroku
fi
