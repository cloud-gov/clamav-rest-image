#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

pushd source/nginx
    cf push -f manifest.yml 
popd

cf add-network-policy clamav-rest clamav-rest-endpoint --protocol tcp --port 8080

    