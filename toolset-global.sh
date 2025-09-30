#!/bin/bash

RED_COLOR='\033[0;31m'
GREEN_COLOR='\033[0;32m'
BLUE_COLOR='\033[0;34m'
PURPLE_COLOR='\033[0;35m'
NO_COLOR='\033[0m'

info() {
  echo -e "${BLUE_COLOR}[INFO]${NO_COLOR} $@"
}

error() {
  echo -e "${RED_COLOR}[ERROR]${NO_COLOR} $@"
}

debug() {
  if [[ -n "$TOOLSET_DEBUG" ]]; then
    echo -e "${PURPLE_COLOR}[DEBUG]${NO_COLOR} $@"
  fi
}