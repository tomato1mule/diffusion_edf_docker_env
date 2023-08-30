FROM nvidia/cudagl:11.4.0-devel-ubuntu20.04
#https://hub.docker.com/r/nvidia/cudagl/

ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

RUN apt update &&  \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends  \
    wget curl unzip git make cmake gcc clang gdb libeigen3-dev libncurses5-dev libncursesw5-dev libfreeimage-dev \
    # libs for FFMPEG functionality in OpenCV
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libgtk-3-dev pkg-config \
    libcanberra-gtk-module libcanberra-gtk3-module lsb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

# --------------------------------------------------------------- #
# Install and configure Conda env with Mambaforge
# https://mamba.readthedocs.io/en/latest/mamba-installation.html#mamba-install
# --------------------------------------------------------------- #

RUN wget https://github.com/conda-forge/miniforge/releases/latest/download/Mambaforge-Linux-x86_64.sh && \ 
    bash Mambaforge-Linux-x86_64.sh -b && \
    rm Mambaforge-Linux-x86_64.sh

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends vim

RUN echo ". /root/mambaforge/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN . /root/.bashrc && \
    mamba init

RUN . /root/.bashrc && \
    mamba create -n ros_env

# --------------------------------------------------------------- #
# Install and configure ROS on Mamba with Robostack
# https://robostack.github.io/GettingStarted.html
# --------------------------------------------------------------- #

RUN . /root/.bashrc && \
    mamba activate ros_env && \
    conda config --env --add channels conda-forge && \
    conda config --env --add channels robostack-staging

    