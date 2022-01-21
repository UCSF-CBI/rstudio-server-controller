[![shellcheck](https://github.com/UCSF-CBI/rstudio-server-launcher/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/UCSF-CBI/rstudio-server-launcher/actions/workflows/shellcheck.yml)

# rstudio-server-launcher

This is a tool for a non-privileged user to launch their own instance of RStudio Server on a machine and then remotely connect to it from the browser running on their local computer.


## Usage

User logs onto a development node and launches the RStudio Server:

```sh
$ launch_rstudio_server.sh
```

This will generate a one-time random password, that the user can use to log into at the RStudio Server web prompt.  The user will also get cut'n'pastable instructions for how to use SSH to set up a tunnel into the cluster such that they can access the RStudio Server instance from their local web browser.


## Requirements

This tool currently makes assumptions about the following Linux environment variables being available on the machine:

* [`CBI`](github.com/HenrikBengtsson/CBI-software)
* `r`
* `rstudio-server`
