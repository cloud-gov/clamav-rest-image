#!/bin/bash

set -e

this_directory=$(dirname "$0")

cd ${this_directory}/test-files

echo "Running clamav-rest tests for ${CLAMAV_REST_ENDPOINT}..."

test_count=0
fail_count=0

# ensure the endpoint is running
test_count=$((test_count + 1))
version_test="failed"
version_result=$(curl -s ${CLAMAV_REST_ENDPOINT}/version | jq -r '.Clamav')
if [[ -z "$version_result" ]]; then
    echo "FAILED: Endpoint failed to return ClamAV version: ${version_result}" >&2
    fail_count=$((fail_count + 1))
else 
    version_test="passed"
    echo "PASSED: Endpoint returned ClamAV version: ${version_result}"
fi

# test clean file
test_count=$((test_count + 1))
clean_test="failed"
clean_result_http_status=$(curl -s -o clean_response.txt -w "%{response_code}" -F "file=@clean.test" ${CLAMAV_REST_ENDPOINT}/v2/scan)
clean_result_body_status=$(cat clean_response.txt | jq -r '.[].Status')
if [[ "200" != "$clean_result_http_status" ]] || [[ "OK" != "$clean_result_body_status" ]]; then
    echo "TEST FAILED: Scanning clean file failed. http_status: expected \"200\", got \"${clean_result_http_status}\". body_status: expected \"OK\", got \"${clean_result_body_status}\"." >&2
    fail_count=$((fail_count + 1))
else
    clean_test="passed"
    echo "PASSED: Clean file scanned correctly. http_status: \"${clean_result_http_status}\". body_status: \"${clean_result_body_status}\""
fi 

# test eicar file
test_count=$((test_count + 1))
eicar_test="failed"
eicar_result_http_status=$(curl -s -o eicar_response.txt -w "%{response_code}" -F "file=@eicar.test" ${CLAMAV_REST_ENDPOINT}/v2/scan)
eicar_result_body_status=$(cat eicar_response.txt | jq -r '.[].Status')
if [[ "406" != "$eicar_result_http_status" ]] || [[ "FOUND" != "$eicar_result_body_status" ]]; then
    echo "TEST FAILED: Scanning eicar file failed. http_status: expected \"406\", got \"${eicar_result_http_status}\". body_status: expected \"FOUND\", got \"${eicar_result_body_status}\"." >&2
    fail_count=$((fail_count + 1))
else
    eicar_test="passed"
    echo "PASSED: Eicar file scanned correctly. http_status: \"${eicar_result_http_status}\". body_status: \"${eicar_result_body_status}\""
fi 

# test large file
test_count=$((test_count + 1))
wget -q https://github.com/cloudfoundry/loggregator-release/releases/download/v107.0.21/loggregator-107.0.21.tgz
large_test="failed"
large_result_http_status=$(curl -s -o large_response.txt -w "%{response_code}" -F "file=@loggregator-107.0.21.tgz" ${CLAMAV_REST_ENDPOINT}/v2/scan)
large_result_body_status=$(cat large_response.txt | jq -r '.[].Status')
if [[ "200" != "$large_result_http_status" ]] || [[ "OK" != "$large_result_body_status" ]]; then
    echo "TEST FAILED: Scanning large file failed. http_status: expected \"200\", got \"${large_result_http_status}\". body_status: expected \"OK\", got \"${large_result_body_status}\". File size: $(du -h loggregator-107.0.21.tgz)." >&2
    fail_count=$((fail_count + 1))
else
    large_test="passed"
    echo "PASSED: Large file scanned correctly. http_status: \"${large_result_http_status}\". body_status: \"${large_result_body_status}\". File size: $(du -h loggregator-107.0.21.tgz)."
fi 

# test oversized file
test_count=$((test_count + 1))
wget -q https://github.com/cloudfoundry/system-metrics-release/releases/download/v3.0.13/system-metrics-3.0.13.tgz
oversize_test="failed"
oversize_result_http_status=$(curl -s -o oversize_response.txt -w "%{response_code}" -F "file=@system-metrics-3.0.13.tgz" ${CLAMAV_REST_ENDPOINT}/v2/scan)
oversize_result_body_status=$(cat oversize_response.txt | jq -r '.[].Status')
if [[ "413" != "$oversize_result_http_status" ]] || [[ "PARSE ERROR" != "$oversize_result_body_status" ]]; then
    echo "TEST FAILED: Scanning oversize file failed. http_status: expected \"413\", got \"${oversize_result_http_status}\". body_status: expected \"PARSE ERROR\", got \"${oversize_result_body_status}\". File size: $(du -h system-metrics-3.0.13.tgz)." >&2
    fail_count=$((fail_count + 1))
else
    oversize_test="passed"
    echo "PASSED: Oversize file rejected correctly. http_status: \"${oversize_result_http_status}\". body_status: \"${oversize_result_body_status}\". File size: $(du -h system-metrics-3.0.13.tgz)."
fi 

if [[ "$fail_count" != 0 ]]; then
    echo "Tests failed. $fail_count FAILED out of $total_count."
    exit 1
else 
    echo "Tests complete. $test_count PASSED. 0 FAILED."
    exit 0
fi


