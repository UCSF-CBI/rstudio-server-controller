# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# NAVIGATION
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function change_dir {
    local opwd
    opwd=${PWD}
    assert_directory_exists "$1"
    cd "$1" || error "Failed to set working directory to $1"
    mdebug "New working directory: '$1' (was '${opwd}')"
}

function make_dir {
    mkdir -p "$1" || error "Failed to create new working directory $1"
}

function remove_dir {
    rm -rf "$1" || error "Failed to remove directory $1"
}

function equal_dirs {
    local a
    local b
    a=$(readlink -f "$1")
    b=$(readlink -f "$2")
    [[ "${a}" == "${b}" ]]
}
