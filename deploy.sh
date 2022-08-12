#!/bin/bash

VER=focal
REGISTRY=rnd-builds.repos.natinst.com

function buildAll() {
    cd ~/ecal
    git pull
    #make images
    #make -B build
    docker pull ${REGISTRY}/dtots/ecal-base:${VER}
    docker tag ${REGISTRY}/dtots/ecal-base:${VER} ecal-base:${VER}
    docker pull ${REGISTRY}/dtots/ecal-src-build:${VER}
    docker tag ${REGISTRY}/dtots/ecal-src-build:${VER}  ecal-src-build:${VER}
}

if [ -d ~/ecal ]; then
    echo "not cloing again..."
else
    git clone https://github.com/abhishekns/ecal.git
    cd ~/ecal
    git submodule update --init
fi

buildAll