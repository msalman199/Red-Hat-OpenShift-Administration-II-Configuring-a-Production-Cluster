#!/bin/bash

echo "=== Webapp Deployment Status ==="
echo "Date: $(date)"
echo

# Function to display deployment info
show_deployment_info() {
    local env=$1
    local deployment="webapp-${env}"
    
    if kubectl get deployment "$deployment" > /dev/null 2>&1; then
        echo "Environment: $env"
        echo "Deployment: $deployment"
        
        # Get deployment details
        REPLICAS=$(kubectl get deployment "$deployment" -o jsonpath='{.spec.replicas}')
        READY_REPLICAS=$(kubectl get deployment "$deployment" -o jsonpath='{.status.readyReplicas}')
        IMAGE=$(kubectl get deployment "$deployment" -o jsonpath='{.spec.template.spec.containers[0].image}')
        
        echo "  Replicas: ${READY_REPLICAS:-0}/${REPLICAS}"
        echo "  Image: $IMAGE"
        echo "  Status: $(kubectl get deployment "$deployment" -o jsonpath='{.status.conditions[?(@.type=="Available")].status}')"
        echo
    else
        echo "Environment: $env - NOT DEPLOYED"
        echo
    fi
}

# Check all environments
for env in dev staging prod; do
    show_deployment_info "$env"
done

echo "=== Pod Status ==="
kubectl get pods -l app=webapp -o wide

echo
echo "=== Service Status ==="
kubectl get services -l app=webapp -o wide
