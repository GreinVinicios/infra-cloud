#!/usr/bin/env bash
set -euo pipefail

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
CHART_VERSION=${CHART_VERSION:-"1.9.1"}
CHART_NAME=${CHART_NAME:-"certmanager"}
NAMESPACE=${NAMESPACE:-${CHART_NAME}}
UPGRADE=${UPGRADE:-""}
DRY_RUN=${DRY_RUN:-"y"}

if [[ "$DRY_RUN" =~ ^([yY])+$ ]]; then
  DRY_RUN=\ --dry-run
else
  DRY_RUN=""
fi

function main() {
  if [[ "$UPGRADE" =~ ^([yY])+$ ]]; then
    upgrade
  else
    repoConfig
    install
    extraResources
  fi
}

function repoConfig() {
  helm repo add certmanager https://charts.jetstack.io
  helm repo update
}

function install() {
  helm install ${CHART_NAME} certmanager/cert-manager \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --create-namespace \
  --set installCRDs=true ${DRY_RUN}
}

function upgrade() {
  helm upgrade ${CHART_NAME} certmanager/cert-manager \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --namespace ${NAMESPACE} ${DRY_RUN}
}

function extraResources() {
  hasNamespace=$(kubectl get namespaces | grep ${NAMESPACE})
  if [[ ! -z "${hasNamespace}" ]];
  then
    secret
    issuer
  fi
}

function secret() {
  kubectl create secret generic cloudflare-api-key-secret \
    --namespace=certmanager \
    --context=${KUBE_CONTEXT} \
    --from-literal=api-key="<you_cloudFlareAPI_key>"  
}

function issuer() {
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: <you_cloudFlareEmail>
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-account-key
    solvers:
    - dns01:
        cloudflare:
          email: <you_cloudFlareEmail>
          apiKeySecretRef:
            name: cloudflare-api-key-secret
            key: api-key
EOF
}

main
