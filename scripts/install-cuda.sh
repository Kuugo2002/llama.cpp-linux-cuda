#!/usr/bin/env bash
set -euo pipefail

: "${CUDA_VERSION:?CUDA_VERSION must be set}"

case "${CUDA_VERSION}" in
  13.2) cuda_package="cuda-toolkit-13-2" ;;
  13.0) cuda_package="cuda-toolkit-13-0" ;;
  12.9) cuda_package="cuda-toolkit-12-9" ;;
  *) echo "Unsupported CUDA version: ${CUDA_VERSION}" >&2; exit 2 ;;
esac

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates cmake coreutils curl g++ git gzip ninja-build pkg-config tar xz-utils

curl --fail --location --retry 5 \
  --output /tmp/cuda-keyring.deb \
  https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i /tmp/cuda-keyring.deb
apt-get update
apt-get install -y --no-install-recommends "${cuda_package}"

nvcc --version
