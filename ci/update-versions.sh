#!/bin/bash

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

pushd source
    # gpg setup
    ci/setup-gpg.sh

    echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
    echo "GO_VERSION=${go_version}" >> image/args/build-args.conf
    cat image/args/build-args.conf
    git checkout -b depenedencies
    git commit -S -m "update depenedencies" image/args/build-args.conf
popd
