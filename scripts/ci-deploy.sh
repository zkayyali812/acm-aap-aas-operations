#!/bin/sh
set -e

echo "= CI Deployment Script ="
_cloud_provider=$1
_GITREPO=$2
_GITBRANCH=$3
_GITCOMMIT=$4


echo "$_cloud_provider"
echo "$_GITREPO\n"
echo "$_GITBRANCH\n"
echo "$_GITCOMMIT\n"

# if ! command -v yq &> /dev/null
# then
#     echo "Installing yq ..."
#     wget https://github.com/mikefarah/yq/releases/download/v4.9.3/yq_linux_amd64.tar.gz -O - |\
#     tar xz && sudo mv yq_linux_amd64 /usr/bin/yq >/dev/null
# fi

echo "== Deploying ACM-AAP-AAS-Operations to ${_cloud_provider}..."

# # Check if cloud provider is valid. Perhaps support AKS next.
# if [[ "$_cloud_provider" == "aws" ]]; then
#   make deploy-dev
# else
#   echo "Invalid cloud provider. Exiting."
#   exit 1
# fi
