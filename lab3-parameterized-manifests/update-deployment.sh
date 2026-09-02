#!/bin/bash

usage() {
    echo "Usage: $0 <environment> [--replicas <count>] [--image-tag <tag>]"
    echo "Example: $0 dev --replicas 2 --image-tag 1.22-alpine"
    exit 1
}

if [ $# -lt 2 ]; then
    usage
fi

ENVIRONMENT=$1
shift

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --replicas)
            NEW_REPLICAS="$2"
            shift 2
            ;;
        --image-tag)
            NEW_IMAGE_TAG="$2"
            shift 2
            ;;
        *)
            echo "Unknown option $1"
            usage
            ;;
    esac
done

DEPLOYMENT_NAME="webapp-${ENVIRONMENT}"

# Check if deployment exists
if ! kubectl get deployment "$DEPLOYMENT_NAME" > /dev/null 2>&1; then
    echo "Error: Deployment $DEPLOYMENT_NAME not found!"
    exit 1
fi

echo "Updating deployment: $DEPLOYMENT_NAME"

# Update replicas if specified
if [ ! -z "$NEW_REPLICAS" ]; then
    echo "Scaling to $NEW_REPLICAS replicas..."
    kubectl scale deployment "$DEPLOYMENT_NAME" --replicas="$NEW_REPLICAS"
    
    # Update the environment file
    ENV_FILE="environments/${ENVIRONMENT}.env"
    if [ -f "$ENV_FILE" ]; then
        sed -i "s/REPLICA_COUNT=.*/REPLICA_COUNT=$NEW_REPLICAS/" "$ENV_FILE"
        echo "Updated $ENV_FILE with new replica count"
    fi
fi

# Update image tag if specified
if [ ! -z "$NEW_IMAGE_TAG" ]; then
    # Get current image name
    CURRENT_IMAGE=$(kubectl get deployment "$DEPLOYMENT_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}')
    IMAGE_NAME=$(echo "$CURRENT_IMAGE" | cut -d':' -f1)
    NEW_IMAGE="${IMAGE_NAME}:${NEW_IMAGE_TAG}"
    
    echo "Updating image to $NEW_IMAGE..."
    kubectl set image deployment/"$DEPLOYMENT_NAME" webapp="$NEW_IMAGE"
    
    # Update the environment file
    ENV_FILE="environments/${ENVIRONMENT}.env"
    if [ -f "$ENV_FILE" ]; then
        sed -i "s/IMAGE_TAG=.*/IMAGE_TAG=$NEW_IMAGE_TAG/" "$ENV_FILE"
        echo "Updated $ENV_FILE with new image tag"
    fi
fi

echo "Update completed!"
echo "Current deployment status:"
kubectl get deployment "$DEPLOYMENT_NAME" -o wide
