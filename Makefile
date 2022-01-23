shellcheck:
	shellcheck -x bin/freeport
	(cd bin; shellcheck -x rstudio-server)


