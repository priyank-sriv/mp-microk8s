#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

GREEN='\033[0;32m'
RED='\033[1;31m'
BLUE='\033[0;36m'
NC='\033[0m'

WD="$(cd "$(dirname "$0")" >/dev/null && pwd)"
. "${WD}/microk8s.sh"

STORAGE_VOL="/multipass/volume/dev"
PV_CAPACITY_STORAGE=${PV_CAPACITY_STORAGE:-30Gi}
PVC_REQUEST_STORAGE=${PVC_REQUEST_STORAGE:-15Gi}

KUBE_CONFIGS_DIR="/multipass/volume/kube-configs"
TEMPLATES_DIR="${WD}/templates"

function install_k8s() {
  sudo snap install core
  install_kubernetes
  log_success "Installed microk8s successfully"

  enable_kube_addons
  log_success "Enabled MicroK8s addons."
}

function install_volume() {
  mkdir -p ${KUBE_CONFIGS_DIR}
  cp -f ${TEMPLATES_DIR}/*.yaml ${KUBE_CONFIGS_DIR}
  sed -i'.orig' -e `echo s^\$\{\{pv.host.path}}^${STORAGE_VOL}^g`                 ${KUBE_CONFIGS_DIR}/*.yaml
  sed -i'.orig' -e `echo s/\$\{\{pv.capacity.storage}}/${PV_CAPACITY_STORAGE}/g`  ${KUBE_CONFIGS_DIR}/*.yaml
  sed -i'.orig' -e `echo s/\$\{\{pvc.request.storage}}/${PVC_REQUEST_STORAGE}/g`  ${KUBE_CONFIGS_DIR}/*.yaml

  kubectl create -f ${KUBE_CONFIGS_DIR}/storage_class.yaml
  kubectl create -f ${KUBE_CONFIGS_DIR}/persistent_volume.yaml
  kubectl create -f ${KUBE_CONFIGS_DIR}/pv_claim.yaml

  log_info "\nPersistent Volume Status:\n"
  kubectl get pv

  log_info "PV Claim Status:\n"
  kubectl get pvc

  return $?
}

function install_helm() {
  sudo snap install helm --classic
  helm init
  log_success "Installed helm successfully"
}

# function exit_if_not_root() {
#   if [[ $UID -ne 0 ]]; then
#       fatal "This script should run using sudo or as the root user"
#   fi
# }

function fatal() {
  log_error $@
  exit 1
}

function log_success() {
  printf "${GREEN}${@}${NC}\n"
}

function log_info() {
  printf "${BLUE}${@}${NC}\n"
}

function log_error() {
  printf "${RED}${@}${NC}\n"
}

#exit_if_not_root
install_k8s
install_volume
install_helm
