# Task Queues

![imag](./assets/preview.png)

**Figure 1**. Preview image of frontend implementation.

## General idea

The frontend ([`React.js`](reactjs.org)) will generate a request (through [`GraphQL`](https://graphql.org/) endpoints) to the backend in order to create new tasks. The backend (`Django`) will respond with a task item scheduled for running which is seen in the table with a `QUEUEING` status. 

![imag](./assets/stack.png)

**Figure 2**. General idea of the stack implemented.

[`ZMQ`](https://zeromq.org/) now handles the distribution of one or several tasks (which may be created by one or several users) using the `Ventilator` design pattern shown below. The ventilator is the Django backend whom creates the tasks and `PUSH` them to the `Julia` workers. When a certain task is set to run its status changes to `RUNNING`. Right now two things can happen:

- The task fails with `FAILED` status. Currently in this project we make 40% of the tasks to fail just for illustration.

- The task completes with `FINISHED` status. In this case the result is pushed to a `Sink`. This sink in the future might preserve the results in a separate database. Later, the sink mutates the backend status with the calculated value.

![imag](https://zguide.zeromq.org/images/fig5.png)

**Figure 3**. Ventilator pattern used in the project to queue tasks.

Finally, a long polling connection between the frontend and the backend is made so the results are updated in a table.

Below, there is a small video showcasing the project capabilities.

[![Video Preview](./assets/preview_video.png)](https://youtu.be/iDR7H2wmgDc)

# Instructions 

## Installation

1. Install julia dependencies from `Worker` and `Sink`

```sh
cd results/Worker
julia
PRESS ']' KEY
activate .
instantiate
```

and repeat the process inside the `Sink` folder.

2. Install `Proxy` dependencies

```sh
cd results/Proxy
pipenv shell
pipenv install
```

3. Install `frontend` dependencies

```sh
cd frontend
npm run install
```

4. Install `backend` dependencies

```sh
cd backend
pipenv shell
pipenv install
````

## Running 

Running all the stack is simple by using the provided script

```sh
./RUN.sh [--workers|-w N]
```

where `N` is the number of workers we want to deploy. Default: `N = 1`.