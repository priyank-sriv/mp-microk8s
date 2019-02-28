#!/usr/bin/env bash

set -e  # exit immediately on error
set -u  # fail on undeclared variables

WD="$(cd "$(dirname "$0")" >/dev/null && pwd)"

# import
. "${WD}/commons.sh"
. "${WD}/mp-commons.sh"

function launch() {
  install_if_not_exists_multipass
  wait_for_multipassd

  if vm_exists ${VM_NAME} ; then
    log_info "${VM_NAME} already exists!"
    vm_start ${VM_NAME}
  else
    vm_launch ${VM_NAME}
  fi
}

function restart() {
  install_if_not_exists_multipass

  if vm_exists ${VM_NAME} ; then
    vm_restart ${VM_NAME}
  else
    log_error "VM ${VM_NAME} does NOT exist."
  fi
}

function stop() {
  if vm_exists ${VM_NAME} ; then
    vm_stop ${VM_NAME}
  else
    log_error "VM ${VM_NAME} does NOT exist."
  fi
}

function destroy() {
  if vm_exists ${VM_NAME} ; then
    vm_destroy ${VM_NAME}
  else
    log_error "VM ${VM_NAME} does NOT exist."
  fi
}

function connect() {
  if vm_exists ${VM_NAME} ; then
    vm_connect ${VM_NAME}
  else
    log_error "Image ${VM_NAME} does NOT exist."
  fi
}

#######################################################

declare -a ACTIONS=(up down restart destroy connect)
command_list=$(printf ", %s" "${ACTIONS[@]}")

function usage () {
  log_info "Usage : script <action> <vm_name>"
  log_info "Supported actions=> ${command_list:2}"
  exit 0
}

if [ "$#" -ne 2 ] ; then
  log_error "Incorrect script parameters"
  usage
fi

ACTION=$1
VM_NAME=$2

if [ $ACTION == "up" ]; then
  launch
elif [ $ACTION == "down" ]; then
  stop
elif [ $ACTION == "restart" ]; then
  restart
elif [ $ACTION == "destroy" ]; then
  destroy
elif [ $ACTION == "connect" ]; then
  connect
else
  fatal "Unknown action: $ACTION\nSupported actions=> ${command_list:2}"
fi
