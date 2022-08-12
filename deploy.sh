#!/bin/bash

git clone https://github.com/abhishekns/ecal.git
cd ecal
git submodule update --init
make images
make -B build