# rstudio-server-launcher

## Version 0.1.0-9003

New features:

* Add `rsc start --background`, to launch the RStudio Server in the background.

* Add `rsc config --full`.

* Add `rsc log`.


## Version 0.1.0

New features:

* Add `freeport` to find a free TCP port.

* Add `launch_rstudio_server`, which launches the RStudio Server on the current
  machine at a random port.  The server and any running R session it launched
  will be terminated when `launch_rstudio_server` terminates, e.g. from Ctrl-C.


