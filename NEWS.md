# rstudio-server-controller

## Version 0.9.1 [2022-06-27]

### Bug Fixes

 * If `rsc stop` could fail to terminate some processes,
   e.g. `rserver` or `rsession`.  Now it attempts multiple times
   before giving up with an informative warning.  It attempts four
   times with TERM signals with three seconds in-between.  If those
   fail, it tries one last time with the stronger KILL signal.


## Version 0.9.0 [2022-06-09]

### New features

 * When using `rsc start --auth=auth-via-env --random-password`, the
   password is now display at the very end, instead of at the
   beginning.

 * `rsc start` now highlights URLs and temporary passwords in output,
   if the terminal supports it.

 * `rsc status --full` will show information how to reconnect to an
   already running RStudio Server instance.

 * The error message produced by `rsc start` when an instance is
   already running now suggests calling `rsc status --full` for
   instructions on how to reconnect.

### Bug fixes

 * `rsc start` and `rsc status` could report on the incorrect hostname
   of the machine where the RStudio Server instance is running,
   e.g. when launched via an interactive Slurm job.


## Version 0.8.4 [2022-04-20]

### New features

* The warning and error messages on stray 'rserver' processes will now
  include instructions on how to terminate such processes.


## Version 0.8.3 [2022-04-03]

### Significant changes

* For security reasons, environment variable `RSC_PASSWORD` is never
  exported to any of the R sessions running via the RStudio Server.
  Likewise, it is never written to the config files or any temporary
  file.

### New features

* Environment variable `RSC_PASSWORD=random` now corresponds to
  specifying command-line option `--random-password`.
  

## Version 0.8.2 [2022-03-13]

### New features

* Now `rsc status` reports also on the optional SSH reverse tunnel.

* The `rsc start` message now not only specifies for how long, but
  also until what time the user has to connect and log into to the
  RStudio Server before everything times out.

### Bug fixes

* When using `rsc start --revtunnel=<spec>`, the startup message did
  not including messages about timeout limits.


## Version 0.8.1 [2022-03-07]

### New features

* The `rsc startup` startup message now includes "WARNING: You now
  have 10 minutes to connect to the RStudio Server and start the R
  session before everything times out".

* Increased the RStudio Server timeout to 10 minutes.

* Now timeout warnings reports also on the time point when the timeout
  shutdown will take place.

### Bug fixes

* The RStudio Server timeout did not apply if the user never logged.


## Version 0.8.0 [2022-03-07]

### Significant changes

* The RStudio Server will automatically terminate 5 minutes after the
  most recent R session was terminated. An R session may be terminated
  either by the user (e.g. calling `quit()` in R), or from timing out
  because it has been idle for more than two hours.  In other words,
  the default behavior is to automatically shut down everything after
  the user having been idle for more than 125 minutes.

* The timeout limit of an R session is now two hours regardless of how
  the RStudio Server is running. Previously, this timeout limit would
  be overridden by the maximum runtime of the job scheduler, but in
  order to avoid jobs running idle for a long time, locking up slots
  of the scheduler, we choose to time out everything regardless of
  requested run time.
  

## Version 0.7.0 [2022-03-02]

### New features

* Now `rsc --version --full` report on the version for `rsc`, RStudio
  Server, and R.

* `rsc` now respected environment variable `NO_COLOR`. Set it to any
  non-empty value to disable colored output.

* `rsc status` will now warn against stray `rserver` processes that
  are running despite no existing lock and PID files.

### Bug fixes

* In rare cases there can be stray `rserver` processes running that
  where launched by `rsc start`. Investigation showed that the PID
  files for such processes do not exist, e.g. `rsc status` would
  report that nothing was running. Now `rsc start` checks for such
  stray processes before attempting to start another RStudio Server
  instance and gives an informative error message if detected.
  
* In the rare case that `rsc start` found a free random port that
  immediately after was found to be occupied, it would output the an
  obscure `ERROR: Not an integer: ERROR: [INTERNAL]: Identified port
  is not free: 4321` message. Now it reports `ERROR: Identified a free
  port, which now appears to be occupied: 4321`.


## Version 0.6.1 [2022-02-20]

