#!/bin/bash

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

cf delete -fr  ${CLAMAV_REST_HOSTNAME}

cf delete -fr  ${CLAMAV_REST_HOSTNAME}-test
