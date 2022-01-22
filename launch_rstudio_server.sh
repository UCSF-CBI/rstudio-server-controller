#!/bin/bash
#SBATCH --time=08:00:00             # Maximum run-time
#SBATCH --nodes=1                   # Run on a single machine
#SBATCH --ntasks=4                  # Number of CPU cores
#SBATCH --mem=16G                   # Memory (GiB)
#SBATCH --output=rstudio-server.%j
#SBATCH --export=NONE

## Remove file lock, when the RStudio Server instance is shutdown
function on_exit_rm {
    rm "${lockfile}"
}

## Terminate the R session, when the RStudio Server instance is shutdown
function on_exit_rsession {
    local pid
    pid=$(cat "${workdir}/var/run/rstudio-server/rstudio-rsession/${USER}-d.pid")
    echo "pid=$pid"
    kill -TERM "${pid}"
}

function on_exit {
    on_exit_rsession
    on_exit_rm
}

LOCALPORT=${LOCALPORT:-8787}
LOGIN_HOST=${LOGIN_HOST:-c4-log2}

# Need a workdir for sqlite database, otherwise we'd have to be root. Also for our rsession.sh
workdir=$HOME/.config/rstudio-server-launcher
mkdir -p "${workdir}"/{run,tmp,var/lib/rstudio-server,/var/run/rstudio-server}
chmod 700 "${workdir}"/{run,tmp,var/lib/rstudio-server,/var/run/rstudio-server}

## Prevent user from running multiple instances of the RStudio Server
lockfile=${workdir}/pid.lock
if [[ -f "${lockfile}" ]]; then
    2>&1 echo "ERROR: Another RStudio Server session of yours is already active on the cluster. Please terminate that first. As a last resort, remove lock file '${lockfile}' and retry."
    exit 1
fi

# Load CBI software stack
module load CBI

## Use the default R version, unless overridden by R_VERSION
module load "r/${R_VERSION}"

## Use the default RStudio Server version
module load rstudio-server

## Assert executables are available
command -v R           &> /dev/null || { 2>&1 echo "ERROR: No such executable: R";           exit 1; }
command -v rserver     &> /dev/null || { 2>&1 echo "ERROR: No such executable: reserver";    exit 1; }
command -v rsession    &> /dev/null || { 2>&1 echo "ERROR: No such executable: resession";   exit 1; }
command -v auth-via-su &> /dev/null || { 2>&1 echo "ERROR: No such executable: auth-via-su"; exit 1; }

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

## The PPID can be used to identify child process 'rsession', e.g. ps --ppid <pid>
echo "\${PPID}" > "$workdir/rsession.ppid"

RSESSION_LOG_FILE="$workdir/rsession.log"
export RSESSION_LOG_FILE

{
    echo "Launching rsession:"
    echo "Time: \$(date)"
    echo "HOSTNAME: \${HOSTNAME}"
    echo "PPID: \${PPID}"
    echo "Command: exec rsession --r-libs-user "${R_LIBS_USER}" \"\${@}\""
} > "\${RSESSION_LOG_FILE}"

exec &>> "\${RSESSION_LOG_FILE}"
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

## Validate correctness of auth-via-su executable (should return true)
#echo "${RSTUDIO_PASSWORD}" | PAM_HELPER_LOGFILE="" auth-via-su "${RSTUDIO_USER}" || { 2>&1 echo "ERROR: Validation of 'auth-via-su' failed: $(command -v auth-via-su)"; exit 1; }

[[ -n ${PAM_HELPER_LOGFILE} ]] && { 
  echo "************************************************************"
  echo "WARNING: Environment variable 'PAM_HELPER_LOGFILE' is set."
  echo "All usernames and passwords entered at the RStudio Server"
  echo "login prompt will be recorded to the file:"
  echo "${PAM_HELPER_LOGFILE}"
  echo "************************************************************"
  echo
}

echo "${PID}" > "${lockfile}"
trap "on_exit" EXIT

# get unused socket per https://unix.stackexchange.com/a/132524
# tiny race condition between the Python and launching the rserver
RSTUDIO_PORT=${RSTUDIO_PORT:-$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')}
readonly RSTUDIO_PORT

# Instructions for user
cat 1>&2 <<END
The RStudio Server is being launched on ${HOSTNAME}. Next,

1. SSH to the cluster from your local computer using:

  ssh -N -L ${LOCALPORT}:${HOSTNAME}:${RSTUDIO_PORT} ${RSTUDIO_USER}@${LOGIN_HOST}

2. Open your web browser at <http://127.0.0.1:${LOCALPORT}>

3. Enter your cluster credentials at the RStudio Server authentication prompt

When done:

1. Exit the RStudio session, e.g. quit()

2. Interrupt this script, e.g. press Ctrl-C

END

rserver --server-daemonize 0 \
	--server-data-dir "$workdir/var/run/rstudio-server" \
        --database-config-file "$workdir/database.conf" \
        --www-port "$RSTUDIO_PORT" \
        --auth-pam-helper-path "auth-via-su" \
        --auth-none 0 \
        --auth-stay-signed-in-days 1 \
        --auth-timeout-minutes 0 \
        --auth-minimum-user-id 500 \
        --rsession-path "$workdir/rsession.sh" \
        --secure-cookie-key-file "$workdir/tmp/my-secure-cookie-key" \
        --server-user "$USER"
echo "rserver exited" 1>&2