### Miscellaneous

* `rsc start` would output "rsc: line 825: kill: (30801) - No such
  process" when terminated via SIGINT (e.g. Ctrl-C).

### Bug fixes

* `rsc stop` did not stop the SSH reverse-tunnel connection, if
  called, which prevented the `rsc start --revtunnel=<host>:<port>`
  call from terminating.


## Version 0.6.0 [2022-02-13]

### Security fix

* The `$HOME/.config/rsc/var/run/rstudio-server/` folder and its
  subfolder `rstudio-rsession` folder were writable by anyone on the
  system (777 in Unix terms). The `rserver` process sets these file
  permissions by design, because these folders are meant to be used by
  different users on the system. This would not have been a problem if
  the `$HOME/.config/rsc/` folder would be fully private to the user
  (700 in Unix terms), but due to a thinko, that folder was accessible
  and readable by anyone. Combined, this could lead to anyone on the
  system being able to write to the above folders. We now make sure
  `$HOME/.config/rsc/` is fully private. Also, since `rsc` is only
  used to launch a personal RStudio Server instance, we recursively
  set all of its files and folders private too (700).

### New features

* Using `rsc status --no-ssh` will skip attempts to SSH into another
  machine to check if the rserver is running there.

* Now `rsc reset --force` warns if critical rsc-related files exists,
  and which they are, otherwise the cleanup is silent.

### Prototype

* Add `freeport`.

### Bug fixes

* `rsc` failed if called via a symbolic link.


## Version 0.5.0 [2022-02-10]

### Significant changes

* `--port=uid` is the new default.

### New features

* Add option `--quiet` to silence the instructions.

* Now `rsc start` outputs a message when it shuts down the RStudio
  Server.

* Now `rsc start` shuts down nicely when it receives a SIGCONT,
  SIGTERM, SIGUSR2, or SIGINT (e.g. Ctrl-C) signal.

* Add built-in 'auth-via-ssh' authentication tool that use SSH toward
  a hostname to validate the password,
  e.g. `--auth=auth-via-ssh:log2`.

* Now `rsc start --auth=<spec>` gives an informative error message if
  the `<spec>` is incomplete, e.g. when the 'expect' tool is missing.

* Add `--random-password`, which sets `RSC_PASSWORD` randomly and
  echoes it. This can be used in combination with
  `--auth=auth-via-env`.

### Alpha testing

* Add `rsc start --revtunnel=<spec>`.


## Version 0.4.0 [2022-02-10]

### New features

* Add support to specify an alternative authentication method for the
  RStudio Server login, e.g. `rsc start --auth=<file>`, where `<file>`
  can be the path to an executable, or one of the built-in ones, which
  are 'auth-via-su' (default) and 'auto-via-env'.

* `rsc status --field=hostname` and `rsc status --field=port` report
  on the hostname and the port of the running RStudio Server.

* `rsc status --force --field=...` skips any attempts to check and
  clean up stray files.

* `rsc status` now reports also on the RStudio Server's listening
  port.

* Now `rsc` tries extra hard to infer the hostname, which is done by
  first querying `$HOSTNAME` and `hostname` as a fallback. If neither
  works, then an informative error is produced.

* Now `rsc reset --force` produces an informative warning.

* Added `rsc wait`, which waits until `rsc start &` is fully running.

### Bug fixes

* `rsc start` no longer uses `mktemp` in case that fails, which, by
  the way, is extremely rare and a problem with the system setup.


## Version 0.3.4 [2022-02-08]

### New features

* Add option `--env-pattern=<regular expression>`.

### Deprecated and defunct

* Remove option `--env` in favor of `--env-pattern`.


## Version 0.3.3 [2022-02-03]

### Bug fixes

* Internal `check_pid()` could give incorrect results when checking a
  process PID on another machine.


## Version 0.3.2 [2022-02-03]

### Bug fixes

* `rsc start` failed to remove stray lockfile, even when it was known
  that there were no 'rserver' and 'rsession' processes running.


## Version 0.3.1 [2022-02-03]

### New features

* Now `rsc` can check process PIDs on another machine as well, which
  requires SSH access to that other machine.

