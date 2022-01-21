#!/bin/bash
#SBATCH --time=08:00:00
#SBATCH --ntasks=4              # Number of CPUs
#SBATCH --mem=16gb              # Memory (GB)
#SBATCH --output=rstudio.job.%j
#SBATCH --export=NONE
#SBATCH --nodelist=c4-n11

# Need a workdir for sqlite database, otherwise we'd have to be root. Also for our rsession.sh. Using STMPDIR (local /scratch).
# The working directory will be created and then deleted for each run via prolog/epilog slurm scripts.
workdir=$TMPDIR/rstudio-server
mkdir -p "${workdir}"/{run,tmp,var/lib/rstudio-server}
chmod 700 "${workdir}"/{run,tmp,var/lib/rstudio-server}

# Load R version from CBI
module load CBI r/4.1.2

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

echo "Launching rsession on..."
set -x
exec rsession --r-libs-user "$HOME/R/%p-library/%v-CBI-gcc8" "\${@}"
END

chmod +x "${workdir}/rsession.sh"

# set up variables - actual user id & generated password. To be validated by auth script
RSTUDIO_USER=$(id --user --name)
RSTUDIO_PASSWORD=$(openssl rand -base64 15)
export RSTUDIO_USER
export RSTUDIO_PASSWORD

# set up authentication helper. Use custom pam-helper file (borrowed from rocker)
cat > "${workdir}/pam-helper" <<END
#!/bin/bash

set -o nounset

## Enforces the custom password specified in the RSTUDIO_PASSWORD environment variable
## The accepted RStudio username is the same as the USER environment variable (i.e., local user name).

# set a dummy password
password="dummy"

IFS='' read -r password

[ "${USER}" = "${1}" ] && [ "${RSTUDIO_PASSWORD}" = "${password}" ]
END

chmod +x ${workdir}/pam-helper
RSTUDIO_AUTH="${workdir}/pam-helper" 
export RSTUDIO_AUTH

LOCALPORT=8787

# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the Python and launching the rserver
PORT=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
readonly PORT

# Instructions for user
cat 1>&2 <<END
1. SSH tunnel from your workstation using the following command from a terminal on your local workstation:

   ssh -N -L ${LOCALPORT}:${HOSTNAME}:${PORT} $RSTUDIO_USER@${SLURM_SUBMIT_HOST}:-c4-log1

   and point your web browser to http://localhost:${LOCALPORT}

2. log in to RStudio Server using the following credentials:

   user: $RSTUDIO_USER
   password: $RSTUDIO_PASSWORD

When done using RStudio Server, terminate the job by:

1. Exit the RStudio Session ("power" button in the top right corner of the RStudio window)
2. Issue the following command on the login node:

      scancel -f ${SLURM_JOB_ID}
END

PATH=/usr/lib/rstudio-server/bin:$PATH
rserver --server-daemonize 0 \
        --database-config-file "$workdir/database.conf" \
        --www-port "${PORT}" \
        --auth-none 0 \
        --auth-pam-helper-path "$RSTUDIO_AUTH" \
        --auth-stay-signed-in-days 30 \
        --auth-timeout-minutes 0 \
        --auth-minimum-user-id 500 \
        --rsession-path "$workdir/rsession.sh" \
        --secure-cookie-key-file "$workdir/tmp/my-secure-cookie-key" \
        --server-user "$USER"
printf 'rserver exited' 1>&2
