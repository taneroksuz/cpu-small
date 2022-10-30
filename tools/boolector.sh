#!/bin/bash

sudo apt-get install build-essential clang bison flex \
              libreadline-dev gawk tcl-dev libffi-dev git haskell-stack \
              graphviz xdot pkg-config python3 libboost-system-dev \
              libboost-python-dev libboost-filesystem-dev zlib1g-dev

if [ -d "boolector" ]; then
  rm -rf boolector
fi

git clone https://github.com/boolector/boolector.git

cd boolector

./contrib/setup-lingeling.sh
./contrib/setup-btor2tools.sh

./configure.sh
cd build

make -j$(nproc)
sudo make install