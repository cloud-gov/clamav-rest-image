#!/bin/bash

set -e

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

pushd source


    source ci/setup-github.sh
    source ci/setup-gpg.sh

    set -x 

    git pull --rebase
    branch_name=$(dependencies-branch)
    dependencies-branch=$(git branch -r list | grep $branch_name)
    if [ -z $branch_name ]; then
        git checkout -b $branch_name
    else 
        git checkout $branch_name
    fi
        
    echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
    echo "GO_VERSION=${go_version}" >> image/args/build-args.conf
    cat image/args/build-args.conf

    git commit -S -m "update depenedencies" image/args/build-args.conf

popd
