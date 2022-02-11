[![shellcheck](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml)

# RStudio Server Controller (RSC)

This is a shell tool for conveniently launching a personal instance of
the RStudio Server on a Linux machine, which then can be access in the
local web browser, either locally, or remotely via SSH tunneling.


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
  which authenticates using SSH towards host <hostname>. If neither
  are an option, [`--auth=auth-via-env
  --random-password`](https://github.com/UCSF-CBI/rstudio-server-controller/blob/main/bin/utils/auth-via-env)
  can be used to authenticate with a one-time, temporary password
  that is echoed. It is also possible to use a custom authentication
  helper, e.g. `--auth=<command-on-PATH>` and `--auth=<file>`.


### Stability

* A user can run at most one RStudio Server instance on a multi-host
  system, which minimized the number of stray instances being left
  behind

* The default timeout for an idle R session is two hours. When running
  via a job scheduler, this timeout is the same as the maximum runtime
  of the job. Currently, only Slurm is recognize

* The tool attempts to be agile to different POSIX signals to shut
  down everything when the RStudio Server instance is terminated,
  e.g. by `SIGINT` from <kbd>Ctrl-C</kbd>, or a `SIGUSR2` notification
  signal by a job scheduler


## Instruction

To launch your personal RStudio Server instance, call:

```sh
$ rsc start
alice, your personal RStudio Server is available on <http://127.0.0.1:51172> from
this machine (alice-notebook).
Any R session started times out after being idle for 120 minutes.

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
alice, your personal RStudio Server is available on <http://127.0.0.1:51172> from
Any R session started times out after being idle for 120 minutes.
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

from the same machine, which sends a `SIGTERM` signal to shut it down nicely.

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
lock file: exists (/home/alice/.config/rsc/pid.lock)
```


## Requirements

* Linux

* Bash

* `expect` (<https://core.tcl-lang.org/expect/index>) - needed by the `auth-via-ssh` method, and depending system and `su` implementation, also by `auth-via-su`

* R (<https://www.r-project.org>)

* RStudio Server (<https://www.rstudio.com/products/rstudio/#rstudio-server>)

* Python (<https://www.python.org/>) - used for generating random ports and to validate port is available


## Installation

```sh
$ cd /path/to/software
$ curl -L -O https://github.com/UCSF-CBI/rstudio-server-controller/archive/refs/tags/0.5.0.tar.gz
$ tar xf 0.5.0.tar.gz
$ PATH=/path/to/softwarerstudio-server-controller-0.5.0/bin:$PATH
$ export PATH
$ rsc --version
0.5.0
```

