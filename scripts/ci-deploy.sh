#!/bin/bash
set -e

checkoutClusterClaim() {
    echo "Log in to Collective"

    oc login ${_AWS_CLUSTERPOOL_API_URL} --insecure-skip-tls-verify --token="${_AWS_CLUSTERPOOL_TOKEN}"
    echo "Logged in"
}

echo "= CI Deployment Script ="
_cloud_provider=$1

echo "==> Deploying ACM-AAP-AAS-Operations to ${_cloud_provider}..."

# Check if cloud provider is valid. Perhaps support AKS next.
if [[ "$_cloud_provider" == "aws" ]]; then
  checkoutClusterClaim
else
  echo "Invalid cloud provider. Exiting."
  exit 1
fi