* Now `rsc` respects environment variable `XDG_CONFIG_HOME`. If not
  set, the default is `$HOME/.config`.


## Version 0.3.0 [2022-01-30]

### Significant changes

* Add option `--env=<spec>`. If `--env=all`, then the R session, and
  any terminal opened in RStudio, inherits all environment variables
  that were exported in the shell where `rsc start` was called. If
  `--env=none`, then only environment variables predefined by the
  RStudio Server are set.
  
### Bug fixes

* `rsc` would incorrectly remove the lock file when the RStudio Server
  was running on another machine on the same system.

* `rsc status` reported that 'rserver' and 'rsession' were not running
  when called on another machine than where they are running.


## Version 0.2.4 [2022-01-29]

### New features

* Add support for `--port-seed=<seed>`, which sets the random seed
  used when finding a free, random port (`--port=random`).

* Add support for `--port=uid`, which is short for `--port-seed=$(id
  -u)` and `--port=random`. This makes the sequence of random ports
  tests deterministic and unique to the current user. This strategy
  increases the chance for a user to get the same port in subsequent
  calls.

* Add support for `--dryrun`, which does everything but launching the
  RStudio Server. This is useful for troubleshooting and development.

* Now `rsc` removes stray PID and lock files, if it can be concluded
  that they are stray files.
  

## Version 0.2.3 [2022-01-29]

### New features

* `rsc start` now ignores a stray lock file if there is no other
  evidence that an RStudio Server instance is running.

* `rsc start` now detect when RStudio Server fails to launch and gives
  an informative error message.

* `rsc start` now asserts that the port is available before trying to
  launch the RStudio Server.


## Version 0.2.2 [2022-01-29]

### New features

* `rsc start` instructions include information on `$USER`.

* `rsc status` report on the lock file too.

* `rsc status` now reports on "unknown" statuses if the RStudio Server
  is running on another machine.

### Bug fixes

* `rsc start` failed to shut down nicely when receiving SIGTERM,
  resulting in R sessions and lock files being left behind.

* `src stop` would fail on machines where environment `HOSTNAME` is
  not correct. Now relying on `hostname` instead.


## Version 0.2.1 [2022-01-26]

### New features

* If `rsc start` fails because there's already an existing RStudio
  Server running, the error message now includes on what machine that
  instance is running.

### Bug fixes

* Internal validation of `auth-via-su` could output messages to
  standard error. Those are now muffled.


## Version 0.2.0 [2022-01-26]

### New features

* Now `rsc start` only gives instructions how to access the RStudio
  Server instance from a remote machine, when connected from one.

* Now the `rsc start` instructions on how to connect from a remote
  machine infers the login hostname from the current connection by
  querying `who` and `host`.

* When running the RStudio Server via an interactive job, then the R
  session timeout limit is inferred from maximum run-time as given by
  the job scheduler. If this cannot be inferred, the timeout limit
  defaults to 120 minutes.

### Bug fixes

* `rsc stop` called from another machine on the same system would
  silently remove the internal lock file used to prevent more than one
  RStudio Server instance from running. Now an informative error
  message is produced informing on what machine the server is running
  and need to be stopped from.


## Version 0.1.2 [2022-01-25]

### New features

* Now the `auth-via-su` script is distributed part of this software.

### Bug fixes

* Environment variable R_LIBS_USER was ignore.


## Version 0.1.1 [2022-01-25]

### Significant changes

* `rsc` no longer loads Linux environment modules. Instead, the user
  is responsible for making sure R and RStudio Server executables are
  on the `PATH`. This gives the user maximum flexibility in what R
  version to run. The `rsc` tool will produce informative error
  messages if these executables are not found.

### New features

* Add `rsc config --full`.

* Add `rsc log`.

* Now `rsc start` will make sure to terminate the RStudio Server
  instance and any running R sessions when exiting.
  

## Version 0.1.0 [2022-01-22]

### New features

* Add `freeport` to find a free TCP port.

* Add `launch_rstudio_server`, which launches the RStudio Server on
  the current machine at a random port. The server and any running R
  session it launched will be terminated when `launch_rstudio_server`
  terminates, e.g. from Ctrl-C.
