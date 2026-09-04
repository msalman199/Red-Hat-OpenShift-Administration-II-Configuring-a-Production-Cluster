#!/bin/bash

SUCCESS=0
FAILURE=0

while true; do
    if oc get pods -n upgrade-test | grep -q "Running"; then
        if curl -s http://localhost:8080 > /dev/null; then
            SUCCESS=$((SUCCESS + 1))
            echo "$(date): SUCCESS - Total: $SUCCESS, Failures: $FAILURE"
        else
            FAILURE=$((FAILURE + 1))
            echo "$(date): FAILURE - Total: $SUCCESS, Failures: $FAILURE"
        fi
    else
        echo "$(date): Pods not ready"
    fi
    sleep 5
done
