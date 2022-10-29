#!/bin/bash

sudo apt-get install build-essential clang bison flex \
              libreadline-dev gawk tcl-dev libffi-dev git \
              graphviz xdot pkg-config python3 libboost-system-dev \
              libboost-python-dev libboost-filesystem-dev zlib1g-dev

if [ -d "sby" ]; then
  rm -rf sby
fi

git clone https://github.com/YosysHQ/sby

cd sby

make -j$(nproc)
sudo make install
