#!/bin/bash
set -e

checkoutClusterClaim() {
    echo "Log in to Collective"

    oc login ${_AWS_CLUSTERPOOL_API_URL} --insecure-skip-tls-verify --token="${_AWS_CLUSTERPOOL_TOKEN}"
    oc project managed-services

    _TEMPLATE="apiVersion: hive.openshift.io/v1
    kind: ClusterClaim
    metadata:
    annotations:
        cluster.open-cluster-management.io/createmanagedcluster: 'false'
    name: acm-aap-aas-ops-ci-cluster
    spec:
    clusterPoolName: hypershift-cluster-pool
    lifetime: 2h
    subjects:
    - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: idp-for-the-masses
    - apiGroup: rbac.authorization.k8s.io
        kind: Group
        name: system:serviceaccounts:managed-services"

    echo "$_TEMPLATE" | oc apply -f -

    echo "Clusterclaim created. Waiting upto 90 minutes for the cluster to be Running"
    oc wait --for=condition=ClusterRunning clusterclaim.hive/acm-aap-aas-ops-ci-cluster --timeout=90m

    NAMESPACE=$(oc get clusterclaim.hive acm-aap-aas-ops-ci-cluster -o=jsonpath='{.spec.namespace}')
    CD_INFO=$(oc get clusterdeployment ${NAMESPACE} -n ${NAMESPACE} -o yaml -o=jsonpath='{.spec.clusterMetadata.adminPasswordSecretRef.name}')
    KUBECONFIG_SECRET=$(oc get cd ${NAMESPACE} -n ${NAMESPACE} -o yaml | yq eval '.spec.clusterMetadata.adminKubeconfigSecretRef.name' -)

    _USERNAME=$(oc get secret ${CD_INFO} -n ${NAMESPACE} -o jsonpath='{.data.username}' | base64 -d )
    _PASSWORD=$(oc get secret ${CD_INFO} -n ${NAMESPACE} -o jsonpath='{.data.password}' | base64 -d  )
    _API_URL=$(oc get cd ${NAMESPACE} -n ${NAMESPACE} -o jsonpath='{.status.apiURL}' )
    
    echo "API URL of claimed cluster: $_API_URL"
    echo "Password for the claimed cluster: $_PASSWORD"
    echo ""
    echo "Clusterclaim successfully checked out"

    oc login ${_API_URL} -u ${_USERNAME} -p ${_PASSWORD} --insecure-skip-tls-verify=true

}

echo "= CI Deployment Script ="
_cloud_provider=$1

echo "==> Deploying ACM-AAP-AAS-Operations to ${_cloud_provider}..."

# Check if cloud provider is valid. Perhaps support AKS next.
if [[ "$_cloud_provider" == "aws" ]]; then
  checkoutClusterClaim
  make deploy-dev
else
  echo "Invalid cloud provider. Exiting."
  exit 1
fi
