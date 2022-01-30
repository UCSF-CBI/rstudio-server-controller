# -------------------------------------------------------------------------
# PORTS
#
# Requirements:
# * python
# * asserts.sh
# -------------------------------------------------------------------------
pwd=${BASH_SOURCE%/*}

# shellcheck source=incl/asserts.sh
source "${pwd}"/asserts.sh

function free_random_port {
    local port
    # get unused socket per https://unix.stackexchange.com/a/132524
    # tiny race condition between the Python and launching the rserver
    assert_executable python
    port=$(python -c 'import socket; s=socket.socket(); s.bind(("", 0)); print(s.getsockname()[1]); s.close()')
    assert_port "${port}"
    echo "${port}"
}    

function free_uid_port {
    local port
    local ports
    local uid

    uid=${1:-$(id -u)}
    assert_integer "${uid}"
    
    # get unused socket per https://unix.stackexchange.com/a/132524
    # tiny race condition between the Python and launching the rserver
    assert_executable python

    mapfile ports < <(printf "import random;\nrandom.seed(%d);\nfor i in range(1000):print(random.randrange(1024,65535));" "${uid}" | python -)
    
    for port in "${ports[@]}"; do
        if is_port_free "${port}"; then
            echo "${port}"
            return 0
        fi
    done
    
    echo ""
    return 1
}    

## Usage: is_port_free <port>
function is_port_free {
    local port
    local res
    port=${1:?}
    assert_integer "${port}"
    assert_executable python
    res=$(python -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_STREAM); print(s.connect_ex((\"\", ${port})) != 0); s.close()")
    [[ "${res}" == "True" ]]
}

function assert_port {
    [[ -z $1 ]] && error "Port must not be empty"
    assert_integer "$1"
    if [[ $1 -lt 0 ]] || [[ $1 -gt 65535 ]]; then
        error "Port out of range [0,65535]: $1"
    fi
}

function assert_port_free {
    assert_port "${1}"
    is_port_free "$1" || error "Port is already in use on $(hostname): ${1}"
}

