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

cuda_home="/usr/local/cuda-${CUDA_VERSION}"
nvcc_path="${cuda_home}/bin/nvcc"

if [[ ! -x "${nvcc_path}" ]]; then
  nvcc_path="$(find /usr/local -type f -path '*/bin/nvcc' -print -quit)"
  if [[ -z "${nvcc_path}" ]]; then
    echo "CUDA package was installed, but nvcc could not be found under /usr/local." >&2
    exit 1
  fi
  cuda_home="${nvcc_path%/bin/nvcc}"
fi

export CUDA_HOME="${cuda_home}"
export CUDACXX="${nvcc_path}"
export PATH="${cuda_home}/bin:${PATH}"

if [[ -n "${GITHUB_PATH:-}" ]]; then
  echo "${cuda_home}/bin" >> "${GITHUB_PATH}"
fi
if [[ -n "${GITHUB_ENV:-}" ]]; then
  {
    echo "CUDA_HOME=${cuda_home}"
    echo "CUDACXX=${nvcc_path}"
  } >> "${GITHUB_ENV}"
fi

"${nvcc_path}" --version
