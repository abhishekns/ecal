#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

cd $SCRIPT_DIR

git config --global --add safe.directory /ecal

mkdir -p build
cd build
cmake .. -DHAS_QT5=OFF
make -j 8 install
ldconfig
