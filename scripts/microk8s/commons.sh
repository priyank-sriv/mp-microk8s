#!/usr/bin/env bash

GREEN='\033[0;32m'
RED='\033[1;31m'
BLUE='\033[0;36m'
NC='\033[0m'

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
