# rstudio-server-launcher

## Version 0.6.1-9003

* Now `rsc --version --full` report on the version for `rsc`, RStudio
  Server, and R.

* `rsc` now respected environment variable `NO_COLOR`. Set it to any
  non-empty value to disable colored output.

* Added more protection for launching multiple RStudio Server
  instances. Now `rsc start` asserts there are no stray `rsc` launched
  `rserver` processes still running even if it has already validated
  that there are no lock and PID files.
  
Bug fixes:

* In the rare case that `rsc start` found a free random port that
  immediately after was found to be occupied, it would output the an
  obscure `ERROR: Not an integer: ERROR: [INTERNAL]: Identified port
  is not free: 4321` message. Now it reports `ERROR: Identified a free
  port, which now appears to be occupied: 4321`.


## Version 0.6.1

Miscellaneous:

* `rsc start` would output "rsc: line 825: kill: (30801) - No such process"
  when terminated via SIGINT (e.g. Ctrl-C).

Bug fixes:

* `rsc stop` did not stop the SSH reverse-tunnel connection, if called, which
  prevented the `rsc start --revtunnel=<host>:<port>` call from terminating.


## Version 0.6.0

Security fix:

* The `$HOME/.config/rsc/var/run/rstudio-server/` folder and its subfolder
  `rstudio-rsession` folder were writable by anyone on the system (777 in
  Unix terms). The `rserver` process sets these file permissions by design,
  because these folders are meant to be used by different users on the
  system. This would not have been a problem if the `$HOME/.config/rsc/`
  folder would be fully private to the user (700 in Unix terms), but due to
  a thinko, that folder was accessible and readable by anyone.  Combined,
  this could lead to anyone on the system being able to write to the above
  folders. We now make sure `$HOME/.config/rsc/` is fully private. Also,
  since `rsc` is only used to launch a personal RStudio Server instance,
  we recursively set all of its files and folders private too (700).

New features:

* Using `rsc status --no-ssh` will skip attempts to SSH into another
  machine to check if the rserver is running there.

* Now `rsc reset --force` warns if critical rsc-related files exists, and
  which they are, otherwise the cleanup is silent.

Prototype:

* Add `freeport`.

Bug fixes:

* `rsc` failed if called via a symbolic link.


## Version 0.5.0

Significant changes:

* `--port=uid` is the new default.

New features:

* Add option `--quiet` to silence the instructions.

* Now `rsc start` outputs a message when it shuts down the RStudio Server.

* Now `rsc start` shuts down nicely when it receives a SIGCONT, SIGTERM,
  SIGUSR2, or SIGINT (e.g. Ctrl-C) signal.

* Add built-in 'auth-via-ssh' authenatication tool that use SSH toward a
  hostname to validate the password, e.g. `--auth=auth-via-ssh:log2`.

* Now `rsc start --auth=<spec>` gives an informative error message if
  the `<spec>` is incomplete, e.g. when the 'expect' tool is missing.

* Add `--random-password`, which sets `RSC_PASSWORD` randomly and echoes it.
  This can be used in combination with `--auth=auth-via-env`.

Alpha testing:

* Add `rsc start --revtunnel=<spec>`.


## Version 0.4.0

New features:

* Add support to specify an alternative authentication method for the
  RStudio Server login, e.g. `rsc start --auth=<file>`, where `<file>` can
  be the path to an executable, or one of the built-in ones, which are
  'auth-via-su' (default) and 'auto-via-env'.

* `rsc status --field=hostname` and `rsc status --field=port` report on the
  hostname and the port of the running RStudio Server.

* `rsc status --force --field=...` skips any attempts to check and clean up
  stray files.

* `rsc status` now reports also on the RStudio Server's listening port.

* Now `rsc` tries extra hard to infer the hostname, which is done by first
  querying `$HOSTNAME` and `hostname` as a fallback. If neither works, then
  an informative error is produced.

* Now `rsc reset --force` produces an informative warning.

* Added `rsc wait`, which waits until `rsc start &` is fully running.

Bug fixes:

* `rsc start` no longer uses `mktemp` in case that fails, which, by the way,
  is extremely rare and a problem with the system setup.


## Version 0.3.4

New features:

* Add option `--env-pattern=<regular expression>`.

Deprecated and defunct:

* Remove option `--env` in favor of `--env-pattern`.


## Version 0.3.3

Bug fixes:

* Internal `check_pid()` could give incorrect results when checking
  a process PID on another machine.


## Version 0.3.2

Bug fixes:

* `rsc start` failed to remove stray lockfile, even when it was known
  that there were no 'rserver' and 'rsession' processes running.


## Version 0.3.1

New features:

* Now `rsc` can check process PIDs on another machine as well, which
  requires SSH access to that other machine.

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
