#!/bin/bash
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

set -u
# This script gets called from postcreateCommand.sh directly after the devcontainer
# has been started. Its job is to make the project files available to the CMK site.

#exit

L_SHARE_CMK="local/share/check_mk"
L_LIB_CMK_BASE="local/lib/check_mk/base"

function main {
    sync_files
    echo "linkfiles.sh finished."
    echo "===================="
}

function rmpath {
    echo "clearing $1"
    rm -rf $1
}

function linkpath {
    TARGET=$WORKSPACE/$1
    LINKNAME=$2
    echo "linking $TARGET -> $LINKNAME"
    # make sure that the link's parent dir exists
    mkdir -p $(dirname $LINKNAME)
    ln -sf $TARGET $LINKNAME
    #chmod 666 $TARGET/*
}

# Do not only symlink, but also generate needed directories. 
function create_symlink {
    echo "---"
    TARGET=$1
    if [ ${2:0:1} == "/" ]; then 
        # absolute link
        LINKNAME=$2
    else
        # relative link in OMD_ROOT
        LINKNAME=$OMD_ROOT/$2
    fi    
    rmpath $LINKNAME
    linkpath $TARGET $LINKNAME
    tree $LINKNAME
}


function sync_files {
    for DIR in "agents" "bakery" "checkman" "checks" "images" "checkman" "images" "web"; do
        create_symlink $DIR $L_SHARE_CMK/$DIR
    done

    # agent_based
    create_symlink agent_based $L_LIB_CMK_BASE/plugins/agent_based
    rm -rf $L_LIB_CMK_BASE/plugins/agent_based/__pycache__


    # Bash aliases
    # TODO 
    create_symlink .devcontainer/.site_bash_aliases $OMD_ROOT/.bash_aliases

    # TODO: Custom stuff
    # # RF test suites 
    #create_symlink rf_tests /usr/lib/check_mk_agent/robot    
    # Folder where agent output can be sourced with rule
    # "Datasource Programs > Individual program call instead of agent access"
    # (folder gets created in postCreateCommand.sh)
    #create_symlink agent_output var/check_mk/agent_output         
}

main

