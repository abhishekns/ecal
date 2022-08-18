#!/bin/bash


MIN_VER=`cat image-build-number.txt`
VER=focal
REGISTRY=rnd-builds.repos.natinst.com

function pullImages() {
    cd ~/ecal
    git pull
    #make images
    #make -B build
    docker pull ${REGISTRY}/dtots/ecal-base:${VER}.${MIN_VER}
    docker tag ${REGISTRY}/dtots/ecal-base:${VER}.${MIN_VER} ecal-base:${VER}
    docker pull ${REGISTRY}/dtots/ecal-src-build:${VER}.${MIN_VER}
    docker tag ${REGISTRY}/dtots/ecal-src-build:${VER}.${MIN_VER}  ecal-install:${VER}
    docker pull ${REGISTRY}/dtots/ecal-install:${VER}.${MIN_VER}
    docker tag ${REGISTRY}/dtots/ecal-install:${VER}.${MIN_VER}  ecal-install:${VER}
}

if [ -d ~/ecal ]; then
    echo "not cloing again..."
else
    git clone https://github.com/abhishekns/ecal.git
    cd ~/ecal
    git submodule update --init
fi

pullImages