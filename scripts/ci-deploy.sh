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

mkdir -p samples/
cd samples/
git clone --single-branch --branch "${_GITBRANCH}"  https://github.com/${_GITREPO}.git

echo "== Deploying ACM-AAP-AAS-Operations to ${_cloud_provider}..."

# Check if cloud provider is valid. Perhaps support AKS next.
if [[ "$_cloud_provider" == "aws" ]]; then
    oc login ${_AWS_CLUSTERPOOL_API_URL} --insecure-skip-tls-verify --token="${_AWS_CLUSTERPOOL_TOKEN}"
    oc project managed-services
else
  echo "Invalid cloud provider. Exiting."
  exit 1
fi
