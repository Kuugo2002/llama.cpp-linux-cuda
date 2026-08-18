# llama.cpp Linux CUDA builds

这个仓库使用 GitHub Actions 在 **Ubuntu 26.04** 容器中编译
[ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp) 的 Linux x86_64 CUDA 版本。

支持的 CUDA 工具链：

- CUDA 12.9
- CUDA 13.0
- CUDA 13.2

## 运行构建

打开仓库的 **Actions** 页面，选择 **Build llama.cpp (Linux CUDA)**，点击
**Run workflow**。可以一次构建全部版本，也可以选择一个 CUDA 版本；`llama_ref`
接受上游分支、tag 或 commit。工作流默认每周一构建一次上游 `master`。

每个 CUDA 版本会生成一个独立的 Actions artifact，内含：

- `llama-cpp-<commit>-linux-x86_64-cuda-<version>.tar.gz`
- 对应的 `.sha256` 校验文件

压缩包按 `/usr` 目录布局组织，包含可执行文件、动态库、头文件、CMake/pkg-config
元数据、许可证和构建信息。解压到任意目录后，如不安装到系统路径，需要把其中的
`usr/lib` 加入 `LD_LIBRARY_PATH`。

## CUDA 架构

默认编译 `75;80;86;89;90;100;120`。手动运行工作流时可修改
`cuda_architectures`；该值直接传给 CMake 的 `CMAKE_CUDA_ARCHITECTURES`。

## 构建环境说明

GitHub 托管 runner 尚无 `ubuntu-26.04` runner 标签，因此工作流在
`ubuntu-24.04` runner 上启动官方 `ubuntu:26.04` 容器，所有依赖、CUDA 工具链和
llama.cpp 都在该容器内安装及编译。CUDA 来自 NVIDIA 的 Ubuntu 26.04 软件源。
