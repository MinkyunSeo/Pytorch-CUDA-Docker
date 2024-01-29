# Docker Image for Development Environment

## Introduction
This Dockerfile creates a development environment with essential tools and packages for deep learning and general software development. The base image is built on NVIDIA CUDA, which enables GPU acceleration for deep learning tasks. The environment includes Python 3.8, essential libraries, and a customized user setup for seamless development.

## Versions (Could be modified)
- **CUDA Version:** 11.3.1
- **Operating System Version:** Ubuntu 20.04
- **Python Version:** 3.8

## User Configuration (Could be modified)
- **User ID:** 1004
- **Conda Environment Name:** torch

## Base Image
The base image is derived from `nvidia/cuda:11.3.1-devel-ubuntu20.04`.

## Usage 
Build the Docker image using the provided Dockerfile. Once built, you can run a container from the image and start your development environment.

```bash
docker build -t my_dev_environment .
docker run -itd my_dev_environment --gpus all
```

## Installed Packages
The Dockerfile installs the following packages:
- build-essential
- ca-certificates
- ccache
- cmake
- curl
- ffmpeg
- git
- ninja-build
- libopenblas-dev
- xterm
- xauth
- openssh-server
- tmux
- mate-desktop-environment-core
- ... (and many more)

## CUDA Configuration
The Dockerfile sets up CUDA configurations, including specified architectures and paths for profiling.

## Miniconda Installation
Miniconda is installed to manage Python environments and packages.

## User Setup
A non-root user named "user" is created with the specified user ID and added to the sudo group. The password is set to "user". Passwordless sudo access is configured.

## Conda Environment Setup
A conda environment named "torch" is created, and the user's default shell is configured to activate this environment.

## Python Packages
The Dockerfile installs various Python packages, including PyTorch, torchvision, torchaudio, and additional libraries for deep learning tasks.

## Development Tools
The environment is equipped with development tools such as zsh, tmux, neovim, NodeJS, and oh-my-zsh with the Spaceship theme, zsh-autosuggestions, and zsh-syntax-highlighting plugins.
