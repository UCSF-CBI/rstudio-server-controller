# -------------------------------------------------------------------------
# Output utility functions
# -------------------------------------------------------------------------
debug=false
verbose=false
theme=

function _tput {
    if [[ $theme == "none" ]] || [[ -n ${NO_COLOR} ]]; then
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

function fg_magenta {
    _tput setaf 5 ## magenta
    echo "$*"
    _tput sgr0    ## reset
}

function _exit {
    local -i value

    value=${1:-0}
    mdebug "Exiting with exit code $value"
    exit "$value"
}


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

        ## Text effects
        bold=$(tput bold)  # bold
        dim=$(tput dim)    # dim
        smso=$(tput smso)  # standout
        rmso=$(tput rmso)  # standout end
        smul=$(tput smso)  # underline
        rmul=$(tput rmso)  # underline end

        ## Reset text effects and foreground colors
        reset=$(tput sgr0)
    else
        black=""
        red=""
        green=""
        yellow=""
        blue=""
        magenta=""
        cyan=""
        white=""
        bold=""
        dim=""
        smso=""
        rmso=""
        smul=""
        rmul=""
        reset=""
    fi
    undo=$'\016' ## ASCII Shift Out = ASCII 14 = ASCII 016 = ASCII 0x0E
    
    export black
    export red
    export green
    export yellow
    export blue
    export magenta
    export cyan
    export white
    export bold
    export dim
    export smso
    export rmso
    export smul
    export rmul
    export reset
    export undo
}


function term_width {
    local -i value
    value=$(tput cols)
    [[ -z ${value} ]] && value=79
    echo "${value}"
}

function term_height {
    local -i value
    value=$(tput lines)
    [[ -z ${value} ]] && value=24
    echo "${value}"
}


function ruler {
    local -i width
    local symbol
    symbol=${1:-"-"}
    width=${2:-$(term_width)}
    printf -- "%*s" "${width}" " " | tr " " "${symbol}"
}
