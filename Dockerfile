FROM nvidia/cuda:11.6.2-devel-ubuntu20.04
# https://hub.docker.com/r/nvidia/cudagl/

ENV NVIDIA_DRIVER_CAPABILITIES graphics,utility,compute

RUN apt update &&  \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends  \
    wget curl unzip git make cmake gcc clang gdb libeigen3-dev libncurses5-dev libncursesw5-dev libfreeimage-dev \
    # libs for FFMPEG functionality in OpenCV
    libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libgtk-3-dev pkg-config \
    libcanberra-gtk-module libcanberra-gtk3-module lsb && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /root

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
    python3-pip vim

# # --------------------------------------------------------------- #
# # Install PyTorch
# # https://pytorch.org/get-started/previous-versions/#linux-and-windows-3
# # --------------------------------------------------------------- #

# RUN pip install torch==1.13.1+cu116 torchvision==0.14.1+cu116 torchaudio==0.13.1 --extra-index-url https://download.pytorch.org/whl/cu116


# --------------------------------------------------------------- #
# Install ROS
# https://wiki.ros.org/noetic/Installation/Ubuntu
# --------------------------------------------------------------- #
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    apt update

RUN DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends ros-noetic-desktop-full

RUN echo "source /opt/ros/noetic/setup.bash" >> ~/.bashrc

RUN . /opt/ros/noetic/setup.sh && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
    python3-rosdep python3-rosinstall python3-rosinstall-generator python3-wstool build-essential

RUN . /opt/ros/noetic/setup.sh && \
    rosdep init && \
    rosdep update


# --------------------------------------------------------------- #
# Install Realsense SDK
# https://github.com/IntelRealSense/librealsense/blob/master/doc/distribution_linux.md
# --------------------------------------------------------------- #
RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends apt-transport-https

RUN mkdir -p /etc/apt/keyrings && \
    curl -sSf https://librealsense.intel.com/Debian/librealsense.pgp | tee /etc/apt/keyrings/librealsense.pgp > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/librealsense.pgp] https://librealsense.intel.com/Debian/apt-repo `lsb_release -cs` main" | tee /etc/apt/sources.list.d/librealsense.list && \
    apt-get update

RUN apt update && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dkms && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-utils && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dev && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-dbg && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends librealsense2-udev-rules

RUN pip install pyrealsense2

# --------------------------------------------------------------- #
# Install Realsense ROS
# https://github.com/IntelRealSense/realsense-ros/tree/ros1-legacy
# --------------------------------------------------------------- #
RUN . /opt/ros/noetic/setup.sh && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
    ros-$ROS_DISTRO-realsense2-camera \
    ros-$ROS_DISTRO-realsense2-description 


# --------------------------------------------------------------- #
# Install Rtab-Map ROS
# https://wiki.ros.org/rtabmap_ros
# --------------------------------------------------------------- #
RUN . /opt/ros/noetic/setup.sh && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
    ros-$ROS_DISTRO-rtabmap-ros

# --------------------------------------------------------------- #
# Install UR ROS
# https://github.com/ros-industrial/universal_robot
# --------------------------------------------------------------- #
RUN . /opt/ros/noetic/setup.sh && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends ros-noetic-universal-robots

RUN mkdir -p catkin_ws/src && cd catkin_ws && \
    git clone https://github.com/UniversalRobots/Universal_Robots_ROS_Driver.git src/Universal_Robots_ROS_Driver && \
    git clone -b melodic-devel https://github.com/ros-industrial/universal_robot.git src/universal_robot

RUN . /opt/ros/noetic/setup.sh && \
    cd catkin_ws && \
    apt update -qq && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -y && \
    catkin_make

RUN echo "source /root/catkin_ws/devel/setup.bash" >> ~/.bashrc

# --------------------------------------------------------------- #
# Install Additional Dependencies
# --------------------------------------------------------------- #
RUN . /opt/ros/noetic/setup.sh && \
    DEBIAN_FRONTEND="noninteractive" apt install -y --no-install-recommends \
    ros-$ROS_DISTRO-moveit-visual-tools \
    ros-$ROS_DISTRO-octomap-rviz-plugins

RUN pip install opencv-python 

RUN echo 'if [ "$color_prompt" = yes ]; then' >> ~/.bashrc && \
    echo '    PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '\''' >> ~/.bashrc && \
    echo 'else' >> ~/.bashrc && \
    echo '    PS1='\''${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '\''' >> ~/.bashrc && \
    echo 'fi' >> ~/.bashrc
