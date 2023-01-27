#!/usr/bin/env bash
set -euo pipefail

KUBE_CONTEXT=${1:-$(kubectl config current-context)}
CHART_VERSION=${CHART_VERSION:-"4.1.16"}
CHART_NAME=${CHART_NAME:-"jenkins"}
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
  helm repo add jenkins https://charts.jenkins.io
  helm repo update
}

function install() {
  #https://raw.githubusercontent.com/jenkins/helm-charts/main/charts/jenkins/values.yaml
  helm install ${CHART_NAME} jenkins/jenkins \
  --namespace ${NAMESPACE} \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --create-namespace \
  --set controller.image=<your_customJenkins_image> \
  --set controller.tag=<your_customJenkins_imagetag> \
  -f values.yaml ${DRY_RUN}
}

function upgrade() {
  helm upgrade ${CHART_NAME} jenkins/jenkins \
  --version ${CHART_VERSION} \
  --kube-context=${KUBE_CONTEXT} \
  --namespace ${NAMESPACE} \
  --set controller.image=<your_customJenkins_image> \
  --set controller.tag=<your_customJenkins_imagetag> \
  -f values.yaml ${DRY_RUN}
}

function extraResources() {
  hasNamespace=$(kubectl get namespaces | grep ${NAMESPACE})
  if [[ ! -z "${hasNamespace}" ]];
  then
    createCertificate
    defaultUsr
    defaultPass
  fi
}

function createCertificate() {
cat <<EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: jenkins-certificate
  namespace: jenkins
spec:
  dnsNames:
  - <you_domain_here>
  issuerRef:
    kind: ClusterIssuer
    name: letsencrypt-prod
  secretName: jenkins-certificate
EOF
}

function defaultUsr() {
  jsonpath="{.data.jenkins-admin-user}"
  secret=$(kubectl get secret -n ${NAMESPACE} jenkins --context=${KUBE_CONTEXT} -o jsonpath=$jsonpath)
  echo $(echo $secret | base64 --decode)
}

function defaultPass() {
  kubectl exec --namespace ${NAMESPACE} -it svc/jenkins -c jenkins --context=${KUBE_CONTEXT} -- /bin/cat /run/secrets/additional/chart-admin-password && echo
}


main
