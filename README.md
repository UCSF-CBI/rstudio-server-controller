[![shellcheck](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml)

# RStudio Server Controller (RSC)

This is a shell tool for conveniently launching a personal instance of the RStudio Server on a Linux machine, which then can be access via the web browser, either directly or via SSH tunneling.


## Features

* It is easy to start and stop the RStudio Server, e.g. `rsc start` and `rsc stop`

* RStudio Server login is validated using the system's authentication method, i.e. no need for random, one-time passwords

* Any user can run it, i.e. it requires no special privileges

* It gives cut'n'paste instructions on how to access a remote RStudio Server instance via SSH tunneling through a login host

* A user can run at most one RStudio Server instance on a multi-host system, which minimized the number of stray instances being left behind

* It provides convenient alternative for setting the port where RStudio Server is hosted, e.g. `--port=uid` and `--port=random --port-seed="$(id -u)"`

* R sessions can inherit the environment variables from the shell launching the RStudio Server, e.g. `--env=all`

* The default timeout for an idle R session is two hours. When running via a job scheduler, this timeout is the same as the maximum runtime of the job. Currently, only Slurm is recognize


The user authentication is done by providing the RStudio Server a special [`auth-via-su`](bin/utils/auto-via-su) script, which uses `su` to validate the username and password.


## Instruction

To launch your personal RStudio Server instance, call:

```sh
$ rsc start
```

The RStudio Server can then be accessed via the web browser at <http://127.0.0.1:8787>.

The `rsc` command will run until terminated, e.g. Ctrl-C.  A user can only launch one instance.  Attempts to start more, will produce an informative error message.  This limit applies across all machines on the same file system.

To start the RStudio Server on another port than the default 8787, specify option `--port`, e.g.

```sh
$ rsc start --port=9000
```

To use a random, available port, use:

```sh
$ rsc start --port=random
```

On multi-tenant system, we recommend:

```sh
$ rsc start --port=uid
```

which draws a random port likely to be unique to each user and stable over time.


To check if the RStudio Server is running, use:

```sh
$ rsc status
```

This will also list if there is an active R session running within the RStudio Server.

To stop any running RStudio Server and any R session, use:

```sh
$ rsc stop
```


## Requirements

* Linux

* Bash

* `expect`, if `su` does not support password via the standard input (<https://www.nist.gov/services-resources/software/expect>)

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

