# Deploy services 

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

> The following parameters are read from the file `deploy/ENV.deploy.yml`
```
SUBFOLDER = frontend
```

```sh
cd frontend
npm run deploy
```

## Backend

Deploy the django backend

```
APP_NAME = backend-django-task-queues
APP_TYPE = web
GIT_HEROKU_REMOTE = backend-django-task-queues
REMOTE_BRANCH = main
SUBFOLDER = backend
```

```sh
git push backend-django-task-queues `git subtree split --prefix backend main`:main --force
```

## Worker

Deploy the worker

```
APP_NAME = background-worker-julia-docker
APP_TYPE = worker
GIT_HEROKU_REMOTE = background-worker-julia-docker
REMOTE_BRANCH = main
SUBFOLDER = results/Worker
```

```sh
git push background-worker-julia-docker `git subtree split --prefix results/Worker main`:main --force
```

## Sink

Deploy the sink

```
APP_NAME = background-sink-julia-docker
APP_TYPE = worker
GIT_HEROKU_REMOTE = background-sink-julia-docker
REMOTE_BRANCH = master
SUBFOLDER = results/Sink
```

```sh
git push background-sink-julia-docker `git subtree split --prefix results/Sink main`:master --force
```

## More generally

given `APP_NAME`, `APP_TYPE`, `GIT_HEROKU_REMOTE`, `REMOTE_BRANCH` and `SUBFOLDER`

> we deploy from main branch.

```sh
git push GIT_HEROKU_REMOTE `git subtree split --prefix SUBFOLDER main`:REMOTE_BRANCH --force
```

# Scale services

Start the apps by

```sh
heroku ps:scale APP_TYPE=1 --app APP_NAME 
```

or

```sh
heroku ps:scale APP_TYPE=1 --remote GIT_HEROKU_REMOTE 
```

We can also use the provided script

```sh
./SCALE.prod.sh [UP|DOWN] [backend] [workers] [sink]
```

For example to set online a worker

```sh
./SCALE.prod.sh UP workers
```

# Get Logs from services

Log the apps by

```sh
heroku logs --tail --app APP_NAME 
```

or

```sh
heroku logs --tail --remote GIT_HEROKU_REMOTE 
```

We can also use the provided script

```sh
./LOGS.prod.sh [backend] [workers] [sink]
```

For example to get the logs from the worker

```sh
./LOGS.prod.sh workers
```

> Each opened service will instantiate a new shell tab.
