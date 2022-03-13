[![shellcheck](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml)

# RStudio Server Controller (RSC)

This is a shell tool for conveniently launching a personal instance of
the [RStudio Server] on a Linux machine, which then can be access in the
local web browser, either locally, or remotely via SSH tunneling.
RStudio is an integrated development environment (IDE) for [R].


## Features

### User experience

* It is easy to start and stop the RStudio Server, e.g. `rsc start`
  and `rsc stop`

* Any user can run it, i.e. it requires no special privileges

* It gives cut'n'paste instructions on how to access a remote RStudio
  Server instance via SSH tunneling through a login host

* It is possible to expose the RStudio Server port on a remote machine
  via reverse SSH tunneling,
  e.g. `--revtunnel=<user>@<remote-hostname>:<remote-port>`

* It provides convenient alternatives for setting the port where
  RStudio Server is hosted, e.g. `--port=<fix-port>`, `--port=uid`
  (default), and `--port=random --port-seed="$(id -u)"`

* R sessions can inherit the environment variables from the shell
  launching the RStudio Server, e.g. all variables by
  `--env-pattern="^.*$"` (default), or a subset as
  `--env-pattern="^(R_.*|SLURM_.*)$"`

### Authentication

* There are multiple options for how the RStudio Server login is
  authenticated. The default,
  [`--auth=auth-via-su`](https://github.com/UCSF-CBI/rstudio-server-controller/blob/main/bin/utils/auth-via-su),
  relies on `su` to authenticate using the system's authentication
  method. An alternative to this, is
  [`--auth=auth-via-ssh:<hostname>`](https://github.com/UCSF-CBI/rstudio-server-controller/blob/main/bin/utils/auth-via-ssh),
  which authenticates using SSH towards host `<hostname>`. If neither
  are an option, [`--auth=auth-via-env
  --random-password`](https://github.com/UCSF-CBI/rstudio-server-controller/blob/main/bin/utils/auth-via-env)
  can be used to authenticate with a one-time, temporary password
  that is echoed. It is also possible to use a custom authentication
  helper, e.g. `--auth=<command-on-PATH>` and `--auth=<file>`


### Stability

* A user can run at most one RStudio Server instance on a multi-host
  system, which minimized the number of stray instances being left
  behind

* The RStudio Server will time out ten minutes after the most recent
  R session was terminated. This prevents stray RStudio Server processes
  being left behind
  
* The default timeout for an idle R session is two hours

* The tool attempts to be agile to different POSIX signals to shut
  down everything when the RStudio Server instance is terminated,
  e.g. by `SIGINT` from <kbd>Ctrl-C</kbd>, `SIGQUIT` from <kbd>Ctrl-\\</kbd>,
  or a `SIGUSR2` notification signal by a job scheduler


## Running RStudio Server locally

To launch your personal RStudio Server instance, call:

```sh
$ rsc start
alice, your personal RStudio Server is available on <http://127.0.0.1:51172> from this
machine (alice-notebook).
Any R session started times out after being idle for 120 minutes.
WARNING: You now have 10 minutes, until 2022-03-11 13:30:33-08:00, to connect and log
in to the RStudio Server before everything times out.
```

The RStudio Server can then be accessed via the web browser at
<http://127.0.0.1:51172>.  The exact port number will by default be
unique to each user based on the user's `UID`.  If the default port is
occupied, another random port that is likely to be unique to the user
is tested, and so, until a free port is found.

The `rsc start` command will run until terminated,
e.g. <kbd>Ctrl-C</kbd>:

```sh
 $ rsc start
alice, your personal RStudio Server is available on <http://127.0.0.1:51172> from this
machine (alice-notebook).
Any R session started times out after being idle for 120 minutes.
WARNING: You now have 10 minutes, until 2022-03-11 13:30:33-08:00, to connect and log
in to the RStudio Server before everything times out.
^C
Received a SIGINT signal
Shutting down RStudio Server ...
Shutting down RStudio Server ... done
```

Alternatively, the RStudio Server instance can be terminated by calling:

```sh
$ rsc stop
RStudio Server stopped
```

which sends a `SIGTERM` signal to shut it down nicely.  If this command is
not called from the same machine as from where `rsc start` was called, then
it will attempt to SSH to that machine to terminate the RStudio Server.

A user can only launch one instance.  Attempts to start more, will
produce an informative error message, e.g.

```sh
$ rsc start
ERROR: alice, another RStudio Server session of yours is already running on
alice-notebook on this system. See 'rsc status' for details. Please terminate
that first, e.g. call 'rsc stop' from that machine. As a last resort, call
'pkill rserver; pkill rsession', remove lock file '/home/alice/.config/rsc/
pid.lock', and retry.
```

This limit applies across all machines on the same file system, which
helps keep multi-tenant high-performance compute (HPC) environments
tidy.

To check if another RStudio Server instance is already running, use:

```sh
$ rsc status
rserver: running (pid 29062) on current machine (alice-notebook)
listening on port 51172
rsession: not running
rserver monitor: running (pid 29101) on machine (alice-notebook)
lock file: exists (/home/alice/.config/rsc/pid.lock)
```


## Running RStudio Server remotely

### Scenario 1: Direct access to remote machine

Assume you have a remote server that you connect to via SSH as:

```sh
[ab@local ~]$ ssh -l alice server.myuniv.org
[alice@server ~]$
```

If we launch `rsc` on the remote server, we will get:

```sh
[alice@server ~]$ rsc start
alice, your personal RStudio Server is available on <http://server.myuniv.org:51172>.
If you are running from a remote machine without direct access to server.myuniv.org, you
can use SSH port forwarding to access the RStudio Server at <http://127.0.0.1:8787> by
running 'ssh -L 8787:server.myuniv.org:51172 alice@server.myuniv.org' in a second terminal.
Any R session started times out after being idle for 120 minutes.
WARNING: You now have 10 minutes, until 2022-03-11 13:30:33-08:00, to connect and log
in to the RStudio Server before everything times out.
```

If we follow these instructions set up a _second_, _concurrent_ SSH connection to the remote server:

```sh
[ab@local ~]$ ssh -L 8787:server.myuniv.org:51172 alice@server.myuniv.org
[alice@server ~]$
```

we will be able to access the RStudio Server at <http://127.0.0.1:8787> on our local machine.  This works because port 8787 on our local machine is forwarded to port 51172 on the remote server, which is where the RStudio Server is served.


### Scenario 2: Indirect access to remote machine via a login host

Assume you can only access the remote server via a dedicated login host:

```sh
[ab@local ~]$ ssh -l alice login.myuniv.org
[alice@login ~]$ ssh -l alice server.myuniv.org
[alice@server ~]$
```

If we launch `rsc` on the remote server, we will get very similar instructions:

```sh
[alice@server ~]$ rsc start
alice, your personal RStudio Server is available on <http://server.myuniv.org:51172>.
If you are running from a remote machine without direct access to server.myuniv.org, you
can use SSH port forwarding to access the RStudio Server at <http://127.0.0.1:8787> by
running 'ssh -L 8787:server.myuniv.org:51172 alice@login.myuniv.org' in a second terminal.
Any R session started times out after being idle for 120 minutes.
WARNING: You now have 10 minutes, until 2022-03-11 13:30:33-08:00, to connect and log
in to the RStudio Server before everything times out.
```

In this case, we do:

```sh
[ab@local ~]$ ssh -L 8787:server.myuniv.org:51172 alice@login.myuniv.org
[alice@login ~]$
```

After this, the RStudio Server is available at <http://127.0.0.1:8787> on our local machine.  This works because port 8787 on our local machine is forwarded to port 51172 on the remote server, which is where the RStudio Server is served, via the login host.


### Can we achieve the same with a single SSH connection?

Note that, the reason why we have to use two concurrent SSH connections, is that we cannot know what ports are available when we connect the first time to launch the RStudio Server.  If we could know that, or if we would take a chance that it's available to use, we could do everything with one connections.  For example, we have used port 51172 several times before, so we will try that this time too:

```sh
[ab@local ~]$ ssh -L 8787:server.myuniv.org:51172 alice@login.myuniv.org
[alice@login ~]$ ssh -l alice server.myuniv.org
[alice@server ~]$ rsc start --port=51172
alice, your personal RStudio Server is available on <http://server.myuniv.org:51172>.
If you are running from a remote machine without direct access to server.myuniv.org, you
can use SSH port forwarding to access the RStudio Server at <http://127.0.0.1:8787> by
running 'ssh -L 8787:server.myuniv.org:51172 alice@login.myuniv.org' in a second terminal.
Any R session started times out after being idle for 120 minutes.
WARNING: You now have 10 minutes, until 2022-03-11 13:30:33-08:00, to connect and log
in to the RStudio Server before everything times out.
```

As before, the RStudio Server is available at <http://127.0.0.1:8787>.


### Scenario 3: Remote machine with direct access to our local machine

Assume you can SSH to the remote server, directly or via a login host, and that the remote server can access your local machine directly via SSH.  This is an unusual setup, but it might be the case when your local machine is connected to the same network as the server, e.g. a desktop and compute cluster at work.  In this case, we can ask `rsc` to set up a _reverse_ SSH tunnel to our local machine at the same time it launches the RStudio Server;

```sh
[ab@local ~]$ ssh -l alice server.myuniv.org
[alice@server ~]$ rsc start --revtunnel=ab@local.myuniv.org:8787
alice, your personal RStudio Server is available on <http://local.myuniv.org:8787>.
```

As before, the RStudio Server is available at <http://127.0.0.1:8787>.


## Requirements

* Linux

* Bash

* R (<https://www.r-project.org>)

* RStudio Server (<https://www.rstudio.com/products/rstudio/#rstudio-server>)

* Python (<https://www.python.org/>) - used for generating random ports and to validate port is available

* `expect` (<https://core.tcl-lang.org/expect/index>) - needed by the `auth-via-ssh` method, and, depending on system and `su` implementation, also by `auth-via-su`


## Installation

```sh
$ cd /path/to/software
$ curl -L -O https://github.com/UCSF-CBI/rstudio-server-controller/archive/refs/tags/0.8.2.tar.gz
$ tar xf 0.8.2.tar.gz
$ PATH=/path/to/softwarerstudio-server-controller-0.8.2/bin:$PATH
$ export PATH
$ rsc --version
0.8.2
```

[R]: https://www.r-project.org/
[RStudio Server]: https://www.rstudio.com/products/rstudio/#rstudio-server
