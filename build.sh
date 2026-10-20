#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

BASE_OS_IMAGE="${BASE_OS_IMAGE:-ubuntu:22.04}"
AMX_BASE_IMAGE="${AMX_BASE_IMAGE:-amx-base:ubuntu}"

docker build -f base/Dockerfile \
  --build-arg BASE_IMAGE="$BASE_OS_IMAGE" \
  -t "$AMX_BASE_IMAGE" .

docker build -f examples/greeter/Dockerfile \
  --build-arg BASE_IMAGE="$AMX_BASE_IMAGE" \
  -t amx-greeter-demo:ubuntu .
