#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cd source/test


if [[ "$CLAMAV_REST_DOMAIN" == "apps.internal" ]]; then
    clamav_rest_endpoint="https://${CLAMAV_REST_HOSTNAME}.${CLAMAV_REST_DOMAIN}:443"
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
    echo "All tests passed."
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent | tail -n 25 | grep 'OUT PASSED')"
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent | tail -n 25 | grep 'OUT Tests complete')"
else 
    echo "Tests failed."
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent | tail -n 25 | grep 'ERR FAILED')"  
    echo " "
    echo "Here are all the recent logs to help you sort it out."
    echo " "
    echo "$(cf logs ${CLAMAV_REST_HOSTNAME}-test --recent)"
    exit 1
fi
