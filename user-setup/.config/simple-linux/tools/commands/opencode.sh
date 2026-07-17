#!/bin/bash

set -euo pipefail

. "${TOOLSET_SCRIPT_DIR}/global.sh"

DEFAULT_DOCKER_PATH="$(toolset.set_if_exists "${HOME}/containers")"
OPENCODE_VERSION="1.15.10"
IMAGE="opencode-custom:$OPENCODE_VERSION"
BUILD=false

WORKSPACE="${WORKSPACE:-$(pwd)}"
WORKSPACE="$(realpath "$WORKSPACE")"

OPENCODE_CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode}"
OPENCODE_CACHE="${OPENCODE_CACHE:-$HOME/.cache/opencode}"
OPENCODE_SHARE="${OPENCODE_SHARE:-$HOME/.local/share/opencode}"
OPENCODE_STATE="${OPENCODE_STATE:-$HOME/.local/state/opencode}"

toolset.verify_variable_exists DEFAULT_DOCKER_PATH

mkdir -p $OPENCODE_CONFIG
mkdir -p $OPENCODE_CACHE
mkdir -p $OPENCODE_SHARE
mkdir -p $OPENCODE_STATE

if [[ "${1:-}" == "--build" ]]; then
  BUILD=true
fi

if [[ "$BUILD" == true ]]; then
  nerdctl build -f $DEFAULT_DOCKER_PATH/opencode.Dockerfile \
    --build-arg OPENCODE_VERSION=$OPENCODE_VERSION \
    -t "$IMAGE" \
    $DEFAULT_DOCKER_PATH
fi

nerdctl run --rm -it \
  --net internet \
  -v "$WORKSPACE:/workspace" \
  -v "$OPENCODE_CONFIG:/root/.config/opencode" \
  -v "$OPENCODE_CACHE:/root/.cache/opencode" \
  -v "$OPENCODE_SHARE:/root/.local/share/opencode" \
  -v "$OPENCODE_STATE:/root/.local/state/opencode" \
  -w /workspace \
  "$IMAGE"