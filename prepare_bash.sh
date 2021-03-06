#!/usr/bin/env bash

preexec () {
    read -a arr <<< ${1};
    comm=${arr[0]}
    echo ${comm} >> ${SUIBASH_HOME}/bash_command_usage;
}

preexec_invoke_exec () {
    [ -n "${COMP_LINE}" ] && return  # do nothing if completing
    [ "${BASH_COMMAND}" = "${PROMPT_COMMAND}" ] && return # don't cause a preexec for ${PROMPT_COMMAND}
    local this_command=`HISTTIMEFORMAT= history 1 | sed -e "s/^[ ]*[0-9]*[ ]*//"`;
    preexec "${this_command}"
    return
}

trap 'preexec_invoke_exec' DEBUG

nothing_found_handle() { echo "There isn't a single match"; }

command_not_found_handle() {
    com=`python3 ${SUIBASH_HOME}/.src/suibash.py $@`;
    if [ "${com}" == "SUIBASH" ]; then
        echo "This wrapper is meant to guess the real command you want to write when there is a typo in it"
    elif [ "${com}" == "HISTFILE" ]; then
        echo "This is the recorded commands until today"
        cat ${SUIBASH_HOME}/bash_command_usage;
    elif [ "${com}" == "nothing_found_handle" ]; then
        nothing_found_handle
    else
        echo "NOT FOUND; executing ${com} instead";
        head -n-1 ${SUIBASH_HOME}/bash_command_usage > /tmp/_usage
        cp /tmp/_usage ${SUIBASH_HOME}/bash_command_usage
        eval ${com};
    fi
}