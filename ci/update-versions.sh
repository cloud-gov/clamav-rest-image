#!/bin/bash

set -e

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

pushd source
    # gpg setup
    ci/setup-gpg.sh

    branch_name=dependencies

    echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
    echo "GO_VERSION=${go_version}" >> image/args/build-args.conf
    cat image/args/build-args.conf

    set -x

    if ! git rev-parse --verify $branch_name >/dev/null 2>&1; then
        git checkout -b $branch_name
    else 
        git checkout $branch_name
    fi
    git commit -S -m "update depenedencies" image/args/build-args.conf
popd
