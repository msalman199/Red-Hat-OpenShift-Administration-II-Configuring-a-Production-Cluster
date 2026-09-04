#!/bin/bash

echo "=== OpenShift Upgrade Monitor ==="
echo "Starting monitoring at $(date)"

while true; do
    echo "--- $(date) ---"
    
    # Check cluster version
    echo "Cluster Version:"
    oc get clusterversion version --no-headers
    
    # Check cluster operators
    echo "Degraded Operators:"
    oc get clusteroperators | grep -v "True.*False.*False" | tail -n +2
    
    # Check node status
    echo "Node Status:"
    oc get nodes --no-headers | awk '{print $1, $2}'
    
    # Check test application
    echo "Test App Status:"
    oc get pods -n upgrade-test --no-headers | awk '{print $1, $3}'
    
    echo "------------------------"
    sleep 30
done
