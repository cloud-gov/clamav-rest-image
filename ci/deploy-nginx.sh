#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

pushd source/nginx
    cf push -f manifest.yml --var concourse_garden_ip_range1="${CONCOURSE_GARDEN_IP_RANGE1}" --var concourse_garden_ip_range2="${CONCOURSE_GARDEN_IP_RANGE2}"
popd

cf add-network-policy clamav-rest clamav-rest-endpoint --protocol tcp --port 8080

    