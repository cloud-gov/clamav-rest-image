#!/bin/bash

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

pushd source
    gpg --batch --import private.key
    
    git config --global user.email "no-reply@cloud.gov"
    git config --global user.name "cg-ci-bot"
    git config commit.gpgsign true


    echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
    echo "GO_VERSION=${go_version}" >> image/args/build-args.conf
    cat image/args/build-args.conf
    git checkout -b depenedencies
    git commit -m "update depenedencies" image/args/build-args.conf
popd
