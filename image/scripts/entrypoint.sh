#!/bin/bash

# cp /etc/clamav/* /etc/clamav

# Replace values in freshclam.conf
# sed -i 's/^#\?NotifyClamd .*$/NotifyClamd \/etc\/clamav\/clamd.conf/g' /etc/clamav/freshclam.conf
# sed -i 's/^#DatabaseDirectory .*$/DatabaseDirectory \/etc\/clamav\/data/g' /etc/clamav/freshclam.conf
# sed -i 's/^#\?NotifyClamd .*$/NotifyClamd \/etc\/clamav\/\/clamd.conf/g' /etc/clamav/freshclam.conf
# sed -i 's/^#TemporaryDirectory .*$/TemporaryDirectory \/etc\/clamav\/tmp/g' /etc/clamav/clamd.conf
# sed -i 's/^#DatabaseDirectory .*$/DatabaseDirectory \/etc\/clamav\/data/g' /etc/clamav/clamd.conf

# Replace values with environment variables in freshclam.conf
# sed -i 's/^#\?Checks .*$/Checks '"$SIGNATURE_CHECKS"'/g' /etc/clamav/freshclam.conf

# Replace values with environment variables in clamd.conf
# sed -i 's/^#MaxScanSize .*$/MaxScanSize '"$MAX_SCAN_SIZE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#StreamMaxLength .*$/StreamMaxLength '"$MAX_FILE_SIZE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxFileSize .*$/MaxFileSize '"$MAX_FILE_SIZE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxRecursion .*$/MaxRecursion '"$MAX_RECURSION"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxFiles .*$/MaxFiles '"$MAX_FILES"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxEmbeddedPE .*$/MaxEmbeddedPE '"$MAX_EMBEDDEDPE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxHTMLNormalize .*$/MaxHTMLNormalize '"$MAX_HTMLNORMALIZE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxHTMLNoTags.*$/MaxHTMLNoTags '"$MAX_HTMLNOTAGS"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxScriptNormalize .*$/MaxScriptNormalize '"$MAX_SCRIPTNORMALIZE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxZipTypeRcg .*$/MaxZipTypeRcg '"$MAX_ZIPTYPERCG"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxPartitions .*$/MaxPartitions '"$MAX_PARTITIONS"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#MaxIconsPE .*$/MaxIconsPE '"$MAX_ICONSPE"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#PCREMatchLimit.*$/PCREMatchLimit '"$PCRE_MATCHLIMIT"'/g' /etc/clamav/clamd.conf
# sed -i 's/^#PCRERecMatchLimit .*$/PCRERecMatchLimit '"$PCRE_RECMATCHLIMIT"'/g' /etc/clamav/clamd.conf
# echo "TCPSocket 3310" >> /etc/clamav/clamd.conf

# if [ -z "$(ls -A /clamav/data)" ]; then
#   cp /var/lib/clamav/* /clamav/data/
# fi

(
    echo " "
    echo "Starting clamd"
    clamd --config-file=/etc/clamav/clamd.conf &

    sleep 15 # let clamav start

    echo " "
    echo "Starting freshclam"
    freshclam --config-file=/etc/clamav/freshclam.conf \
        --log=/var/log/clamav/freshclam.log \
        --daemon-notify=/etc/clamav/clamd.conf \
        --checks=24 \
        --daemon &

    echo " "    
    echo "Starting clamav-rest"
    /usr/bin/clamav-rest &

) 2>&1 | tee -a /var/log/clamav/clamav.log

pids=`jobs -p`

exitcode=0

terminate() {
    for pid in $pids; do
        if ! kill -0 $pid 2>/dev/null; then
            wait $pid
            exitcode=$?
        fi
    done
    kill $pids 2>/dev/null
}

trap terminate CHLD
wait

exit $exitcode
