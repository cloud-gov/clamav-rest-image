#!/bin/bash

set -e

clamav_rest_version=$(cat clamav-rest-release/version)
go_version=$(curl -s "https://go.dev/VERSION?m=text" | head -n 1)

# gpg setup
source/ci/setup-gpg.sh

if [ -d dependencies-branch ]; then
    cd dependencies-branch
else 
    git checkout -b ${branch_name}
fi
    
echo "CLAMAV_REST_VERSION=${clamav_rest_version}" > image/args/build-args.conf
echo "GO_VERSION=${go_version}" >> image/args/build-args.conf
cat image/args/build-args.conf

git commit -S -m "update depenedencies" image/args/build-args.conf

