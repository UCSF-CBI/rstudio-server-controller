# rstudio-server-launcher

## Version 0.3.0-9001

New features:

* Now `rsc` respects environment variable `XDG_CONFIG_HOME`.  If not set,
  the default is `$HOME/.config`.


## Version 0.3.0

Significant changes:

* Add option `--env=<spec>`.  If `--env=all`, then the R session, and any
  terminal opened in RStudio, inherits all environment variables that were
  exported in the shell where `rsc start` was called.  If `--env=none`,
  then only environment variables predefined by the RStudio Server are set.
  
Bug fixes:

* `rsc` would incorrectly remove the lock file when the RStudio Server
  was running on another machine on the same system.

* `rsc status` reported that 'rserver' and 'rsession' were not running
  when called on another machine than where they are running.


## Version 0.2.4

New features:

* Add support for `--port-seed=<seed>`, which sets the random seed used
  when finding a free, random port (`--port=random`).

* Add support for `--port=uid`, which is short for `--port-seed=$(id -u)`
  and `--port=random`.  This makes the sequence of random ports tests
  deterministic and unique to the current user.  This strategy increases
  the chance for a user to get the same port in subsequent calls.

* Add support for `--dryrun`, which does everything but launching the
  RStudio Server.  This is useful for troubleshooting and development.

* Now `rsc` removes stray PID and lock files, if it can be concluded
  that they are stray files.
  

## Version 0.2.3

New features:

* `rsc start` now ignores a stray lock file if there is no other
  evidence that an RStudio Server instance is running.

* `rsc start` now detect when RStudio Server fails to launch and
  gives an informative error message.

* `rsc start` now asserts that the port is available before trying
  to launch the RStudio Server.


## Version 0.2.2

New features:

* `rsc start` instructions include information on `$USER`.

* `rsc status` report on the lock file too.

* `rsc status` now reports on "unknown" statuses if the RStudio
  Server is running on another machine.

Bug fixes:

* `rsc start` failed to shut down nicely when receiving SIGTERM,
  resulting in R sessions and lock files being left behind.

* `src stop` would fail on machines where environment `HOSTNAME`
  is not correct. Now relying on `hostname` instead.


## Version 0.2.1

New features:

* If `rsc start` fails because there's already an existing RStudio
  Server running, the error message now includes on what machine
  that instance is running.

Bug fixes:

* Internal validation of `auth-via-su` could output messages to
  standard error. Those are now muffled.


## Version 0.2.0

New features:

* Now `rsc start` only gives instructions how to access the RStudio
  Server instance from a remote machine, when connected from one.

* Now the `rsc start` instructions on how to connect from a remote
  machine infers the login hostname from the current connection
  by querying `who` and `host`.

* When running the RStudio Server via an interactive job, then the
  R session timeout limit is inferred from maximum run-time as given
  by the job scheduler. If this cannot be inferred, the timeout
  limit defaults to 120 minutes.

Bug fixes:

* `rsc stop` called from another machine on the same system would
  silently remove the internal lock file used to prevent more than
  one RStudio Server instance from running.  Now an informative
  error message is produced informing on what machine the server
  is running and need to be stopped from.


## Version 0.1.2

New features:

* Now the `auth-via-su` script is distributed part of this software.

Bug fixes:

* Environment variable R_LIBS_USER was ignore.


## Version 0.1.1

Significant changes:

* `rsc` no longer loads Linux environment modules.  Instead, the user is
  responsible for making sure R and RStudio Server executables are on the
  `PATH`.  This gives the user maximum flexibility in what R version to
  run.  The `rsc` tool will produce informative error messages if these
  executables are not found.

New features:

* Add `rsc config --full`.

* Add `rsc log`.

* Now `rsc start` will make sure to terminate the RStudio Server instance
  and any running R sessions when exiting.
  

## Version 0.1.0

New features:

* Add `freeport` to find a free TCP port.

* Add `launch_rstudio_server`, which launches the RStudio Server on the current
  machine at a random port.  The server and any running R session it launched
  will be terminated when `launch_rstudio_server` terminates, e.g. from Ctrl-C.


