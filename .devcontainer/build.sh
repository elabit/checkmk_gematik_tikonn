#!/bin/bash
# SPDX-FileCopyrightText: © 2022 ELABIT GmbH <mail@elabit.de>
# SPDX-License-Identifier: GPL-3.0-or-later

# This file creates a CMK MKP file for the project. 
# It leverages the "mkp" command from CMK, which reads a package description file
# (JSON).
# After the MKP has been built, the script check if it runs within a Github 
# Workflow. If so, it sets the artifact name as output variable.  
set -e

if [ -z $WORKSPACE ]; then 
    echo "ERROR: WORKSPACE variable must be set to the project root folder. Exiting."
    exit 1
fi

if [ -z $OMD_SITE ]; then 
    echo "ERROR: You do not seem to be on a OMD site (variable OMD_SITE not set). Exiting."
    exit 1
fi 
echo "Starting MKP build script"

set -u 
# set -x 
# Read the project name
source $WORKSPACE/project.env
# checkmk_my_check -> my_check
CHECK_NAME=${PROJECT_NAME#*_}
PKGFILE=$OMD_ROOT/var/check_mk/packages/package


echo "Copying $WORKSPACE/package to $PKGFILE.tmp ..."
cp -f $WORKSPACE/package $PKGFILE.tmp
PKGNAME=$(jq -r '.name' $PKGFILE.tmp)

echo "Package file content:"
cat $PKGFILE.tmp
# get the current tag (if Release) or commit hash...
export PKGVERSION=$(git describe --exact-match --tags 2> /dev/null || git rev-parse --short HEAD)
echo "---------------------------------------------"
echo "▹ Merging package version '$PKGVERSION' into $PKGFILE ..."
cat $PKGFILE.tmp | jq '. + {version:env.PKGVERSION}' > $PKGFILE


echo "---------------------------------------------"
echo "▹ Building MKP '$PKGNAME' (packagefile: $PKGFILE) ..."
# set -x
echo "> mkp -v pack $PKGNAME"
mkp -v pack $PKGNAME

# get the latest written file
FILE=$(ls -rt1 *.mkp | tail -1)
NEWFILENAME=$PKGNAME.$PKGVERSION.mkp
mv $FILE $NEWFILENAME
PKG_PATH=$(readlink -f "$NEWFILENAME")
echo "📦 -> $PKG_PATH"
echo "---------------------------------------------"
echo "Checking if we are running within a Github Workflow..."
if [ -n "${GITHUB_WORKSPACE-}" ]; then
    echo "🐙 ...Github Workflow exists."
    echo "▹ Set Outputs for GitHub Workflow steps"
    echo "::set-output name=pkgfile::$NEWFILENAME"
    VERSION=$(jq -r '.version' $PKGFILE)
    echo "::set-output name=artifactname::$NEWFILENAME"
else 
    echo "...no GitHub Workflow detected (local execution)."
fi
echo "END OF build.sh"
echo "---------------------------------------------"