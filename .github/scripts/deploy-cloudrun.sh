#!/bin/bash
# =============================================================================
# CLOUD RUN DEPLOYMENT SCRIPT
# =============================================================================

set -euo pipefail

GCP_PROJECT="$1"
GCP_REGION="$2"
IMAGE_TAG="$3"
ENVIRONMENT="$4"

echo "==> Deploying to Cloud Run"
echo "    Project: ${GCP_PROJECT}"
echo "    Region: ${GCP_REGION}"
echo "    Tag: ${IMAGE_TAG}"
echo "    Environment: ${ENVIRONMENT}"

# Function to deploy a service
deploy_service() {
    local service_name=$1
    local image=$2
    local port=$3
    local memory=$4
    local cpu=$5
    
    echo ""
    echo "==> Deploying ${service_name}..."
    
    # Check if service exists
    if gcloud run services describe "${service_name}" --region="${GCP_REGION}" --project="${GCP_PROJECT}" &>/dev/null; then
        echo "    Service exists, updating..."
    else
        echo "    Creating new service..."
    fi
    
    # Deploy the service
    gcloud run deploy "${service_name}" \
        --image "${image}" \
        --region "${GCP_REGION}" \
        --project "${GCP_PROJECT}" \
        --port "${port}" \
        --memory "${memory}" \
        --cpu "${cpu}" \
        --concurrency 1000 \
        --max-instances 10 \
        --min-instances 0 \
        --timeout 300s \
        --no-allow-unauthenticated \
        --set-env-vars "ENVIRONMENT=${ENVIRONMENT}" \
        --set-env-vars "PROJECT_ID=${GCP_PROJECT}" \
        || {
            echo "    WARNING: Failed to deploy ${service_name}"
            return 1
        }
    
    echo "    ✓ ${service_name} deployed"
    return 0
}

# Deploy Redis (if using Redis Labs or similar, otherwise skip)
if [[ -f "services/redis/Dockerfile" ]]; then
    deploy_service "infra-redis" \
        "gcr.io/${GCP_PROJECT}/redis:${IMAGE_TAG}" \
        6379 \
        "512Mi" \
        "1" \
        || echo "Skipping Redis deployment"
fi

# Deploy NATS
deploy_service "infra-nats" \
    "gcr.io/${GCP_PROJECT}/nats:${IMAGE_TAG}" \
    4222 \
    "512Mi" \
    "1" \
    || echo "Skipping NATS deployment"

# Deploy Qdrant
if [[ -f "services/qdrant/Dockerfile" ]]; then
    deploy_service "infra-qdrant" \
        "gcr.io/${GCP_PROJECT}/qdrant:${IMAGE_TAG}" \
        6333 \
        "1Gi" \
        "1" \
        || echo "Skipping Qdrant deployment"
fi

echo ""
echo "==> Cloud Run deployment complete"
echo ""
echo "Deployed services:"
gcloud run services list --region="${GCP_REGION}" --project="${GCP_PROJECT}" --format="table(metadata.name,status.address.url)" 2>/dev/null || true
