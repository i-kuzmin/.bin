#!/bin/bash

function vm_init
{
    VM_HOST=igk@10.75.131.30
    VM_GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
    VM_GIT_ROOT=${VM_GIT_ROOT//btrfs/btrfs}
    VM_DIR=$(git rev-parse --show-prefix)

    VM_ENV="export JAVA_HOME=/usr/java/default; \
            PATH+=:$VM_GIT_ROOT/build.x86_64-unknown-linux/bin/; \
            PATH+=:/usr/sbin/"
}

function b_default
{
    #exec /opt/bear/bin/bear --append 
    local pass=
    for arg in "$@"; do
        if [ "$arg" == "--help" ]; then
            b_help
            exit 0
        elif [ "$arg" == "RCN" ]; then
            RECURSIVE=NO
        elif [ "$arg" == "RCY" ]; then
            RECURSIVE=YES
        else
            pass+=" $arg"
        fi
    done
    exec  tbmake TESTS=${TESTS-NO} RECURSIVE=${RECURSIVE-YES} GOLD_VERSION_SUFFIX= -j $pass
}

function b_tmp
{
    find "$@" -name '*.sw[a-z]' -or -name '*.un~'
}

function b_help
{
    echo "b              - run build"
    echo "  RCN             - RECURSIVE=NO shorthand"
    echo "  RCY             - RECURSIVE=YES shorthand"
    echo "b.new          - create empty project"
    echo "b.tmp          - list temporary files"
    echo "b.vm           - run build on vm"
    echo "     --tags      - build tags on vm"
    echo "     --run       - run cmd on vm"
    echo "     --sw        - switch repository"
}

function b_vm
{
    vm_init
    local ssh="exec stdbuf -i0 -o0 -e0 ssh -x $VM_HOST -t -q"

    if [ "$1" == "--tags" ]; then shift;
        $ssh "
            cd $VM_GIT_ROOT;
            $VM_ENV;
            exec toolchain/x86_64-unknown-linux/bin/tbmake -C ""$VM_DIR"" \
                -f ~/.dotfiles/bin/makefiles/Makefile.exrc -sj4 print-depends |grep --color=never "^#"
        ";
    elif [ "$1" == "--run" ]; then shift;
        $ssh "
            cd $VM_GIT_ROOT/$VM_DIR;
            $VM_ENV;
            "$@"
        ";

    elif [ "$1" == "--sw" ]; then shift;
        $ssh "
            $VM_ENV;
            ~/.dotfiles/bin/sw-git \"$@\"
        ";

    else
        $ssh "
            cd $VM_GIT_ROOT;
            $VM_ENV;
            exec toolchain/x86_64-unknown-linux/bin/tbmake -C ""$VM_DIR"" \
                TESTS=${TESTS-NO} RECURSIVE=${RECURSIVE-NO} -j4 ""$@"" 
        ";
    fi
}

function b_fix_util
{
    cd $(git rev-parse --show-cdup)./src/libraries/util/
    sed '/^##### Link with LLVM/,/^##### Sanity checks./s/^/#/;' Makefile  -i
}

function b_new
{
    local name=$1; shift;
    if [ -z "$name" ]; then
        name=$(basename $(pwd))
    else
        mkdir $name
        cd $name
    fi
    echo "Creating new project \"$name\""

    if [ -e Makefile ]; then
        echo "project already exists in the directory";
        exit -1;
    fi
    cat > Makefile << END_Makefile
###############################################################################
#  Tbricks Build System
#
#  Copyright (c) 2006-$(date +%Y) Tbricks AB.
#
###############################################################################

PROGRAMS = $name

SOURCES += \$(wildcard src/*.cpp)

DEPENDS += scripts/server
#DEPENDS += libraries/util
#DEPENDS += libraries/cpphelper

#LIBS += benchmark

include \$(MK_BUILD_SYSTEM)/main.make

###############################################################################
END_Makefile

    mkdir -p src;
    cat > src/main.cpp << END_main.cpp
#include <iostream>

int main() {
    return 0;
}
END_main.cpp
    echo "DONE"
}
case $0 in
    */b.new) b_new "$@" ;;
    */b.tmp) b_tmp "$@" ;;
    */b.vm)  b_vm  "$@" ;;
    */b) b_default "$@" ;;
    */b.fix_util) b_fix_util "$@" ;;
    *) b_help ;;
esac
