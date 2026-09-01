#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <environment>"
    echo "Available environments: dev, staging, prod"
    exit 1
}

# Check if environment parameter is provided
if [ $# -eq 0 ]; then
    usage
fi

ENVIRONMENT=$1
ENV_FILE="environments/${ENVIRONMENT}.env"

# Check if environment file exists
if [ ! -f "$ENV_FILE" ]; then
    echo "Error: Environment file $ENV_FILE not found!"
    echo "Available environments:"
    ls environments/*.env 2>/dev/null | sed 's/environments\///g' | sed 's/\.env//g'
    exit 1
fi

echo "Deploying to $ENVIRONMENT environment..."

# Source the environment variables
set -a
source "$ENV_FILE"
set +a

# Create output directory
mkdir -p "output/${ENVIRONMENT}"

# Process deployment template
envsubst < templates/webapp-deployment.yaml > "output/${ENVIRONMENT}/webapp-deployment.yaml"

# Process service template
envsubst < templates/webapp-service.yaml > "output/${ENVIRONMENT}/webapp-service.yaml"

echo "Generated manifests for $ENVIRONMENT environment:"
echo "- output/${ENVIRONMENT}/webapp-deployment.yaml"
echo "- output/${ENVIRONMENT}/webapp-service.yaml"

# Apply the manifests
echo "Applying manifests to cluster..."
kubectl apply -f "output/${ENVIRONMENT}/"

echo "Deployment completed for $ENVIRONMENT environment!"
