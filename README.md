# llama.cpp Linux CUDA builds

这个仓库使用 GitHub Actions 在 **Ubuntu 26.04** 容器中编译
[ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) 的 Linux x86_64 CUDA 版本。

支持的 CUDA 工具链：

- CUDA 13.2
- CUDA 13.0
- CUDA 12.9

## 运行构建

打开仓库的 **Actions** 页面，选择 **Build llama.cpp (Linux CUDA)**，点击
**Run workflow**。每次运行选择一个 CUDA 版本；`llama_ref` 接受上游分支、tag 或
commit。

每个 CUDA 版本会生成一个独立的 Actions artifact。下载得到的 ZIP 中直接包含
llama.cpp 官方构建流程在 `build/bin` 中生成的可执行文件和动态库，不再嵌套
tar.gz，也不生成 SHA256 校验文件。artifact 不包含编译中间文件、头文件或
CMake/pkg-config 元数据。构建使用上游推荐命令：

```bash
cmake -B build -DGGML_CUDA=ON -DGGML_NATIVE=OFF
cmake --build build --config Release --parallel "$(nproc)"
```

## 构建环境说明

GitHub 托管 runner 尚无 `ubuntu-26.04` runner 标签，因此工作流在
`ubuntu-24.04` runner 上启动官方 `ubuntu:26.04` 容器，所有依赖、CUDA 工具链和
llama.cpp 都在该容器内安装及编译。CUDA 来自 NVIDIA 的 Ubuntu 24.04 软件源。
安装脚本会将版本化 CUDA 目录写入 Actions 环境，供后续 CMake 构建使用。
使用 CUDA 12.9 时，安装脚本会显式安装并选择 `gcc-14`/`g++-14` 作为 CMake 和
NVCC 的主机编译器，避免使用 Ubuntu 26.04 容器中的系统默认 GCC。
