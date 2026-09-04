#!/bin/bash

echo "=== Monitoring SCC-related Events ==="
echo "Recent events related to security context constraints:"

oc get events --all-namespaces --field-selector reason=FailedCreate,reason=FailedMount | grep -i scc
oc get events --all-namespaces --field-selector reason=SecurityContextConstraintsAdmission

echo ""
echo "=== Current Pod Security Contexts ==="
for pod in $(oc get pods -o name); do
    echo "Pod: $pod"
    oc get $pod -o jsonpath='{.metadata.annotations.openshift\.io/scc}{"\n"}'
done
