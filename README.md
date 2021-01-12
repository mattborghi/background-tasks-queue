Idea of the stack

The frontend (React.js) will generate a request to the backend. The backend (django) will respond with a RUNNING/ERROR message and

1. Start a task scheduler to run (Julia) the desired task.

2. Given that task id start a subscription connection with the client and wait for the result.

![imag](https://zguide.zeromq.org/images/fig5.png)

# Instructions 

```sh
./RUN.sh [--workers|-w N]
```

where `N` is the number of workers we want to deploy. Default: `N = 1`.