#!/usr/bin/env bash
set -euo pipefail

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
CHART_VERSION=${CHART_VERSION:-"4.10.5"}
CHART_NAME=${CHART_NAME:-"argocd"}
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

    echo 'ArgoCD password ...'
    kubectl -n argocd get secret argocd-initial-admin-secret --context=${KUBE_CONTEXT} -o jsonpath="{.data.password}" | base64 -d; echo
  fi
}

function repoConfig() {
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
}

function install() {
  #https://github.com/argoproj/argo-helm/blob/main/charts/argo-cd/values.yaml
  helm install ${CHART_NAME} argo/argo-cd \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --create-namespace \
  -f values.yaml ${DRY_RUN}
}

function upgrade() {
  helm upgrade ${CHART_NAME} argo/argo-cd \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --namespace ${NAMESPACE} \
  -f values.yaml ${DRY_RUN}
}

function extraResources() {
  hasNamespace=$(kubectl get namespaces | grep ${NAMESPACE})
  if [[ ! -z "${hasNamespace}" ]];
  then
    #createArgoCDApplication
  fi
}

function createArgoCDApplication() {
cat <<EOF | kubectl apply -f -
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: myapp
  namespace: argocd
spec:
  destination:
    name: ''
    namespace: argocd
    server: 'https://kubernetes.default.svc'
  source:
    path: chart
    repoURL: '<you_git_repository>'
    targetRevision: HEAD
    helm:
      valueFiles:
        - values.yaml
        - imgValues.yaml
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
}

main
