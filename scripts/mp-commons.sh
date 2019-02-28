#!/usr/bin/env bash

VM_IMG=${VM_IMG:-"lts"}
VM_MEM=${VM_MEM:-4G}
VM_CPUS=${VM_CPUS:-2}

WD="$(cd "$(dirname "$0")" >/dev/null && pwd)"
. "${WD}/commons.sh"

LOCAL_STORAGE_VOL_TMPL=${LOCAL_VOL_TMPL:-"${HOME}/.canonical-vol/{{vm.name}}"}
VM_STORAGE_VOL="/multipass/volume/dev"

LOCAL_SCRIPTS_VOL="${WD}/microk8s"
VM_SCRIPTS_VOL="/multipass/volume/scripts"

#MP_CLOUD_INIT=${MP_CLOUD_INIT:-"${WD}/mp_cloud_init"}

function vm_exists() {
  multipass list | grep $1 &>/dev/null
  return $?
}

function vm_launch() {
  local vm_name=$1
  log_info "Creating VM '${vm_name}'..."
  multipass launch --verbose \
      --name ${vm_name} \
      --mem ${VM_MEM} \
      --cpus ${VM_CPUS} \
      ${VM_IMG}
  log_success "Successfully launched '${vm_name}'..."
  vm_mount ${vm_name}
  instructions ${vm_name}
  return $?
}

function vm_mount() {
  local VM=$1
  local LOCAL_STORAGE_VOL=$(echo "$LOCAL_STORAGE_VOL_TMPL" | sed "s/{{vm.name}}/${VM}/g")

  mkdir -p ${LOCAL_STORAGE_VOL}
  log_info "Mounting volume local:${LOCAL_STORAGE_VOL} to ${VM}:${VM_STORAGE_VOL}"
  multipass mount ${LOCAL_STORAGE_VOL} ${VM}:${VM_STORAGE_VOL}

  log_info "Mounting installation scripts local:${LOCAL_SCRIPTS_VOL} to ${VM}:${VM_SCRIPTS_VOL}"
  multipass mount ${LOCAL_SCRIPTS_VOL} ${VM}:${VM_SCRIPTS_VOL}
}

function vm_start() {
  log_info "Starting '$1'..."
  multipass start $1
  log_success "Successfully started '$1'..."
  instructions $1
  return $?
}

function vm_restart() {
  log_info "Restarting '$1'..."
  multipass restart $1
  log_success "Successfully restarted '$1'..."
  instructions $1
  return $?
}

function vm_stop() {
  log_info "Stopping '$1'..."
  multipass stop $1
  log_success "VM stopped!"
  return $?
}

function vm_connect() {
  log_info "Connecting '$1'..."
  multipass shell $1
}

function vm_destroy() {
  local VM=$1
  log_info "Cleaning up '${VM}'"

  local LOCAL_STORAGE_VOL=$(echo "$LOCAL_STORAGE_VOL_TMPL" | sed "s/{{vm.name}}/${VM}/g")
#  multipass umount ${VM}:${VM_STORAGE_VOL}
#  multipass umount ${VM}:${VM_SCRIPTS_VOL}
  multipass delete ${VM}
  multipass purge

  log_info "Removing local volume..."
  rm -rf ${LOCAL_STORAGE_VOL}

  log_success "VM destroyed!"
  return $?
}

function instructions() {
  log_info "Connect to shell: mp-compose connect $1"
  log_info "Once connected to shell, steps to install K8s:"
  log_success "\t$ cd $VM_SCRIPTS_VOL"
  log_success "\t$ chmod +x install.sh"
  log_success "\t$ ./install.sh"
}

function wait_for_multipassd() {
  until [[ `multipass list 2>&1 > /dev/null` != *"list failed"* ]] ; do                                                                    11:29  28.02.19 ⇣93%
    echo "Waiting for multipassd..."
    sleep 3
  done
}
