#!/bin/bash

set -e

cf api $CF_API
cf auth

cf t -o $CF_ORG -s $CF_SPACE

app_guid=$(cf app clamav-rest --guid)
clamav_rest_route=$(cf curl "/v3/apps/${app_guid}/routes" | jq -r '.resources[].url[0]')

clamav_rest_endpoint="https://${clamav_rest_route}"

version_result=$(curl -s ${clamav_rest_endpoint}/version | jq -r '.Clamav')
if [[ -z "$version_result" ]]; then
    echo "FAILED: Endpoint failed to return ClamAV version: ${version_result}" 
    exit 1
else 
    echo "PASSED: Endpoint returned ClamAV version: ${version_result}"
fi

# test clean file
clean_result_http_status=$(curl -s -o clean_response.txt -w "%{response_code}" -F "file=@source/test/tasks/test-files/clean.test" ${clamav_rest_endpoint}/v2/scan)
clean_result_body_status=$(cat clean_response.txt | jq -r '.[].Status')
if [[ "200" != "$clean_result_http_status" ]] || [[ "OK" != "$clean_result_body_status" ]]; then
    echo "TEST FAILED: Scanning clean file failed. http_status: expected \"200\", got \"${clean_result_http_status}\". body_status: expected \"OK\", got \"${clean_result_body_status}\"." 
else
    echo "PASSED: Clean file scanned correctly. http_status: \"${clean_result_http_status}\". body_status: \"${clean_result_body_status}\""
fi 

# test eicar file
eicar_result_http_status=$(curl -s -o eicar_response.txt -w "%{response_code}" -F "file=@source/test/tasks/test-files/eicar.test" ${clamav_rest_endpoint}/v2/scan)
eicar_result_body_status=$(cat eicar_response.txt | jq -r '.[].Status')
if [[ "406" != "$eicar_result_http_status" ]] || [[ "FOUND" != "$eicar_result_body_status" ]]; then
    echo "TEST FAILED: Scanning eicar file failed. http_status: expected \"406\", got \"${eicar_result_http_status}\". body_status: expected \"FOUND\", got \"${eicar_result_body_status}\"."
else
    echo "PASSED: Eicar file scanned correctly. http_status: \"${eicar_result_http_status}\". body_status: \"${eicar_result_body_status}\""
fi 


# ensure access from CF apps is blocked.
blocked_invocation=$(cf ssh -t clamav-rest -c 'curl https://clamav-rest.dev.us-gov-west-1.aws-us-gov.cloud.gov/version 2>&1' | grep "Connection refused")
if [ -z "$blocked_invocation" ];then
    echo "FAILED: Expected execution from CloudFoundry to be blocked"
    exit 1
fi

# invocation from inside this app should succeed
direct_invocation=$(cf ssh clamav-rest -c "curl http://clamav-rest-endpoint.apps.internal:8080/version | jq -r '.Clamav'")
if [[ -z "$direct_invocation" ]]; then
    echo "FAILED: Endpoint failed to return ClamAV version: ${version_result}" 
    exit 1
fi
