#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cd source/test


if [[ "$CLAMAV_REST_DOMAIN" == "apps.internal" ]]; then
    clamav_rest_endpoint="http://${CLAMAV_REST_HOSTNAME}.${CLAMAV_REST_DOMAIN}:8080"
else 
    clamav_rest_endpoint="https://${CLAMAV_REST_HOSTNAME}.${CLAMAV_REST_DOMAIN}"
fi 

cf push \
    --var clamav_rest_endpoint=${clamav_rest_endpoint} \
    --var app_name=${CLAMAV_REST_HOSTNAME}-test

cf add-network-policy ${CLAMAV_REST_HOSTNAME}-test ${CLAMAV_REST_HOSTNAME}

set +e
cf run-task ${CLAMAV_REST_HOSTNAME}-test -c "tasks/run-tests.sh" -w
test_exit_code=$?
set -e

if [[ "$test_exit_code" == "0" ]]; then
    echo "Tests passed. Enjoy the last 10 recent logs..."
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent | tail -n 10)"
else 
    echo "Tests failed. Here are the recent logs to help you figure out why..."
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent)"    
    exit 1
fi
