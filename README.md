[![shellcheck](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/UCSF-CBI/rstudio-server-controller/actions/workflows/shellcheck.yml)

# RStudio Server Controller (RSC)

This is a tool for launching a personal instance of the RStudio Server on a Linux machine, which then can be access via the web browser, either directly or via SSH tunneling.


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


To check if the RStudio Server is running, use:

```sh
$ rsc status
```

This will also list if there is an active R session running within the RStudio Server.

To stop any running RStudio Server and any R session, use:

```sh
$ rsc stop
```
