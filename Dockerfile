# Set Versions
ARG CUDA_VERSION=11.3.1
ARG CUDA=11.3
ARG OS_VERSION=20.04
ARG PYTHON_VERSION=3.8

# Set user id
ARG USER_ID=1004

# Set conda env name
ARG CONDA_ENV_NAME=torch

# Define base image
FROM nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${OS_VERSION}
ARG CUDA_VERSION
ARG OS_VERSION
ARG USER_ID

# Set CUDA architectures
ARG CUDA_ARCHITECTURES=86
ARG TORCH_CUDA_ARCH_LIST="Ampere"

# Set environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Seoul
ENV LC_ALL=C.UTF-8
ENV CUDA_HOME="/usr/local/cuda"

# Install packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    ccache \
    cmake \
    curl \
    ffmpeg \
    git \
    ninja-build libopenblas-dev \
    xterm xauth openssh-server tmux mate-desktop-environment-core \
    libatlas-base-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-program-options-dev \
    libboost-system-dev \
    libboost-test-dev \
    libhdf5-dev \
    libcgal-dev \
    libeigen3-dev \
    libflann-dev \
    libfreeimage-dev \
    libgflags-dev \
    libglew-dev \
    libgoogle-glog-dev \
    libmetis-dev \
    libprotobuf-dev \
    libqt5opengl5-dev \
    libsqlite3-dev \
    libsuitesparse-dev \
    nano \
    protobuf-compiler \
    python-is-python3 \
    python3.8-dev \
    python3-pip \
    qtbase5-dev \
    sudo \
    vim-tiny \
    wget \
    unzip \
    htop && \
    rm -rf /var/lib/apt/lists/*

# For CUDA profiling
ENV LD_LIBRARY_PATH /usr/local/cuda-${CUDA}/targets/x86_64-linux/lib:/usr/local/cuda/extras/CUPTI/lib64:/usr/local/cuda/lib64:$LD_LIBRARY_PATH
RUN ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1 && \
    echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf && \
    ldconfig

# See http://bugs.python.org/issue19846
ENV LANG C.UTF-8
RUN curl -o /tmp/miniconda.sh -sSL http://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    chmod +x /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -bfp /usr/local && \
    rm /tmp/miniconda.sh
RUN conda update -y conda

# Create non root user and setup environment.
RUN useradd -m -d /home/user -g root -G sudo -u ${USER_ID} user
RUN usermod -aG sudo user
# Set user password
RUN echo "user:user" | chpasswd
# Ensure sudo group users are not asked for a password when using sudo command by ammending sudoers file
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to new uer and workdir.
USER ${USER_ID}
WORKDIR /home/user

# Add local user binary folder to PATH variable.
ENV PATH="${PATH}:/home/user/.local/bin"
SHELL ["/bin/bash", "-c"]

# Switch to root temporarily to install conda packages
USER root
RUN conda create -n $CONDA_ENV_NAME python=$PYTHON_VERSION

# Continue with the rest of the installation
RUN echo "source activate ${CONDA_ENV_NAME}" >> ~/.bashrc

# Install the packages
RUN source activate ${CONDA_ENV_NAME} && \
    conda install pytorch==1.10.1 torchvision==0.11.2 torchaudio==0.10.1 cudatoolkit=11.3 -c pytorch -y && \
    conda install openblas-devel h5py pyyaml -c anaconda -y && \
    conda install sharedarray tensorboard tensorboardx yapf addict einops scipy plyfile termcolor timm -c conda-forge -y && \
    conda install pyg pytorch-cluster pytorch-scatter pytorch-sparse -c pyg -y

USER ${USER_ID}

# Change working directory
WORKDIR /home/user

# Set dev env
## Install zsh, tmux, and libfuse2
RUN sudo apt-get update && \
    sudo apt-get install -y --no-install-recommends \
      zsh \
      tmux \
      libfuse2

# Install neovim
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage && \
    chmod u+x ./nvim.appimage && \
    sudo mv ./nvim.appimage /usr/local/bin/nvim

# Install oh-my-zsh, theme, and plugins
WORKDIR /home/user
ENV ZSH_CUSTOM=/home/user/.oh-my-zsh/custom
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
RUN git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1 && \
    ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"
RUN git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
RUN git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

# zsh as default entrypoint.
WORKDIR /home/user

