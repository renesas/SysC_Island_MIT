#!/bin/bash

function usage
{
    echo "Usage: $0 should be run at the top level of a GreenSocs Virtual Platform" ; exit
}


DOCKER_NAME="greensocs-vpenv";

if [[ -z `docker images -q $DOCKER_NAME` ]] ; then
    echo "Building $DOCKER_NAME";
    docker build -t $DOCKER_NAME --force-rm \
           --build-arg USER=`whoami` \
           - <<EOF 
FROM ubuntu:20.04

ARG USER=user
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y
RUN apt full-upgrade -y
RUN apt-get install -y  \
    build-essential \
    gdb \
    git \
    cmake \
    ninja-build \
    wget \
    unzip \
    python \
    libpixman-1-dev \
    libglib2.0-dev \
    libhdf5-serial-dev \
    liblua5.2-dev \
    python3-pexpect

RUN useradd -Ms /bin/bash $USER
USER $USER
WORKDIR /home/$USER

EOF
fi

if [[ -z `docker ps -q -f name=$DOCKER_NAME` ]] ; then
    docker run -e _PWD=`pwd|sed s:$HOME:/home/$USER:`  --privileged --rm -it -v ~/:/home/`whoami` -v /tmp/.X11-unix:/tmp/.X11-unix -e DISPLAY=:0 --name $DOCKER_NAME $DOCKER_NAME /bin/bash -c "cd \$_PWD; /bin/bash $*" 
else
    docker exec -e NEWPWD=`pwd|sed s:$HOME:/home/$USER:` --privileged -it $DOCKER_NAME /bin/bash
fi
