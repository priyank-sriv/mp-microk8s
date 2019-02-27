#!/usr/bin/env bash

WD="$(cd "$(dirname "$0")" >/dev/null && pwd)"

MICROK8S_CHANNEL=1.13/stable

function install_kubernetes() {
  log_info "Installing MicroK8s snap..."
  sudo snap install microk8s --classic --channel=$MICROK8S_CHANNEL

  log_info "Aliasing kubectl..."
  sudo snap alias microk8s.kubectl kubectl

  log_info "Exporting kube config..."
  mkdir -p $HOME/.kube
  microk8s.kubectl config view --raw > $HOME/.kube/config

  log_info "Waiting for Kubernetes services to initialise..."
  microk8s.status --wait-ready

  return $?
}

# https://github.com/ubuntu/microk8s#kubernetes-addons
function enable_kube_addons() {
  log_info "Enabling microk8s addons..."
  microk8s.enable dns ingress dashboard

  until [[ `kubectl get pods -n=kube-system | grep -o 'ContainerCreating' | wc -l` == 0 ]] ; do
    echo "Waiting for microk8s addons to be ready... ("`kubectl get pods -n=kube-system | grep -o 'ContainerCreating' | wc -l`" not running)"
    sleep 5
  done

  return $?
}

function forward_dashboard() {
  FORWARD_PORT=59001
  LOCAL_HOST='0.0.0.0'

  # Ensure the port is open...
  PORT_STATUS=`sudo netstat -tulpn | grep ${PROXY_PORT}` &>/dev/null
  if ! [ -z "$PORT_STATUS" ] ; then
    log_error "Port ${PROXY_PORT} is already used. Exiting"
    fatal "Process: `echo ${PORT_STATUS} | cut -d ' ' -f 7`"
  fi

  # This command runs the proxy, allowing anyone to connect
  kubectl proxy --port=${FORWARD_PORT} --accept-hosts='^.*$' --address=${LOCAL_HOST} &

  log_success "\nTo access the kubernetes dashboard, go to:\n"
  log_success "\n\t http://<EXTERNAL_IP>:59001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/ \n"
}

#iptables -P FORWARD ACCEPT
