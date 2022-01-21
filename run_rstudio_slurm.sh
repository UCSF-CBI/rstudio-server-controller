#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --ntasks=4              # Number of CPUs
#SBATCH --mem=16gb              # Memory (GB)
#SBATCH --output=rstudio.job.%j
#SBATCH --export=NONE
#SBATCH --nodelist=c4-n11

# The 
LOCALPORT=${LOCALPORT:-8787}

# Need a workdir for sqlite database, otherwise we'd have to be root. Also for our rsession.sh
workdir=$HOME/.config/rstudio-server-launcher
mkdir -p "${workdir}"/{run,tmp,var/lib/rstudio-server,/var/run/rstudio-server}
chmod 700 "${workdir}"/{run,tmp,var/lib/rstudio-server,/var/run/rstudio-server}

# Load CBI software stack
module load CBI

## Use the default R version, unless overridden by R_VERSION
module load "r/${R_VERSION}"

## Use the default RStudio Server version
module load rstudio-server

## Assert executables are available
command -v R          &> /dev/null || { 2>&1 echo "ERROR: No such executable: R";          exit 1; }
command -v rserver    &> /dev/null || { 2>&1 echo "ERROR: No such executable: reserver";   exit 1; }
command -v rsession   &> /dev/null || { 2>&1 echo "ERROR: No such executable: resession";  exit 1; }
command -v pam-helper &> /dev/null || { 2>&1 echo "ERROR: No such executable: pam-helper"; exit 1; }

## FIXME: This shouldn't really be hardcoded. See also comment below. /HB 2022-01-21
R_LIBS_USER=${R_LIBS_USER:-"$HOME/R/%p-library/%v-CBI-gcc8"}
R_LIBS_USER="$HOME/R/%p-library/%v-CBI-gcc8"

cat > "${workdir}/database.conf" <<END
provider=sqlite
directory=${workdir}/var/lib/rstudio-server
END


cat > "${workdir}/rsession.sh" <<END
#!/bin/sh

# Set OMP_NUM_THREADS to prevent OpenBLAS (and any other OpenMP-enhanced
# libraries used by R) from spawning more threads than the number of processors
# allocated to the job.
OMP_NUM_THREADS=${SLURM_JOB_CPUS_PER_NODE:-$(nproc 2> /dev/null || echo "1")}
export OMP_NUM_THREADS

RSESSION_LOG_FILE="$workdir/rsession.log"
export RSESSION_LOG_FILE

exec &>>"\$RSESSION_LOG_FILE"

echo "Launching rsession on ..."
set -x

## FIXME: This shouldn't really be hardcoded. See also comment above. /HB 2022-01-21
## Seems like it should work without specifying --r-libs-user; default?!?
## exec rsession "\${@}"
exec rsession --r-libs-user "${R_LIBS_USER}" "\${@}"
END

chmod +x "${workdir}/rsession.sh"

# set up variables - actual user id & generated password. To be validated by auth script
RSTUDIO_USER=${RSTUDIO_USER:-$(id --user --name)}
RSTUDIO_PASSWORD=${RSTUDIO_PASSWORD:-$(openssl rand -base64 15)}

export RSTUDIO_USER
export RSTUDIO_PASSWORD

## Validate correctness of pam-helper executable (should return true)
echo "${RSTUDIO_PASSWORD}" | pam-helper "${RSTUDIO_USER}" || { 2>&1 echo "ERROR: Validation of 'pam-helper' failed: $(command -v pam-helper)"; exit 1; }

# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the Python and launching the rserver
RSTUDIO_PORT=${RSTUDIO_PORT:-$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')}
readonly RSTUDIO_PORT

# Instructions for user
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command from a terminal on your local workstation:

   ssh -N -L ${LOCALPORT}:${HOSTNAME}:${RSTUDIO_PORT} $RSTUDIO_USER@c4-log2

   and point your web browser to http://127.0.0.1:${LOCALPORT}

2. log in to RStudio Server using the following credentials:

   user: $RSTUDIO_USER
   password: $RSTUDIO_PASSWORD

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

rserver --server-daemonize 0 \
	--server-data-dir "$workdir/var/run/rstudio-server" \
        --database-config-file "$workdir/database.conf" \
        --www-port "$RSTUDIO_PORT" \
        --auth-none 0 \
        --auth-stay-signed-in-days 1 \
        --auth-timeout-minutes 0 \
        --auth-minimum-user-id 500 \
        --rsession-path "$workdir/rsession.sh" \
        --secure-cookie-key-file "$workdir/tmp/my-secure-cookie-key" \
        --server-user "$USER"
echo "rserver exited" 1>&2
