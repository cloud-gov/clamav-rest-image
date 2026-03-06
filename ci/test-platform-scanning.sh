#!/bin/bash

clamav_rest_endpoint="https://clamav-rest.${CF_DOMAIN}"

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
