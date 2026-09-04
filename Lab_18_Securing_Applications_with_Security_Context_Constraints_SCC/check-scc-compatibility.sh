#!/bin/bash

echo "=== SCC Compatibility Check ==="
echo "Checking which SCCs are available to each service account..."

for sa in privileged-sa moderate-sa restricted-sa; do
    echo ""
    echo "Service Account: $sa"
    echo "Available SCCs:"
    oc policy can-i use scc --as=system:serviceaccount:scc-lab:$sa --list | grep scc
done
