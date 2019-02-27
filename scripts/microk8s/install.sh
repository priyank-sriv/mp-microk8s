#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

WD="$(cd "$(dirname "$0")" >/dev/null && pwd)"
. "${WD}/commons.sh"
. "${WD}/microk8s.sh"

STORAGE_VOL="/multipass/volume/dev"
PV_CAPACITY_STORAGE=${PV_CAPACITY_STORAGE:-30Gi}
PVC_REQUEST_STORAGE=${PVC_REQUEST_STORAGE:-15Gi}

CONFIGS_DIR="$HOME/k8s/configs"
TEMPLATES_DIR="${WD}/templates"

function install_k8s() {
  sudo snap install core
  install_kubernetes
  log_success "Installed microk8s successfully"

  enable_kube_addons
  log_success "Enabled MicroK8s addons."

  install_volume
  install_helm
  forward_dashboard
}

install_k8s
