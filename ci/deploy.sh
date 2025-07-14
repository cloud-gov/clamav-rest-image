#!/bin/bash

set -e

ecr_repository=$(cat clamav-rest-image/.repository)
image_version=$(cat clamav-rest-image/.tag)

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cf push -f source/cf/manifest.yml \
    --var docker_username=${docker_username} \
    --var ecr_repository=${ecr_repository} \
    --var image_version=${image_version}
    