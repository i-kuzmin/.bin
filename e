#!/bin/bash
# Edit helper

# --- helpers:
# if ack tool is exist
function has_ack
{
    which ack>/dev/null
    return $?
}

# list files which match $1
# -m - show matched place
function list_files
{
    local src=$1; shift;
    local show_match=false;

    for opt in $@; do
        if [ "$opt" == "-m" ]; then show_match=true; fi
    done

    if has_ack; then
        local ack_opt=
        if ! $show_match; then 
            ack_opt+=" -l"
        fi

        ack $ack_opt "$src" \
            --ignore-file=is:.tbexrc

    else
        local grep_opt="-r -n" 
        if ! $show_match; then 
            grep_opt+=-l
        fi
        grep $grep_opt --color=always \
            --include=*.[ch]pp \
            --include=*.[hc] \
            --include=*.in[lc] \
            --include=*.patch *
    fi
}


# --- Commands:
function e_cmd_help
{
    echo "NAME - batch file edit helper"
    echo "    e [cmd] [args]"
    echo "CMDs"
    echo "    rename src_name [dst_name] [-i] - substitute \"src_name\" to \"dst_name\" (do nothing if -i is not defined)"
    echo "    spaces                          - remove trailing spaces"
}

# -----------------------------------------------------------------------------------

function e_cmd_rename
{
    local src="$1"; shift;
    local dst="$1"; shift;

    if [ -z "$src" ]; then
        e_cmd_help rename
        exit -1
    fi

    if [ "$1" == "-i" ]; then
        list_files "$src" | xargs sed "s|$src|$dst|g" -i
    else
        if [ -z "$dst" ]; then
            list_files "$src" -m
        else
            list_files "$src" |xargs sed "s|$src|$dst|g"
        fi
    fi
}

# -----------------------------------------------------------------------------------

function e_cmd_spaces
{
    if [ "$1" == "-i" ]; then
        list_files "\s\s+$" |xargs sed "s/\s\+$//" -i
    else
        list_files "\s\s+$" -m
    fi
}

# -----------------------------------------------------------------------------------

function e_cmd
{
    local cmd=$1; shift;
    case "$cmd" in
        spaces) e_cmd_spaces "$@";;
        rename) e_cmd_rename "$@";;
        *|help) e_cmd_help "$@" ;;
    esac
}

if [[ "$0" =~ ^.+/e\.([a-zA-Z0-0_]+) ]]; then
    e_cmd ${BASH_REMATCH[1]} "$@";
else
    e_cmd "$@";
fi
