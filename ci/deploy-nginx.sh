#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cf push -f source/nginx/manifest.yml 

cf add-network-policy clamav-rest clamav-rest-endpoint --protocol tcp --port 8080

    