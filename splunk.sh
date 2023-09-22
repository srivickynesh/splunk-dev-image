#!/bin/bash

export SPLUNK_HOME=/opt/splunk
export SPLUNK_PASSWORD="Password"
export SPLUNK_START_ARGS="'--accept-license'"

/sbin/entrypoint.sh start-service >> $SPLUNK_HOME/output.log 2>&1 &

# Wait for Splunk to start
timeout_start=$(date +%s)
while true; do
    if grep -q "Ansible playbook complete" $SPLUNK_HOME/output.log; then
        break
    fi
    if [ "$(($(date +%s) - timeout_start))" -ge 120 ]; then
        cat $SPLUNK_HOME/output.log >&2
        echo "The Splunk instance is not up after waiting for 2 minutes." >&2
        exit 1
    fi
    sleep 5
done

for i in {1..12}; do
    curl -k -s https://localhost:8089 | grep "Splunk" && break
    sleep 5
    [ $i -eq 12 ] && echo "Timeout reached: Unable to find Splunk after 60 seconds." && exit 1
done

# Shut down the Splunk service
sudo -u splunk /opt/splunk/bin/splunk stop
