#!/bin/bash

function v()
{
    local cmd=
    for arg in $*; do
        echo \"$arg\"
        local file=
        local line=
        local column=

        if [[ "$arg" =~ ^│(.+)$ ]]; then arg=${BASH_REMATCH[1]}; fi

        if [[ "$arg" =~ ^(.+):([0-9]+):([0-9]+):{0,1}$ ]]; then 
            #file.txt:2:3
            #file.txt:2:3:
            file=${BASH_REMATCH[1]}
            line=${BASH_REMATCH[2]}
            column=${BASH_REMATCH[3]}

        elif [[ "$arg" =~ ^(.+):([0-9]+):{0,1}$ ]]; then 
            #file.txt:2:
            #file.txt:2
            file=${BASH_REMATCH[1]}
            line=${BASH_REMATCH[2]}

        elif [[ "$arg" =~ ^(.+)\(([0-9]+)\):{0,1}$ ]]; then
            #file.cpp(521)
            file=${BASH_REMATCH[1]}
            line=${BASH_REMATCH[2]}

        else
            file=$arg
        fi

        if ! [ -z "$file" ]; then
            cmd+=" $file"
            if ! [ -z "$line" ]; then
                cmd+=" +$line"
            fi
            if ! [ -z "$column" ]; then
                cmd+=" +normal${column}|"
            fi
        fi
    done
    exec vim </dev/tty $cmd
}

v $*
