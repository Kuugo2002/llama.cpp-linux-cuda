#!/usr/bin/env bash
set -euo pipefail

: "${CUDA_VERSION:?CUDA_VERSION must be set}"
: "${LLAMA_REF:=master}"

workspace="${GITHUB_WORKSPACE:-$(pwd)}"
source_dir="${workspace}/llama.cpp"
build_dir="${workspace}/build"
stage_dir="${workspace}/stage"
dist_dir="${workspace}/dist"

git init "${source_dir}"
git -C "${source_dir}" remote add origin https://github.com/ggml-org/llama.cpp.git
git -C "${source_dir}" fetch --depth=1 origin "${LLAMA_REF}"
git -C "${source_dir}" checkout --detach FETCH_HEAD
llama_commit="$(git -C "${source_dir}" rev-parse --short=12 HEAD)"

cmake -S "${source_dir}" -B "${build_dir}" -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr \
  -DGGML_CUDA=ON \
  -DLLAMA_CURL=OFF \
  -DLLAMA_BUILD_TESTS=OFF \
  -DLLAMA_BUILD_EXAMPLES=ON \
  -DLLAMA_BUILD_SERVER=ON
cmake --build "${build_dir}" --parallel "$(nproc)"
cmake --install "${build_dir}" --prefix "${stage_dir}/usr" --strip

mkdir -p "${stage_dir}/share/llama.cpp" "${dist_dir}"
cp "${source_dir}/LICENSE" "${stage_dir}/share/llama.cpp/"
{
  echo "llama.cpp commit: ${llama_commit}"
  echo "CUDA toolkit: ${CUDA_VERSION}"
  echo "Build image: ubuntu:26.04"
} > "${stage_dir}/share/llama.cpp/BUILD-INFO.txt"

package="llama-cpp-${llama_commit}-linux-x86_64-cuda-${CUDA_VERSION}"
tar -C "${stage_dir}" -czf "${dist_dir}/${package}.tar.gz" .
(
  cd "${dist_dir}"
  sha256sum "${package}.tar.gz" > "${package}.tar.gz.sha256"
)
