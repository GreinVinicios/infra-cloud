#!/usr/bin/env bash
set -euo pipefail

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
CHART_VERSION=${CHART_VERSION:-"4.0.17"}
CHART_NAME=${CHART_NAME:-"ingress-nginx"}
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
  fi
}

function repoConfig() {
  helm repo add ${CHART_NAME} https://kubernetes.github.io/ingress-nginx
  helm repo update
}

function install() {
  helm install ${CHART_NAME} ingress-nginx/ingress-nginx \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --values values.yaml \
  --create-namespace ${DRY_RUN}
}

function upgrade() {
  helm upgrade ${CHART_NAME} ingress-nginx/ingress-nginx \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --values values.yaml ${DRY_RUN}
}

main