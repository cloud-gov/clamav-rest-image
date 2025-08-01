#!/bin/bash

set -e

ecr_repository=$(cat clamav-rest-candidate-image/repository)
image_version=$(cat clamav-rest-candidate-image/tag)

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cf push -f source/cf/manifest.yml \
    --var app_name=${CLAMAV_REST_HOSTNAME} \
    --var docker_username=${CF_DOCKER_USERNAME} \
    --var ecr_repository=${ecr_repository} \
    --var route=${CLAMAV_REST_HOSTNAME}.${CLAMAV_REST_DOMAIN} \
    --var image_version=${image_version}
    