#!/usr/bin/env zsh

preexec () {
    arr=(`echo $1 | cut -d' ' -f1,2`) # @ modifier
    comm=$arr[1]
    echo $comm >> $SUIBASH_HOME/zsh_command_usage;
}

command_not_found_handler () {
    com=`python $SUIBASH_HOME/.src/suibash.py $@`;
    if [ "$com" = "SUIBASH" ]; then
        echo "This wrapper if meant to guess the real command you want to write when there is a typo in it"
    elif [ "$com" = "nothing_found_handle" ]; then
        eval $com;
    else
        echo "NOT FOUND; executing $com instead";
        eval $com;
    fi
}

nothing_found_handle() { echo "There isn't a single match"; }