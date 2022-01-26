# rstudio-server-launcher

## Version 0.1.2-9001

Bug fixes:

* `rsc stop` called from another machine on the same system would
  silently remove the internal lock file used to prevent more than
  one RStudio Server instance from running.  Now an informative
  error message is produced informing on what machine the server
  is running and need to be stopped from.


## Version 0.1.2

New features:

* Now the 'auth-via-su' script is distributed part of this software.

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

* Now 'rsc start' will make sure to terminate the RStudio Server instance
  and any running R sessions when exiting.
  

## Version 0.1.0

New features:

* Add `freeport` to find a free TCP port.

* Add `launch_rstudio_server`, which launches the RStudio Server on the current
  machine at a random port.  The server and any running R session it launched
  will be terminated when `launch_rstudio_server` terminates, e.g. from Ctrl-C.


