# Deploy subfolders 

## Using Script

```sh
./RUN.prod.sh [frontend] [backend] [workers] [sink]
```

when `[]` means optional. That is, to deploy only the frontend


```sh
./RUN.prod.sh frontend
```

and the keywords can be written in camel case or make a mix `FRONTEND` or `FrOnTeNd`.

## Frontend

```sh
cd frontend
npm run deploy
```

## Backend

Deploy the django backend

APP_NAME = backend-django-task-queues
APP_TYPE = web
GIT_HEROKU_REMOTE = backend-django-task-queues
REMOTE_BRANCH = main
SUBFOLDER = backend


```sh
git push backend-django-task-queues `git subtree split --prefix backend main`:main --force
```

## Worker

Deploy the worker

APP_NAME = background-worker-julia-docker
APP_TYPE = worker
GIT_HEROKU_REMOTE = background-worker-julia-docker
REMOTE_BRANCH = main
SUBFOLDER = results/Worker

```sh
git push background-worker-julia-docker `git subtree split --prefix results/Worker main`:main --force
```

## Sink

Deploy the sink

APP_NAME = background-sink-julia-docker
APP_TYPE = worker
GIT_HEROKU_REMOTE = background-sink-julia-docker
REMOTE_BRANCH = master
SUBFOLDER = results/Sink

```sh
git push background-sink-julia-docker `git subtree split --prefix results/Sink main`:master --force
```

## More generally

given APP_NAME, APP_TYPE, GIT_HEROKU_REMOTE, REMOTE_BRANCH and SUBFOLDER

> we deploy from main branch.

```sh
git push GIT_HEROKU_REMOTE `git subtree split --prefix SUBFOLDER main`:REMOTE_BRANCH --force
```
start the apps by

```sh
heroku ps:scale APP_TYPE=1 --app APP_NAME 
```
or
```sh
heroku ps:scale APP_TYPE=1 --remote GIT_HEROKU_REMOTE 
```
