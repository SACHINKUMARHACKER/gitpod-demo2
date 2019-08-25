FROM ubuntu:16.04

USER root

# Install Xvfb, JavaFX-helpers and Openbox window manager
RUN apt-get update \
    && apt-get install -y git-core \
    && apt-get install -y htop \
    && apt-get install -y firefox \
    && apt-get install -yq xvfb x11vnc xterm openjfx libopenjfx-java openbox \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/*

# ROS installation
RUN echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list

# key
RUN apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# update
RUN apt-get update

# installation
RUN apt-get install -y ros-kinetic-desktop-full

# rosdep
RUN rosdep init
RUN rosdep update

# source file
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
# RUN source ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

# useful tools
RUN apt install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# overwrite this env variable to use a different window manager
ENV WINDOW_MANAGER="openbox"

# Install novnc
RUN git clone https://github.com/novnc/noVNC.git /opt/novnc \
    && git clone https://github.com/novnc/websockify /opt/novnc/utils/websockify
COPY novnc-index.html /opt/novnc/index.html

# Add VNC startup script
COPY start-vnc-session.sh /usr/bin/
RUN chmod +x /usr/bin/start-vnc-session.sh

# This is a bit of a hack. At the moment we have no means of starting background
# tasks from a Dockerfile. This workaround checks, on each bashrc eval, if the X
# server is running on screen 0, and if not starts Xvfb, x11vnc and novnc.
RUN echo "export DISPLAY=:0" >> ~/.bashrc
RUN echo "[ ! -e /tmp/.X0-lock ] && (/usr/bin/start-vnc-session.sh &> /tmp/display-\${DISPLAY}.log)" >> ~/.bashrc


### checks ###
# no root-owned files in the home directory
#RUN notOwnedFile=$(find . -not "(" -user gitpod -and -group gitpod ")" -print -quit) \
#    && { [ -z "$notOwnedFile" ] \
#        || { echo "Error: not all files/dirs in $HOME are owned by 'gitpod' user & group"; exit 1; } }
