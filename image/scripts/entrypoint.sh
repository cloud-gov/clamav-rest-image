#!/bin/bash

echo " "
echo "Starting clamd"
clamd --config-file=/etc/clamav/clamd.conf &

sleep 10 # let clamav start

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
