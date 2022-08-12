#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

git config --global --add safe.directory /ecal

mkdir -p build
#cd build
#iceoryx_posh_DIR=/ecal/thirdparty/iceoryx/build/install/prefix iceoryx_hoofs_DIR=/ecal/thirdparty/iceoryx/build/install/prefix iceoryx_dust_DIR=/ecal/thirdparty/iceoryx/build/install/prefix cmake .. -DHAS_QT5=OFF  
#make -j 8 install

cd build
#cmake .. -DCMAKE_BUILD_TYPE=Debug -DECAL_THIRDPARTY_BUILD_PROTOBUF=OFF -DECAL_THIRDPARTY_BUILD_CURL=OFF -DECAL_THIRDPARTY_BUILD_HDF5=OFF -DECAL_THIRDPARTY_BUILD_QWT=OFF -DHAS_QT5=OFF -DHAS_ICEORYX=OFF
cmake .. -DCMAKE_BUILD_TYPE=Debug -DECAL_THIRDPARTY_BUILD_QWT=OFF -DHAS_QT5=OFF -DHAS_ICEORYX=OFF
make -j8

cpack -G DEB
dpkg -i _deploy/eCAL-*


ldconfig
