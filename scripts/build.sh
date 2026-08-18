#!/usr/bin/env bash
set -euo pipefail

: "${CUDA_VERSION:?CUDA_VERSION must be set}"
: "${LLAMA_REF:=master}"

workspace="${GITHUB_WORKSPACE:-$(pwd)}"
source_dir="${workspace}/llama.cpp"
build_dir="${source_dir}/build"
dist_dir="${workspace}/dist"

git init "${source_dir}"
git -C "${source_dir}" remote add origin https://github.com/ggml-org/llama.cpp.git
git -C "${source_dir}" fetch --depth=1 origin "${LLAMA_REF}"
git -C "${source_dir}" checkout --detach FETCH_HEAD
llama_commit="$(git -C "${source_dir}" rev-parse --short=12 HEAD)"

(
  cd "${source_dir}"
  cmake -B build -DGGML_CUDA=ON
  cmake --build build --config Release
)

if [[ ! -d "${build_dir}/bin" ]]; then
  echo "Build completed, but ${build_dir}/bin was not created." >&2
  exit 1
fi

mkdir -p "${dist_dir}"
package="llama-cpp-${llama_commit}-linux-x86_64-cuda-${CUDA_VERSION}"
tar -C "${build_dir}/bin" -czf "${dist_dir}/${package}.tar.gz" .
(
  cd "${dist_dir}"
  sha256sum "${package}.tar.gz" > "${package}.tar.gz.sha256"
)
