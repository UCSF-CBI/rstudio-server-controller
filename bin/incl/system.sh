# -------------------------------------------------------------------------
# SYSTEM
#
# Requirements:
# * asserts.sh
# -------------------------------------------------------------------------
pwd=${BASH_SOURCE%/*}

# shellcheck source=incl/asserts.sh
source "${pwd}"/asserts.sh

## A version of 'hostname' that will use either 'hostname', and
## then $HOSTNAME as backup
function hostname {
    local res
    res=$(command hostname)
    [[ -z ${res} ]] && res=${HOSTNAME}
    [[ -z ${res} ]] && error "Failed to infer hostname"
    echo "${res}"
}
