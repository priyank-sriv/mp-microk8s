#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[1;31m'
BLUE='\033[0;36m'
NC='\033[0m'

MULTIPASS_VER=v0.5
MULTIPASS_PKG=multipass-$MULTIPASS_VER-full-Darwin.pkg

function install_if_not_exists_multipass() {
  if ! hash multipass &>/dev/null; then
    if [[ "$(uname -s)" == "Darwin" ]]; then
      install_multipass_darwin
    elif [[ "$(uname -s)" == "Linux" ]]; then
      # todo : without snap
      install_multipass_snap
    else
      fatal "Multipass is not supported... Exiting"
    fi
  fi
}

function install_multipass_snap() {
  log_info "Installing multipass..."
  snap install multipass --beta --classic

  log_success "Successfully installed multipass"
}

function install_multipass_darwin() {
  local DWNLD_DIR=$HOME/.canonical-multipass
  sudo mkdir -p $DWNLD_DIR

  local PKG_NAME=multipass.pkg

  log_info "Downloading multipass package..."
  sudo curl -L -C - -o $DWNLD_DIR/$PKG_NAME \
    "https://github.com/CanonicalLtd/multipass/releases/download/$MULTIPASS_VER/$MULTIPASS_PKG"

  log_info "Installing multipass..."
  sudo installer -pkg $DWNLD_DIR/$PKG_NAME -target /

  log_success "Successfully installed multipass"
}

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
