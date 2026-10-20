#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

AMX_BASE_IMAGE="${AMX_BASE_IMAGE:-amx-base:ubuntu}"

docker build -f examples/greeter/Dockerfile \
  --build-arg BASE_IMAGE="$AMX_BASE_IMAGE" \
  -t amx-greeter-demo:ubuntu .
