#!/usr/bin/env bash
set -euo pipefail

: "${CUDA_VERSION:?CUDA_VERSION must be set}"
: "${LLAMA_REF:=master}"

workspace="${GITHUB_WORKSPACE:-$(pwd)}"
source_dir="${workspace}/llama.cpp"
build_dir="${source_dir}/build"
dist_dir="${workspace}/dist"
build_parallelism="$(nproc)"

git init "${source_dir}"
git -C "${source_dir}" remote add origin https://github.com/ggml-org/llama.cpp.git
git -C "${source_dir}" fetch --depth=1 origin "${LLAMA_REF}"
git -C "${source_dir}" checkout --detach FETCH_HEAD

(
  cd "${source_dir}"
  cmake -B build -DGGML_CUDA=ON -DGGML_NATIVE=OFF
  cmake --build build --config Release --parallel "${build_parallelism}"
)

if [[ ! -d "${build_dir}/bin" ]]; then
  echo "Build completed, but ${build_dir}/bin was not created." >&2
  exit 1
fi

mkdir -p "${dist_dir}"
cp -a "${build_dir}/bin/." "${dist_dir}/"
