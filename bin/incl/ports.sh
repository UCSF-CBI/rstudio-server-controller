# -------------------------------------------------------------------------
# PORTS
#
# Requirements:
# * asserts.sh
# -------------------------------------------------------------------------
pwd=${BASH_SOURCE%/*}

# shellcheck source=incl/asserts.sh
source "${pwd}"/asserts.sh

function assert_port {
    [[ -z $1 ]] && error "Port must not be empty"
    assert_integer "$1"
    if [[ $1 -lt 1 ]] || [[ $1 -gt 65535 ]]; then
        error "Port out of range [1,65535]: $1"
    fi
}

function assert_port_free {
    assert_port "${1}"
    PORT4ME_TEST="$1" port4me || error "Port is already in use on $(hostname): ${1}"
}
