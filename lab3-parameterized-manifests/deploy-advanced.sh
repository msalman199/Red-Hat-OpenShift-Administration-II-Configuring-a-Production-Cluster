#!/bin/bash

usage() {
    echo "Usage: $0 <environment>"
    echo "Available environments: dev, staging, prod"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

ENVIRONMENT=$1
ENV_FILE="environments/${ENVIRONMENT}.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE not found!"
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment with advanced configuration..."

# Source the environment variables
set -a
source "$ENV_FILE"
set +a

# Create output directory
mkdir -p "output/${ENVIRONMENT}"

# Process all templates
for template in templates/*.yaml; do
    filename=$(basename "$template")
    envsubst < "$template" > "output/${ENVIRONMENT}/$filename"
    echo "Generated: output/${ENVIRONMENT}/$filename"
done

# Apply the manifests
echo "Applying manifests to cluster..."
kubectl apply -f "output/${ENVIRONMENT}/"

echo "Advanced deployment completed for $ENVIRONMENT environment!"

# Show deployment status
echo
echo "Deployment Status:"
kubectl get all -l environment="$ENVIRONMENT"
