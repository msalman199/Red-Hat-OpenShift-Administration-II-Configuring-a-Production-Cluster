#!/bin/bash

echo "=== OpenShift Route Testing Script ==="
echo

# Get route information
BASIC_ROUTE=$(oc get route webapp-secure -o jsonpath='{.spec.host}' 2>/dev/null)
CUSTOM_ROUTE=$(oc get route webapp-custom-cert -o jsonpath='{.spec.host}' 2>/dev/null)

if [ -n "$BASIC_ROUTE" ]; then
    echo "Testing basic secure route: $BASIC_ROUTE"
    echo "1. Testing HTTPS access:"
    curl -s -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n" https://$BASIC_ROUTE -k
    
    echo "2. Testing HTTP redirect:"
    curl -s -o /dev/null -w "Status: %{http_code}, Redirect: %{redirect_url}\n" http://$BASIC_ROUTE
    echo
fi

if [ -n "$CUSTOM_ROUTE" ]; then
    echo "Testing custom certificate route: $CUSTOM_ROUTE"
    echo "3. Testing HTTPS access:"
    curl -s -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n" https://$CUSTOM_ROUTE -k
    echo
fi

echo "4. Checking route configurations:"
oc get routes -o wide
