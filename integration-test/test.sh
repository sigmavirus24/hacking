#!/bin/bash

# Usage: test.sh openstack keystone path-to-repo
# path-to-repo is an optional parameter, if it exists
# no cloning will happen and the local directory will be used,
# the first two parameter get ignored.
# Note: you can clone from a local file with REPO_ROOT=file:////~/path/to/repo

set -x
set -e

REPO_ROOT=${REPO_ROOT:-git://git.openstack.org}

if [[ -z "$2" ]]; then
    org=openstack
    project=nova
else
    org=$1
    project=$2
fi
if [[ $# -eq 3 ]] ; then
    projectdir=$3
    clone=0
else
    clone=1
    projectdir=$project
fi

if [ "$clone" = "1" ] ; then

    tempdir="$(mktemp -d)"

    trap "rm -rf $tempdir" EXIT
    pushd $tempdir
    if [[ $REPO_ROOT  == file://* ]]; then
        git clone $REPO_ROOT/$org/$project
    else
        git clone $REPO_ROOT/$org/$project --depth=1
    fi
fi

pushd $projectdir
set +e
flake8 --select H --statistics
popd

if [ "$clone" = "1" ] ; then
    popd
fi
