#!/bin/bash
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

# This file is used to generate the devcontainer.json file. It is called from the project 
# root directory. It sets the container name to the project name and Checkmk version to
# ARG1 = Checkmk version, e.g. 2.1.0p11

export VERSION=$1
DEVC_FILE=".devcontainer/devcontainer.json"
DEVC_TPL_FILE=".devcontainer/devcontainer_tpl.json"

function main() {
    # if version is unset, exit with error
    if [ -z "$VERSION" ]; then
        echo "No cmk version (arg1) specified. Choose one of the following:"
        PWD=$(folder_of $0)
        cat $PWD/devcontainer_versions.env
        exit 1
    fi

    PROJECT_DIR="$(dirname $(folder_of $0))"
    PROJECT=${PROJECT_DIR##*/} 
    export CONTAINER_NAME=${PROJECT}-devc

    echo "+ Generating CMK devcontainer file ..."
    # Ref LeP3qq
    envsubst < $DEVC_TPL_FILE > $DEVC_FILE
    # devcontainer.json contains a VS Code Variable ${containerWorkspaceFolder}, which would also 
    # be processed by envsubst. To avoid this, the template files contain ###{containerWorkspaceFolder}.
    # The three hashes are replaced with $ _after_ envsusbt has done its work. 
    # Mac-only sed... 
    sed -i "" 's/###/$/' $DEVC_FILE

    echo ">>> $DEVC_FILE for Checkmk version $VERSION created."
    echo "Container will start with name: '$CONTAINER_NAME'"
    echo "VS Code: 'Remote-Containers: Rebuild Container'."
}


function folder_of() {
  DIR="${1%/*}"
  (cd "$DIR" && echo "$(pwd -P)")
}


main $@