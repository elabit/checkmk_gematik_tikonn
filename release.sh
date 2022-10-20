#!/bin/bash
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

function main (){
    MODE=$1
    TAG=$2

    if [[ ! "$MODE" =~ release ]]; then 
        echo "ERROR: Param 1 must be either 'release' or 'unrelease'. Exiting."
        exit 1
    fi 

    if [ "x$TAG" == "x" ] || [ ${TAG:0:1} == "v" ]; then 
        echo "ERROR: Param 2 must be the version WITHOUT a leading 'v', e.g. 1.0.1.  Exiting."
        exit 1
    fi 
    if [ ! -x $(which chag) ]; then 
        echo "ERROR: chag not found."
        echo "-> https://github.com/mtdowling/chag"
        exit 1
    fi    
    export TAG
    export VTAG="v$TAG"
    export preVTAG="pre-$VTAG"
    if [ $MODE == 'release' ]; then 
        release
    elif [ $MODE == 'unrelease' ]; then
        unrelease
    fi
}


function release() {
    do_asserts

    header "Setting pre-release tag $preVTAG ..."
    git tag $preVTAG
    header "Moving changelog entries from Unreleased to $TAG ..."
    chag update $TAG
    header "Committing: 'CHANGELOG: $VTAG'"
    git add . && git commit -m "CHANGELOG: $VTAG"

    header "Committing: 'Version bump $VTAG'"
    git add . && git commit -m "Version bump: $VTAG"
    # Workflow result and artifacts are on https://github.com/elabit/__REPO__/actions/workflows/mkp-artifact.yml

    header "Merging develop into master..."
    git checkout master
    git merge develop --no-ff --no-edit --strategy-option theirs
    header "Create annotated git tag from Changelog entry ..."
    # Ref xBCjym
    chag tag --addv
    header "Pushing ..."
    git push origin master
    git push origin $VTAG
    git checkout develop
}

function unrelease() {
    assert_gh_login
    assert_branch "develop"
    # assert_notdirty
    header "Changing to develop branch ..."
    git checkout develop
    header "Removing the release with tag $VTAG ..."
    gh release delete $VTAG -y
    header "Removing tags ..."
    git push origin :refs/tags/$VTAG 
    header "Removing tags ..."
    git tag -d $VTAG
    #header "Resetting the 'develop' branch to the tag $preVTAG ..."
    #git reset --hard $preVTAG
    #git tag -d $preVTAG 
}

function do_asserts() {
    assert_gh_login
    assert_tag_unique $VTAG
    assert_branch "develop"
    assert_notdirty
    assert_changelog
}

function assert_changelog() {
    # Check if CHANGELOG exists
    if [ ! -f CHANGELOG.md ]; then 
        echo "ERROR: No CHANGELOG.md found. Exiting."
        exit 1
    fi
}

function assert_branch {
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    if [[ "$BRANCH" != $1 ]]; then
        echo "ERROR: You are not in branch '$1'. Exiting."
        exit 1
    fi
}

function assert_notdirty {
    if [ -n "$(git status --porcelain)" ]; then 
        echo "ERROR: The working area is dirty; please commit first! Exiting."
        exit 1
    fi
}

function header() {
    echo "========================="
    echo "$1"
}

function assert_gh_login() {
    gh auth status 2>&1 > /dev/null
    if [ $? -gt 0 ]; then 
        echo "ERROR: you do not seem to be logged in with gh CLI. Exiting."
        exit 1
    fi 
}

function assert_tag_unique(){
    git tag | egrep -q "^$1$"
    if [ $? -eq 0 ]; then 
        echo "ERROR: Tag $1 exists already. Exiting."
        exit 1
    fi
}


main $@
