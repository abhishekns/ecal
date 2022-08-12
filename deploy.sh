#!/bin/bash

function buildAll() {
    cd ~/ecal
    make images
    make -B build
}

if [ -d ~/ecal ]; then
    git clone https://github.com/abhishekns/ecal.git
    cd ~/ecal
    git submodule update --init
fi

buildAll()