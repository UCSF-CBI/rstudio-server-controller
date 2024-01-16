#!/usr/bin/env bats

setup() {
    load "${BATS_SUPPORT_HOME:?}/load.bash"
    load "${BATS_ASSERT_HOME:?}/load.bash"
    
    path="$(dirname "${BATS_TEST_FILENAME}")"

    ## Test with a fresh user config and data folder
    _RSC_TEST_DIR_=$(mktemp -d)
    export _RSC_TEST_DIR_
    
    XDG_CONFIG_HOME=${_RSC_TEST_DIR_}
    export XDG_CONFIG_HOME
    XDG_DATA_HOME=${_RSC_TEST_DIR_}
    export XDG_DATA_HOME

    export RSC_AUTH="auth-via-env"
    export RSC_PASSWORD="random"
}

teardown() {
    rm -rf "${_RSC_TEST_DIR_}"
}

@test "XDG_CONFIG_HOME is a temporary folder" {
    run echo "${XDG_CONFIG_HOME:-<not set>}"
    assert_success
    refute_output --partial "not set"
    assert_output --partial "$(dirname "$(mktemp -d)")"
    
    run echo "${XDG_DATA_HOME:-<not set>}"
    assert_success
    refute_output --partial "not set"
    assert_output --partial "$(dirname "$(mktemp -d)")"
}

@test "rsc --version works" {
    run rsc --version
    assert_success
    assert_output --regexp "[[:digit:]]+([.][[:digit:]]+)+(|-[[:digit:]]+)"
}

@test "rsc --version --full works" {
    run rsc --version --full
    assert_success
    assert_output --regexp "rsc: [[:digit:]]+([.][[:digit:]]+)+(|-[[:digit:]]+)"
    assert_output --regexp "RStudio Server: "
    assert_output --regexp "R: [[:digit:]]+([.][[:digit:]]+)+(|-[[:digit:]]+)"
}

@test "rsc --help works" {
    run rsc --help
    assert_success
    assert_output --partial "rsc"
    assert_output --partial "RStudio Server Controller"
    assert_output --partial "Usage:"
    assert_output --partial "Commands:"
    assert_output --partial "Options:"
    assert_output --partial "Version:"
    assert_output --partial "License:"
}

@test "rsc status works" {
    run rsc status
    assert_success
    assert_output --partial "rserver: "
    assert_output --partial "rsession: "
    assert_output --partial "rserver monitor: "
    assert_output --partial "SSH reverse tunnel (optional): "
    assert_output --partial "lock file: "
}

@test "rsc status --full works" {
    run rsc status --full
    assert_success
    assert_output --partial "rserver: "
    assert_output --partial "rsession: "
    assert_output --partial "rserver monitor: "
    assert_output --partial "SSH reverse tunnel (optional): "
    assert_output --partial "lock file: "
}

@test "rsc config works" {
    run rsc config
    assert_success
    assert_output --partial "RStudio Server Controller Storage:"
    assert_output --partial "RStudio User State Storage:"
    assert_output --partial "XDG_CONFIG_HOME=$(dirname "$(mktemp -d)")"
    assert_output --partial "XDG_DATA_HOME=$(dirname "$(mktemp -d)")"
}

@test "rsc config --full works" {
    run rsc config --full
    assert_success
}

@test "rsc log works" {
    run rsc log
    assert_success
}

@test "rsc reset works" {
    run rsc reset
    assert_success
}

@test "rsc reset --force works" {
    run rsc reset --force
    assert_success
}

@test "rsc stop works" {
    run rsc stop
    assert_success
}


@test "rsc start --dryrun works" {
    run rsc start --dryrun 2>&1
    assert_failure
    assert_output --partial "DRYRUN: rserver --config-file="
    assert_output --partial "DRYRUN: rserver_monitor launched"
    assert_output --partial "ERROR: It looks like the RStudio Server failed during launch"
    assert_output --partial "Shutting down RStudio Server ..."
    assert_output --partial "Shutting down RStudio Server ... done"
}

@test "rsc start --debug --dryrun works" {
    run rsc start --debug --dryrun 2>&1
    assert_failure
    assert_output --partial "DRYRUN: rserver --config-file="
    assert_output --partial "DRYRUN: rserver_monitor launched"
    assert_output --partial "ERROR: It looks like the RStudio Server failed during launch"
    assert_output --partial "Shutting down RStudio Server ..."
    assert_output --partial "Shutting down RStudio Server ... done"
}
