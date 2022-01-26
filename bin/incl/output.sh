# -------------------------------------------------------------------------
# Output utility functions
# -------------------------------------------------------------------------
debug=false
verbose=false
theme=

function _tput {
    if [[ $theme == "none" ]]; then
        return
    fi
    tput "$@" 2> /dev/null
}

function mecho { echo "$@" 1>&2; }

function mdebug {
    if ! $debug; then
        return
    fi
    {
        _tput setaf 8 ## gray
        echo "DEBUG: $*"
        _tput sgr0    ## reset
    } 1>&2
}
function mdebug0 {
    if ! $debug; then
        return
    fi
    {
        _tput setaf 8 ## gray
        echo "$*"
        _tput sgr0    ## reset
    } 1>&2
}

function merror {
    local info version
    {
        info="ucsf-vpn $(version)"
        version=$(openconnect_version 2> /dev/null)
        if [[ -n $version ]]; then
            info="$info, OpenConnect $version"
        else
            info="$info, OpenConnect version unknown"
        fi
        [[ -n $info ]] && info=" [$info]"
        _tput setaf 1 ## red
        echo "ERROR: $*$info"
        _tput sgr0    ## reset
    } 1>&2
    _exit 1
}

function mwarn {
    {
        _tput setaf 3 ## yellow
        echo "WARNING: $*"
        _tput sgr0    ## reset
    } 1>&2
}

function minfo {
    if ! $verbose; then
        return
    fi
    {
        _tput setaf 4 ## blue
        echo "INFO: $*"
        _tput sgr0    ## reset
    } 1>&2
}

function mok {
    {
        _tput setaf 2 ## green
        echo "OK: $*"
        _tput sgr0    ## reset
    } 1>&2
}

function mdeprecated {
    {
        _tput setaf 3 ## yellow
        echo "DEPRECATED: $*"
        _tput sgr0    ## reset
    } 1>&2
}

function mnote {
    {
        _tput setaf 11  ## bright yellow
        echo "NOTE: $*"
        _tput sgr0    ## reset
    } 1>&2
}

function _exit {
    local value

    value=${1:-0}
    mdebug "Exiting with exit code $value"
    exit "$value"
}


# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# OUTPUT
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
## Use colored stdout if the terminal supports it
## and as long as a stdout are not redirected
function term_colors {
    local action
    local what
    
    action=$1
    what=$2
    [[ -z "${what}" ]] && what=1
    
    if [[ "${action}" == "enable" && -t "${what}" ]]; then
        ## ANSI foreground colors
        black=$(tput setaf 0)
        red=$(tput setaf 1)
        green=$(tput setaf 2)
        yellow=$(tput setaf 3)
        blue=$(tput setaf 4)
        magenta=$(tput setaf 5)
        cyan=$(tput setaf 6)
        white=$(tput setaf 7)

        ## Text modes
        bold=$(tput bold)
        dim=$(tput dim)
        reset=$(tput sgr0)
    else
        export black=
        export red=
        export green=
        export yellow=
        export blue=
        export magenta=
        export cyan=
        export white=

        export bold=
        export dim=

        export reset=
    fi
}
