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
    mamba create -n ros_env python=3.9

# --------------------------------------------------------------- #
# Install and configure ROS on Mamba with Robostack
# https://robostack.github.io/GettingStarted.html
# --------------------------------------------------------------- #

RUN . /root/.bashrc && \
    mamba activate ros_env && \
    conda config --env --add channels conda-forge && \
    conda config --env --add channels robostack-staging && \
    conda config --env --add channels robostack-experimental && \
    mamba install -y ros-noetic-desktop=1.5

RUN . /root/.bashrc && \
    mamba activate ros_env && \
    mamba install -y compilers cmake pkg-config make ninja colcon-common-extensions catkin_tools

RUN . /root/.bashrc && \
    mamba activate ros_env && \
    mamba install rosdep && \
    rosdep init && \
    rosdep update

RUN . /root/.bashrc && \
    mamba activate ros_env && \
    mamba install -y mesa-libgl-devel-cos7-x86_64 mesa-dri-drivers-cos7-x86_64 libselinux-cos7-x86_64 libxdamage-cos7-x86_64 libxxf86vm-cos7-x86_64 libxext-cos7-x86_64 xorg-libxfixes

RUN echo "conda activate ros_env" >> ~/.bashrc

# --------------------------------------------------------------- #
# Install MoveIt
# https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md
# --------------------------------------------------------------- #
RUN mkdir -p catkin_ws/src && cd catkin_ws && \
    git clone https://github.com/UniversalRobots/Universal_Robots_ROS_Driver.git src/Universal_Robots_ROS_Driver && \
    git clone -b melodic-devel https://github.com/ros-industrial/universal_robot.git src/universal_robot

RUN . /root/.bashrc && \
    cd catkin_ws && \
    apt update -qq && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y && \
    catkin_make






    
# RUN . /root/.bashrc && \
#     mamba activate ros_env && \
#     mamba install -y ros-noetic-moveit=1.1.0 ros-noetic-moveit-ros-perception=1.1.0 ros-noetic-ros-controllers=0.18.1 ros-noetic-ros-control=0.19.4 ros-noetic-ros-numpy=0.0.4

# # --------------------------------------------------------------- #
# # Install Realsense SDK
# # https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md
# # --------------------------------------------------------------- #
# RUN apt update && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends apt-transport-https

# RUN mkdir -p /etc/apt/keyrings && \
#     curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
#     echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | tee /etc/apt/sources.list.d/librealsense.list && \
#     apt-get update

# RUN apt update && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dkms && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-utils && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dev && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dbg && \
#     DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-udev-rules


